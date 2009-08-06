Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id F1FDD6B005A
	for <linux-mm@kvack.org>; Thu,  6 Aug 2009 08:28:58 -0400 (EDT)
Message-ID: <4A7ACC90.2000808@tungstengraphics.com>
Date: Thu, 06 Aug 2009 14:29:04 +0200
From: =?ISO-8859-1?Q?Thomas_Hellstr=F6m?= <thomas@tungstengraphics.com>
MIME-Version: 1.0
Subject: shmem + TTM  oops
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linux Kernel list <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi!
I've been debugging a strange problem for a while, and it'd be nice to 
have some more eyes on this.

When the TTM graphics memory manager decides it's using too much memory, 
it copies the contents of the buffer to shmem objects and releases the 
buffers. This is because shmem objects are pageable whereas TTM buffers 
are not. When the TTM buffers are accessed in one way or another, it 
copies contents back. Seems to work fairly nice, but not really optimal.

When the X server is VT switched, TTM optionally switches out all 
buffers to shmem objects, but when the contents are read back, some 
shmem objects have corrupted swap entry top directory. The member
shmem_inode_info::i_indirect[0] usually contains a value 0xffffff60 or 
something similar, causing an oops in shmem_truncate_range() when the 
shmem object is freed. Before that, readback seems to work OK. The 
corruption is happening after X server VT switch when TTM is supposed to 
be idle. The shmem objects have been verified to have swap entry 
directories after all buffer objects have been swapped out.

If anyone could shed some light over this, it would be very helpful. 
Relevant TTM code is fairly straightforward looks like this. The process 
that copies out to shmem objects may not be the same process that copies in:

static int ttm_tt_swapin(struct ttm_tt *ttm)
{
    struct address_space *swap_space;
    struct file *swap_storage;
    struct page *from_page;
    struct page *to_page;
    void *from_virtual;
    void *to_virtual;
    int i;
    int ret;

    if (ttm->page_flags & TTM_PAGE_FLAG_USER) {
        ret = ttm_tt_set_user(ttm, ttm->tsk, ttm->start,
                      ttm->num_pages);
        if (unlikely(ret != 0))
            return ret;

        ttm->page_flags &= ~TTM_PAGE_FLAG_SWAPPED;
        return 0;
    }

    swap_storage = ttm->swap_storage;
    BUG_ON(swap_storage == NULL);

    swap_space = swap_storage->f_path.dentry->d_inode->i_mapping;

    for (i = 0; i < ttm->num_pages; ++i) {
        from_page = read_mapping_page(swap_space, i, NULL);
        if (IS_ERR(from_page))
            goto out_err;
        to_page = __ttm_tt_get_page(ttm, i);
        if (unlikely(to_page == NULL))
            goto out_err;

        preempt_disable();
        from_virtual = kmap_atomic(from_page, KM_USER0);
        to_virtual = kmap_atomic(to_page, KM_USER1);
        memcpy(to_virtual, from_virtual, PAGE_SIZE);
        kunmap_atomic(to_virtual, KM_USER1);
        kunmap_atomic(from_virtual, KM_USER0);
        preempt_enable();
        page_cache_release(from_page);
    }

    if (!(ttm->page_flags & TTM_PAGE_FLAG_PERSISTANT_SWAP))
        fput(swap_storage);
    ttm->swap_storage = NULL;
    ttm->page_flags &= ~TTM_PAGE_FLAG_SWAPPED;

    return 0;
out_err:
    ttm_tt_free_alloced_pages(ttm);
    return -ENOMEM;
}

int ttm_tt_swapout(struct ttm_tt *ttm, struct file *persistant_swap_storage)
{
    struct address_space *swap_space;
    struct file *swap_storage;
    struct page *from_page;
    struct page *to_page;
    void *from_virtual;
    void *to_virtual;
    int i;

    BUG_ON(ttm->state != tt_unbound && ttm->state != tt_unpopulated);
    BUG_ON(ttm->caching_state != tt_cached);

    /*
     * For user buffers, just unpin the pages, as there should be
     * vma references.
     */

    if (ttm->page_flags & TTM_PAGE_FLAG_USER) {
        ttm_tt_free_user_pages(ttm);
        ttm->page_flags |= TTM_PAGE_FLAG_SWAPPED;
        ttm->swap_storage = NULL;
        return 0;
    }

    if (!persistant_swap_storage) {
        swap_storage = shmem_file_setup("ttm swap",
                        ttm->num_pages << PAGE_SHIFT,
                        0);
        if (unlikely(IS_ERR(swap_storage))) {
            printk(KERN_ERR "Failed allocating swap storage.\n");
            return -ENOMEM;
        }
    } else
        swap_storage = persistant_swap_storage;

    swap_space = swap_storage->f_path.dentry->d_inode->i_mapping;

    for (i = 0; i < ttm->num_pages; ++i) {
        from_page = ttm->pages[i];
        if (unlikely(from_page == NULL))
            continue;
        to_page = read_mapping_page(swap_space, i, NULL);
        if (unlikely(to_page == NULL))
            goto out_err;

        preempt_disable();
        from_virtual = kmap_atomic(from_page, KM_USER0);
        to_virtual = kmap_atomic(to_page, KM_USER1);
        memcpy(to_virtual, from_virtual, PAGE_SIZE);
        kunmap_atomic(to_virtual, KM_USER1);
        kunmap_atomic(from_virtual, KM_USER0);
        preempt_enable();
        set_page_dirty(to_page);
        mark_page_accessed(to_page);
        page_cache_release(to_page);
    }

    ttm_tt_free_alloced_pages(ttm);
    ttm->swap_storage = swap_storage;
    ttm->page_flags |= TTM_PAGE_FLAG_SWAPPED;
    if (persistant_swap_storage)
        ttm->page_flags |= TTM_PAGE_FLAG_PERSISTANT_SWAP;

    return 0;
out_err:
    if (!persistant_swap_storage)
        fput(swap_storage);

    return -ENOMEM;
}



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

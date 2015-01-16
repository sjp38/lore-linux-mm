Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id 2067D6B0032
	for <linux-mm@kvack.org>; Fri, 16 Jan 2015 08:18:42 -0500 (EST)
Received: by mail-la0-f43.google.com with SMTP id q1so3462182lam.2
        for <linux-mm@kvack.org>; Fri, 16 Jan 2015 05:18:41 -0800 (PST)
Received: from forward-corp1g.mail.yandex.net (forward-corp1g.mail.yandex.net. [2a02:6b8:0:1402::10])
        by mx.google.com with ESMTPS id xu5si4446733lab.9.2015.01.16.05.18.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jan 2015 05:18:40 -0800 (PST)
From: =?koi8-r?B?68/O09TBztTJziDozMXCzsnLz9c=?= <khlebnikov@yandex-team.ru>
In-Reply-To: <20150115171551.a2e6acb5.akpm@linux-foundation.org>
References: <20150115155731.31307.4414.stgit@buzz> <20150115171551.a2e6acb5.akpm@linux-foundation.org>
Subject: Re: [PATCH RFC] page_writeback: cleanup mess around cancel_dirty_page()
MIME-Version: 1.0
Message-Id: <219291421414310@webcorp01h.yandex-team.ru>
Date: Fri, 16 Jan 2015 16:18:30 +0300
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=koi8-r
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Tejun Heo <tj@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, "koct9i@gmail.com" <koct9i@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>

16.01.2015, 04:16, "Andrew Morton" <akpm@linux-foundation.org>:
> On Thu, 15 Jan 2015 18:57:31 +0300 Konstantin Khebnikov <khlebnikov@yandex-team.ru> wrote:
>> ?This patch replaces cancel_dirty_page() with helper account_page_cleared()
>> ?which only updates counters. It's called from delete_from_page_cache()
>> ?and from try_to_free_buffers() (hack for ext3). Page is locked in both cases.
>>
>> ?Hugetlbfs has no dirty pages accounting, ClearPageDirty() is enough here.
>>
>> ?cancel_dirty_page() in nfs_wb_page_cancel() is redundant. This is helper
>> ?for nfs_invalidate_page() and it's called only in case complete invalidation.
>>
>> ?Open-coded kludge at the end of __delete_from_page_cache() is redundant too.
>>
>> ?This mess was started in v2.6.20, after commit 3e67c09 ("truncate: clear page
>> ?dirtiness before running try_to_free_buffers()") reverted back in v2.6.25
>> ?by commit a2b3456 ("Fix dirty page accounting leak with ext3 data=journal").
>> ?Custom fixes were introduced between them. NFS in in v2.6.23 in commit
>> ?1b3b4a1 ("NFS: Fix a write request leak in nfs_invalidate_page()").
>> ?Kludge __delete_from_page_cache() in v2.6.24, commit 3a692790 ("Do dirty
>> ?page accounting when removing a page from the page cache").
>>
>> ?It seems safe to leave dirty flag set on truncated page, free_pages_check()
>> ?will clear it before returning page into buddy allocator.
>
> account_page_cleared() is not a good name - "clearing a page" means
> filling it with zeroes. ?account_page_cleaned(), perhaps?

Ok. account_page_cleaned is better.

>
> I don't think your email cc'ed all the correct people? ?lustre, nfs,
> ext3?

oops

>> ?...
>>
>> ?--- a/fs/buffer.c
>> ?+++ b/fs/buffer.c
>> ?@@ -3243,8 +3243,8 @@ int try_to_free_buffers(struct page *page)
>> ???????????* to synchronise against __set_page_dirty_buffers and prevent the
>> ???????????* dirty bit from being lost.
>> ???????????*/
>> ?- if (ret)
>> ?- cancel_dirty_page(page, PAGE_CACHE_SIZE);
>> ?+ if (ret && TestClearPageDirty(page))
>> ?+ account_page_cleared(page, mapping);
>
> OK.
>> ??????????spin_unlock(&mapping->private_lock);
>> ??out:
>> ??????????if (buffers_to_free) {
>>
>> ?...
>>
>> ?--- a/fs/nfs/write.c
>> ?+++ b/fs/nfs/write.c
>> ?@@ -1811,11 +1811,6 @@ int nfs_wb_page_cancel(struct inode *inode, struct page *page)
>> ???????????????????* request from the inode / page_private pointer and
>> ???????????????????* release it */
>> ??????????????????nfs_inode_remove_request(req);
>> ?- /*
>> ?- * In case nfs_inode_remove_request has marked the
>> ?- * page as being dirty
>> ?- */
>> ?- cancel_dirty_page(page, PAGE_CACHE_SIZE);
>
> hm, if you say so..

That is main reason of this patch.
I dont like these obsoleted pieces of duct tape here and there.

>> ??????????????????nfs_unlock_and_release_request(req);
>> ??????????}
>>
>> ?...
>>
>> ?--- a/mm/filemap.c
>> ?+++ b/mm/filemap.c
>> ?@@ -201,18 +201,6 @@ void __delete_from_page_cache(struct page *page, void *shadow)
>> ??????????if (PageSwapBacked(page))
>> ??????????????????__dec_zone_page_state(page, NR_SHMEM);
>> ??????????BUG_ON(page_mapped(page));
>> ?-
>> ?- /*
>> ?- * Some filesystems seem to re-dirty the page even after
>> ?- * the VM has canceled the dirty bit (eg ext3 journaling).
>> ?- *
>> ?- * Fix it up by doing a final dirty accounting check after
>> ?- * having removed the page entirely.
>> ?- */
>> ?- if (PageDirty(page) && mapping_cap_account_dirty(mapping)) {
>> ?- dec_zone_page_state(page, NR_FILE_DIRTY);
>> ?- dec_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
>> ?- }
>> ??}
>>
>> ??/**
>> ?@@ -230,6 +218,9 @@ void delete_from_page_cache(struct page *page)
>>
>> ??????????BUG_ON(!PageLocked(page));
>>
>> ?+ if (PageDirty(page))
>> ?+ account_page_cleared(page, mapping);
>> ?+
>
> OK, but we lost the important comment - transplant that?
>
> It's strange that we left the dirty bit set after accounting for its
> clearing. ?How does this work? ?Presumably the offending fs dirtied the
> page without accounting for it? ?I have a bad feeling I wrote that code :(

account_page_dirtyed() must be always called after dirtying non-truncated pages.
Here page is truncating from mapping, dirty accounting never will see it again.

This is the only place where dirty page might be truncated. All other places:
replace_page_cache_page, invalidate_complete_page2, __remove_mapping
(in memory reclaimer) forbid removing dirty pages.

As I see PageDirty means nothing for truncated pages, it's never be written anywhere.
We could clear dirty bit here, but probably it might appear again: set_page_dirty()
for some reason has branch for pages without page->mapping.

>> ??????????freepage = mapping->a_ops->freepage;
>> ??????????spin_lock_irq(&mapping->tree_lock);
>> ??????????__delete_from_page_cache(page, NULL);
>> ?diff --git a/mm/page-writeback.c b/mm/page-writeback.c
>> ?index 4da3cd5..f371522 100644
>> ?--- a/mm/page-writeback.c
>> ?+++ b/mm/page-writeback.c
>> ?@@ -2106,6 +2106,25 @@ void account_page_dirtied(struct page *page, struct address_space *mapping)
>> ??EXPORT_SYMBOL(account_page_dirtied);
>>
>> ??/*
>> ?+ * Helper function for deaccounting dirty page without doing writeback.
>> ?+ * Doing this should *normally* only ever be done when a page
>> ?+ * is truncated, and is not actually mapped anywhere at all. However,
>> ?+ * fs/buffer.c does this when it notices that somebody has cleaned
>> ?+ * out all the buffers on a page without actually doing it through
>> ?+ * the VM. Can you say "ext3 is horribly ugly"? Tought you could.
>
> "Thought".

Ah, ok. That is copy-paste from cancel_dirty_page().

>> ?+ */
>> ?+void account_page_cleared(struct page *page, struct address_space *mapping)
>> ?+{
>> ?+ if (mapping_cap_account_dirty(mapping)) {
>> ?+ dec_zone_page_state(page, NR_FILE_DIRTY);
>> ?+ dec_bdi_stat(mapping->backing_dev_info,
>> ?+ BDI_RECLAIMABLE);
>> ?+ task_io_account_cancelled_write(PAGE_CACHE_SIZE);
>> ?+ }
>> ?+}
>> ?+EXPORT_SYMBOL(account_page_cleared);
>>
>> ?...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

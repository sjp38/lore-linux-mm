Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 675A26B0038
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 08:43:49 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id yr2so43243722wjc.4
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 05:43:49 -0800 (PST)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id o131si5544504wmd.167.2017.02.13.05.43.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Feb 2017 05:43:47 -0800 (PST)
Received: by mail-wm0-x244.google.com with SMTP id v77so19539326wmv.0
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 05:43:47 -0800 (PST)
Date: Mon, 13 Feb 2017 16:43:45 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv6 01/37] mm, shmem: swich huge tmpfs to multi-order
 radix-tree entries
Message-ID: <20170213134345.GA20394@node.shutemov.name>
References: <20170126115819.58875-1-kirill.shutemov@linux.intel.com>
 <20170126115819.58875-2-kirill.shutemov@linux.intel.com>
 <20170209035727.GQ2267@bombadil.infradead.org>
 <20170209165820.GA12768@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170209165820.GA12768@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On Thu, Feb 09, 2017 at 07:58:20PM +0300, Kirill A. Shutemov wrote:
> I'll look into it.

I ended up with this (I'll test it more later):

void filemap_map_pages(struct vm_fault *vmf,
		pgoff_t start_pgoff, pgoff_t end_pgoff)
{
	struct radix_tree_iter iter;
	void **slot;
	struct file *file = vmf->vma->vm_file;
	struct address_space *mapping = file->f_mapping;
	pgoff_t last_pgoff = start_pgoff;
	loff_t size;
	struct page *page;
	bool mapped;

	rcu_read_lock();
	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter,
			start_pgoff) {
		unsigned long index = iter.index;
		if (index < start_pgoff)
			index = start_pgoff;
		if (index > end_pgoff)
			break;
repeat:
		page = radix_tree_deref_slot(slot);
		if (unlikely(!page))
			continue;
		if (radix_tree_exception(page)) {
			if (radix_tree_deref_retry(page))
				slot = radix_tree_iter_retry(&iter);
			continue;
		}

		if (!page_cache_get_speculative(page))
			goto repeat;

		/* Has the page moved? */
		if (unlikely(page != *slot)) {
			put_page(page);
			goto repeat;
		}

		/* For multi-order entries, find relevant subpage */
		page = find_subpage(page, index);

		if (!PageUptodate(page) || PageReadahead(page))
			goto skip;
		if (!trylock_page(page))
			goto skip;

		if (page_mapping(page) != mapping || !PageUptodate(page))
			goto skip_unlock;

		size = round_up(i_size_read(mapping->host), PAGE_SIZE);
		if (compound_head(page)->index >= size >> PAGE_SHIFT)
			goto skip_unlock;

		if (file->f_ra.mmap_miss > 0)
			file->f_ra.mmap_miss--;
map_next_subpage:
		if (PageHWPoison(page))
			goto next;

		vmf->address += (index - last_pgoff) << PAGE_SHIFT;
		if (vmf->pte)
			vmf->pte += index - last_pgoff;
		last_pgoff = index;
		mapped = !alloc_set_pte(vmf, NULL, page);

		/* Huge page is mapped or last index? No need to proceed. */
		if (pmd_trans_huge(*vmf->pmd) ||
				index == end_pgoff) {
			unlock_page(page);
			break;
		}
next:
		if (page && PageCompound(page)) {
			/* Last subpage handled? */
			if ((index & (compound_nr_pages(page) - 1)) ==
					compound_nr_pages(page) - 1)
				goto skip_unlock;
			index++;
			page++;

			/*
			 * One page reference goes to page table mapping.
			 * Need additional reference, if last alloc_set_pte()
			 * succeed.
			 */
			if (mapped)
				get_page(page);
			goto map_next_subpage;
		}
skip_unlock:
		unlock_page(page);
skip:
		iter.index = compound_head(page)->index +
			compound_nr_pages(page) - 1;
		/* Only give up reference if alloc_set_pte() failed. */
		if (!mapped)
			put_page(page);
	}
	rcu_read_unlock();
}

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Received: from webmail.andrew.cmu.edu (WEBMAIL2.andrew.cmu.edu [128.2.10.92])
	by smtp3.andrew.cmu.edu (8.12.10/8.12.10) with SMTP id i0LFlKi7029434
	for <linux-mm@kvack.org>; Wed, 21 Jan 2004 10:47:20 -0500
Message-ID: <2276.128.2.181.129.1074700039.squirrel@webmail.andrew.cmu.edu>
Date: Wed, 21 Jan 2004 10:47:19 -0500 (EST)
Subject: Doubt in do_no_page()
From: "Anand Eswaran" <aeswaran@andrew.cmu.edu>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all :

  I have a doubt regarding the do_no_page function in memory.c. I would
greatly appreciate it if someone could help me out.


My questions are appended ( they're between the lines ) near the
corresponding code of concern.





int do_no_page(struct mm_struct * mm,
	               struct vm_area_struct * vma,
	               unsigned long address,
	               int write_access,
	               pte_t *page_table)


	struct page * new_page;
	pte_t entry;

	if (!vma->vm_ops || !vma->vm_ops->nopage)
		return do_anonymous_page(mm, vma, page_table, write_access, address);

QUESTION
------------------------------------------------------------------------

 I assume that most faults would be serviced by the do_anonymous page i.e
for most "normal" vma's ( say heap ) the vma->vm_ops->nopage would be
NULL. Is that true?


------------------------------------------------------------------------

	spin_unlock(&mm->page_table_lock);

	new_page = vma->vm_ops->nopage(vma, address & PAGE_MASK, 0);

	if (new_page == NULL)	/* no page was available -- SIGBUS */
		return 0;
	if (new_page == NOPAGE_OOM)
		return -1;


QUESTION
-----------------------------------------------------------------------

1) What type of vma's come here ?
------------------------------------------------------------------------



	/*
	 * Should we do an early C-O-W break?
	 */
	if (write_access && !(vma->vm_flags & VM_SHARED)) {
		struct page * page = alloc_page(GFP_HIGHUSER);
		if (!page) {
			page_cache_release(new_page);
			return -1;
		}
		copy_user_highpage(page, new_page, address);
		page_cache_release(new_page);
		lru_cache_add(page);
		new_page = page;
	}

	spin_lock(&mm->page_table_lock);
	/*
	 * This silly early PAGE_DIRTY setting removes a race
	 * due to the bad i386 page protection. But it's valid
	 * for other architectures too.
	 *
	 * Note that if write_access is true, we either now have
	 * an exclusive copy of the page, or this is a shared mapping,
	 * so we can make it writable and dirty to avoid having to
	 * handle that later.
	 */
	/* Only go through if we didn't race with anybody else... */
	if (pte_none(*page_table)) {
		++mm->rss;
		flush_page_to_ram(new_page);
		flush_icache_page(vma, new_page);
		entry = mk_pte(new_page, vma->vm_page_prot);
		if (write_access)
			entry = pte_mkwrite(pte_mkdirty(entry));
		set_pte(page_table, entry);
	} else {
		/* One of our sibling threads was faster, back out. */
		page_cache_release(new_page);
		spin_unlock(&mm->page_table_lock);
		return 1;
	}

	/* no need to invalidate: a not-present page shouldn't be cached */
	update_mmu_cache(vma, address, entry);
	spin_unlock(&mm->page_table_lock);
	return 2;	/* Major fault */




I would greatly appreciate if someone could answer this for me in some depth.

Thanks a lot,
------
Anand.






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

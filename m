Received: from rra2002 (helo=localhost)
	by aria.ncl.cs.columbia.edu with local-esmtp (Exim 4.14)
	id 19hwPV-0005uP-7s
	for linux-mm@kvack.org; Wed, 30 Jul 2003 15:14:53 -0400
Date: Wed, 30 Jul 2003 15:14:53 -0400 (EDT)
From: "Raghu R. Arur" <rra2002@aria.ncl.cs.columbia.edu>
Subject: do_wp_page 
Message-ID: <Pine.GSO.4.51.0307301514240.8932@aria.ncl.cs.columbia.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

 hi,

  In do_wp_page of 2.4.19 why is the rss value of  address space
incremented only when the old_page ( the page on which the process faults
due to write protection) is a reserved page. I mean if the process has
mapped a read only page ( which is different from a ZERO_PAGE) and if it
faults on that page when it tries to
write, the rss value is not incremented even if a new page is created
and page table entry is set to the allocated page. What am i missing here?

	new_page = alloc_page(GFP_HIGHUSER);
	if (!new_page)
		goto no_mem;
	copy_cow_page(old_page,new_page,address);
	/*
	 * Re-check the pte - we dropped the lock
	 */
	spin_lock(&mm->page_table_lock);
	if (pte_same(*page_table, pte)) {
	  if (PageReserved(old_page)) {
			++mm->rss;
	  }
		break_cow(vma, new_page, address, page_table);
		lru_cache_add(new_page);
		/* Free the old page.. */
		new_page = old_page;
	}

 thanks,
Raghu
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

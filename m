Date: Mon, 20 Sep 2004 15:31:54 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: PG_slab?
Message-Id: <20040920153154.61e0b413.pj@sgi.com>
In-Reply-To: <20040920200953.GF5521@logos.cnet>
References: <20040920200953.GF5521@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Marcelo writes:
> What is PG_slab about?

A grep in a 2.6.0-mm1 I have expanded shows that its some slab debug
stuff that Suparna wanted.  The last grep at the bottom of this display
is in the routine mm/slab.c: ptrinfo(), that dumps data about some
address.

arch/arm/mm/init.c-				cached++;
arch/arm/mm/init.c:			else if (PageSlab(page))
arch/arm/mm/init.c-				slab++;
--
arch/arm26/mm/init.c-			cached++;
arch/arm26/mm/init.c:		else if (PageSlab(page))
arch/arm26/mm/init.c-			slab++;
include/linux/page-flags.h-#define PG_active		 6
include/linux/page-flags.h:#define PG_slab			 7	/* slab debug (Suparna wants this) */
include/linux/page-flags.h-
--
include/linux/page-flags.h-
include/linux/page-flags.h:#define PageSlab(page)		test_bit(PG_slab, &(page)->flags)
include/linux/page-flags.h:#define SetPageSlab(page)	set_bit(PG_slab, &(page)->flags)
include/linux/page-flags.h:#define ClearPageSlab(page)	clear_bit(PG_slab, &(page)->flags)
include/linux/page-flags.h:#define TestClearPageSlab(page)	test_and_clear_bit(PG_slab, &(page)->flags)
include/linux/page-flags.h:#define TestSetPageSlab(page)	test_and_set_bit(PG_slab, &(page)->flags)
include/linux/page-flags.h-
mm/nommu.c-
mm/nommu.c:	if (PageSlab(page))
mm/nommu.c-		return ksize(objp);
--
mm/page_alloc.c-			1 << PG_reclaim	|
mm/page_alloc.c:			1 << PG_slab	|
mm/page_alloc.c-			1 << PG_writeback )))
--
mm/slab.c-		add_page_state(nr_slab, i);
mm/slab.c-		while (i--) {
mm/slab.c:			SetPageSlab(page);
mm/slab.c-			page++;
mm/slab.c-		}
--
mm/slab.c-
mm/slab.c-	while (i--) {
mm/slab.c:		if (!TestClearPageSlab(page))
mm/slab.c-			BUG();
mm/slab.c-		page++;
--
mm/slab.c-	}
mm/slab.c-	page = virt_to_page(objp);
mm/slab.c:	if (!PageSlab(page)) {
mm/slab.c-		printk(KERN_ERR "kfree_debugcheck: bad ptr %lxh.\n", (unsigned long)objp);
mm/slab.c-		BUG();
--
mm/slab.c-	page = virt_to_page((void*)addr);
mm/slab.c-	printk("struct page at %p, flags %lxh.\n", page, page->flags);
mm/slab.c:	if (PageSlab(page)) {
mm/slab.c-		kmem_cache_t *c;
mm/slab.c-		struct slab *s;


-- 
                          I won't rest till it's the best ...
                          Programmer, Linux Scalability
                          Paul Jackson <pj@sgi.com> 1.650.933.1373
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Date: Wed, 11 May 2005 22:26:07 +0900 (JST)
Message-Id: <20050511.222607.98339736.taka@valinux.co.jp>
Subject: Re: [PATCH 2.6.12-rc3 4/8] mm: manual page migration-rc2 --
 add-sys_migrate_pages-rc2.patch
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20050511.222314.10910241.taka@valinux.co.jp>
References: <20050511043756.10876.72079.60115@jackhammer.engr.sgi.com>
	<20050511043821.10876.47127.71762@jackhammer.engr.sgi.com>
	<20050511.222314.10910241.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: raybry@sgi.com
Cc: marcelo.tosatti@cyclades.com, ak@suse.de, haveblue@us.ibm.com, hch@infradead.org, linux-mm@kvack.org, nathans@sgi.com, raybry@austin.rr.com, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Hi Ray,

> > This is the main patch that creates the migrate_pages() system
> > call.  Note that in this case, the system call number was more
> > or less arbitrarily assigned at 1279.  This number needs to
> > allocated.
> > 
> > This patch sits on top of the page migration patches from
> > the Memory Hotplug project.  This particular patchset is built
> > on top of:
> > 
> > http://www.sr71.net/patches/2.6.12/2.6.12-rc3-mhp1/page_migration/patch-2.6.12-rc3-mhp1-pm.gz
> 
> I found there exited a race condition between migrate_vma() and
                ^^^^^^
                existed

> the swap code. The following code may cause Oops if the swap code
> takes the page from the LRU list before calling steal_page_from_lru().
> 
> migrate_vma()
> {
>                :
> 	if (PageLRU(page) &&
> 	    steal_page_from_lru(zone, page, &page_list))
> 		count++;
> 	else
> 		BUG();
>                :
> }
> 
> Ok, I should make steal_page_from_lru() check PageLRU(page) with
> holding zone->lru_lock. Then migrate_vma() can just call
> steal_page_from_lru().
> 
> static inline int
> steal_page_from_lru(struct zone *zone, struct page *page)
> {
>         int ret = 0;
>         spin_lock_irq(&zone->lru_lock);
> 	if (PageLRU(page))
>                 ret = __steal_page_from_lru(zone, page);
>         spin_unlock_irq(&zone->lru_lock);
>         return ret;
> }
> 
> migrate_vma()
> {
>                :
> 	if (steal_page_from_lru(zone, page, &page_list)
> 		count++;
>                :
> }
> 
> 
> BTW, I'm not sure whether it's enough that migrate_vma() can only
> migrate currently mapped pages. This may leave some pages in the
> page-cache if they're not mapped to the process address spaces yet.
> 
> Thanks,
> Hirokazu Takahashi.
> 
> 
> > Index: linux-2.6.12-rc3-mhp1-page-migration-export/mm/mmigrate.c
> > ===================================================================
> > --- linux-2.6.12-rc3-mhp1-page-migration-export.orig/mm/mmigrate.c	2005-05-10 10:22:24.000000000 -0700
> > +++ linux-2.6.12-rc3-mhp1-page-migration-export/mm/mmigrate.c	2005-05-10 10:40:35.000000000 -0700
> > @@ -5,6 +5,9 @@
> >   *
> >   *  Authors:	IWAMOTO Toshihiro <iwamoto@valinux.co.jp>
> >   *		Hirokazu Takahashi <taka@valinux.co.jp>
> > + *
> > + * sys_migrate_pages() added by Ray Bryant <raybry@sgi.com>
> > + * Copyright (C) 2005, Silicon Graphics, Inc.
> >   */
> >  
> >  #include <linux/config.h>
> > @@ -21,6 +24,9 @@
> >  #include <linux/rmap.h>
> >  #include <linux/mmigrate.h>
> >  #include <linux/delay.h>
> > +#include <linux/blkdev.h>
> > +#include <linux/nodemask.h>
> > +#include <asm/bitops.h>
> >  
> >  /*
> >   * The concept of memory migration is to replace a target page with
> > @@ -587,6 +593,182 @@ int try_to_migrate_pages(struct list_hea
> >  	return nr_busy;
> >  }
> >  
> > +static int
> > +migrate_vma(struct task_struct *task, struct mm_struct *mm,
> > +	struct vm_area_struct *vma, short *node_map)
> > +{
> > +	struct page *page;
> > +	struct zone *zone;
> > +	unsigned long vaddr;
> > +	int count = 0, nid, pass = 0, nr_busy = 0;
> > +	LIST_HEAD(page_list);
> > +
> > +	/* can't migrate mlock()'d pages */
> > +	if (vma->vm_flags & VM_LOCKED)
> > +		return 0;
> > +
> > +	/*
> > +	 * gather all of the pages to be migrated from this vma into page_list
> > +	 */
> > +	spin_lock(&mm->page_table_lock);
> > + 	for (vaddr = vma->vm_start; vaddr < vma->vm_end; vaddr += PAGE_SIZE) {
> > +		page = follow_page(mm, vaddr, 0);
> > +		/*
> > +		 * follow_page has been known to return pages with zero mapcount
> > +		 * and NULL mapping.  Skip those pages as well
> > +		 */
> > +		if (page && page_mapcount(page)) {
> > +			nid = page_to_nid(page);
> > +			if (node_map[nid] >= 0) {
> > +				zone = page_zone(page);
> > +				if (PageLRU(page) &&
> > +				    steal_page_from_lru(zone, page, &page_list))
> > +					count++;
> > +				else
> > +					BUG();
> > +			}
> > +		}
> > +	}
> > +	spin_unlock(&mm->page_table_lock);
> > +
> > +retry:
> > +
> > +	/* call the page migration code to move the pages */
> > +	if (!list_empty(&page_list))
> > +		nr_busy = try_to_migrate_pages(&page_list, node_map);
> > +
> > +	if (nr_busy > 0) {
> > +		pass++;
> > +		if (pass > 10)
> > +			return -EAGAIN;
> > +		/* wait until some I/O completes and try again */
> > +		blk_congestion_wait(WRITE, HZ/10);
> > +		goto retry;
> > +	} else if (nr_busy < 0)
> > +		return nr_busy;
> > +
> > +	return count;
> > +}
> 
> 
> 
> 
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
> 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

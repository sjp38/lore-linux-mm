Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E3BAF6B003D
	for <linux-mm@kvack.org>; Mon, 11 May 2009 06:06:22 -0400 (EDT)
Date: Mon, 11 May 2009 12:03:49 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -mm] vmscan: make mapped executable pages the first class  citizen
Message-ID: <20090511100349.GA5086@cmpxchg.org>
References: <20090508125859.210a2a25.akpm@linux-foundation.org> <20090508230045.5346bd32@lxorguk.ukuu.org.uk> <2f11576a0905100159m32c36a9ep9fb7cc5604c60b2@mail.gmail.com> <1241946446.6317.42.camel@laptop> <2f11576a0905100236u15d45f7fm32d470776659cfec@mail.gmail.com> <20090510144533.167010a9@lxorguk.ukuu.org.uk> <4A06EA08.1030102@redhat.com> <20090510211350.7aecc8de@lxorguk.ukuu.org.uk> <4A073B0D.4090604@redhat.com> <20090510142322.690186a4@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090510142322.690186a4@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Arjan van de Ven <arjan@infradead.org>
Cc: Rik van Riel <riel@redhat.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org, tytso@mit.edu, linux-mm@kvack.org, elladan@eskimo.com, npiggin@suse.de, cl@linux-foundation.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Sun, May 10, 2009 at 02:23:22PM -0700, Arjan van de Ven wrote:
> On Sun, 10 May 2009 16:37:33 -0400
> Rik van Riel <riel@redhat.com> wrote:
> 
> > Alan Cox wrote:
> > > Historically BSD tackled some of this by actually swapping
> > > processes out once pressure got very high 
> > 
> > Our big problem today usually isn't throughput though,
> > but latency - the time it takes to bring a previously
> > inactive application back to life.
> 
> Could we do a chain? E.g. store which page we paged out next (for the
> vma) as part of the first pageout, and then page them just right back
> in? Or even have a (bitmap?) of pages that have been in memory for the
> vma, and on a re-fault, look for other pages "nearby" that used to be
> in but are now out ?

I'm not sure I understand your chaining idea.

As to the virtually-related pages, I hacked up a clustering idea for
swap-out once (and swap-in readahead should then get virtually related
pages grouped together as well) but it didn't work out as expected.

The LRU order is perhaps a better hint for access patterns than the
relationship on a virtual address level, but at the moment we fail to
keep the LRU order intact on swap so bets are off again...

I have only black-box-benchmarked performance numbers and didn't look
too close at it at the time, though.  If somebody wants to play with
it, patch is attached.

	Hannes

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 3b58602..ba11dee 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1020,6 +1020,101 @@ int isolate_lru_page(struct page *page)
 	return ret;
 }
 
+static unsigned long cluster_inactive_anon_vma(struct vm_area_struct *vma,
+					struct page *page,
+					unsigned long *scanned,
+					struct list_head *cluster)
+{
+	pte_t *pte;
+	spinlock_t *ptl;
+	unsigned long va, area, start, end, nr_taken = 0, nr_scanned = 0;
+
+	va = page_address_in_vma(page, vma);
+	if (va == -EFAULT)
+		return 0;
+
+	pte = page_check_address(page, vma->vm_mm, va, &ptl, 0);
+	if (!pte)
+		return 0;
+	pte_unmap_unlock(pte, ptl);
+
+	area = page_cluster << PAGE_SHIFT;
+	start = va - area;
+	if (start < vma->vm_start)
+		start = vma->vm_start;
+	end = va + area;
+	if (end > vma->vm_end)
+		end = vma->vm_end;
+
+	for (va = start; va < end; va += PAGE_SIZE, nr_scanned++) {
+		pgd_t *pgd;
+		pud_t *pud;
+		pmd_t *pmd;
+		struct zone *zone;
+		struct page *cursor;
+
+		pgd = pgd_offset(vma->vm_mm, va);
+		if (!pgd_present(*pgd))
+			continue;
+		pud = pud_offset(pgd, va);
+		if (!pud_present(*pud))
+			continue;
+		pmd = pmd_offset(pud, va);
+		if (!pmd_present(*pmd))
+			continue;
+		pte = pte_offset_map_lock(vma->vm_mm, pmd, va, &ptl);
+		if (!pte_present(*pte)) {
+			pte_unmap_unlock(pte, ptl);
+			continue;
+		}
+		cursor = vm_normal_page(vma, va, *pte);
+		pte_unmap_unlock(pte, ptl);
+
+		if (!cursor || cursor == page)
+			continue;
+
+		zone = page_zone(cursor);
+		if (zone != page_zone(page))
+			continue;
+
+		spin_lock_irq(&zone->lru_lock);
+		if (!__isolate_lru_page(cursor, ISOLATE_INACTIVE, 0)) {
+			list_move_tail(&cursor->lru, cluster);
+			nr_taken++;
+		}
+		spin_unlock_irq(&zone->lru_lock);
+	}
+	*scanned += nr_scanned;
+	return nr_taken;
+}
+
+static unsigned long cluster_inactive_anon(struct list_head *list,
+					unsigned long *scanned)
+{
+	LIST_HEAD(cluster);
+	unsigned long nr_taken = 0, nr_scanned = 0;
+
+	while (!list_empty(list)) {
+		struct page *page;
+		struct anon_vma *anon_vma;
+		struct vm_area_struct *vma;
+
+		page = list_entry(list->next, struct page, lru);
+		list_move(&page->lru, &cluster);
+
+		anon_vma = page_lock_anon_vma(page);
+		if (!anon_vma)
+			continue;
+		list_for_each_entry(vma, &anon_vma->head, anon_vma_node)
+			nr_taken += cluster_inactive_anon_vma(vma, page,
+							&nr_scanned, &cluster);
+		page_unlock_anon_vma(anon_vma);
+	}
+	list_replace(&cluster, list);
+	*scanned += nr_scanned;
+	return nr_taken;
+}
+
 /*
  * shrink_inactive_list() is a helper for shrink_zone().  It returns the number
  * of reclaimed pages
@@ -1061,6 +1156,11 @@ static unsigned long shrink_inactive_list(unsigned long max_scan,
 		nr_taken = sc->isolate_pages(sc->swap_cluster_max,
 			     &page_list, &nr_scan, sc->order, mode,
 				zone, sc->mem_cgroup, 0, file);
+		if (!file && mode == ISOLATE_INACTIVE) {
+			spin_unlock_irq(&zone->lru_lock);
+			nr_taken += cluster_inactive_anon(&page_list, &nr_scan);
+			spin_lock_irq(&zone->lru_lock);
+		}
 		nr_active = clear_active_flags(&page_list, count);
 		__count_vm_events(PGDEACTIVATE, nr_active);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

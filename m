From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070215012454.5343.89160.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070215012449.5343.22942.sendpatchset@schroedinger.engr.sgi.com>
References: <20070215012449.5343.22942.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 1/7] Make try_to_unmap return a special exit code
Date: Wed, 14 Feb 2007 17:24:54 -0800 (PST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: Christoph Hellwig <hch@infradead.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Martin J. Bligh" <mbligh@mbligh.org>, Arjan van de Ven <arjan@infradead.org>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Christoph Lameter <clameter@sgi.com>, Nigel Cunningham <nigel@nigel.suspend2.net>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

[PATCH] Make try_to_unmap() return SWAP_MLOCK for mlocked pages

Modify try_to_unmap() so that we can distinguish failing to
unmap due to a mlocked page from other causes.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.20/include/linux/rmap.h
===================================================================
--- linux-2.6.20.orig/include/linux/rmap.h	2007-02-14 15:47:13.000000000 -0800
+++ linux-2.6.20/include/linux/rmap.h	2007-02-14 16:00:35.000000000 -0800
@@ -134,5 +134,6 @@
 #define SWAP_SUCCESS	0
 #define SWAP_AGAIN	1
 #define SWAP_FAIL	2
+#define SWAP_MLOCK	3
 
 #endif	/* _LINUX_RMAP_H */
Index: linux-2.6.20/mm/rmap.c
===================================================================
--- linux-2.6.20.orig/mm/rmap.c	2007-02-14 15:47:13.000000000 -0800
+++ linux-2.6.20/mm/rmap.c	2007-02-14 16:00:36.000000000 -0800
@@ -631,10 +631,16 @@
 	 * If it's recently referenced (perhaps page_referenced
 	 * skipped over this mm) then we should reactivate it.
 	 */
-	if (!migration && ((vma->vm_flags & VM_LOCKED) ||
-			(ptep_clear_flush_young(vma, address, pte)))) {
-		ret = SWAP_FAIL;
-		goto out_unmap;
+	if (!migration) {
+		if (vma->vm_flags & VM_LOCKED) {
+			ret = SWAP_MLOCK;
+			goto out_unmap;
+		}
+
+		if (ptep_clear_flush_young(vma, address, pte)) {
+			ret = SWAP_FAIL;
+			goto out_unmap;
+		}
 	}
 
 	/* Nuke the page table entry. */
@@ -799,7 +805,8 @@
 
 	list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
 		ret = try_to_unmap_one(page, vma, migration);
-		if (ret == SWAP_FAIL || !page_mapped(page))
+		if (ret == SWAP_FAIL || ret == SWAP_MLOCK ||
+				!page_mapped(page))
 			break;
 	}
 	spin_unlock(&anon_vma->lock);
@@ -830,7 +837,8 @@
 	spin_lock(&mapping->i_mmap_lock);
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
 		ret = try_to_unmap_one(page, vma, migration);
-		if (ret == SWAP_FAIL || !page_mapped(page))
+		if (ret == SWAP_FAIL || ret == SWAP_MLOCK ||
+				!page_mapped(page))
 			goto out;
 	}
 
@@ -913,6 +921,7 @@
  * SWAP_SUCCESS	- we succeeded in removing all mappings
  * SWAP_AGAIN	- we missed a mapping, try again later
  * SWAP_FAIL	- the page is unswappable
+ * SWAP_MLOCK	- the page is under mlock()
  */
 int try_to_unmap(struct page *page, int migration)
 {
Index: linux-2.6.20/mm/vmscan.c
===================================================================
--- linux-2.6.20.orig/mm/vmscan.c	2007-02-14 15:47:13.000000000 -0800
+++ linux-2.6.20/mm/vmscan.c	2007-02-14 16:00:36.000000000 -0800
@@ -509,6 +509,7 @@
 		if (page_mapped(page) && mapping) {
 			switch (try_to_unmap(page, 0)) {
 			case SWAP_FAIL:
+			case SWAP_MLOCK:
 				goto activate_locked;
 			case SWAP_AGAIN:
 				goto keep_locked;

----- End forwarded message -----
----- Forwarded message from owner-linux-mm@kvack.org -----

Subject: BOUNCE linux-mm: Header line too long (>128)
From:	owner-linux-mm@kvack.org
To:	owner-linux-mm@kvack.org
Date:	Wed, 14 Feb 2007 20:25:16 -0500

>From clameter@sgi.com Wed Feb 14 20:25:16 2007
Received: (linux-mm@kanga.kvack.org) by kvack.org id <S26682AbXBOBZN>;
	Wed, 14 Feb 2007 20:25:13 -0500
Received: from netops-testserver-3-out.sgi.com ([192.48.171.28]:8374 "EHLO
	netops-testserver-3.corp.sgi.com") by kvack.org with ESMTP
	id <S26677AbXBOBZB>; Wed, 14 Feb 2007 20:25:01 -0500
Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [150.166.1.51])
	by netops-testserver-3.corp.sgi.com (Postfix) with ESMTP id 02F1090888;
	Wed, 14 Feb 2007 17:24:59 -0800 (PST)
From:	Christoph Lameter <clameter@sgi.com>
To:	akpm@osdl.org
Cc:	Christoph Hellwig <hch@infradead.org>,Arjan van de Ven <arjan@infradead.org>,Nigel Cunningham <nigel@nigel.suspend2.net>,Martin J. Bligh <mbligh@mbligh.org>,Peter Zijlstra <a.p.zijlstra@chello.nl>,Nick Piggin <nickpiggin@yahoo.com.au>,linux-mm@kvack.org,Christoph Lameter <clameter@sgi.com>,Matt Mackall <mpm@selenic.com>,Rik van Riel <riel@redhat.com>,KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20070215012459.5343.72021.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070215012449.5343.22942.sendpatchset@schroedinger.engr.sgi.com>
References: <20070215012449.5343.22942.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 2/7] Add PageMlocked() page state bit and lru infrastructure
Date:	Wed, 14 Feb 2007 17:24:59 -0800 (PST)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.0.3
Return-Path: <clameter@sgi.com>
X-Envelope-To: <"|/home/majordomo/wrapper resend -l linux-mm -h kvack.org linux-mm-outgoing"> (uid 0)
X-Orcpt: rfc822;list-linux-mm@kvack.org
Original-Recipient: rfc822;list-linux-mm@kvack.org

Add PageMlocked() infrastructure

This adds a new PG_mlocked to mark pages that were taken off the LRU
because they have a reference from a VM_LOCKED vma.

(Yes, we still have 4 free page flag bits.... BITS_PER_LONG-FLAGS_RESERVED =
32 - 9 = 23 page flags).

Also add pagevec handling for returning mlocked pages to the LRU.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.20/include/linux/page-flags.h
===================================================================
--- linux-2.6.20.orig/include/linux/page-flags.h	2007-02-14 15:47:13.000000000 -0800
+++ linux-2.6.20/include/linux/page-flags.h	2007-02-14 16:00:40.000000000 -0800
@@ -91,6 +91,7 @@
 #define PG_nosave_free		18	/* Used for system suspend/resume */
 #define PG_buddy		19	/* Page is free, on buddy lists */
 
+#define PG_mlocked		20	/* Page is mlocked */
 
 #if (BITS_PER_LONG > 32)
 /*
@@ -251,6 +252,16 @@
 #define SetPageUncached(page)	set_bit(PG_uncached, &(page)->flags)
 #define ClearPageUncached(page)	clear_bit(PG_uncached, &(page)->flags)
 
+/*
+ * PageMlocked set means that the page was taken off the LRU because
+ * a VM_LOCKED vma does exist. PageMlocked must be cleared before a
+ * page is put back onto the LRU. PageMlocked is only modified
+ * under the zone->lru_lock like PageLRU.
+ */
+#define PageMlocked(page)	test_bit(PG_mlocked, &(page)->flags)
+#define SetPageMlocked(page)	set_bit(PG_mlocked, &(page)->flags)
+#define ClearPageMlocked(page)	clear_bit(PG_mlocked, &(page)->flags)
+
 struct page;	/* forward declaration */
 
 extern void cancel_dirty_page(struct page *page, unsigned int account_size);
Index: linux-2.6.20/include/linux/pagevec.h
===================================================================
--- linux-2.6.20.orig/include/linux/pagevec.h	2007-02-14 15:47:13.000000000 -0800
+++ linux-2.6.20/include/linux/pagevec.h	2007-02-14 16:00:40.000000000 -0800
@@ -25,6 +25,7 @@
 void __pagevec_free(struct pagevec *pvec);
 void __pagevec_lru_add(struct pagevec *pvec);
 void __pagevec_lru_add_active(struct pagevec *pvec);
+void __pagevec_lru_add_mlock(struct pagevec *pvec);
 void pagevec_strip(struct pagevec *pvec);
 unsigned pagevec_lookup(struct pagevec *pvec, struct address_space *mapping,
 		pgoff_t start, unsigned nr_pages);
Index: linux-2.6.20/include/linux/swap.h
===================================================================
--- linux-2.6.20.orig/include/linux/swap.h	2007-02-14 15:47:13.000000000 -0800
+++ linux-2.6.20/include/linux/swap.h	2007-02-14 16:00:40.000000000 -0800
@@ -182,6 +182,7 @@
 extern void FASTCALL(lru_cache_add_active(struct page *));
 extern void FASTCALL(activate_page(struct page *));
 extern void FASTCALL(mark_page_accessed(struct page *));
+extern void FASTCALL(lru_cache_add_mlock(struct page *));
 extern void lru_add_drain(void);
 extern int lru_add_drain_all(void);
 extern int rotate_reclaimable_page(struct page *page);
Index: linux-2.6.20/mm/swap.c
===================================================================
--- linux-2.6.20.orig/mm/swap.c	2007-02-14 15:47:13.000000000 -0800
+++ linux-2.6.20/mm/swap.c	2007-02-14 17:08:07.000000000 -0800
@@ -176,6 +176,7 @@
  */
 static DEFINE_PER_CPU(struct pagevec, lru_add_pvecs) = { 0, };
 static DEFINE_PER_CPU(struct pagevec, lru_add_active_pvecs) = { 0, };
+static DEFINE_PER_CPU(struct pagevec, lru_add_mlock_pvecs) = { 0, };
 
 void fastcall lru_cache_add(struct page *page)
 {
@@ -197,6 +198,16 @@
 	put_cpu_var(lru_add_active_pvecs);
 }
 
+void fastcall lru_cache_add_mlock(struct page *page)
+{
+	struct pagevec *pvec = &get_cpu_var(lru_add_mlock_pvecs);
+
+	page_cache_get(page);
+	if (!pagevec_add(pvec, page))
+		__pagevec_lru_add_mlock(pvec);
+	put_cpu_var(lru_add_mlock_pvecs);
+}
+
 static void __lru_add_drain(int cpu)
 {
 	struct pagevec *pvec = &per_cpu(lru_add_pvecs, cpu);
@@ -207,6 +218,9 @@
 	pvec = &per_cpu(lru_add_active_pvecs, cpu);
 	if (pagevec_count(pvec))
 		__pagevec_lru_add_active(pvec);
+	pvec = &per_cpu(lru_add_mlock_pvecs, cpu);
+	if (pagevec_count(pvec))
+		__pagevec_lru_add_mlock(pvec);
 }
 
 void lru_add_drain(void)
@@ -364,6 +378,7 @@
 			spin_lock_irq(&zone->lru_lock);
 		}
 		VM_BUG_ON(PageLRU(page));
+		VM_BUG_ON(PageMlocked(page));
 		SetPageLRU(page);
 		add_page_to_inactive_list(zone, page);
 	}
@@ -394,6 +409,38 @@
 		SetPageLRU(page);
 		VM_BUG_ON(PageActive(page));
 		SetPageActive(page);
+		VM_BUG_ON(PageMlocked(page));
+		add_page_to_active_list(zone, page);
+	}
+	if (zone)
+		spin_unlock_irq(&zone->lru_lock);
+	release_pages(pvec->pages, pvec->nr, pvec->cold);
+	pagevec_reinit(pvec);
+}
+
+void __pagevec_lru_add_mlock(struct pagevec *pvec)
+{
+	int i;
+	struct zone *zone = NULL;
+
+	for (i = 0; i < pagevec_count(pvec); i++) {
+		struct page *page = pvec->pages[i];
+		struct zone *pagezone = page_zone(page);
+
+		if (pagezone != zone) {
+			if (zone)
+				spin_unlock_irq(&zone->lru_lock);
+			zone = pagezone;
+			spin_lock_irq(&zone->lru_lock);
+		}
+		if (!PageMlocked(page))
+			/* Another process already moved page to LRU */
+			continue;
+		BUG_ON(PageLRU(page));
+		SetPageLRU(page);
+		ClearPageMlocked(page);
+		SetPageActive(page);
+		__dec_zone_state(zone, NR_MLOCK);
 		add_page_to_active_list(zone, page);
 	}
 	if (zone)

----- End forwarded message -----
----- Forwarded message from owner-linux-mm@kvack.org -----

Subject: BOUNCE linux-mm: Header line too long (>128)
From:	owner-linux-mm@kvack.org
To:	owner-linux-mm@kvack.org
Date:	Wed, 14 Feb 2007 20:25:17 -0500

>From clameter@sgi.com Wed Feb 14 20:25:16 2007
Received: (linux-mm@kanga.kvack.org) by kvack.org id <S26679AbXBOBZF>;
	Wed, 14 Feb 2007 20:25:05 -0500
Received: from netops-testserver-4-out.sgi.com ([192.48.171.29]:50397 "EHLO
	netops-testserver-4.corp.sgi.com") by kvack.org with ESMTP
	id <S26618AbXBOBYv>; Wed, 14 Feb 2007 20:24:51 -0500
Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [150.166.1.51])
	by netops-testserver-4.corp.sgi.com (Postfix) with ESMTP id 4F6EA61B31;
	Wed, 14 Feb 2007 17:24:49 -0800 (PST)
From:	Christoph Lameter <clameter@sgi.com>
To:	akpm@osdl.org
Cc:	Christoph Hellwig <hch@infradead.org>,Arjan van de Ven <arjan@infradead.org>,Nigel Cunningham <nigel@nigel.suspend2.net>,Martin J. Bligh <mbligh@mbligh.org>,Peter Zijlstra <a.p.zijlstra@chello.nl>,Nick Piggin <nickpiggin@yahoo.com.au>,linux-mm@kvack.org,Christoph Lameter <clameter@sgi.com>,Matt Mackall <mpm@selenic.com>,Rik van Riel <riel@redhat.com>,KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20070215012449.5343.22942.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 0/7] Move mlocked pages off the LRU and track them V1
Date:	Wed, 14 Feb 2007 17:24:49 -0800 (PST)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.0.3
Return-Path: <clameter@sgi.com>
X-Envelope-To: <"|/home/majordomo/wrapper resend -l linux-mm -h kvack.org linux-mm-outgoing"> (uid 0)
X-Orcpt: rfc822;list-linux-mm@kvack.org
Original-Recipient: rfc822;list-linux-mm@kvack.org

[PATCH Remove mlocked pages from the LRU and track them V1

The patchset removes mlocked pages from the LRU and maintains a counter
for the number of discovered mlocked pages.

This is a lazy scheme for accounting for mlocked pages. The pages
may only be discovered to be mlocked during reclaim. However, we attempt
to detect mlocked pages at various other opportune moments. So in general
the mlock counter is not far off the number of actual mlocked pages in
the system.

Patch against 2.6.20-git9

Changes: RFC->V1
- Fixup a series of issues: PageActive handling, page migration etc.
- Tested on SMP and UP.

Tested on:
- IA64 NUMA 12p
- x86_64 NUMA emulation
- x86_64 SMP
- x86_64 UP

----- End forwarded message -----
----- Forwarded message from owner-linux-mm@kvack.org -----

Subject: BOUNCE linux-mm: Header line too long (>128)
From:	owner-linux-mm@kvack.org
To:	owner-linux-mm@kvack.org
Date:	Wed, 14 Feb 2007 20:25:31 -0500

>From clameter@sgi.com Wed Feb 14 20:25:26 2007
Received: (linux-mm@kanga.kvack.org) by kvack.org id <S26686AbXBOBZQ>;
	Wed, 14 Feb 2007 20:25:16 -0500
Received: from netops-testserver-3-out.sgi.com ([192.48.171.28]:11446 "EHLO
	netops-testserver-3.corp.sgi.com") by kvack.org with ESMTP
	id <S26680AbXBOBZH>; Wed, 14 Feb 2007 20:25:07 -0500
Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [150.166.1.51])
	by netops-testserver-3.corp.sgi.com (Postfix) with ESMTP id 3DA9090889;
	Wed, 14 Feb 2007 17:25:05 -0800 (PST)
From:	Christoph Lameter <clameter@sgi.com>
To:	akpm@osdl.org
Cc:	Christoph Hellwig <hch@infradead.org>,Peter Zijlstra <a.p.zijlstra@chello.nl>,Martin J. Bligh <mbligh@mbligh.org>,Arjan van de Ven <arjan@infradead.org>,Nick Piggin <nickpiggin@yahoo.com.au>,linux-mm@kvack.org,Matt Mackall <mpm@selenic.com>,Christoph Lameter <clameter@sgi.com>,Nigel Cunningham <nigel@nigel.suspend2.net>,Rik van Riel <riel@redhat.com>,KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20070215012505.5343.65950.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070215012449.5343.22942.sendpatchset@schroedinger.engr.sgi.com>
References: <20070215012449.5343.22942.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 3/7] Add NR_MLOCK ZVC
Date:	Wed, 14 Feb 2007 17:25:05 -0800 (PST)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.0.3
Return-Path: <clameter@sgi.com>
X-Envelope-To: <"|/home/majordomo/wrapper resend -l linux-mm -h kvack.org linux-mm-outgoing"> (uid 0)
X-Orcpt: rfc822;list-linux-mm@kvack.org
Original-Recipient: rfc822;list-linux-mm@kvack.org

Basic infrastructure to support NR_MLOCK

Add a new ZVC to support NR_MLOCK. NR_MLOCK counts the number of
mlocked pages taken off the LRU. Get rid of wrong calculation
of cache line size in the comments in mmzone.h.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: current/drivers/base/node.c
===================================================================
--- current.orig/drivers/base/node.c	2007-02-05 11:30:47.000000000 -0800
+++ current/drivers/base/node.c	2007-02-05 11:39:26.000000000 -0800
@@ -60,6 +60,7 @@ static ssize_t node_read_meminfo(struct 
 		       "Node %d FilePages:    %8lu kB\n"
 		       "Node %d Mapped:       %8lu kB\n"
 		       "Node %d AnonPages:    %8lu kB\n"
+		       "Node %d Mlock:        %8lu KB\n"
 		       "Node %d PageTables:   %8lu kB\n"
 		       "Node %d NFS_Unstable: %8lu kB\n"
 		       "Node %d Bounce:       %8lu kB\n"
@@ -82,6 +83,7 @@ static ssize_t node_read_meminfo(struct 
 		       nid, K(node_page_state(nid, NR_FILE_PAGES)),
 		       nid, K(node_page_state(nid, NR_FILE_MAPPED)),
 		       nid, K(node_page_state(nid, NR_ANON_PAGES)),
+		       nid, K(node_page_state(nid, NR_MLOCK)),
 		       nid, K(node_page_state(nid, NR_PAGETABLE)),
 		       nid, K(node_page_state(nid, NR_UNSTABLE_NFS)),
 		       nid, K(node_page_state(nid, NR_BOUNCE)),
Index: current/fs/proc/proc_misc.c
===================================================================
--- current.orig/fs/proc/proc_misc.c	2007-02-05 11:30:47.000000000 -0800
+++ current/fs/proc/proc_misc.c	2007-02-05 11:39:26.000000000 -0800
@@ -166,6 +166,7 @@ static int meminfo_read_proc(char *page,
 		"Writeback:    %8lu kB\n"
 		"AnonPages:    %8lu kB\n"
 		"Mapped:       %8lu kB\n"
+		"Mlock:        %8lu KB\n"
 		"Slab:         %8lu kB\n"
 		"SReclaimable: %8lu kB\n"
 		"SUnreclaim:   %8lu kB\n"
@@ -196,6 +197,7 @@ static int meminfo_read_proc(char *page,
 		K(global_page_state(NR_WRITEBACK)),
 		K(global_page_state(NR_ANON_PAGES)),
 		K(global_page_state(NR_FILE_MAPPED)),
+		K(global_page_state(NR_MLOCK)),
 		K(global_page_state(NR_SLAB_RECLAIMABLE) +
 				global_page_state(NR_SLAB_UNRECLAIMABLE)),
 		K(global_page_state(NR_SLAB_RECLAIMABLE)),
Index: current/include/linux/mmzone.h
===================================================================
--- current.orig/include/linux/mmzone.h	2007-02-05 11:30:47.000000000 -0800
+++ current/include/linux/mmzone.h	2007-02-05 11:45:12.000000000 -0800
@@ -47,17 +47,16 @@ struct zone_padding {
 #endif
 
 enum zone_stat_item {
-	/* First 128 byte cacheline (assuming 64 bit words) */
 	NR_FREE_PAGES,
 	NR_INACTIVE,
 	NR_ACTIVE,
+	NR_MLOCK,	/* Mlocked pages */
 	NR_ANON_PAGES,	/* Mapped anonymous pages */
 	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
 			   only modified from process context */
 	NR_FILE_PAGES,
 	NR_FILE_DIRTY,
 	NR_WRITEBACK,
-	/* Second 128 byte cacheline */
 	NR_SLAB_RECLAIMABLE,
 	NR_SLAB_UNRECLAIMABLE,
 	NR_PAGETABLE,		/* used for pagetables */
Index: current/mm/vmstat.c
===================================================================
--- current.orig/mm/vmstat.c	2007-02-05 11:30:47.000000000 -0800
+++ current/mm/vmstat.c	2007-02-05 11:43:38.000000000 -0800
@@ -434,6 +434,7 @@ static const char * const vmstat_text[] 
 	"nr_free_pages",
 	"nr_active",
 	"nr_inactive",
+	"nr_mlock",
 	"nr_anon_pages",
 	"nr_mapped",
 	"nr_file_pages",

----- End forwarded message -----
----- Forwarded message from owner-linux-mm@kvack.org -----

Subject: BOUNCE linux-mm: Header line too long (>128)
From:	owner-linux-mm@kvack.org
To:	owner-linux-mm@kvack.org
Date:	Wed, 14 Feb 2007 20:25:50 -0500

>From clameter@sgi.com Wed Feb 14 20:25:49 2007
Received: (linux-mm@kanga.kvack.org) by kvack.org id <S26697AbXBOBZb>;
	Wed, 14 Feb 2007 20:25:31 -0500
Received: from netops-testserver-3-out.sgi.com ([192.48.171.28]:14518 "EHLO
	netops-testserver-3.corp.sgi.com") by kvack.org with ESMTP
	id <S26684AbXBOBZN>; Wed, 14 Feb 2007 20:25:13 -0500
Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [150.166.1.51])
	by netops-testserver-3.corp.sgi.com (Postfix) with ESMTP id 75E319088A;
	Wed, 14 Feb 2007 17:25:10 -0800 (PST)
From:	Christoph Lameter <clameter@sgi.com>
To:	akpm@osdl.org
Cc:	Christoph Hellwig <hch@infradead.org>,Arjan van de Ven <arjan@infradead.org>,Nigel Cunningham <nigel@nigel.suspend2.net>,Martin J. Bligh <mbligh@mbligh.org>,Peter Zijlstra <a.p.zijlstra@chello.nl>,Nick Piggin <nickpiggin@yahoo.com.au>,linux-mm@kvack.org,Christoph Lameter <clameter@sgi.com>,Matt Mackall <mpm@selenic.com>,Rik van Riel <riel@redhat.com>,KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20070215012510.5343.52706.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070215012449.5343.22942.sendpatchset@schroedinger.engr.sgi.com>
References: <20070215012449.5343.22942.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 4/7] Logic to move mlocked pages
Date:	Wed, 14 Feb 2007 17:25:10 -0800 (PST)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.0.3
Return-Path: <clameter@sgi.com>
X-Envelope-To: <"|/home/majordomo/wrapper resend -l linux-mm -h kvack.org linux-mm-outgoing"> (uid 0)
X-Orcpt: rfc822;list-linux-mm@kvack.org
Original-Recipient: rfc822;list-linux-mm@kvack.org

Add logic to lazily remove/add mlocked pages from LRU

This is the core of the patchset. It adds the necessary logic to
remove mlocked pages from the LRU and put them back later. The basic idea
by Andrew Morton and others has been around for awhile.

During reclaim we attempt to unmap pages. In order to do so we have
to scan all vmas that a page belongs to to check for VM_LOCKED.

If we find that VM_LOCKED is set for a page then we remove the page from
the LRU and mark it with SetMlocked. We must mark the page with a special
flag bit. Without PageMLocked we have later no way to distinguish pages that
are off the LRU because of mlock from pages that are off the LRU for other
reasons. We should only feed back mlocked pages to the LRU and not the pages
that were removed for other reasons.

We feed pages back to the LRU in two places:

zap_pte_range: 	Here pages are removed from a vma. If a page is mlocked then
	we add it back to the LRU. If other vmas with VM_LOCKED set have
	mapped the page then we will discover that later during reclaim and
	move the page off the LRU again.

munlock/munlockall: We scan all pages in the vma and do the
	same as in zap_pte_range.

We also have to modify the page migration logic to handle PageMlocked
pages. We simply clear the PageMlocked bit and then we can treat
the page as a regular page from the LRU. Page migration feeds all
pages back the LRU and relies on reclaim to move them off again.

Note that this is lazy accounting for mlocked pages. NR_MLOCK may
increase as the system discovers more mlocked pages. If a machine has
a large amount of memory then it may take awhile until reclaim gets through
with all pages. We may only discover the extend of mlocked pages when
memory gets tight.

Some of the later patches opportunistically move pages off the LRU to avoid
delays in accounting. Usually these opportunistic moves do a pretty good job
but there are special situations (such as page migration and munlocking a
memory area mlocked by multiple processes) where NR_MLOCK may become low until
reclaim detects the mlocked pages again.

So, the scheme is fundamentally lazy and one cannot count on NR_MLOCK to
reflect the actual number of mlocked pages. NR_MLOCK represents the number
*discovered* mlocked pages so far which may be less than the actual number
of mlocked pages.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.20/mm/memory.c
===================================================================
--- linux-2.6.20.orig/mm/memory.c	2007-02-14 17:07:44.000000000 -0800
+++ linux-2.6.20/mm/memory.c	2007-02-14 17:08:39.000000000 -0800
@@ -682,6 +682,8 @@
 				file_rss--;
 			}
 			page_remove_rmap(page, vma);
+			if (PageMlocked(page) && vma->vm_flags & VM_LOCKED)
+				lru_cache_add_mlock(page);
 			tlb_remove_page(tlb, page);
 			continue;
 		}
Index: linux-2.6.20/mm/migrate.c
===================================================================
--- linux-2.6.20.orig/mm/migrate.c	2007-02-14 17:07:44.000000000 -0800
+++ linux-2.6.20/mm/migrate.c	2007-02-14 17:08:54.000000000 -0800
@@ -58,6 +58,13 @@
 			else
 				del_page_from_inactive_list(zone, page);
 			list_add_tail(&page->lru, pagelist);
+		} else
+		if (PageMlocked(page)) {
+			ret = 0;
+			get_page(page);
+			ClearPageMlocked(page);
+			list_add_tail(&page->lru, pagelist);
+			__dec_zone_state(zone, NR_MLOCK);
 		}
 		spin_unlock_irq(&zone->lru_lock);
 	}
Index: linux-2.6.20/mm/mlock.c
===================================================================
--- linux-2.6.20.orig/mm/mlock.c	2007-02-14 17:07:44.000000000 -0800
+++ linux-2.6.20/mm/mlock.c	2007-02-14 17:08:39.000000000 -0800
@@ -10,7 +10,7 @@
 #include <linux/mm.h>
 #include <linux/mempolicy.h>
 #include <linux/syscalls.h>
-
+#include <linux/swap.h>
 
 static int mlock_fixup(struct vm_area_struct *vma, struct vm_area_struct **prev,
 	unsigned long start, unsigned long end, unsigned int newflags)
@@ -63,6 +63,23 @@
 		pages = -pages;
 		if (!(newflags & VM_IO))
 			ret = make_pages_present(start, end);
+	} else {
+		unsigned long addr;
+
+		/*
+		 * We are clearing VM_LOCKED. Feed all pages back
+		 * to the LRU via lru_cache_add_mlock()
+		 */
+		for (addr = start; addr < end; addr += PAGE_SIZE) {
+			struct page *page;
+
+			page = follow_page(vma, start, FOLL_GET);
+			if (page && PageMlocked(page)) {
+				lru_cache_add_mlock(page);
+				put_page(page);
+			}
+			cond_resched();
+		}
 	}
 
 	mm->locked_vm -= pages;
Index: linux-2.6.20/mm/vmscan.c
===================================================================
--- linux-2.6.20.orig/mm/vmscan.c	2007-02-14 17:07:44.000000000 -0800
+++ linux-2.6.20/mm/vmscan.c	2007-02-14 17:08:39.000000000 -0800
@@ -509,10 +509,11 @@
 		if (page_mapped(page) && mapping) {
 			switch (try_to_unmap(page, 0)) {
 			case SWAP_FAIL:
-			case SWAP_MLOCK:
 				goto activate_locked;
 			case SWAP_AGAIN:
 				goto keep_locked;
+			case SWAP_MLOCK:
+				goto mlocked;
 			case SWAP_SUCCESS:
 				; /* try to free the page below */
 			}
@@ -587,6 +588,13 @@
 			__pagevec_release_nonlru(&freed_pvec);
 		continue;
 
+mlocked:
+		ClearPageActive(page);
+		unlock_page(page);
+		__inc_zone_page_state(page, NR_MLOCK);
+		SetPageMlocked(page);
+		continue;
+
 activate_locked:
 		SetPageActive(page);
 		pgactivate++;

----- End forwarded message -----
----- Forwarded message from owner-linux-mm@kvack.org -----

Subject: BOUNCE linux-mm: Header line too long (>128)
From:	owner-linux-mm@kvack.org
To:	owner-linux-mm@kvack.org
Date:	Wed, 14 Feb 2007 20:25:50 -0500

>From clameter@sgi.com Wed Feb 14 20:25:50 2007
Received: (linux-mm@kanga.kvack.org) by kvack.org id <S26685AbXBOBZc>;
	Wed, 14 Feb 2007 20:25:32 -0500
Received: from netops-testserver-3-out.sgi.com ([192.48.171.28]:20918 "EHLO
	netops-testserver-3.corp.sgi.com") by kvack.org with ESMTP
	id <S26689AbXBOBZW>; Wed, 14 Feb 2007 20:25:22 -0500
Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [150.166.1.51])
	by netops-testserver-3.corp.sgi.com (Postfix) with ESMTP id DE37A9088F;
	Wed, 14 Feb 2007 17:25:20 -0800 (PST)
From:	Christoph Lameter <clameter@sgi.com>
To:	akpm@osdl.org
Cc:	Christoph Hellwig <hch@infradead.org>,Arjan van de Ven <arjan@infradead.org>,Nigel Cunningham <nigel@nigel.suspend2.net>,Martin J. Bligh <mbligh@mbligh.org>,Peter Zijlstra <a.p.zijlstra@chello.nl>,Nick Piggin <nickpiggin@yahoo.com.au>,linux-mm@kvack.org,Christoph Lameter <clameter@sgi.com>,Matt Mackall <mpm@selenic.com>,Rik van Riel <riel@redhat.com>,KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20070215012520.5343.55834.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070215012449.5343.22942.sendpatchset@schroedinger.engr.sgi.com>
References: <20070215012449.5343.22942.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 6/7] Avoid putting new mlocked anonymous pages on LRU
Date:	Wed, 14 Feb 2007 17:25:20 -0800 (PST)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.0.3
Return-Path: <clameter@sgi.com>
X-Envelope-To: <"|/home/majordomo/wrapper resend -l linux-mm -h kvack.org linux-mm-outgoing"> (uid 0)
X-Orcpt: rfc822;list-linux-mm@kvack.org
Original-Recipient: rfc822;list-linux-mm@kvack.org

Mark new anonymous pages mlocked if they are in a mlocked VMA.

Avoid putting pages onto the LRU that are allocated in a VMA
with VM_LOCKED set. NR_MLOCK will be more accurate.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.20/mm/memory.c
===================================================================
--- linux-2.6.20.orig/mm/memory.c	2007-02-14 12:52:01.000000000 -0800
+++ linux-2.6.20/mm/memory.c	2007-02-14 12:52:36.000000000 -0800
@@ -906,7 +906,16 @@
 				unsigned long address)
 {
 	inc_mm_counter(vma->vm_mm, anon_rss);
-	lru_cache_add_active(page);
+	if (vma->vm_flags & VM_LOCKED) {
+		/*
+		 * Page is new and therefore not on the LRU
+		 * so we can directly mark it as mlocked
+		 */
+		SetPageMlocked(page);
+		ClearPageActive(page);
+		inc_zone_page_state(page, NR_MLOCK);
+	} else
+		lru_cache_add_active(page);
 	page_add_new_anon_rmap(page, vma, address);
 }
 

----- End forwarded message -----
----- Forwarded message from owner-linux-mm@kvack.org -----

Subject: BOUNCE linux-mm: Header line too long (>128)
From:	owner-linux-mm@kvack.org
To:	owner-linux-mm@kvack.org
Date:	Wed, 14 Feb 2007 20:25:50 -0500

>From clameter@sgi.com Wed Feb 14 20:25:50 2007
Received: (linux-mm@kanga.kvack.org) by kvack.org id <S26687AbXBOBZc>;
	Wed, 14 Feb 2007 20:25:32 -0500
Received: from netops-testserver-3-out.sgi.com ([192.48.171.28]:17846 "EHLO
	netops-testserver-3.corp.sgi.com") by kvack.org with ESMTP
	id <S26683AbXBOBZQ>; Wed, 14 Feb 2007 20:25:16 -0500
Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [150.166.1.51])
	by netops-testserver-3.corp.sgi.com (Postfix) with ESMTP id A87E49088E;
	Wed, 14 Feb 2007 17:25:15 -0800 (PST)
From:	Christoph Lameter <clameter@sgi.com>
To:	akpm@osdl.org
Cc:	Christoph Hellwig <hch@infradead.org>,Peter Zijlstra <a.p.zijlstra@chello.nl>,Martin J. Bligh <mbligh@mbligh.org>,Arjan van de Ven <arjan@infradead.org>,Nick Piggin <nickpiggin@yahoo.com.au>,linux-mm@kvack.org,Matt Mackall <mpm@selenic.com>,Christoph Lameter <clameter@sgi.com>,Nigel Cunningham <nigel@nigel.suspend2.net>,Rik van Riel <riel@redhat.com>,KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20070215012515.5343.28018.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070215012449.5343.22942.sendpatchset@schroedinger.engr.sgi.com>
References: <20070215012449.5343.22942.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 5/7] Consolidate new anonymous page code paths
Date:	Wed, 14 Feb 2007 17:25:15 -0800 (PST)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.0.3
Return-Path: <clameter@sgi.com>
X-Envelope-To: <"|/home/majordomo/wrapper resend -l linux-mm -h kvack.org linux-mm-outgoing"> (uid 0)
X-Orcpt: rfc822;list-linux-mm@kvack.org
Original-Recipient: rfc822;list-linux-mm@kvack.org

Consolidate code to add an anonymous page in memory.c

There are two location in which we add anonymous pages. Both
implement the same logic. Create a new function add_anon_page()
to have a common code path.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.20/mm/memory.c
===================================================================
--- linux-2.6.20.orig/mm/memory.c	2007-02-14 12:03:09.000000000 -0800
+++ linux-2.6.20/mm/memory.c	2007-02-14 12:03:12.000000000 -0800
@@ -900,6 +900,17 @@
 }
 
 /*
+ * Add a new anonymous page
+ */
+static void add_anon_page(struct vm_area_struct *vma, struct page *page,
+				unsigned long address)
+{
+	inc_mm_counter(vma->vm_mm, anon_rss);
+	lru_cache_add_active(page);
+	page_add_new_anon_rmap(page, vma, address);
+}
+
+/*
  * Do a quick page-table lookup for a single page.
  */
 struct page *follow_page(struct vm_area_struct *vma, unsigned long address,
@@ -2148,9 +2159,7 @@
 		page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
 		if (!pte_none(*page_table))
 			goto release;
-		inc_mm_counter(mm, anon_rss);
-		lru_cache_add_active(page);
-		page_add_new_anon_rmap(page, vma, address);
+		add_anon_page(vma, page, address);
 	} else {
 		/* Map the ZERO_PAGE - vm_page_prot is readonly */
 		page = ZERO_PAGE(address);
@@ -2294,11 +2303,9 @@
 		if (write_access)
 			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 		set_pte_at(mm, address, page_table, entry);
-		if (anon) {
-			inc_mm_counter(mm, anon_rss);
-			lru_cache_add_active(new_page);
-			page_add_new_anon_rmap(new_page, vma, address);
-		} else {
+		if (anon)
+			add_anon_page(vma, new_page, address);
+		else {
 			inc_mm_counter(mm, file_rss);
 			page_add_file_rmap(new_page);
 			if (write_access) {

----- End forwarded message -----
----- Forwarded message from owner-linux-mm@kvack.org -----

Subject: BOUNCE linux-mm: Header line too long (>128)
From:	owner-linux-mm@kvack.org
To:	owner-linux-mm@kvack.org
Date:	Wed, 14 Feb 2007 20:26:00 -0500

>From clameter@sgi.com Wed Feb 14 20:25:59 2007
Received: (linux-mm@kanga.kvack.org) by kvack.org id <S26698AbXBOBZu>;
	Wed, 14 Feb 2007 20:25:50 -0500
Received: from netops-testserver-3-out.sgi.com ([192.48.171.28]:23990 "EHLO
	netops-testserver-3.corp.sgi.com") by kvack.org with ESMTP
	id <S26696AbXBOBZb>; Wed, 14 Feb 2007 20:25:31 -0500
Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [150.166.1.51])
	by netops-testserver-3.corp.sgi.com (Postfix) with ESMTP id 24D569088B;
	Wed, 14 Feb 2007 17:25:26 -0800 (PST)
From:	Christoph Lameter <clameter@sgi.com>
To:	akpm@osdl.org
Cc:	Christoph Hellwig <hch@infradead.org>,Peter Zijlstra <a.p.zijlstra@chello.nl>,Martin J. Bligh <mbligh@mbligh.org>,Arjan van de Ven <arjan@infradead.org>,Nick Piggin <nickpiggin@yahoo.com.au>,linux-mm@kvack.org,Matt Mackall <mpm@selenic.com>,Christoph Lameter <clameter@sgi.com>,Nigel Cunningham <nigel@nigel.suspend2.net>,Rik van Riel <riel@redhat.com>,KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20070215012525.5343.71985.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070215012449.5343.22942.sendpatchset@schroedinger.engr.sgi.com>
References: <20070215012449.5343.22942.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 7/7] Opportunistically move mlocked pages off the LRU
Date:	Wed, 14 Feb 2007 17:25:26 -0800 (PST)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.0.3
Return-Path: <clameter@sgi.com>
X-Envelope-To: <"|/home/majordomo/wrapper resend -l linux-mm -h kvack.org linux-mm-outgoing"> (uid 0)
X-Orcpt: rfc822;list-linux-mm@kvack.org
Original-Recipient: rfc822;list-linux-mm@kvack.org

Opportunistically move mlocked pages off the LRU

Add a new function try_to_mlock() that attempts to
move a page off the LRU and marks it mlocked.

This function can then be used in various code paths to move
pages off the LRU immediately. Early discovery will make NR_MLOCK
track the actual number of mlocked pages in the system more closely.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.20/mm/memory.c
===================================================================
--- linux-2.6.20.orig/mm/memory.c	2007-02-14 13:10:09.000000000 -0800
+++ linux-2.6.20/mm/memory.c	2007-02-14 13:13:29.000000000 -0800
@@ -59,6 +59,7 @@
 
 #include <linux/swapops.h>
 #include <linux/elf.h>
+#include <linux/mm_inline.h>
 
 #ifndef CONFIG_NEED_MULTIPLE_NODES
 /* use the per-pgdat data instead for discontigmem - mbligh */
@@ -920,6 +921,34 @@
 }
 
 /*
+ * Opportunistically move the page off the LRU
+ * if possible. If we do not succeed then the LRU
+ * scans will take the page off.
+ */
+static void try_to_set_mlocked(struct page *page)
+{
+	struct zone *zone;
+	unsigned long flags;
+
+	if (!PageLRU(page) || PageMlocked(page))
+		return;
+
+	zone = page_zone(page);
+	if (spin_trylock_irqsave(&zone->lru_lock, flags)) {
+		if (PageLRU(page) && !PageMlocked(page)) {
+			ClearPageLRU(page);
+			if (PageActive(page))
+				del_page_from_active_list(zone, page);
+			else
+				del_page_from_inactive_list(zone, page);
+			ClearPageActive(page);
+			SetPageMlocked(page);
+			__inc_zone_page_state(page, NR_MLOCK);
+		}
+		spin_unlock_irqrestore(&zone->lru_lock, flags);
+	}
+}
+/*
  * Do a quick page-table lookup for a single page.
  */
 struct page *follow_page(struct vm_area_struct *vma, unsigned long address,
@@ -979,6 +1008,8 @@
 			set_page_dirty(page);
 		mark_page_accessed(page);
 	}
+	if (vma->vm_flags & VM_LOCKED)
+		try_to_set_mlocked(page);
 unlock:
 	pte_unmap_unlock(ptep, ptl);
 out:
@@ -2317,6 +2348,8 @@
 		else {
 			inc_mm_counter(mm, file_rss);
 			page_add_file_rmap(new_page);
+			if (vma->vm_flags & VM_LOCKED)
+				try_to_set_mlocked(new_page);
 			if (write_access) {
 				dirty_page = new_page;
 				get_page(dirty_page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

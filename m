Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id A6D2D6B00AC
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 19:51:46 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 11/33] autonuma: add the autonuma_last_nid in the page structure
Date: Thu,  4 Oct 2012 01:50:53 +0200
Message-Id: <1349308275-2174-12-git-send-email-aarcange@redhat.com>
In-Reply-To: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Christoph Lameter <cl@linux.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

This is the basic implementation improved by later patches.

Later patches moves the new field to a dynamically allocated
page_autonuma taking 2 bytes per page (only allocated if booted on
NUMA hardware, unless "noautonuma" is passed as parameter to the
kernel at boot).

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/mm_types.h |   11 +++++++++++
 mm/page_alloc.c          |    3 +++
 2 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index c80101c..9e8398a 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -152,6 +152,17 @@ struct page {
 		struct page *first_page;	/* Compound tail pages */
 	};
 
+#ifdef CONFIG_AUTONUMA
+	/*
+	 * FIXME: move to pgdat section along with the memcg and allocate
+	 * at runtime only in presence of a numa system.
+	 */
+#if MAX_NUMNODES > 32767
+#error "too many nodes"
+#endif
+	short autonuma_last_nid;
+#endif
+
 	/*
 	 * On machines where all RAM is mapped into kernel address space,
 	 * we can simply calculate the virtual address. On machines with
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 77845f9..a9b18bc 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3793,6 +3793,9 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
 
 		INIT_LIST_HEAD(&page->lru);
+#ifdef CONFIG_AUTONUMA
+		page->autonuma_last_nid = -1;
+#endif
 #ifdef WANT_PAGE_VIRTUAL
 		/* The shift won't overflow because ZONE_NORMAL is below 4G. */
 		if (!is_highmem_idx(zone))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

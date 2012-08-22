Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 6EE8C6B0075
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 11:00:35 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 11/36] autonuma: add page structure fields
Date: Wed, 22 Aug 2012 16:58:55 +0200
Message-Id: <1345647560-30387-12-git-send-email-aarcange@redhat.com>
In-Reply-To: <1345647560-30387-1-git-send-email-aarcange@redhat.com>
References: <1345647560-30387-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On 64bit archs, 20 bytes are used for async memory migration (specific
to the knuma_migrated per-node threads), and 4 bytes are used for the
thread NUMA false sharing detection logic.

This is the basic implementation improved by later patches.

Later patches moves the new fields to a dynamically allocated
page_autonuma of 32 bytes per page (only allocated if booted on NUMA
hardware, unless "noautonuma" is passed as parameter to the kernel at
boot). Yet another later patch introduces the autonuma_list and
reduces the size of the page_autonuma from 32 to 12 bytes.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/mm_types.h |   26 ++++++++++++++++++++++++++
 mm/page_alloc.c          |    4 ++++
 2 files changed, 30 insertions(+), 0 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index c80101c..3f10fef 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -152,6 +152,32 @@ struct page {
 		struct page *first_page;	/* Compound tail pages */
 	};
 
+#ifdef CONFIG_AUTONUMA
+	/*
+	 * FIXME: move to pgdat section along with the memcg and allocate
+	 * at runtime only in presence of a numa system.
+	 */
+	/*
+	 * To modify autonuma_last_nid lockless the architecture,
+	 * needs SMP atomic granularity < sizeof(long), not all archs
+	 * have that, notably some ancient alpha (but none of those
+	 * should run in NUMA systems). Archs without that requires
+	 * autonuma_last_nid to be a long.
+	 */
+#ifdef CONFIG_64BIT
+	int autonuma_migrate_nid;
+	int autonuma_last_nid;
+#else
+#if MAX_NUMNODES > 32767
+#error "too many nodes"
+#endif
+	/* FIXME: remember to check the updates are atomic */
+	short autonuma_migrate_nid;
+	short autonuma_last_nid;
+#endif
+	struct list_head autonuma_migrate_node;
+#endif
+
 	/*
 	 * On machines where all RAM is mapped into kernel address space,
 	 * we can simply calculate the virtual address. On machines with
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ff61443..a6337b3 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3787,6 +3787,10 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
 
 		INIT_LIST_HEAD(&page->lru);
+#ifdef CONFIG_AUTONUMA
+		page->autonuma_last_nid = -1;
+		page->autonuma_migrate_nid = -1;
+#endif
 #ifdef WANT_PAGE_VIRTUAL
 		/* The shift won't overflow because ZONE_NORMAL is below 4G. */
 		if (!is_highmem_idx(zone))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

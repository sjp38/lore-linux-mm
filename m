Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3991FC31E49
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 23:30:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D23A221537
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 23:30:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D23A221537
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1C4376B000D; Thu, 13 Jun 2019 19:30:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 139A78E0002; Thu, 13 Jun 2019 19:30:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 002C66B0266; Thu, 13 Jun 2019 19:30:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id B0F2E6B000D
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 19:30:04 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id g65so457545plb.9
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 16:30:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=bQ2Qu/5U0oOvpJZmOsQ38gDUKVlSWhPFu3LitWScYc0=;
        b=fUlr8fY1EAXzedCSuLQNnYrAc1W8Ua8vH+YWW55QdyRXkrhuyFEUuSsPL8n99+7gOA
         yy966fp3vdByL19HQ86C4QOAACfjgNRoTisWGb4w2uQKKAUWwM4SnxO96CUwRRQZQnWQ
         bXYfjg763Qo5IeFkNqiPfuvC7r5KW280RCWyTslLY3K8FbU0BZ2Dfe+hDyc0FRhrgNgC
         LWOpkhhLAVx+Zx3Ki2fhA8sAclMOhWE8IExOaPkWwHMg4DtcBq4SlG4UWASt6e1ZQxq2
         DW+7XVGG+ILucZB39RZM8chx9i2sQAublAyoTlnbtA/ySP+9e2yKPl6/XWHQIDIjOdDE
         Iz4A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAW6l6UcnaGWNHuruMCNqFylloZTwlB6q4V/6YjKEfYjG09nHXFn
	UrJp1Y+ktVrzRGuFsd433RrTDkZiz6GNFKkBlKrxPsbyD7VR4Ntm7xY+JaHby/dJ4rTPeyaSvRw
	4VVJUE6fyezs4dzS6ePQwbBwIebnz3YxvUkROV/ysq7/Wh0W6cNq93fJwA9Zpcos+YA==
X-Received: by 2002:a17:902:b18f:: with SMTP id s15mr92817627plr.44.1560468604264;
        Thu, 13 Jun 2019 16:30:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx2TOnBlEUG9jpwmI0R3L2nJ65k5PrE9apqoh3QHEQ8RCOw4wZbODgPtVtaT8GLULlKO5b+
X-Received: by 2002:a17:902:b18f:: with SMTP id s15mr92817511plr.44.1560468602286;
        Thu, 13 Jun 2019 16:30:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560468602; cv=none;
        d=google.com; s=arc-20160816;
        b=PorOYmbdHsI6q+KX8iGoXAxMqXOXWM5VoU4g+19zTVR61/fDiKGSg60Ea4RhYVuB0t
         E+WmeV76Enpdeu7/74y3V/S+mHF1y6Q3cBjErDKDbT8W0AfWvcjGKpg6cWKkqk0Pglyu
         y/VXWcIYlkecBQr9sRZZUCdO+QXMb2DjE4DU9/z7yOkVpA0b/A7WQuwYWhx+4k5ZWTQ3
         C8BQLv6axSjNmp5+oCzRJHfzjZBYxLzZnetJd5EDTqI2gIwAgbkTeuT3Ksmw8ShwP/Z+
         HVrS23jJwLyQBjvXUVjvTu6Y54OgXTpWzmusbnKXqZ0xzcvbjy78AvRD2/g5uw4XmikP
         wTlw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=bQ2Qu/5U0oOvpJZmOsQ38gDUKVlSWhPFu3LitWScYc0=;
        b=stgVg4vly4auAOvuvV50IuSc020vnMt7olHTpdNY0fjRsa2BGkrvObw/dMoiF5MqZ/
         w/QbeEtVjMJPmMKkBeyLrLAsq+QAucPuFvUopnKkpAc1R650aLBOSLIfyKHYh8gsIQ0m
         R48ZcPaqPcw86xulHA/EPtY6B1IH1PhzjGJ4qIunyyJVvp1x2qTObR31wgOVQ2CTG1QN
         +oAeFIX8Bi4PEsQBFFPrnT+KnMBrzjoy8sPCRdE6lR3bfTd8e5ZgjKHZU7s16jm7Odn8
         B0WXJzFenujGWEGqBMJR6s/XFXNRPPCp/hUrXRHa20GB6ctB83/MFKCTkCf4RH40Rlkz
         UUtw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-56.freemail.mail.aliyun.com (out30-56.freemail.mail.aliyun.com. [115.124.30.56])
        by mx.google.com with ESMTPS id 64si466066plw.37.2019.06.13.16.30.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 16:30:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) client-ip=115.124.30.56;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R401e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07487;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=15;SR=0;TI=SMTPD_---0TU6DYEz_1560468591;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TU6DYEz_1560468591)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 14 Jun 2019 07:30:00 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: mhocko@suse.com,
	mgorman@techsingularity.net,
	riel@surriel.com,
	hannes@cmpxchg.org,
	akpm@linux-foundation.org,
	dave.hansen@intel.com,
	keith.busch@intel.com,
	dan.j.williams@intel.com,
	fengguang.wu@intel.com,
	fan.du@intel.com,
	ying.huang@intel.com,
	ziy@nvidia.com
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [v3 PATCH 5/9] mm: vmscan: demote anon DRAM pages to migration target node
Date: Fri, 14 Jun 2019 07:29:33 +0800
Message-Id: <1560468577-101178-6-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1560468577-101178-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1560468577-101178-1-git-send-email-yang.shi@linux.alibaba.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Since migration target node (i.e. PMEM) typically provides larger
capacity than DRAM and has much lower access latency than disk, so
it is a good choice to use as a middle tier between DRAM and disk in
page reclaim path.

With migration target nodes, the demotion path of anonymous pages could be:

DRAM -> PMEM -> swap device

This patch demotes anonymous pages only for the time being and demote
THP to the migration target node in a whole.  To avoid expensive page
reclaim and/or compaction on the target node if there is memory pressure
on it, the most conservative gfp flag is used, which would fail quickly if
there is memory pressure and just wakeup kswapd on failure.  The
migrate_pages() would split THP to migrate one by one as base page upon
THP allocation failure.

Demote pages to the cloest migration target node even though the system is
swapless.  The current logic of page reclaim just scan anon LRU when
swap is on and swappiness is set properly.  Demoting to the migration
target doesn't need care whether swap is available or not.  But, reclaiming
from the migration target node still skip anon LRU if swap is not available.

The demotion just happens from DRAM node to its cloest migration target node.
Demoting to a remote migration target node or migrating from the target node
to DRAM on reclaim path is not allowed.

And, define a new migration reason for demotion, called MR_DEMOTE.
Demote page via async migration to avoid blocking.

The migration is just allowed via node reclaim.  Introduce a new node
reclaim mode: migrate mode.  The migrate mode is not compatible with
cpuset and mempolicy settings.

Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 Documentation/sysctl/vm.txt    |   6 ++
 include/linux/gfp.h            |  12 ++++
 include/linux/migrate.h        |   1 +
 include/trace/events/migrate.h |   3 +-
 mm/debug.c                     |   1 +
 mm/internal.h                  |  12 ++++
 mm/migrate.c                   |  15 +++-
 mm/vmscan.c                    | 157 +++++++++++++++++++++++++++++++++--------
 8 files changed, 175 insertions(+), 32 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 7493220..4b76a55 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -919,6 +919,7 @@ This is value ORed together of
 1	= Zone reclaim on
 2	= Zone reclaim writes dirty pages out
 4	= Zone reclaim swaps pages
+8	= Zone reclaim migrate pages
 
 zone_reclaim_mode is disabled by default.  For file servers or workloads
 that benefit from having their data cached, zone_reclaim_mode should be
@@ -943,4 +944,9 @@ Allowing regular swap effectively restricts allocations to the local
 node unless explicitly overridden by memory policies or cpuset
 configurations.
 
+Allowing zone reclaim to migrate pages to the migration target nodes, which
+are typically cheaper and slower than DRAM, but have larger capacity, i.e.
+NVDIMM nodes, if such nodes are present in the system.  The migrate mode
+is not compatible with cpuset and mempolicy settings.
+
 ============ End of Document =================================
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index fb07b50..b294455 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -285,6 +285,14 @@
  * available and will not wake kswapd/kcompactd on failure. The _LIGHT
  * version does not attempt reclaim/compaction at all and is by default used
  * in page fault path, while the non-light is used by khugepaged.
+ *
+ * %GFP_DEMOTE is for migration on memory reclaim (a.k.a demotion) allocations.
+ * The allocation might happen in kswapd or direct reclaim, so assuming
+ * __GFP_IO and __GFP_FS are not allowed looks safer.  Demotion happens for
+ * user pages (on LRU) only and on specific node.  Generally it will fail
+ * quickly if memory is not available, but may wake up kswapd on failure.
+ *
+ * %GFP_TRANSHUGE_DEMOTE is used for THP demotion allocation.
  */
 #define GFP_ATOMIC	(__GFP_HIGH|__GFP_ATOMIC|__GFP_KSWAPD_RECLAIM)
 #define GFP_KERNEL	(__GFP_RECLAIM | __GFP_IO | __GFP_FS)
@@ -300,6 +308,10 @@
 #define GFP_TRANSHUGE_LIGHT	((GFP_HIGHUSER_MOVABLE | __GFP_COMP | \
 			 __GFP_NOMEMALLOC | __GFP_NOWARN) & ~__GFP_RECLAIM)
 #define GFP_TRANSHUGE	(GFP_TRANSHUGE_LIGHT | __GFP_DIRECT_RECLAIM)
+#define GFP_DEMOTE	(__GFP_HIGHMEM | __GFP_MOVABLE | __GFP_NORETRY | \
+			__GFP_NOMEMALLOC | __GFP_NOWARN | __GFP_THISNODE | \
+			GFP_NOWAIT)
+#define GFP_TRANSHUGE_DEMOTE	(GFP_DEMOTE | __GFP_COMP)
 
 /* Convert GFP flags to their corresponding migrate type */
 #define GFP_MOVABLE_MASK (__GFP_RECLAIMABLE|__GFP_MOVABLE)
diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 837fdd1..cfb1f57 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -25,6 +25,7 @@ enum migrate_reason {
 	MR_MEMPOLICY_MBIND,
 	MR_NUMA_MISPLACED,
 	MR_CONTIG_RANGE,
+	MR_DEMOTE,
 	MR_TYPES
 };
 
diff --git a/include/trace/events/migrate.h b/include/trace/events/migrate.h
index 705b33d..c1d5b36 100644
--- a/include/trace/events/migrate.h
+++ b/include/trace/events/migrate.h
@@ -20,7 +20,8 @@
 	EM( MR_SYSCALL,		"syscall_or_cpuset")		\
 	EM( MR_MEMPOLICY_MBIND,	"mempolicy_mbind")		\
 	EM( MR_NUMA_MISPLACED,	"numa_misplaced")		\
-	EMe(MR_CONTIG_RANGE,	"contig_range")
+	EM( MR_CONTIG_RANGE,	"contig_range")			\
+	EMe(MR_DEMOTE,		"demote")
 
 /*
  * First define the enums in the above macros to be exported to userspace
diff --git a/mm/debug.c b/mm/debug.c
index 8345bb6..0bcced8 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -25,6 +25,7 @@
 	"mempolicy_mbind",
 	"numa_misplaced",
 	"cma",
+	"demote",
 };
 
 const struct trace_print_flags pageflag_names[] = {
diff --git a/mm/internal.h b/mm/internal.h
index a3181e2..3d756f2 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -303,6 +303,18 @@ static inline int find_next_best_node(int node, nodemask_t *used_node_mask,
 }
 #endif
 
+static inline bool has_migration_target_node_online(void)
+{
+	int nid;
+
+	for_each_online_node(nid) {
+		if (node_state(nid, N_MIGRATE_TARGET))
+			return true;
+	}
+
+	return false;
+}
+
 /* mm/util.c */
 void __vma_link_list(struct mm_struct *mm, struct vm_area_struct *vma,
 		struct vm_area_struct *prev, struct rb_node *rb_parent);
diff --git a/mm/migrate.c b/mm/migrate.c
index bc4242a..9fb76a6 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1006,7 +1006,8 @@ static int move_to_new_page(struct page *newpage, struct page *page,
 }
 
 static int __unmap_and_move(struct page *page, struct page *newpage,
-				int force, enum migrate_mode mode)
+				int force, enum migrate_mode mode,
+				enum migrate_reason reason)
 {
 	int rc = -EAGAIN;
 	int page_was_mapped = 0;
@@ -1143,8 +1144,16 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 	if (rc == MIGRATEPAGE_SUCCESS) {
 		if (unlikely(!is_lru))
 			put_page(newpage);
-		else
+		else {
+			/*
+			 * Put demoted pages on the target node's
+			 * active LRU.
+			 */
+			if (!PageUnevictable(newpage) &&
+			    reason == MR_DEMOTE)
+				SetPageActive(newpage);
 			putback_lru_page(newpage);
+		}
 	}
 
 	return rc;
@@ -1198,7 +1207,7 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 		goto out;
 	}
 
-	rc = __unmap_and_move(page, newpage, force, mode);
+	rc = __unmap_and_move(page, newpage, force, mode, reason);
 	if (rc == MIGRATEPAGE_SUCCESS)
 		set_page_owner_migrate_reason(newpage, reason);
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7acd0af..428a83b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1094,6 +1094,55 @@ static void page_check_dirty_writeback(struct page *page,
 		mapping->a_ops->is_dirty_writeback(page, dirty, writeback);
 }
 
+#ifdef CONFIG_NUMA
+#define RECLAIM_OFF 0
+#define RECLAIM_ZONE (1<<0)	/* Run shrink_inactive_list on the zone */
+#define RECLAIM_WRITE (1<<1)	/* Writeout pages during reclaim */
+#define RECLAIM_UNMAP (1<<2)	/* Unmap pages during reclaim */
+#define RECLAIM_MIGRATE (1<<3)	/* Migrate pages to migration target
+				 * node during reclaim */
+static struct page *alloc_demote_page(struct page *page, unsigned long node)
+{
+	if (unlikely(PageHuge(page)))
+		/* HugeTLB demotion is not supported for now */
+		BUG();
+	else if (PageTransHuge(page)) {
+		struct page *thp;
+
+		thp = alloc_pages_node(node, GFP_TRANSHUGE_DEMOTE,
+				       HPAGE_PMD_ORDER);
+		if (!thp)
+			return NULL;
+		prep_transhuge_page(thp);
+		return thp;
+	} else
+		return __alloc_pages_node(node, GFP_DEMOTE, 0);
+}
+#else
+static inline struct page *alloc_demote_page(struct page *page,
+					     unsigned long node)
+{
+	return NULL;
+}
+#endif
+
+static inline bool is_demote_ok(int nid)
+{
+	/* Just do demotion with migrate mode of node reclaim */
+	if (!(node_reclaim_mode & RECLAIM_MIGRATE))
+		return false;
+
+	/* Current node is cpuless node */
+	if (!node_state(nid, N_CPU_MEM))
+		return false;
+
+	/* No online migration target node */
+	if (!has_migration_target_node_online())
+		return false;
+
+	return true;
+}
+
 /*
  * shrink_page_list() returns the number of reclaimed pages
  */
@@ -1106,6 +1155,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 {
 	LIST_HEAD(ret_pages);
 	LIST_HEAD(free_pages);
+	LIST_HEAD(demote_pages);
 	unsigned nr_reclaimed = 0;
 	unsigned pgactivate = 0;
 
@@ -1269,6 +1319,18 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 */
 		if (PageAnon(page) && PageSwapBacked(page)) {
 			if (!PageSwapCache(page)) {
+				/*
+				 * Demote anonymous pages only for now and
+				 * skip MADV_FREE pages.
+				 *
+				 * Demotion only happen from primary nodes
+				 * to cpuless nodes.
+				 */
+				if (is_demote_ok(page_to_nid(page))) {
+					list_add(&page->lru, &demote_pages);
+					unlock_page(page);
+					continue;
+				}
 				if (!(sc->gfp_mask & __GFP_IO))
 					goto keep_locked;
 				if (PageTransHuge(page)) {
@@ -1480,6 +1542,30 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		VM_BUG_ON_PAGE(PageLRU(page) || PageUnevictable(page), page);
 	}
 
+	/* Demote pages to migration target */
+	if (!list_empty(&demote_pages)) {
+		int err, target_nid;
+		unsigned int nr_succeeded = 0;
+		nodemask_t used_mask;
+
+		nodes_clear(used_mask);
+		target_nid = find_next_best_node(pgdat->node_id, &used_mask,
+						 true);
+
+		/* Demotion would ignore all cpuset and mempolicy settings */
+		err = migrate_pages(&demote_pages, alloc_demote_page, NULL,
+				    target_nid, MIGRATE_ASYNC, MR_DEMOTE,
+				    &nr_succeeded);
+
+		nr_reclaimed += nr_succeeded;
+
+		if (err) {
+			putback_movable_pages(&demote_pages);
+
+			list_splice(&ret_pages, &demote_pages);
+		}
+	}
+
 	mem_cgroup_uncharge_list(&free_pages);
 	try_to_unmap_flush();
 	free_unref_page_list(&free_pages);
@@ -2136,10 +2222,11 @@ static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
 	unsigned long gb;
 
 	/*
-	 * If we don't have swap space, anonymous page deactivation
-	 * is pointless.
+	 * If we don't have swap space or migtation target node online,
+	 * anonymous page deactivation is pointless.
 	 */
-	if (!file && !total_swap_pages)
+	if (!file && !total_swap_pages &&
+	    !is_demote_ok(pgdat->node_id))
 		return false;
 
 	inactive = lruvec_lru_size(lruvec, inactive_lru, sc->reclaim_idx);
@@ -2213,22 +2300,34 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	unsigned long ap, fp;
 	enum lru_list lru;
 
-	/* If we have no swap space, do not bother scanning anon pages. */
-	if (!sc->may_swap || mem_cgroup_get_nr_swap_pages(memcg) <= 0) {
-		scan_balance = SCAN_FILE;
-		goto out;
-	}
-
 	/*
-	 * Global reclaim will swap to prevent OOM even with no
-	 * swappiness, but memcg users want to use this knob to
-	 * disable swapping for individual groups completely when
-	 * using the memory controller's swap limit feature would be
-	 * too expensive.
+	 * Anon pages can be demoted to PMEM. If there is PMEM node online,
+	 * still scan anonymous LRU even though the systme is swapless or
+	 * swapping is disabled by memcg.
+	 *
+	 * If current node is already PMEM node, demotion is not applicable.
 	 */
-	if (!global_reclaim(sc) && !swappiness) {
-		scan_balance = SCAN_FILE;
-		goto out;
+	if (!is_demote_ok(pgdat->node_id)) {
+		/*
+		 * If we have no swap space, do not bother scanning
+		 * anon pages.
+		 */
+		if (!sc->may_swap || mem_cgroup_get_nr_swap_pages(memcg) <= 0) {
+			scan_balance = SCAN_FILE;
+			goto out;
+		}
+
+		/*
+		 * Global reclaim will swap to prevent OOM even with no
+		 * swappiness, but memcg users want to use this knob to
+		 * disable swapping for individual groups completely when
+		 * using the memory controller's swap limit feature would be
+		 * too expensive.
+		 */
+		if (!global_reclaim(sc) && !swappiness) {
+			scan_balance = SCAN_FILE;
+			goto out;
+		}
 	}
 
 	/*
@@ -2577,7 +2676,7 @@ static inline bool should_continue_reclaim(struct pglist_data *pgdat,
 	 */
 	pages_for_compaction = compact_gap(sc->order);
 	inactive_lru_pages = node_page_state(pgdat, NR_INACTIVE_FILE);
-	if (get_nr_swap_pages() > 0)
+	if (get_nr_swap_pages() > 0 || is_demote_ok(pgdat->node_id))
 		inactive_lru_pages += node_page_state(pgdat, NR_INACTIVE_ANON);
 	if (sc->nr_reclaimed < pages_for_compaction &&
 			inactive_lru_pages > pages_for_compaction)
@@ -3262,7 +3361,8 @@ static void age_active_anon(struct pglist_data *pgdat,
 {
 	struct mem_cgroup *memcg;
 
-	if (!total_swap_pages)
+	/* Aging anon page as long as demotion is fine */
+	if (!total_swap_pages && !is_demote_ok(pgdat->node_id))
 		return;
 
 	memcg = mem_cgroup_iter(NULL, NULL, NULL);
@@ -4003,11 +4103,6 @@ static int __init kswapd_init(void)
  */
 int node_reclaim_mode __read_mostly;
 
-#define RECLAIM_OFF 0
-#define RECLAIM_ZONE (1<<0)	/* Run shrink_inactive_list on the zone */
-#define RECLAIM_WRITE (1<<1)	/* Writeout pages during reclaim */
-#define RECLAIM_UNMAP (1<<2)	/* Unmap pages during reclaim */
-
 /*
  * Priority for NODE_RECLAIM. This determines the fraction of pages
  * of a node considered for each zone_reclaim. 4 scans 1/16th of
@@ -4084,8 +4179,10 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
 		.gfp_mask = current_gfp_context(gfp_mask),
 		.order = order,
 		.priority = NODE_RECLAIM_PRIORITY,
-		.may_writepage = !!(node_reclaim_mode & RECLAIM_WRITE),
-		.may_unmap = !!(node_reclaim_mode & RECLAIM_UNMAP),
+		.may_writepage = !!((node_reclaim_mode & RECLAIM_WRITE) ||
+				    (node_reclaim_mode & RECLAIM_MIGRATE)),
+		.may_unmap = !!((node_reclaim_mode & RECLAIM_UNMAP) ||
+				(node_reclaim_mode & RECLAIM_MIGRATE)),
 		.may_swap = 1,
 		.reclaim_idx = gfp_zone(gfp_mask),
 	};
@@ -4105,7 +4202,8 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
 	reclaim_state.reclaimed_slab = 0;
 	p->reclaim_state = &reclaim_state;
 
-	if (node_pagecache_reclaimable(pgdat) > pgdat->min_unmapped_pages) {
+	if (node_pagecache_reclaimable(pgdat) > pgdat->min_unmapped_pages ||
+	    (node_reclaim_mode & RECLAIM_MIGRATE)) {
 		/*
 		 * Free memory by calling shrink node with increasing
 		 * priorities until we have enough memory freed.
@@ -4138,9 +4236,12 @@ int node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned int order)
 	 * thrown out if the node is overallocated. So we do not reclaim
 	 * if less than a specified percentage of the node is used by
 	 * unmapped file backed pages.
+	 *
+	 * Migrate mode doesn't care the above restrictions.
 	 */
 	if (node_pagecache_reclaimable(pgdat) <= pgdat->min_unmapped_pages &&
-	    node_page_state(pgdat, NR_SLAB_RECLAIMABLE) <= pgdat->min_slab_pages)
+	    node_page_state(pgdat, NR_SLAB_RECLAIMABLE) <= pgdat->min_slab_pages &&
+	    !(node_reclaim_mode & RECLAIM_MIGRATE))
 		return NODE_RECLAIM_FULL;
 
 	/*
-- 
1.8.3.1


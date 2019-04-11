Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D660C10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 03:58:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 38E212133D
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 03:58:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 38E212133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D7C7D6B0010; Wed, 10 Apr 2019 23:58:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D06476B0266; Wed, 10 Apr 2019 23:58:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BA6D56B0269; Wed, 10 Apr 2019 23:58:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 783406B0010
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 23:58:14 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id p8so3397771pfd.4
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 20:58:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=/lKb2r94b4CHm8hvCuJYyFgwh4EfbW3OAW6MiwwGvc0=;
        b=EFEXJGg5ObT3xO9uASxUOUkAiXRdXtp4N3SnUFacByYKyDsl+Nw6lMOKJgaIVYtDLI
         4f8slym6inr/s84UuuyRnsqRq6HEkbUhL4k2Or+Mn/kJZ0CTH45aeqLEoiXrG0HaUNdl
         s7yFMtEs8N65nK4/nznVF2MdLgX6t+yF4WQ1NjyAh++nDMSvse9PfsQ8XmIIhmfmbjsg
         7CxF02fHtURHQ4Js5qpAdk9uriK7KWW3tqdg06hMtbwACAG0R2GwNClUN0JaNxOwHyzZ
         MxnT5XNwd0U4jqfKAytHvN/ue2tbRQnhv4eoXM+KbyVt7ppe8wewxTlmi+23213GJ5eP
         EDfw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAX6taefUGrzLb1tkEUFJO59vIXd61Hm/gfojdtlSylBaM8/cRx4
	om3UFyRl8gJc+3c37Od66EHL9bcyn045O8VOwVg7sLia3MNY/cQ7WHIonjhHpo2ZAlFQgMp7rSc
	dBe5JgA39PeoCYZZ7fyqdyBsyiUaj+Bkh/8d2D7c0R16dOuYdM38p4Mt2JajRtO2n0A==
X-Received: by 2002:a17:902:f089:: with SMTP id go9mr46154228plb.309.1554955094003;
        Wed, 10 Apr 2019 20:58:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwvbzvlnYdFTLXfXMnRaQWlmy6Ya6lqeh8OAnt5WnwxCplI7TtmGlAMRy3at9AyqOdQLVkt
X-Received: by 2002:a17:902:f089:: with SMTP id go9mr46154116plb.309.1554955091927;
        Wed, 10 Apr 2019 20:58:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554955091; cv=none;
        d=google.com; s=arc-20160816;
        b=NT7j3peLzq0jiAHOLl7X1QkoGk5TpX4FjzymFeHZv7MAZH7ZwXpqEpfjoRloyQSaaR
         n0nYCyCYtbyx0cZ7iZxonlrdao5B0HjCU08/tzhVVP1T8kuTK6wCyYwWfbArdfBjzDTE
         +gpvuKvRsw43FbaEaV8HfO+fb2pBlUxq/NMSOW2OTCz2nr/EJCVbe4kswwuhODy4mAjr
         q9AERe7244moGrocNQNEB2/1y/Ou9kgqBjv/vZOkznqbjS6opk3FoGp5CnFozsHUnAyD
         83+ZGjnORZ+EhDOO19djHR+MoglcUnh8QzmcVFJqUASuRoJJdEyR0j4QThZyPtOfVJKN
         LloA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=/lKb2r94b4CHm8hvCuJYyFgwh4EfbW3OAW6MiwwGvc0=;
        b=A9g87izwEmAuRDS8kKMKqrVnH0NAFL9AWslZdphXA/IrxxM1TAjdbrfSly++h6n7o7
         XGMGcvq2VzGboDY3oLJXS+hfX9M1x0RpnGOx1WGI5be/djYHcPGaTbgn41Md0NmzY8ym
         FJivPRbcFyi/jK+x6jt2+d/lWbxPN8mNk8IicgR50ZxOQhmsSV4m8NGNOTOadb0pxXF3
         cp7XUaGb5966c+liK3S3AJS+NYjcB2jNAkRxWyCLuN+sLOBy/sqfxKIfHCDD6kABK8vx
         oXawVLt1eIu2LRi2O41gQRUoVtAAtBjoA/PPhz6En6LwJ5nxWlTGsdLYflw9u3Ka+s1i
         /Vxw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-56.freemail.mail.aliyun.com (out30-56.freemail.mail.aliyun.com. [115.124.30.56])
        by mx.google.com with ESMTPS id o9si32302785pgv.25.2019.04.10.20.58.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 20:58:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) client-ip=115.124.30.56;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R351e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04394;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=15;SR=0;TI=SMTPD_---0TP0I5rB_1554955031;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TP0I5rB_1554955031)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 11 Apr 2019 11:57:23 +0800
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
Subject: [v2 PATCH 5/9] mm: vmscan: demote anon DRAM pages to PMEM node
Date: Thu, 11 Apr 2019 11:56:55 +0800
Message-Id: <1554955019-29472-6-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Since PMEM provides larger capacity than DRAM and has much lower
access latency than disk, so it is a good choice to use as a middle
tier between DRAM and disk in page reclaim path.

With PMEM nodes, the demotion path of anonymous pages could be:

DRAM -> PMEM -> swap device

This patch demotes anonymous pages only for the time being and demote
THP to PMEM in a whole.  To avoid expensive page reclaim and/or
compaction on PMEM node if there is memory pressure on it, the most
conservative gfp flag is used, which would fail quickly if there is
memory pressure and just wakeup kswapd on failure.  The migrate_pages()
would split THP to migrate one by one as base page upon THP allocation
failure.

Demote pages to the cloest non-DRAM node even though the system is
swapless.  The current logic of page reclaim just scan anon LRU when
swap is on and swappiness is set properly.  Demoting to PMEM doesn't
need care whether swap is available or not.  But, reclaiming from PMEM
still skip anon LRU if swap is not available.

The demotion just happens from DRAM node to its cloest PMEM node.
Demoting to a remote PMEM node or migrating from PMEM to DRAM on reclaim
is not allowed for now.

And, define a new migration reason for demotion, called MR_DEMOTE.
Demote page via async migration to avoid blocking.

Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 include/linux/gfp.h            |  12 ++++
 include/linux/migrate.h        |   1 +
 include/trace/events/migrate.h |   3 +-
 mm/debug.c                     |   1 +
 mm/internal.h                  |  13 +++++
 mm/migrate.c                   |  15 ++++-
 mm/vmscan.c                    | 127 +++++++++++++++++++++++++++++++++++------
 7 files changed, 149 insertions(+), 23 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index fdab7de..57ced51 100644
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
index c0b31b6..cc0d7df 100644
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
index bee4d6c..8c424b5 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -383,6 +383,19 @@ static inline int find_next_best_node(int node, nodemask_t *used_node_mask,
 }
 #endif
 
+static inline bool has_cpuless_node_online(void)
+{
+	nodemask_t nmask;
+
+	nodes_andnot(nmask, node_states[N_MEMORY],
+		     node_states[N_CPU_MEM]);
+
+	if (nodes_empty(nmask))
+		return false;
+
+	return true;
+}
+
 /* mm/util.c */
 void __vma_link_list(struct mm_struct *mm, struct vm_area_struct *vma,
 		struct vm_area_struct *prev, struct rb_node *rb_parent);
diff --git a/mm/migrate.c b/mm/migrate.c
index 84bba47..c97a739 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1001,7 +1001,8 @@ static int move_to_new_page(struct page *newpage, struct page *page,
 }
 
 static int __unmap_and_move(struct page *page, struct page *newpage,
-				int force, enum migrate_mode mode)
+				int force, enum migrate_mode mode,
+				enum migrate_reason reason)
 {
 	int rc = -EAGAIN;
 	int page_was_mapped = 0;
@@ -1138,8 +1139,16 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
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
@@ -1193,7 +1202,7 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 		goto out;
 	}
 
-	rc = __unmap_and_move(page, newpage, force, mode);
+	rc = __unmap_and_move(page, newpage, force, mode, reason);
 	if (rc == MIGRATEPAGE_SUCCESS)
 		set_page_owner_migrate_reason(newpage, reason);
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 0504845..2a96609 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1046,6 +1046,45 @@ static void page_check_dirty_writeback(struct page *page,
 		mapping->a_ops->is_dirty_writeback(page, dirty, writeback);
 }
 
+static inline bool is_demote_ok(int nid)
+{
+	/* Current node is cpuless node */
+	if (!node_state(nid, N_CPU_MEM))
+		return false;
+
+	/* No online PMEM node */
+	if (!has_cpuless_node_online())
+		return false;
+
+	return true;
+}
+
+#ifdef CONFIG_NUMA
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
 /*
  * shrink_page_list() returns the number of reclaimed pages
  */
@@ -1058,6 +1097,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 {
 	LIST_HEAD(ret_pages);
 	LIST_HEAD(free_pages);
+	LIST_HEAD(demote_pages);
 	unsigned nr_reclaimed = 0;
 
 	memset(stat, 0, sizeof(*stat));
@@ -1220,6 +1260,18 @@ static unsigned long shrink_page_list(struct list_head *page_list,
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
@@ -1429,6 +1481,29 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		VM_BUG_ON_PAGE(PageLRU(page) || PageUnevictable(page), page);
 	}
 
+	/* Demote pages to PMEM */
+	if (!list_empty(&demote_pages)) {
+		int err, target_nid;
+		unsigned int nr_succeeded = 0;
+		nodemask_t used_mask;
+
+		nodes_clear(used_mask);
+		target_nid = find_next_best_node(pgdat->node_id, &used_mask,
+						 true);
+
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
@@ -2140,10 +2215,11 @@ static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
 	unsigned long gb;
 
 	/*
-	 * If we don't have swap space, anonymous page deactivation
-	 * is pointless.
+	 * If we don't have swap space or PMEM online, anonymous page
+	 * deactivation is pointless.
 	 */
-	if (!file && !total_swap_pages)
+	if (!file && !total_swap_pages &&
+	    !is_demote_ok(pgdat->node_id))
 		return false;
 
 	inactive = lruvec_lru_size(lruvec, inactive_lru, sc->reclaim_idx);
@@ -2223,22 +2299,34 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
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
@@ -2587,7 +2675,7 @@ static inline bool should_continue_reclaim(struct pglist_data *pgdat,
 	 */
 	pages_for_compaction = compact_gap(sc->order);
 	inactive_lru_pages = node_page_state(pgdat, NR_INACTIVE_FILE);
-	if (get_nr_swap_pages() > 0)
+	if (get_nr_swap_pages() > 0 || is_demote_ok(pgdat->node_id))
 		inactive_lru_pages += node_page_state(pgdat, NR_INACTIVE_ANON);
 	if (sc->nr_reclaimed < pages_for_compaction &&
 			inactive_lru_pages > pages_for_compaction)
@@ -3284,7 +3372,8 @@ static void age_active_anon(struct pglist_data *pgdat,
 {
 	struct mem_cgroup *memcg;
 
-	if (!total_swap_pages)
+	/* Aging anon page as long as demotion is fine */
+	if (!total_swap_pages && !is_demote_ok(pgdat->node_id))
 		return;
 
 	memcg = mem_cgroup_iter(NULL, NULL, NULL);
-- 
1.8.3.1


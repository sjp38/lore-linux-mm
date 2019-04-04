Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0B94C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 02:02:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 444DB20820
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 02:02:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sent.com header.i=@sent.com header.b="MBp3j9bH";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="qkA7/ZD2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 444DB20820
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=sent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 70C636B027B; Wed,  3 Apr 2019 22:01:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 699136B027C; Wed,  3 Apr 2019 22:01:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 51A5E6B027D; Wed,  3 Apr 2019 22:01:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1A2596B027B
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 22:01:54 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id x12so986824qtk.2
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 19:01:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=KCLXIWPn2wPPaX//haXWVGdcpCWLncsANSVaA+4FczE=;
        b=F0W/rJ712XVL1VLIru8ddvMNf4wq/D4H/mvG18z5KdfFLvLSSmo5wl4fybbipP2nf4
         rQQyyIqDsW3CZty8m2jVtRALzc1byxtm4sMV/CFnV7wB1sJTsaJhoO96IGbNGs2K/+60
         rlpfzt5elb9gF0QF1am1XURd8vw02yf1isZp1EqXiX8iwoRP8oIVHbS23jiSjOlIT7Ey
         UhS4dDGMrZgfIkXBnwerQo1wvUZqYp4sQ71jcx0w1TWAhlgw0JHwb1boap2zGLLzBB36
         1C8c1N4T1BtBKBSfBTAG+Yx7UUoIoc/dRYKjxwftNsPtvRvDk7kZUvfrVQljmBc+b7CE
         9ltg==
X-Gm-Message-State: APjAAAV9MTgrdith3I2Vc2H39RSy/AqZDvx3f9XThECuuvP071Z6BGoR
	Srsuh3XJXdwcS9D/8ysy5/TW4OnlcGqFw1lI/NBZK+10vgyzvQLQGQVktOuMtxjypRl2xNlIilk
	2mi5PdrEqU5BkIIzg3Ad10C828zWvQIzWeI0Fy/n6Bz6LlSvkcHlKBoow5FJhxiDeGA==
X-Received: by 2002:a37:a546:: with SMTP id o67mr2965528qke.134.1554343313823;
        Wed, 03 Apr 2019 19:01:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxz56OCkeoQS5oFrRED1H2bKE1d7lrJPxmbbI6WYdtoVuEAZ8TUxRK3oIX5NbRyu8u4+iwI
X-Received: by 2002:a37:a546:: with SMTP id o67mr2965466qke.134.1554343312684;
        Wed, 03 Apr 2019 19:01:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554343312; cv=none;
        d=google.com; s=arc-20160816;
        b=n8ubtybBV9+8iG9AhqZXbYpZrqQU5G4Z+3h407O+tcHFzmKBUca0Yo1RFB6hHx54qw
         Ae1aHvxnAkxag+ZpO5eOKXMEeaE207zK4/yiZFC8hparoR9AY1edxTNhNCBSJk4mhWea
         zEV7grWrvDI9Vb+tRhZViw2LBnen9ZbMrjnNi9kjmY8LHGXvAIJGuBtF3J8Zu4z01PMh
         OmOj5BYlFjWVwnB4OWA7dmbAhorRSbml8VHyB26zhB5Ix91GJ+nUmM7iO3Sn+o133k21
         dypHY0xw4i/9n0vSXDZ72aEMbpJCwVnWsUtB7vgaY3detSVPHpaSQPv1MTSdZAnhgkOx
         EDSw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=KCLXIWPn2wPPaX//haXWVGdcpCWLncsANSVaA+4FczE=;
        b=rMd/0nsx9IlWRUmI0Mx8xczM6KMAmSbbKmDOUmU409UWKW7LmPVua1kaRyz488iiYv
         HzOkoXJCn7OiPvP5VNzOG5rkG1PM/FypxY1Z5Q7sJardQYBdvRLamQIW6tlF0Kx8HCQC
         pQM3Qeqt9wHHlOEmkNz+734FEFrG/KFXQCCa7AE27acPjbXxAvaHS/QiYu0oqBI+WaDv
         Oq/NMamvcXRndgFdAajYMXB4QbNk14vVyVW+7u5poWaaVk/tN0PuQzwZxVVJM8JcGcab
         gfM2yU9/PxZ2lKk5nqcJt+C8Ygl2nhqcKuQ4ibOGg471dkiePtmdLeWu5bNWBweV2aXZ
         uXzQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm3 header.b=MBp3j9bH;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b="qkA7/ZD2";
       spf=pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from out5-smtp.messagingengine.com (out5-smtp.messagingengine.com. [66.111.4.29])
        by mx.google.com with ESMTPS id q47si1194742qvf.4.2019.04.03.19.01.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 19:01:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) client-ip=66.111.4.29;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm3 header.b=MBp3j9bH;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b="qkA7/ZD2";
       spf=pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 6AC0C225E4;
	Wed,  3 Apr 2019 22:01:52 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Wed, 03 Apr 2019 22:01:52 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sent.com; h=from
	:to:cc:subject:date:message-id:in-reply-to:references:reply-to
	:mime-version:content-transfer-encoding; s=fm3; bh=KCLXIWPn2wPPa
	X//haXWVGdcpCWLncsANSVaA+4FczE=; b=MBp3j9bHaCgiDCWMOpc0eYvTzoFNl
	s7ncTpUi6YimkWJAvnpJXe2/pxIoit8B37S2iW96yrfE9kQppfYJ0pwggJs0cmUy
	xB9nKLHyLu2p30mI7rcE3MnP0Sh4qtVRVcJP1RXyuVyhTjdLkS4rwCPrZ5mG6O71
	OuFXXZTTPa4nA10XVB36jkHMifJhn3w0JGZbukdGdEwY+IkeYzDL09uR1Fowdv+M
	qRuTTxsMVJYa+mSnQqEVsi5WPx0ORmn1SBkmcPwbg//2Kf+vRPUcHl5u0w8vYXIf
	4B/J3ziemsBolK4WwIha0UB8jtlu1LNz5bzEouikNurPJSX3S5kWx7Nmw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=KCLXIWPn2wPPaX//haXWVGdcpCWLncsANSVaA+4FczE=; b=qkA7/ZD2
	BwJSpBIjr3CaPbOcDkKoKiLpDUkEkU9dcNfFob2cHnp678IE9w9gJLV/gj9qLvSn
	oFrkoEAHO+3J19psvJpUD2SZtW6j6MQ9l5VPh5PbNIuatOdH9CN+ZtW+SG2n1gcn
	vglhxwxtIwEy3RRqsoN/Z49KbgQzzY5ZOJoWrAIASga+CzSfhjuuAItExIbh/QII
	Nnu00rv4J6PuSESCkSLUexyqIFd8JWoSJc8dyvlEyigjWg4ETm4SrTD282za36Gi
	ndcy1l5Fl6rcFdF5iysSdfmopADJ5KfQnmmbnuxGPG+6gGiJtrKwB1KFi6p7K4lT
	oibgye0lHPX39Q==
X-ME-Sender: <xms:kGWlXHizyVJ8E7yZbxNtnDt-3yo_hfpSXP9o1q2JxZ0fPbvDWI_CLA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrtdeggdehudculddtuddrgedutddrtddtmd
    cutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdp
    uffrtefokffrpgfnqfghnecuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivg
    hnthhsucdlqddutddtmdenucfjughrpefhvffufffkofgjfhhrggfgsedtkeertdertddt
    necuhfhrohhmpegkihcujggrnhcuoeiiihdrhigrnhesshgvnhhtrdgtohhmqeenucfkph
    epvdduiedrvddvkedrudduvddrvddvnecurfgrrhgrmhepmhgrihhlfhhrohhmpeiiihdr
    higrnhesshgvnhhtrdgtohhmnecuvehluhhsthgvrhfuihiivgepvddu
X-ME-Proxy: <xmx:kGWlXF6irVzBaekNnZjU8djm101xOTs8wkv21QD2BWxOtklunBL3xw>
    <xmx:kGWlXLvSNrOzVp-5jBR0GVU7z36TTLkbbP3n6lhYdCepoe248LlS8Q>
    <xmx:kGWlXCwEeZET18Rh8_gcpMyr4Y6e_V5ZWXCgz8X_6IGmTRg8WPytrw>
    <xmx:kGWlXIXNaZCkjKwtUMD3Ai5Go7gWviEIwDy-3It2GKSJZwNFKqjh_g>
Received: from nvrsysarch5.nvidia.com (thunderhill.nvidia.com [216.228.112.22])
	by mail.messagingengine.com (Postfix) with ESMTPA id 7306E10319;
	Wed,  3 Apr 2019 22:01:50 -0400 (EDT)
From: Zi Yan <zi.yan@sent.com>
To: Dave Hansen <dave.hansen@linux.intel.com>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	Keith Busch <keith.busch@intel.com>,
	Fengguang Wu <fengguang.wu@intel.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>,
	Michal Hocko <mhocko@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Mel Gorman <mgorman@techsingularity.net>,
	John Hubbard <jhubbard@nvidia.com>,
	Mark Hairgrove <mhairgrove@nvidia.com>,
	Nitin Gupta <nigupta@nvidia.com>,
	Javier Cabezas <jcabezas@nvidia.com>,
	David Nellans <dnellans@nvidia.com>,
	Zi Yan <ziy@nvidia.com>
Subject: [RFC PATCH 22/25] memory manage: active/inactive page list manipulation in memcg.
Date: Wed,  3 Apr 2019 19:00:43 -0700
Message-Id: <20190404020046.32741-23-zi.yan@sent.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190404020046.32741-1-zi.yan@sent.com>
References: <20190404020046.32741-1-zi.yan@sent.com>
Reply-To: ziy@nvidia.com
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Zi Yan <ziy@nvidia.com>

The syscall allows users to trigger page list scanning to actively
move pages between active/inactive lists according to page
references. This is limited to the memcg which the process belongs
to. It would not impact the global LRU lists, which is the root
memcg.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 include/uapi/linux/mempolicy.h |  1 +
 mm/internal.h                  | 93 +++++++++++++++++++++++++++++++++++++++++-
 mm/memory_manage.c             | 76 +++++++++++++++++++++++++++++++++-
 mm/vmscan.c                    | 90 ++++++++--------------------------------
 4 files changed, 184 insertions(+), 76 deletions(-)

diff --git a/include/uapi/linux/mempolicy.h b/include/uapi/linux/mempolicy.h
index 4722bb7..dac474a 100644
--- a/include/uapi/linux/mempolicy.h
+++ b/include/uapi/linux/mempolicy.h
@@ -53,6 +53,7 @@ enum {
 #define MPOL_MF_MOVE_MT  (1<<6)	/* Use multi-threaded page copy routine */
 #define MPOL_MF_MOVE_CONCUR  (1<<7)	/* Move pages in a batch */
 #define MPOL_MF_EXCHANGE	(1<<8)	/* Exchange pages */
+#define MPOL_MF_SHRINK_LISTS	(1<<9)	/* Exchange pages */
 
 #define MPOL_MF_VALID	(MPOL_MF_STRICT   | 	\
 			 MPOL_MF_MOVE     | 	\
diff --git a/mm/internal.h b/mm/internal.h
index 94feb14..eec88de 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -564,7 +564,7 @@ extern int copy_page_lists_mt(struct page **to,
 extern int exchange_page_mthread(struct page *to, struct page *from,
 			int nr_pages);
 extern int exchange_page_lists_mthread(struct page **to,
-						  struct page **from, 
+						  struct page **from,
 						  int nr_pages);
 
 extern int exchange_two_pages(struct page *page1, struct page *page2);
@@ -577,4 +577,95 @@ int expected_page_refs(struct address_space *mapping, struct page *page);
 int get_nodes(nodemask_t *nodes, const unsigned long __user *nmask,
 		     unsigned long maxnode);
 
+unsigned move_active_pages_to_lru(struct lruvec *lruvec,
+				     struct list_head *list,
+				     struct list_head *pages_to_free,
+				     enum lru_list lru);
+void putback_inactive_pages(struct lruvec *lruvec, struct list_head *page_list);
+
+struct scan_control {
+	/* How many pages shrink_list() should reclaim */
+	unsigned long nr_to_reclaim;
+
+	/*
+	 * Nodemask of nodes allowed by the caller. If NULL, all nodes
+	 * are scanned.
+	 */
+	nodemask_t	*nodemask;
+
+	/*
+	 * The memory cgroup that hit its limit and as a result is the
+	 * primary target of this reclaim invocation.
+	 */
+	struct mem_cgroup *target_mem_cgroup;
+
+	/* Writepage batching in laptop mode; RECLAIM_WRITE */
+	unsigned int may_writepage:1;
+
+	/* Can mapped pages be reclaimed? */
+	unsigned int may_unmap:1;
+
+	/* Can pages be swapped as part of reclaim? */
+	unsigned int may_swap:1;
+
+	/* e.g. boosted watermark reclaim leaves slabs alone */
+	unsigned int may_shrinkslab:1;
+
+	/*
+	 * Cgroups are not reclaimed below their configured memory.low,
+	 * unless we threaten to OOM. If any cgroups are skipped due to
+	 * memory.low and nothing was reclaimed, go back for memory.low.
+	 */
+	unsigned int memcg_low_reclaim:1;
+	unsigned int memcg_low_skipped:1;
+
+	unsigned int hibernation_mode:1;
+
+	/* One of the zones is ready for compaction */
+	unsigned int compaction_ready:1;
+
+	unsigned int isolate_only_huge_page:1;
+	unsigned int isolate_only_base_page:1;
+	unsigned int no_reclaim:1;
+
+	/* Allocation order */
+	s8 order;
+
+	/* Scan (total_size >> priority) pages at once */
+	s8 priority;
+
+	/* The highest zone to isolate pages for reclaim from */
+	s8 reclaim_idx;
+
+	/* This context's GFP mask */
+	gfp_t gfp_mask;
+
+	/* Incremented by the number of inactive pages that were scanned */
+	unsigned long nr_scanned;
+
+	/* Number of pages freed so far during a call to shrink_zones() */
+	unsigned long nr_reclaimed;
+
+	struct {
+		unsigned int dirty;
+		unsigned int unqueued_dirty;
+		unsigned int congested;
+		unsigned int writeback;
+		unsigned int immediate;
+		unsigned int file_taken;
+		unsigned int taken;
+	} nr;
+};
+
+unsigned long isolate_lru_pages(unsigned long nr_to_scan,
+		struct lruvec *lruvec, struct list_head *dst,
+		unsigned long *nr_scanned, struct scan_control *sc,
+		enum lru_list lru);
+void shrink_active_list(unsigned long nr_to_scan,
+			       struct lruvec *lruvec,
+			       struct scan_control *sc,
+			       enum lru_list lru);
+unsigned long shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
+		     struct scan_control *sc, enum lru_list lru);
+
 #endif	/* __MM_INTERNAL_H */
diff --git a/mm/memory_manage.c b/mm/memory_manage.c
index b8f3654..e8dddbf 100644
--- a/mm/memory_manage.c
+++ b/mm/memory_manage.c
@@ -5,13 +5,79 @@
 #include <linux/sched/mm.h>
 #include <linux/cpuset.h>
 #include <linux/mempolicy.h>
+#include <linux/memcontrol.h>
+#include <linux/mm_inline.h>
 #include <linux/nodemask.h>
+#include <linux/rmap.h>
 #include <linux/security.h>
+#include <linux/swap.h>
 #include <linux/syscalls.h>
 
 #include "internal.h"
 
 
+static unsigned long shrink_lists_node_memcg(pg_data_t *pgdat,
+	struct mem_cgroup *memcg, unsigned long nr_to_scan)
+{
+	struct lruvec *lruvec = mem_cgroup_lruvec(pgdat, memcg);
+	enum lru_list lru;
+
+	for_each_evictable_lru(lru) {
+		unsigned long nr_to_scan_local = lruvec_size_memcg_node(lru, memcg,
+				pgdat->node_id) / 2;
+		struct scan_control sc = {.may_unmap = 1, .no_reclaim = 1};
+		/*nr_reclaimed += shrink_list(lru, nr_to_scan, lruvec, memcg, sc);*/
+		/*
+		 * for slow node, we want active list, we start from the top of
+		 * the active list. For pages in the bottom of
+		 * the inactive list, we can place it to the top of inactive list
+		 */
+		/*
+		 * for fast node, we want inactive list, we start from the bottom of
+		 * the inactive list. For pages in the active list, we just keep them.
+		 */
+		/*
+		 * A key question is how many pages to scan each time, and what criteria
+		 * to use to move pages between active/inactive page lists.
+		 *  */
+		if (is_active_lru(lru))
+			shrink_active_list(nr_to_scan_local, lruvec, &sc, lru);
+		else
+			shrink_inactive_list(nr_to_scan_local, lruvec, &sc, lru);
+	}
+	cond_resched();
+
+	return 0;
+}
+
+static int shrink_lists(struct task_struct *p, struct mm_struct *mm,
+		const nodemask_t *slow, const nodemask_t *fast, unsigned long nr_to_scan)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_task(p);
+	int slow_nid, fast_nid;
+	int err = 0;
+
+	if (!memcg)
+		return 0;
+	/* Let's handle simplest situation first */
+	if (!(nodes_weight(*slow) == 1 && nodes_weight(*fast) == 1))
+		return 0;
+
+	if (memcg == root_mem_cgroup)
+		return 0;
+
+	slow_nid = first_node(*slow);
+	fast_nid = first_node(*fast);
+
+	/* move pages between page lists in slow node */
+	shrink_lists_node_memcg(NODE_DATA(slow_nid), memcg, nr_to_scan);
+
+	/* move pages between page lists in fast node */
+	shrink_lists_node_memcg(NODE_DATA(fast_nid), memcg, nr_to_scan);
+
+	return err;
+}
+
 SYSCALL_DEFINE6(mm_manage, pid_t, pid, unsigned long, nr_pages,
 		unsigned long, maxnode,
 		const unsigned long __user *, slow_nodes,
@@ -42,10 +108,14 @@ SYSCALL_DEFINE6(mm_manage, pid_t, pid, unsigned long, nr_pages,
 		goto out;
 
 	/* Check flags */
-	if (flags & ~(MPOL_MF_MOVE_MT|
+	if (flags & ~(
+				  MPOL_MF_MOVE|
+				  MPOL_MF_MOVE_MT|
 				  MPOL_MF_MOVE_DMA|
 				  MPOL_MF_MOVE_CONCUR|
-				  MPOL_MF_EXCHANGE))
+				  MPOL_MF_EXCHANGE|
+				  MPOL_MF_SHRINK_LISTS|
+				  MPOL_MF_MOVE_ALL))
 		return -EINVAL;
 
 	/* Find the mm_struct */
@@ -94,6 +164,8 @@ SYSCALL_DEFINE6(mm_manage, pid_t, pid, unsigned long, nr_pages,
 		set_bit(MMF_MM_MANAGE, &mm->flags);
 	}
 
+	if (flags & MPOL_MF_SHRINK_LISTS)
+		shrink_lists(task, mm, slow, fast, nr_pages);
 
 	clear_bit(MMF_MM_MANAGE, &mm->flags);
 	mmput(mm);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 1d539d6..3693550 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -63,75 +63,6 @@
 #define CREATE_TRACE_POINTS
 #include <trace/events/vmscan.h>
 
-struct scan_control {
-	/* How many pages shrink_list() should reclaim */
-	unsigned long nr_to_reclaim;
-
-	/*
-	 * Nodemask of nodes allowed by the caller. If NULL, all nodes
-	 * are scanned.
-	 */
-	nodemask_t	*nodemask;
-
-	/*
-	 * The memory cgroup that hit its limit and as a result is the
-	 * primary target of this reclaim invocation.
-	 */
-	struct mem_cgroup *target_mem_cgroup;
-
-	/* Writepage batching in laptop mode; RECLAIM_WRITE */
-	unsigned int may_writepage:1;
-
-	/* Can mapped pages be reclaimed? */
-	unsigned int may_unmap:1;
-
-	/* Can pages be swapped as part of reclaim? */
-	unsigned int may_swap:1;
-
-	/* e.g. boosted watermark reclaim leaves slabs alone */
-	unsigned int may_shrinkslab:1;
-
-	/*
-	 * Cgroups are not reclaimed below their configured memory.low,
-	 * unless we threaten to OOM. If any cgroups are skipped due to
-	 * memory.low and nothing was reclaimed, go back for memory.low.
-	 */
-	unsigned int memcg_low_reclaim:1;
-	unsigned int memcg_low_skipped:1;
-
-	unsigned int hibernation_mode:1;
-
-	/* One of the zones is ready for compaction */
-	unsigned int compaction_ready:1;
-
-	/* Allocation order */
-	s8 order;
-
-	/* Scan (total_size >> priority) pages at once */
-	s8 priority;
-
-	/* The highest zone to isolate pages for reclaim from */
-	s8 reclaim_idx;
-
-	/* This context's GFP mask */
-	gfp_t gfp_mask;
-
-	/* Incremented by the number of inactive pages that were scanned */
-	unsigned long nr_scanned;
-
-	/* Number of pages freed so far during a call to shrink_zones() */
-	unsigned long nr_reclaimed;
-
-	struct {
-		unsigned int dirty;
-		unsigned int unqueued_dirty;
-		unsigned int congested;
-		unsigned int writeback;
-		unsigned int immediate;
-		unsigned int file_taken;
-		unsigned int taken;
-	} nr;
-};
 
 #ifdef ARCH_HAS_PREFETCH
 #define prefetch_prev_lru_page(_page, _base, _field)			\
@@ -1261,6 +1192,13 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			; /* try to reclaim the page below */
 		}
 
+		/* We keep the page in inactive list for migration in the next
+		 * step */
+		if (sc->no_reclaim) {
+			stat->nr_ref_keep++;
+			goto keep_locked;
+		}
+
 		/*
 		 * Anonymous process memory has backing store?
 		 * Try to allocate it some swap space here.
@@ -1613,7 +1551,7 @@ int __isolate_lru_page(struct page *page, isolate_mode_t mode)
  *
  * returns how many pages were moved onto *@dst.
  */
-static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
+unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		struct lruvec *lruvec, struct list_head *dst,
 		unsigned long *nr_scanned, struct scan_control *sc,
 		enum lru_list lru)
@@ -1634,6 +1572,13 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		struct page *page;
 
 		page = lru_to_page(src);
+		nr_pages = hpage_nr_pages(page);
+
+		if (sc->isolate_only_base_page && nr_pages != 1)
+			continue;
+		if (sc->isolate_only_huge_page && nr_pages == 1)
+			continue;
+
 		prefetchw_prev_lru_page(page, src, flags);
 
 		VM_BUG_ON_PAGE(!PageLRU(page), page);
@@ -1653,7 +1598,6 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		scan++;
 		switch (__isolate_lru_page(page, mode)) {
 		case 0:
-			nr_pages = hpage_nr_pages(page);
 			nr_taken += nr_pages;
 			nr_zone_taken[page_zonenum(page)] += nr_pages;
 			list_move(&page->lru, dst);
@@ -1855,7 +1799,7 @@ static int current_may_throttle(void)
  * shrink_inactive_list() is a helper for shrink_node().  It returns the number
  * of reclaimed pages
  */
-static noinline_for_stack unsigned long
+noinline_for_stack unsigned long
 shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 		     struct scan_control *sc, enum lru_list lru)
 {
@@ -2029,7 +1973,7 @@ unsigned move_active_pages_to_lru(struct lruvec *lruvec,
 	return nr_moved;
 }
 
-static void shrink_active_list(unsigned long nr_to_scan,
+void shrink_active_list(unsigned long nr_to_scan,
 			       struct lruvec *lruvec,
 			       struct scan_control *sc,
 			       enum lru_list lru)
-- 
2.7.4


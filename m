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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 391EBC4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 02:02:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C7D7820820
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 02:02:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sent.com header.i=@sent.com header.b="rm2vS3tR";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="qgwfMbcI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C7D7820820
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=sent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 70E396B027C; Wed,  3 Apr 2019 22:01:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 696CB6B027D; Wed,  3 Apr 2019 22:01:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 55D246B027E; Wed,  3 Apr 2019 22:01:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 30E146B027C
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 22:01:56 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id b188so929648qkg.15
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 19:01:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=K0zKEQYNg9vA6LlAqXa0LlxwYDj+DZBEdtgFhqGYyMM=;
        b=goAOR2K2PCR9BWVBb7IhskAbvCxc+O74T02TOW6LSHC1+4djypMdbIiofCoFeo2QHL
         rbbvC4ZhOKGPIF3ho4TGSFb4gW7IQhhxD14dv55EOrbhum3DGAanHPuB+3AtjhWIR8n6
         UReyCtj4WpUIynDXcAdlp0lkmhfyWk0bWBbRatnfygwGCsskB20NgzSHhEHCLpHiUhk1
         h+IuR2kXtTNsuCxm+1LcNmsj13BgvLkbdSuP3zp9o/xBye5zJs9/kgx3tPxH/sD+MW/S
         ZGeW6fGOdWmQHfNFnjsKUAmlWEySEgeHJVnxdZg36NRa7bfgsjficCMGJ6Quverer9eh
         Z2Yg==
X-Gm-Message-State: APjAAAXA35RqT1GUh1gs7s5tlyMV3wLao92YF631aafpVCE0d/B/rn10
	Z3onxkEC59GblF6h+xSMU748ppZTmX0yfzsRHtTUqqTSC0a/mGroAybN4n4gBVu02U7O/LoCfJL
	KJe9ddU4ch6ShXapeMsT/lw7joTwJaSAXLVAuFLopqjPpTa5ip3H7f3pqKwTtrorOBw==
X-Received: by 2002:a0c:d28f:: with SMTP id q15mr2523038qvh.185.1554343315927;
        Wed, 03 Apr 2019 19:01:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyMK//Rilg8xxhxjVSSKoTeQ3jAhCIaSAx6s1yiH1RQbw3fDt0VKOkF04FZW3Cw0ESWSHcg
X-Received: by 2002:a0c:d28f:: with SMTP id q15mr2522968qvh.185.1554343314476;
        Wed, 03 Apr 2019 19:01:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554343314; cv=none;
        d=google.com; s=arc-20160816;
        b=C0ZkODxFNiSAlcTtoi5JuHQeUhZBDIFdNRlPQJ1/cDvb7xaItrBatPu2G+sUPvz7UB
         XHiAlFQD30kObYtAVbtBTiIOyKMAbPNmGVL0Zrb+/xzdZ162eUSyOHvNgnQ8O3biEOKm
         NZPQ0QKEKB2PM7ZKX1dDlDZWZkj4M2CyyWSKm6gwFMqgAGmEoycrXnGPBL9QJlugB4Bp
         YpSg+9eNIRopXhwkVURDbqC9FMjqucmdSblkmUZPyD+ypEDnP3rQ0YXIRNBabwgVN8jV
         4S4X9jsly7vVrDkeopFwM5wldkXP16q9cOF+IjjfuFOYbKI0Pg6So2EpHHRbbXdSI//P
         e2EA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=K0zKEQYNg9vA6LlAqXa0LlxwYDj+DZBEdtgFhqGYyMM=;
        b=rN2xhY15osGLaCKFg7PsINVBvwvKHxStKxNLQnnGpugIcKzX7TliK2FO4ou8nvnW6J
         gzdcv/8uYond2HeFF2cvA/0ab9KoWmPtJ4mzjJnZZka9mFxZCWvLIO/sgbUkEMF3xMfB
         qDKyevrXYbqqUlHcZ/t64sdTpgW24iGqzHDBPXiGx6WFy4m4lGJoSYVRyZTkOlnczcOv
         ZML5JMEAVvUOoiu6KqaTiCfF9XklNQLfxSgspgFsw6UCoBM0YmExvUhcHfCAc234lC9/
         e+QnVwKcGJfIzJhAJEdrnGYnmAZnh4Ot7Jk3fzUqUX+JlerVlya8wxyTAjuSQyAlzH0M
         md9w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm3 header.b=rm2vS3tR;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=qgwfMbcI;
       spf=pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from out5-smtp.messagingengine.com (out5-smtp.messagingengine.com. [66.111.4.29])
        by mx.google.com with ESMTPS id v24si1897430qth.193.2019.04.03.19.01.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 19:01:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) client-ip=66.111.4.29;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm3 header.b=rm2vS3tR;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=qgwfMbcI;
       spf=pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 248E822540;
	Wed,  3 Apr 2019 22:01:54 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Wed, 03 Apr 2019 22:01:54 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sent.com; h=from
	:to:cc:subject:date:message-id:in-reply-to:references:reply-to
	:mime-version:content-transfer-encoding; s=fm3; bh=K0zKEQYNg9vA6
	LlAqXa0LlxwYDj+DZBEdtgFhqGYyMM=; b=rm2vS3tR5QUYYMFHtm8drYY7K3zaL
	sGwtg1jQk5nmv9aRvOn2yTFkVZMbcmx2noGILAdtXSJQKJZhGXVj475iLEw1Vhwo
	cEaHc2UwdMeekVirdkE0dRaABzomvqv1NwGXHSJy5BTKzF7t/O+NWKwth2p31Va+
	aVdoA7juNsP/FGYEdxktwlzwhFPnwrUQxZ7GS7gJSNlLQcoewZake+DQCwIieR6E
	rUsgFHjpfRpqRR291tNhpmNM5a3ppbhUG1oPxajV5NwmObv5/hHGJbhbdjhuRh7v
	U55/Yd9cmsIG2mKLqhT9CyoABkBqdB/YgSS59KAncLVmW/wUS67k1Ezcg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=K0zKEQYNg9vA6LlAqXa0LlxwYDj+DZBEdtgFhqGYyMM=; b=qgwfMbcI
	eBFpaV6MMHzN5rIerjMrDKrbAWBiNNEtFg9eDeybWW7/wCBOzaFqhqHES6LQ3vHq
	/5wNJJIo9YwTCOXPzoe2sxzzynOOn4HIhs+sOQmRXtJ8xTXS2NK1hKA1b8GuOgXG
	/NR4yJ6BTLhqEQtRAnexNhRWE80XHcJL+YaM/9H9tQ2h68lyracLdVumqMymMbej
	jkUwuNchlfU8V9S7Ju78YYN02EDsLJKB4XYmAcjwjnHUvUSP3WuoGso4mU1mEXXB
	wM84Dh5ud02Zhvx8CQ/66sz/7W0L/DmwQxnwvlZSqJZ3r2WaRTfdnEVjnUphhSf0
	jajSPBQ7AP5RTA==
X-ME-Sender: <xms:kWWlXEs5Dq_JMO7cybYJO6ksoCaKsxMCSjWpBJigsEqPhMg2WCQkGA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrtdeggdehudculddtuddrgedutddrtddtmd
    cutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdp
    uffrtefokffrpgfnqfghnecuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivg
    hnthhsucdlqddutddtmdenucfjughrpefhvffufffkofgjfhhrggfgsedtkeertdertddt
    necuhfhrohhmpegkihcujggrnhcuoeiiihdrhigrnhesshgvnhhtrdgtohhmqeenucfkph
    epvdduiedrvddvkedrudduvddrvddvnecurfgrrhgrmhepmhgrihhlfhhrohhmpeiiihdr
    higrnhesshgvnhhtrdgtohhmnecuvehluhhsthgvrhfuihiivgepvddu
X-ME-Proxy: <xmx:kWWlXFu80Myacqe5Y92e45_25KuGyiBFI55Ciwf14p6XcZcsJCd0ew>
    <xmx:kWWlXKzhqA0Eevizp4Tun2j8HHmFvMlCTiBhORmDDx7zWKVNviEovQ>
    <xmx:kWWlXLinN82foMVnpT-C-usELmyZaUy4cLvHjdyYAu9mX9modxYzgA>
    <xmx:kmWlXJ04_JKiIOGYPEP97vn9M5yq1QNNWx97C4YU-l7BdCpSeUZf3w>
Received: from nvrsysarch5.nvidia.com (thunderhill.nvidia.com [216.228.112.22])
	by mail.messagingengine.com (Postfix) with ESMTPA id 222CA1030F;
	Wed,  3 Apr 2019 22:01:52 -0400 (EDT)
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
Subject: [RFC PATCH 23/25] memory manage: page migration based page manipulation between NUMA nodes.
Date: Wed,  3 Apr 2019 19:00:44 -0700
Message-Id: <20190404020046.32741-24-zi.yan@sent.com>
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

Users are expected to set memcg max size to reflect their memory
resource allocation policy. The syscall simply migrates pages belong
to the application's memcg between from_node to to_node, where
from_node is considered fast memory and to_node is considered slow
memory. In common cases, active(hot) pages are migrated from to_node
to from_node and inactive(cold) pages are migrated from from_node to
to_node.

Separate migration for base pages and huge pages to achieve high
throughput.

1. They are migrated via different calls.
2. 4KB base pages are not transferred via multi-threaded.
3. All pages are migrated together if no optimization is used.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 mm/memory_manage.c | 275 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 275 insertions(+)

diff --git a/mm/memory_manage.c b/mm/memory_manage.c
index e8dddbf..d63ad25 100644
--- a/mm/memory_manage.c
+++ b/mm/memory_manage.c
@@ -6,6 +6,7 @@
 #include <linux/cpuset.h>
 #include <linux/mempolicy.h>
 #include <linux/memcontrol.h>
+#include <linux/migrate.h>
 #include <linux/mm_inline.h>
 #include <linux/nodemask.h>
 #include <linux/rmap.h>
@@ -15,6 +16,11 @@
 
 #include "internal.h"
 
+enum isolate_action {
+	ISOLATE_COLD_PAGES = 1,
+	ISOLATE_HOT_PAGES,
+	ISOLATE_HOT_AND_COLD_PAGES,
+};
 
 static unsigned long shrink_lists_node_memcg(pg_data_t *pgdat,
 	struct mem_cgroup *memcg, unsigned long nr_to_scan)
@@ -78,6 +84,272 @@ static int shrink_lists(struct task_struct *p, struct mm_struct *mm,
 	return err;
 }
 
+static unsigned long isolate_pages_from_lru_list(pg_data_t *pgdat,
+		struct mem_cgroup *memcg, unsigned long nr_pages,
+		struct list_head *base_page_list,
+		struct list_head *huge_page_list,
+		unsigned long *nr_taken_base_page,
+		unsigned long *nr_taken_huge_page,
+		enum isolate_action action)
+{
+	struct lruvec *lruvec = mem_cgroup_lruvec(pgdat, memcg);
+	enum lru_list lru;
+	unsigned long nr_all_taken = 0;
+
+	if (nr_pages == ULONG_MAX)
+		nr_pages = memcg_size_node(memcg, pgdat->node_id);
+
+	lru_add_drain_all();
+
+	for_each_evictable_lru(lru) {
+		unsigned long nr_scanned, nr_taken;
+		int file = is_file_lru(lru);
+		struct scan_control sc = {.may_unmap = 1};
+
+		if (action == ISOLATE_COLD_PAGES && is_active_lru(lru))
+			continue;
+		if (action == ISOLATE_HOT_PAGES && !is_active_lru(lru))
+			continue;
+
+		spin_lock_irq(&pgdat->lru_lock);
+
+		/* Isolate base pages */
+		sc.isolate_only_base_page = 1;
+		nr_taken = isolate_lru_pages(nr_pages, lruvec, base_page_list,
+					&nr_scanned, &sc, lru);
+		/* Isolate huge pages */
+		sc.isolate_only_base_page = 0;
+		sc.isolate_only_huge_page = 1;
+		nr_taken += isolate_lru_pages(nr_pages - nr_scanned, lruvec,
+					huge_page_list, &nr_scanned, &sc, lru);
+
+		__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, nr_taken);
+
+		spin_unlock_irq(&pgdat->lru_lock);
+
+		nr_all_taken += nr_taken;
+
+		if (nr_all_taken > nr_pages)
+			break;
+	}
+
+	return nr_all_taken;
+}
+
+static int migrate_to_node(struct list_head *page_list, int nid,
+		enum migrate_mode mode)
+{
+	bool migrate_concur = mode & MIGRATE_CONCUR;
+	int num = 0;
+	int from_nid;
+	int err;
+
+	if (list_empty(page_list))
+		return num;
+
+	from_nid = page_to_nid(list_first_entry(page_list, struct page, lru));
+
+	if (migrate_concur)
+		err = migrate_pages_concur(page_list, alloc_new_node_page,
+			NULL, nid, mode, MR_SYSCALL);
+	else
+		err = migrate_pages(page_list, alloc_new_node_page,
+			NULL, nid, mode, MR_SYSCALL);
+
+	if (err) {
+		struct page *page;
+
+		list_for_each_entry(page, page_list, lru)
+			num += hpage_nr_pages(page);
+		pr_debug("%d pages failed to migrate from %d to %d\n",
+			num, from_nid, nid);
+
+		putback_movable_pages(page_list);
+	}
+	return num;
+}
+
+static inline int _putback_overflow_pages(unsigned long max_nr_pages,
+		struct list_head *page_list, unsigned long *nr_remaining_pages)
+{
+	struct page *page;
+	LIST_HEAD(putback_list);
+
+	if (list_empty(page_list))
+		return max_nr_pages;
+
+	*nr_remaining_pages = 0;
+	/* in case we need to drop the whole list */
+	page = list_first_entry(page_list, struct page, lru);
+	if (max_nr_pages <= (2 * hpage_nr_pages(page))) {
+		max_nr_pages = 0;
+		putback_movable_pages(page_list);
+		goto out;
+	}
+
+	list_for_each_entry(page, page_list, lru) {
+		int nr_pages = hpage_nr_pages(page);
+		/* drop just one more page to avoid using up free space  */
+		if (max_nr_pages <= (2 * nr_pages)) {
+			max_nr_pages = 0;
+			break;
+		}
+		max_nr_pages -= nr_pages;
+		*nr_remaining_pages += nr_pages;
+	}
+
+	/* we did not scan all pages in page_list, we need to put back some */
+	if (&page->lru != page_list) {
+		list_cut_position(&putback_list, page_list, &page->lru);
+		putback_movable_pages(page_list);
+		list_splice(&putback_list, page_list);
+	}
+out:
+	return max_nr_pages;
+}
+
+static int putback_overflow_pages(unsigned long max_nr_base_pages,
+		unsigned long max_nr_huge_pages,
+		long nr_free_pages,
+		struct list_head *base_page_list,
+		struct list_head *huge_page_list,
+		unsigned long *nr_base_pages,
+		unsigned long *nr_huge_pages)
+{
+	if (nr_free_pages < 0) {
+		if ((-nr_free_pages) > max_nr_base_pages) {
+			nr_free_pages += max_nr_base_pages;
+			max_nr_base_pages = 0;
+		}
+
+		if ((-nr_free_pages) > max_nr_huge_pages) {
+			nr_free_pages = 0;
+			max_nr_base_pages = 0;
+		}
+	}
+	/*
+	 * counting pages in page lists and substract the number from max_nr_*
+	 * when max_nr_* go to zero, drop the remaining pages
+	 */
+	max_nr_huge_pages += _putback_overflow_pages(nr_free_pages/2 + max_nr_base_pages,
+			base_page_list, nr_base_pages);
+	return _putback_overflow_pages(nr_free_pages/2 + max_nr_huge_pages,
+			huge_page_list, nr_huge_pages);
+}
+
+static int do_mm_manage(struct task_struct *p, struct mm_struct *mm,
+		const nodemask_t *slow, const nodemask_t *fast,
+		unsigned long nr_pages, int flags)
+{
+	bool migrate_mt = flags & MPOL_MF_MOVE_MT;
+	bool migrate_concur = flags & MPOL_MF_MOVE_CONCUR;
+	bool migrate_dma = flags & MPOL_MF_MOVE_DMA;
+	bool move_hot_and_cold_pages = flags & MPOL_MF_MOVE_ALL;
+	struct mem_cgroup *memcg = mem_cgroup_from_task(p);
+	int err = 0;
+	unsigned long nr_isolated_slow_pages;
+	unsigned long nr_isolated_slow_base_pages = 0;
+	unsigned long nr_isolated_slow_huge_pages = 0;
+	unsigned long nr_isolated_fast_pages;
+	/* in case no migration from to node, we migrate all isolated pages from
+	 * slow node  */
+	unsigned long nr_isolated_fast_base_pages = ULONG_MAX;
+	unsigned long nr_isolated_fast_huge_pages = ULONG_MAX;
+	unsigned long max_nr_pages_fast_node, nr_pages_fast_node;
+	unsigned long nr_pages_slow_node, nr_active_pages_slow_node;
+	long nr_free_pages_fast_node;
+	int slow_nid, fast_nid;
+	enum migrate_mode mode = MIGRATE_SYNC |
+		(migrate_mt ? MIGRATE_MT : MIGRATE_SINGLETHREAD) |
+		(migrate_dma ? MIGRATE_DMA : MIGRATE_SINGLETHREAD) |
+		(migrate_concur ? MIGRATE_CONCUR : MIGRATE_SINGLETHREAD);
+	enum isolate_action isolate_action =
+		move_hot_and_cold_pages?ISOLATE_HOT_AND_COLD_PAGES:ISOLATE_HOT_PAGES;
+	LIST_HEAD(slow_base_page_list);
+	LIST_HEAD(slow_huge_page_list);
+
+	if (!memcg)
+		return 0;
+	/* Let's handle simplest situation first */
+	if (!(nodes_weight(*slow) == 1 && nodes_weight(*fast) == 1))
+		return 0;
+
+	/* Only work on specific cgroup not the global root */
+	if (memcg == root_mem_cgroup)
+		return 0;
+
+	slow_nid = first_node(*slow);
+	fast_nid = first_node(*fast);
+
+	max_nr_pages_fast_node = memcg_max_size_node(memcg, fast_nid);
+	nr_pages_fast_node = memcg_size_node(memcg, fast_nid);
+	nr_active_pages_slow_node = active_inactive_size_memcg_node(memcg,
+			slow_nid, true);
+	nr_pages_slow_node = memcg_size_node(memcg, slow_nid);
+
+	nr_free_pages_fast_node = max_nr_pages_fast_node - nr_pages_fast_node;
+
+	/* do not migrate in more pages than fast node can hold */
+	nr_pages = min_t(unsigned long, max_nr_pages_fast_node, nr_pages);
+	/* do not migrate away more pages than slow node has */
+	nr_pages = min_t(unsigned long, nr_pages_slow_node, nr_pages);
+
+	/* if fast node has enough space, migrate all possible pages in slow node */
+	if (nr_pages != ULONG_MAX &&
+		nr_free_pages_fast_node > 0 &&
+		nr_active_pages_slow_node < nr_free_pages_fast_node) {
+		isolate_action = ISOLATE_HOT_AND_COLD_PAGES;
+	}
+
+	nr_isolated_slow_pages = isolate_pages_from_lru_list(NODE_DATA(slow_nid),
+			memcg, nr_pages, &slow_base_page_list, &slow_huge_page_list,
+			&nr_isolated_slow_base_pages, &nr_isolated_slow_huge_pages,
+			isolate_action);
+
+	if (max_nr_pages_fast_node != ULONG_MAX &&
+		(nr_free_pages_fast_node < 0 ||
+		 nr_free_pages_fast_node < nr_isolated_slow_pages)) {
+		LIST_HEAD(fast_base_page_list);
+		LIST_HEAD(fast_huge_page_list);
+
+		nr_isolated_fast_base_pages = 0;
+		nr_isolated_fast_huge_pages = 0;
+		/* isolate pages on fast node to make space */
+		nr_isolated_fast_pages = isolate_pages_from_lru_list(NODE_DATA(fast_nid),
+			memcg,
+			nr_isolated_slow_pages - nr_free_pages_fast_node,
+			&fast_base_page_list, &fast_huge_page_list,
+			&nr_isolated_fast_base_pages, &nr_isolated_fast_huge_pages,
+			move_hot_and_cold_pages?ISOLATE_HOT_AND_COLD_PAGES:ISOLATE_COLD_PAGES);
+
+		/* Migrate pages to slow node */
+		/* No multi-threaded migration for base pages */
+		nr_isolated_fast_base_pages -=
+			migrate_to_node(&fast_base_page_list, slow_nid, mode & ~MIGRATE_MT);
+
+		nr_isolated_fast_huge_pages -=
+			migrate_to_node(&fast_huge_page_list, slow_nid, mode);
+	}
+
+	if (nr_isolated_fast_base_pages != ULONG_MAX &&
+		nr_isolated_fast_huge_pages != ULONG_MAX)
+		putback_overflow_pages(nr_isolated_fast_base_pages,
+				nr_isolated_fast_huge_pages, nr_free_pages_fast_node,
+				&slow_base_page_list, &slow_huge_page_list,
+				&nr_isolated_slow_base_pages,
+				&nr_isolated_slow_huge_pages);
+
+	/* Migrate pages to fast node */
+	/* No multi-threaded migration for base pages */
+	nr_isolated_slow_base_pages -=
+		migrate_to_node(&slow_base_page_list, fast_nid, mode & ~MIGRATE_MT);
+
+	nr_isolated_slow_huge_pages -=
+		migrate_to_node(&slow_huge_page_list, fast_nid, mode);
+
+	return err;
+}
+
 SYSCALL_DEFINE6(mm_manage, pid_t, pid, unsigned long, nr_pages,
 		unsigned long, maxnode,
 		const unsigned long __user *, slow_nodes,
@@ -167,6 +439,9 @@ SYSCALL_DEFINE6(mm_manage, pid_t, pid, unsigned long, nr_pages,
 	if (flags & MPOL_MF_SHRINK_LISTS)
 		shrink_lists(task, mm, slow, fast, nr_pages);
 
+	if (flags & MPOL_MF_MOVE)
+		err = do_mm_manage(task, mm, slow, fast, nr_pages, flags);
+
 	clear_bit(MMF_MM_MANAGE, &mm->flags);
 	mmput(mm);
 out:
-- 
2.7.4


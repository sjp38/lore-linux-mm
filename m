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
	by smtp.lore.kernel.org (Postfix) with ESMTP id C82DBC4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 02:01:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 504E420820
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 02:01:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sent.com header.i=@sent.com header.b="q6z6NMOG";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="fMkp9+Bf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 504E420820
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=sent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B15D6B0270; Wed,  3 Apr 2019 22:01:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3882F6B0271; Wed,  3 Apr 2019 22:01:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 204D36B0272; Wed,  3 Apr 2019 22:01:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id E4C9B6B0270
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 22:01:37 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id p26so927010qtq.21
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 19:01:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=yK2eUC0I9aY6x1nEEB/U0Fv2Pko7D0eSucs6UTRXLHU=;
        b=oq9kBkMAtYGGXlM6WAv+LBX9UVKIdoNqHfO39ZN93886y5QLBSSOJO54QUXeNScUDP
         eFslZqBIa4FwuOE03mS4YjlxY54sSh3E5bnxPZnZRUenjVcUV7KHc2QgYnj9WbdPHN55
         7AKmR2P67MyiHzOJ1VgFfpOUxgYmO9Su/TgLMeaSj4luJ6gf1xUZHGmww6Wvr4M/PIuY
         yBQorBWN5rarn7L7ZCL1K3qnx8A4inuzYY1GckbUY/otG3B4tft16vQopCGV8+rPGXAR
         ynAMifgpwQvFheq84cWr61Ar5SMRFySd9WAzs6jh8zz10nRxnn8pbaqJNKa+s20l6tiN
         Mdjw==
X-Gm-Message-State: APjAAAXmq3LRN6S88sq5PdL7tIWT6mQcy3+YatdzhInRk3xk3HYuh9En
	AudomjvvH69jHaoMeu6N/MRDfv4Tt2ctUHZZoPiiG0U+rrC6GkldSHdzQuQGIUcOXyRtYdGg2Cm
	XYorEIUSThqidOE7EwYHlte21bdgjYgZi/KbeuiRR7Z57dFTfweKTS7cHFnyn90tfMw==
X-Received: by 2002:ac8:2684:: with SMTP id 4mr3201870qto.67.1554343297634;
        Wed, 03 Apr 2019 19:01:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyx8Sph4kooxcm4kls2eEEZsjqj3rn/Kx/Hico1mTl1Tjz5xUoTVrNh6q51nzzAdgYeYJcV
X-Received: by 2002:ac8:2684:: with SMTP id 4mr3201728qto.67.1554343295775;
        Wed, 03 Apr 2019 19:01:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554343295; cv=none;
        d=google.com; s=arc-20160816;
        b=Quq4L1VlLYDi9Z5743LjRJY1AaBD4q4+d/CqXYbXR7KKihuaVbaoEfLv0WX/bGnKVn
         EJ5ggTKNzvB3O4HhyeJ9LUJdKFJjNWc2vD3B5IYB+sYnrXA+HAA7X7jbi8WWUE+p8+T3
         gqnUcC9zoatTD7B6rB0F0JyozLluMt/BWQM/vzvhUJyjQVbT7hhqtM8+USLMFAB5r8Wy
         c/cJytps4vLw/VDKRveOALIdMBQ089cSGD2it90oLyCsJjKk17JXvONhPUOuVcNx/RtW
         NLJkT/kxB4MB2XnkGcz1fqkLQnvmSXPOo3HKIN0bjHYFcmqKxGgBUlJHG4rDj05yQYrV
         JsGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=yK2eUC0I9aY6x1nEEB/U0Fv2Pko7D0eSucs6UTRXLHU=;
        b=SLaT4tui0nOVotP/Sm6oqYZn2jefI8ZEQfb/W2RfjycVNHb0HFYqE6r1kl4gxI70H4
         FngyTPIApHwrG6UHrQeKHp7iMtQIcU5bEeJVIs52N3AfH8RGWyvkl+YKjOvWUO/KGbY1
         mgYt4Zqar6abc6FlKpCQFcReovuW8P4H8DPbaPzqOlXCODkIRtbvxABdkAddfOvPjBdi
         LXeVEdbUzpdopeyPsPP3ut6SpC1qxNh1G63/uOQO145qPIjtRLLxIRoxObsFtkS3DZbv
         firydxSlSxh71biiZw7uB7Jytj7TKQ9GQNWwsPVNJhanrNXyXJF3pv/JSDRkTSwVndpU
         m/6g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm3 header.b=q6z6NMOG;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=fMkp9+Bf;
       spf=pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from out5-smtp.messagingengine.com (out5-smtp.messagingengine.com. [66.111.4.29])
        by mx.google.com with ESMTPS id i7si2579877qke.204.2019.04.03.19.01.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 19:01:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) client-ip=66.111.4.29;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm3 header.b=q6z6NMOG;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=fMkp9+Bf;
       spf=pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 7C0B222826;
	Wed,  3 Apr 2019 22:01:35 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Wed, 03 Apr 2019 22:01:35 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sent.com; h=from
	:to:cc:subject:date:message-id:in-reply-to:references:reply-to
	:mime-version:content-transfer-encoding; s=fm3; bh=yK2eUC0I9aY6x
	1nEEB/U0Fv2Pko7D0eSucs6UTRXLHU=; b=q6z6NMOGCfnvgFrtoi86cET1Cc2ja
	E3zSKbA6IHmp5gGp9/W95Aj7SnuptDIou0/g1dV6Eksldx/RrUFSBstcIR3BSOHy
	1Js9KXkez7HJ5A1NdiwAJlBfgv3VnPSmmPqXFut3gQ0GtotYnZJpTuYJ7DQ0SQ6E
	itXy+JmonkkrUErFsNPn+/CSYF2mgsP3oFAWvXMCZ1I+Ieh7IMNBX28n1LNh7huu
	vvm3IwC74efbWWYmIDCXKX+QJgeYI5c4F90u8AfCg25T2mi1Q1QcM+mrVMjG/Gq8
	bmk6PfVHqrV+NHavozQdYhqGS7bevriR5W1D0aAzdBa8X5c95IcoMG/mw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=yK2eUC0I9aY6x1nEEB/U0Fv2Pko7D0eSucs6UTRXLHU=; b=fMkp9+Bf
	g/fn2PPQYRra7dNca9xApuTL6t1n8eZ3gOIYDly+suAEQA8lEKFFygEwigy0zthL
	xwbu3jYzsCgT4eQQF02+7OssBKNd1IHIG9t4qjh8fbKMiX26GHVKg9HF/dSoEghv
	venpMBWrAezIbOY0tPVd3HKYPArf85P5bNxKJrHrBVdT+TuS91SDQKMIakHN33cJ
	4tYMDhBYcvBf/d2Tez8VIUtBrmRQ6ciCzSE/GOMYewaw98bsncKpQfn1RpbDRPy9
	12b9DsqPl8BX62zv1UM2qXLl5iGOjD1snFplc7jj3IgfMmsL+X1hdL+TZMX8AR3s
	WN+EjFGnXY8Bcg==
X-ME-Sender: <xms:f2WlXOip0AbUzE6PQWDj_g7X533D52cfhpfxCxENOWgLc9x-NeNQBQ>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrtdeggdehudculddtuddrgedutddrtddtmd
    cutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdp
    uffrtefokffrpgfnqfghnecuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivg
    hnthhsucdlqddutddtmdenucfjughrpefhvffufffkofgjfhhrggfgsedtkeertdertddt
    necuhfhrohhmpegkihcujggrnhcuoeiiihdrhigrnhesshgvnhhtrdgtohhmqeenucfkph
    epvdduiedrvddvkedrudduvddrvddvnecurfgrrhgrmhepmhgrihhlfhhrohhmpeiiihdr
    higrnhesshgvnhhtrdgtohhmnecuvehluhhsthgvrhfuihiivgepuddt
X-ME-Proxy: <xmx:f2WlXMqC_n7jpW0L_YzgXJ1pdwP2_dAZJoxhZnAMfnSPY7rycRQVeQ>
    <xmx:f2WlXNe9T0kTFbgk0iv6rRjhsyLhRz1J-kwM1qshgPX8H9i6-UBg-w>
    <xmx:f2WlXPfK3iFC6_ESBdLD3gBNiYKji_CA3SJNw4daMgGcDduINScpmg>
    <xmx:f2WlXOz2No8RtFPppiKXtBM8qm3wFGvjfszVxpc_re6bAZQKCLxFQQ>
Received: from nvrsysarch5.nvidia.com (thunderhill.nvidia.com [216.228.112.22])
	by mail.messagingengine.com (Postfix) with ESMTPA id 60CC41030F;
	Wed,  3 Apr 2019 22:01:33 -0400 (EDT)
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
Subject: [RFC PATCH 12/25] exchange pages: new page migration mechanism: exchange_pages()
Date: Wed,  3 Apr 2019 19:00:33 -0700
Message-Id: <20190404020046.32741-13-zi.yan@sent.com>
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

It exchanges two pages by unmapping both first, then exchanging the
data of the pages using a u64 register, and finally remapping both
pages.

It saves the overheads of allocating two new pages in two
back-to-back migrate_pages().

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 include/linux/exchange.h |  23 ++
 include/linux/ksm.h      |   4 +
 mm/Makefile              |   1 +
 mm/exchange.c            | 597 +++++++++++++++++++++++++++++++++++++++++++++++
 mm/ksm.c                 |  35 +++
 5 files changed, 660 insertions(+)
 create mode 100644 include/linux/exchange.h
 create mode 100644 mm/exchange.c

diff --git a/include/linux/exchange.h b/include/linux/exchange.h
new file mode 100644
index 0000000..778068e
--- /dev/null
+++ b/include/linux/exchange.h
@@ -0,0 +1,23 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+#ifndef _LINUX_EXCHANGE_H
+#define _LINUX_EXCHANGE_H
+
+#include <linux/migrate.h>
+
+struct exchange_page_info {
+	struct page *from_page;
+	struct page *to_page;
+
+	struct anon_vma *from_anon_vma;
+	struct anon_vma *to_anon_vma;
+
+	int from_page_was_mapped;
+	int to_page_was_mapped;
+
+	struct list_head list;
+};
+
+int exchange_pages(struct list_head *exchange_list,
+			enum migrate_mode mode,
+			int reason);
+#endif /* _LINUX_EXCHANGE_H */
diff --git a/include/linux/ksm.h b/include/linux/ksm.h
index e48b1e4..170312d 100644
--- a/include/linux/ksm.h
+++ b/include/linux/ksm.h
@@ -55,6 +55,7 @@ void rmap_walk_ksm(struct page *page, struct rmap_walk_control *rwc);
 void ksm_migrate_page(struct page *newpage, struct page *oldpage);
 bool reuse_ksm_page(struct page *page,
 			struct vm_area_struct *vma, unsigned long address);
+void ksm_exchange_page(struct page *to_page, struct page *from_page);
 
 #else  /* !CONFIG_KSM */
 
@@ -92,6 +93,9 @@ static inline bool reuse_ksm_page(struct page *page,
 			struct vm_area_struct *vma, unsigned long address)
 {
 	return false;
+static inline void ksm_exchange_page(struct page *to_page,
+				struct page *from_page)
+{
 }
 #endif /* CONFIG_MMU */
 #endif /* !CONFIG_KSM */
diff --git a/mm/Makefile b/mm/Makefile
index fa02a9f..5e6c591 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -45,6 +45,7 @@ obj-y += init-mm.o
 obj-y += memblock.o
 
 obj-y += copy_page.o
+obj-y += exchange.o
 
 ifdef CONFIG_MMU
 	obj-$(CONFIG_ADVISE_SYSCALLS)	+= madvise.o
diff --git a/mm/exchange.c b/mm/exchange.c
new file mode 100644
index 0000000..626bbea
--- /dev/null
+++ b/mm/exchange.c
@@ -0,0 +1,597 @@
+/*
+ * Exchange two in-use pages. Page flags and page->mapping are exchanged
+ * as well. Only anonymous pages are supported.
+ *
+ * Copyright (C) 2016 NVIDIA, Zi Yan <ziy@nvidia.com>
+ *
+ * This work is licensed under the terms of the GNU GPL, version 2.
+ */
+
+#include <linux/syscalls.h>
+#include <linux/migrate.h>
+#include <linux/exchange.h>
+#include <linux/security.h>
+#include <linux/cpuset.h>
+#include <linux/hugetlb.h>
+#include <linux/mm_inline.h>
+#include <linux/page_idle.h>
+#include <linux/page-flags.h>
+#include <linux/ksm.h>
+#include <linux/memcontrol.h>
+#include <linux/balloon_compaction.h>
+#include <linux/buffer_head.h>
+
+
+#include "internal.h"
+
+/*
+ * Move a list of individual pages
+ */
+struct pages_to_node {
+	unsigned long from_addr;
+	int from_status;
+
+	unsigned long to_addr;
+	int to_status;
+};
+
+struct page_flags {
+	unsigned int page_error :1;
+	unsigned int page_referenced:1;
+	unsigned int page_uptodate:1;
+	unsigned int page_active:1;
+	unsigned int page_unevictable:1;
+	unsigned int page_checked:1;
+	unsigned int page_mappedtodisk:1;
+	unsigned int page_dirty:1;
+	unsigned int page_is_young:1;
+	unsigned int page_is_idle:1;
+	unsigned int page_swapcache:1;
+	unsigned int page_writeback:1;
+	unsigned int page_private:1;
+	unsigned int __pad:3;
+};
+
+
+static void exchange_page(char *to, char *from)
+{
+	u64 tmp;
+	int i;
+
+	for (i = 0; i < PAGE_SIZE; i += sizeof(tmp)) {
+		tmp = *((u64*)(from + i));
+		*((u64*)(from + i)) = *((u64*)(to + i));
+		*((u64*)(to + i)) = tmp;
+	}
+}
+
+static inline void exchange_highpage(struct page *to, struct page *from)
+{
+	char *vfrom, *vto;
+
+	vfrom = kmap_atomic(from);
+	vto = kmap_atomic(to);
+	exchange_page(vto, vfrom);
+	kunmap_atomic(vto);
+	kunmap_atomic(vfrom);
+}
+
+static void __exchange_gigantic_page(struct page *dst, struct page *src,
+				int nr_pages)
+{
+	int i;
+	struct page *dst_base = dst;
+	struct page *src_base = src;
+
+	for (i = 0; i < nr_pages; ) {
+		cond_resched();
+		exchange_highpage(dst, src);
+
+		i++;
+		dst = mem_map_next(dst, dst_base, i);
+		src = mem_map_next(src, src_base, i);
+	}
+}
+
+static void exchange_huge_page(struct page *dst, struct page *src)
+{
+	int i;
+	int nr_pages;
+
+	if (PageHuge(src)) {
+		/* hugetlbfs page */
+		struct hstate *h = page_hstate(src);
+		nr_pages = pages_per_huge_page(h);
+
+		if (unlikely(nr_pages > MAX_ORDER_NR_PAGES)) {
+			__exchange_gigantic_page(dst, src, nr_pages);
+			return;
+		}
+	} else {
+		/* thp page */
+		BUG_ON(!PageTransHuge(src));
+		nr_pages = hpage_nr_pages(src);
+	}
+
+	for (i = 0; i < nr_pages; i++) {
+		cond_resched();
+		exchange_highpage(dst + i, src + i);
+	}
+}
+
+/*
+ * Copy the page to its new location without polluting cache
+ */
+static void exchange_page_flags(struct page *to_page, struct page *from_page)
+{
+	int from_cpupid, to_cpupid;
+	struct page_flags from_page_flags, to_page_flags;
+	struct mem_cgroup *to_memcg = page_memcg(to_page),
+					  *from_memcg = page_memcg(from_page);
+
+	from_cpupid = page_cpupid_xchg_last(from_page, -1);
+
+	from_page_flags.page_error = TestClearPageError(from_page);
+	from_page_flags.page_referenced = TestClearPageReferenced(from_page);
+	from_page_flags.page_uptodate = PageUptodate(from_page);
+	ClearPageUptodate(from_page);
+	from_page_flags.page_active = TestClearPageActive(from_page);
+	from_page_flags.page_unevictable = TestClearPageUnevictable(from_page);
+	from_page_flags.page_checked = PageChecked(from_page);
+	ClearPageChecked(from_page);
+	from_page_flags.page_mappedtodisk = PageMappedToDisk(from_page);
+	ClearPageMappedToDisk(from_page);
+	from_page_flags.page_dirty = PageDirty(from_page);
+	ClearPageDirty(from_page);
+	from_page_flags.page_is_young = test_and_clear_page_young(from_page);
+	from_page_flags.page_is_idle = page_is_idle(from_page);
+	clear_page_idle(from_page);
+	from_page_flags.page_swapcache = PageSwapCache(from_page);
+	from_page_flags.page_private = PagePrivate(from_page);
+	ClearPagePrivate(from_page);
+	from_page_flags.page_writeback = test_clear_page_writeback(from_page);
+
+
+	to_cpupid = page_cpupid_xchg_last(to_page, -1);
+
+	to_page_flags.page_error = TestClearPageError(to_page);
+	to_page_flags.page_referenced = TestClearPageReferenced(to_page);
+	to_page_flags.page_uptodate = PageUptodate(to_page);
+	ClearPageUptodate(to_page);
+	to_page_flags.page_active = TestClearPageActive(to_page);
+	to_page_flags.page_unevictable = TestClearPageUnevictable(to_page);
+	to_page_flags.page_checked = PageChecked(to_page);
+	ClearPageChecked(to_page);
+	to_page_flags.page_mappedtodisk = PageMappedToDisk(to_page);
+	ClearPageMappedToDisk(to_page);
+	to_page_flags.page_dirty = PageDirty(to_page);
+	ClearPageDirty(to_page);
+	to_page_flags.page_is_young = test_and_clear_page_young(to_page);
+	to_page_flags.page_is_idle = page_is_idle(to_page);
+	clear_page_idle(to_page);
+	to_page_flags.page_swapcache = PageSwapCache(to_page);
+	to_page_flags.page_private = PagePrivate(to_page);
+	ClearPagePrivate(to_page);
+	to_page_flags.page_writeback = test_clear_page_writeback(to_page);
+
+	/* set to_page */
+	if (from_page_flags.page_error)
+		SetPageError(to_page);
+	if (from_page_flags.page_referenced)
+		SetPageReferenced(to_page);
+	if (from_page_flags.page_uptodate)
+		SetPageUptodate(to_page);
+	if (from_page_flags.page_active) {
+		VM_BUG_ON_PAGE(from_page_flags.page_unevictable, from_page);
+		SetPageActive(to_page);
+	} else if (from_page_flags.page_unevictable)
+		SetPageUnevictable(to_page);
+	if (from_page_flags.page_checked)
+		SetPageChecked(to_page);
+	if (from_page_flags.page_mappedtodisk)
+		SetPageMappedToDisk(to_page);
+
+	/* Move dirty on pages not done by migrate_page_move_mapping() */
+	if (from_page_flags.page_dirty)
+		SetPageDirty(to_page);
+
+	if (from_page_flags.page_is_young)
+		set_page_young(to_page);
+	if (from_page_flags.page_is_idle)
+		set_page_idle(to_page);
+
+	/* set from_page */
+	if (to_page_flags.page_error)
+		SetPageError(from_page);
+	if (to_page_flags.page_referenced)
+		SetPageReferenced(from_page);
+	if (to_page_flags.page_uptodate)
+		SetPageUptodate(from_page);
+	if (to_page_flags.page_active) {
+		VM_BUG_ON_PAGE(to_page_flags.page_unevictable, from_page);
+		SetPageActive(from_page);
+	} else if (to_page_flags.page_unevictable)
+		SetPageUnevictable(from_page);
+	if (to_page_flags.page_checked)
+		SetPageChecked(from_page);
+	if (to_page_flags.page_mappedtodisk)
+		SetPageMappedToDisk(from_page);
+
+	/* Move dirty on pages not done by migrate_page_move_mapping() */
+	if (to_page_flags.page_dirty)
+		SetPageDirty(from_page);
+
+	if (to_page_flags.page_is_young)
+		set_page_young(from_page);
+	if (to_page_flags.page_is_idle)
+		set_page_idle(from_page);
+
+	/*
+	 * Copy NUMA information to the new page, to prevent over-eager
+	 * future migrations of this same page.
+	 */
+	page_cpupid_xchg_last(to_page, from_cpupid);
+	page_cpupid_xchg_last(from_page, to_cpupid);
+
+	ksm_exchange_page(to_page, from_page);
+	/*
+	 * Please do not reorder this without considering how mm/ksm.c's
+	 * get_ksm_page() depends upon ksm_migrate_page() and PageSwapCache().
+	 */
+	ClearPageSwapCache(to_page);
+	ClearPageSwapCache(from_page);
+	if (from_page_flags.page_swapcache)
+		SetPageSwapCache(to_page);
+	if (to_page_flags.page_swapcache)
+		SetPageSwapCache(from_page);
+
+
+#ifdef CONFIG_PAGE_OWNER
+	/* exchange page owner  */
+	BUG();
+#endif
+	/* exchange mem cgroup  */
+	to_page->mem_cgroup = from_memcg;
+	from_page->mem_cgroup = to_memcg;
+
+}
+
+/*
+ * Replace the page in the mapping.
+ *
+ * The number of remaining references must be:
+ * 1 for anonymous pages without a mapping
+ * 2 for pages with a mapping
+ * 3 for pages with a mapping and PagePrivate/PagePrivate2 set.
+ */
+
+static int exchange_page_move_mapping(struct address_space *to_mapping,
+			struct address_space *from_mapping,
+			struct page *to_page, struct page *from_page,
+			enum migrate_mode mode,
+			int to_extra_count, int from_extra_count)
+{
+	int to_expected_count = 1 + to_extra_count,
+		from_expected_count = 1 + from_extra_count;
+	unsigned long from_page_index = page_index(from_page),
+				  to_page_index = page_index(to_page);
+	int to_swapbacked = PageSwapBacked(to_page),
+		from_swapbacked = PageSwapBacked(from_page);
+	struct address_space *to_mapping_value = to_page->mapping,
+						 *from_mapping_value = from_page->mapping;
+
+
+	if (!to_mapping) {
+		/* Anonymous page without mapping */
+		if (page_count(to_page) != to_expected_count)
+			return -EAGAIN;
+	}
+
+	if (!from_mapping) {
+		/* Anonymous page without mapping */
+		if (page_count(from_page) != from_expected_count)
+			return -EAGAIN;
+	}
+
+	/*
+	 * Now we know that no one else is looking at the page:
+	 * no turning back from here.
+	 */
+	/* from_page  */
+	from_page->index = to_page_index;
+	from_page->mapping = to_mapping_value;
+
+	ClearPageSwapBacked(from_page);
+	if (to_swapbacked)
+		SetPageSwapBacked(from_page);
+
+
+	/* to_page  */
+	to_page->index = from_page_index;
+	to_page->mapping = from_mapping_value;
+
+	ClearPageSwapBacked(to_page);
+	if (from_swapbacked)
+		SetPageSwapBacked(to_page);
+
+	return MIGRATEPAGE_SUCCESS;
+}
+
+static int exchange_from_to_pages(struct page *to_page, struct page *from_page,
+				enum migrate_mode mode)
+{
+	int rc = -EBUSY;
+	struct address_space *to_page_mapping, *from_page_mapping;
+
+	VM_BUG_ON_PAGE(!PageLocked(from_page), from_page);
+	VM_BUG_ON_PAGE(!PageLocked(to_page), to_page);
+
+	/* copy page->mapping not use page_mapping()  */
+	to_page_mapping = page_mapping(to_page);
+	from_page_mapping = page_mapping(from_page);
+
+	BUG_ON(from_page_mapping);
+	BUG_ON(to_page_mapping);
+
+	BUG_ON(PageWriteback(from_page));
+	BUG_ON(PageWriteback(to_page));
+
+	/* actual page mapping exchange */
+	rc = exchange_page_move_mapping(to_page_mapping, from_page_mapping,
+						to_page, from_page, mode, 0, 0);
+	/* actual page data exchange  */
+	if (rc != MIGRATEPAGE_SUCCESS)
+		return rc;
+
+	rc = -EFAULT;
+
+	if (PageHuge(from_page) || PageTransHuge(from_page))
+		exchange_huge_page(to_page, from_page);
+	else
+		exchange_highpage(to_page, from_page);
+	rc = 0;
+
+	exchange_page_flags(to_page, from_page);
+
+	return rc;
+}
+
+static int unmap_and_exchange(struct page *from_page, struct page *to_page,
+				enum migrate_mode mode)
+{
+	int rc = -EAGAIN;
+	int from_page_was_mapped = 0, to_page_was_mapped = 0;
+	pgoff_t from_index, to_index;
+	struct anon_vma *from_anon_vma = NULL, *to_anon_vma = NULL;
+
+	/* from_page lock down  */
+	if (!trylock_page(from_page)) {
+		if ((mode & MIGRATE_MODE_MASK) == MIGRATE_ASYNC)
+			goto out;
+
+		lock_page(from_page);
+	}
+
+	BUG_ON(PageWriteback(from_page));
+
+	/*
+	 * By try_to_unmap(), page->mapcount goes down to 0 here. In this case,
+	 * we cannot notice that anon_vma is freed while we migrates a page.
+	 * This get_anon_vma() delays freeing anon_vma pointer until the end
+	 * of migration. File cache pages are no problem because of page_lock()
+	 * File Caches may use write_page() or lock_page() in migration, then,
+	 * just care Anon page here.
+	 *
+	 * Only page_get_anon_vma() understands the subtleties of
+	 * getting a hold on an anon_vma from outside one of its mms.
+	 * But if we cannot get anon_vma, then we won't need it anyway,
+	 * because that implies that the anon page is no longer mapped
+	 * (and cannot be remapped so long as we hold the page lock).
+	 */
+	if (PageAnon(from_page) && !PageKsm(from_page))
+		from_anon_vma = page_get_anon_vma(from_page);
+
+	/* to_page lock down  */
+	if (!trylock_page(to_page)) {
+		if ((mode & MIGRATE_MODE_MASK) == MIGRATE_ASYNC)
+			goto out_unlock;
+
+		lock_page(to_page);
+	}
+
+	BUG_ON(PageWriteback(to_page));
+
+	/*
+	 * By try_to_unmap(), page->mapcount goes down to 0 here. In this case,
+	 * we cannot notice that anon_vma is freed while we migrates a page.
+	 * This get_anon_vma() delays freeing anon_vma pointer until the end
+	 * of migration. File cache pages are no problem because of page_lock()
+	 * File Caches may use write_page() or lock_page() in migration, then,
+	 * just care Anon page here.
+	 *
+	 * Only page_get_anon_vma() understands the subtleties of
+	 * getting a hold on an anon_vma from outside one of its mms.
+	 * But if we cannot get anon_vma, then we won't need it anyway,
+	 * because that implies that the anon page is no longer mapped
+	 * (and cannot be remapped so long as we hold the page lock).
+	 */
+	if (PageAnon(to_page) && !PageKsm(to_page))
+		to_anon_vma = page_get_anon_vma(to_page);
+
+	from_index = from_page->index;
+	to_index = to_page->index;
+
+	/*
+	 * Corner case handling:
+	 * 1. When a new swap-cache page is read into, it is added to the LRU
+	 * and treated as swapcache but it has no rmap yet.
+	 * Calling try_to_unmap() against a page->mapping==NULL page will
+	 * trigger a BUG.  So handle it here.
+	 * 2. An orphaned page (see truncate_complete_page) might have
+	 * fs-private metadata. The page can be picked up due to memory
+	 * offlining.  Everywhere else except page reclaim, the page is
+	 * invisible to the vm, so the page can not be migrated.  So try to
+	 * free the metadata, so the page can be freed.
+	 */
+	if (!from_page->mapping) {
+		VM_BUG_ON_PAGE(PageAnon(from_page), from_page);
+		if (page_has_private(from_page)) {
+			try_to_free_buffers(from_page);
+			goto out_unlock_both;
+		}
+	} else if (page_mapped(from_page)) {
+		/* Establish migration ptes */
+		VM_BUG_ON_PAGE(PageAnon(from_page) && !PageKsm(from_page) &&
+					   !from_anon_vma, from_page);
+		try_to_unmap(from_page,
+			TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
+		from_page_was_mapped = 1;
+	}
+
+	if (!to_page->mapping) {
+		VM_BUG_ON_PAGE(PageAnon(to_page), to_page);
+		if (page_has_private(to_page)) {
+			try_to_free_buffers(to_page);
+			goto out_unlock_both_remove_from_migration_pte;
+		}
+	} else if (page_mapped(to_page)) {
+		/* Establish migration ptes */
+		VM_BUG_ON_PAGE(PageAnon(to_page) && !PageKsm(to_page) &&
+					   !to_anon_vma, to_page);
+		try_to_unmap(to_page,
+			TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
+		to_page_was_mapped = 1;
+	}
+
+	if (!page_mapped(from_page) && !page_mapped(to_page))
+		rc = exchange_from_to_pages(to_page, from_page, mode);
+
+	/* In remove_migration_ptes(), page_walk_vma() assumes
+	 * from_page and to_page have the same index.
+	 * Thus, we restore old_page->index here.
+	 * Here to_page is the old_page.
+	 */
+	if (to_page_was_mapped) {
+		if (rc == MIGRATEPAGE_SUCCESS)
+			swap(to_page->index, to_index);
+
+		remove_migration_ptes(to_page,
+			rc == MIGRATEPAGE_SUCCESS ? from_page : to_page, false);
+
+		if (rc == MIGRATEPAGE_SUCCESS)
+			swap(to_page->index, to_index);
+	}
+
+out_unlock_both_remove_from_migration_pte:
+	if (from_page_was_mapped) {
+		if (rc == MIGRATEPAGE_SUCCESS)
+			swap(from_page->index, from_index);
+
+		remove_migration_ptes(from_page,
+			rc == MIGRATEPAGE_SUCCESS ? to_page : from_page, false);
+
+		if (rc == MIGRATEPAGE_SUCCESS)
+			swap(from_page->index, from_index);
+	}
+
+
+
+out_unlock_both:
+	if (to_anon_vma)
+		put_anon_vma(to_anon_vma);
+	unlock_page(to_page);
+out_unlock:
+	/* Drop an anon_vma reference if we took one */
+	if (from_anon_vma)
+		put_anon_vma(from_anon_vma);
+	unlock_page(from_page);
+out:
+
+	return rc;
+}
+
+/*
+ * Exchange pages in the exchange_list
+ *
+ * Caller should release the exchange_list resource.
+ *
+ * */
+int exchange_pages(struct list_head *exchange_list,
+			enum migrate_mode mode,
+			int reason)
+{
+	struct exchange_page_info *one_pair, *one_pair2;
+	int failed = 0;
+
+	list_for_each_entry_safe(one_pair, one_pair2, exchange_list, list) {
+		struct page *from_page = one_pair->from_page;
+		struct page *to_page = one_pair->to_page;
+		int rc;
+		int retry = 0;
+
+again:
+		if (page_count(from_page) == 1) {
+			/* page was freed from under us. So we are done  */
+			ClearPageActive(from_page);
+			ClearPageUnevictable(from_page);
+
+			put_page(from_page);
+			dec_node_page_state(from_page, NR_ISOLATED_ANON +
+					page_is_file_cache(from_page));
+
+			if (page_count(to_page) == 1) {
+				ClearPageActive(to_page);
+				ClearPageUnevictable(to_page);
+				put_page(to_page);
+			} else
+				goto putback_to_page;
+
+			continue;
+		}
+
+		if (page_count(to_page) == 1) {
+			/* page was freed from under us. So we are done  */
+			ClearPageActive(to_page);
+			ClearPageUnevictable(to_page);
+
+			put_page(to_page);
+
+			dec_node_page_state(to_page, NR_ISOLATED_ANON +
+					page_is_file_cache(to_page));
+
+			dec_node_page_state(from_page, NR_ISOLATED_ANON +
+					page_is_file_cache(from_page));
+			putback_lru_page(from_page);
+			continue;
+		}
+
+		/* TODO: compound page not supported */
+		if (PageCompound(from_page) || page_mapping(from_page)) {
+			++failed;
+			goto putback;
+		}
+
+		rc = unmap_and_exchange(from_page, to_page, mode);
+
+		if (rc == -EAGAIN && retry < 3) {
+			++retry;
+			goto again;
+		}
+
+		if (rc != MIGRATEPAGE_SUCCESS)
+			++failed;
+
+putback:
+		dec_node_page_state(from_page, NR_ISOLATED_ANON +
+				page_is_file_cache(from_page));
+
+		putback_lru_page(from_page);
+putback_to_page:
+		dec_node_page_state(to_page, NR_ISOLATED_ANON +
+				page_is_file_cache(to_page));
+
+		putback_lru_page(to_page);
+
+	}
+	return failed;
+}
diff --git a/mm/ksm.c b/mm/ksm.c
index fc64874..e5b492b 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -2716,6 +2716,41 @@ void ksm_migrate_page(struct page *newpage, struct page *oldpage)
 		set_page_stable_node(oldpage, NULL);
 	}
 }
+
+void ksm_exchange_page(struct page *to_page, struct page *from_page)
+{
+	struct stable_node *to_stable_node, *from_stable_node;
+
+	VM_BUG_ON_PAGE(!PageLocked(to_page), to_page);
+	VM_BUG_ON_PAGE(!PageLocked(from_page), from_page);
+
+	to_stable_node = page_stable_node(to_page);
+	from_stable_node = page_stable_node(from_page);
+	if (to_stable_node) {
+		VM_BUG_ON_PAGE(to_stable_node->kpfn != page_to_pfn(from_page),
+					from_page);
+		to_stable_node->kpfn = page_to_pfn(to_page);
+		/*
+		 * newpage->mapping was set in advance; now we need smp_wmb()
+		 * to make sure that the new stable_node->kpfn is visible
+		 * to get_ksm_page() before it can see that oldpage->mapping
+		 * has gone stale (or that PageSwapCache has been cleared).
+		 */
+		smp_wmb();
+	}
+	if (from_stable_node) {
+		VM_BUG_ON_PAGE(from_stable_node->kpfn != page_to_pfn(to_page),
+					to_page);
+		from_stable_node->kpfn = page_to_pfn(from_page);
+		/*
+		 * newpage->mapping was set in advance; now we need smp_wmb()
+		 * to make sure that the new stable_node->kpfn is visible
+		 * to get_ksm_page() before it can see that oldpage->mapping
+		 * has gone stale (or that PageSwapCache has been cleared).
+		 */
+		smp_wmb();
+	}
+}
 #endif /* CONFIG_MIGRATION */
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-- 
2.7.4


Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 52D8CC004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 04:06:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC9DB206BF
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 04:06:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="O6bV/fR4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC9DB206BF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C2ECF6B000C; Tue,  7 May 2019 00:06:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A4A956B000E; Tue,  7 May 2019 00:06:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 653DC6B0269; Tue,  7 May 2019 00:06:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1BF176B000D
	for <linux-mm@kvack.org>; Tue,  7 May 2019 00:06:15 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id q73so9343598pfi.17
        for <linux-mm@kvack.org>; Mon, 06 May 2019 21:06:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=B2oLl3my7A6QZIWt7+S+OSBsACbrdesDlp/r7QymXXM=;
        b=b/uqzw3wMMa/Py+YTR7LKX8WGYNSLXtM7tV0ocyBDJiK7Ant5igZtuWATTee51hiGh
         hsQ09Ef1v/hAVBgGd1b1FJOMxFbI+dwDTLDhdk5v9cSmRc7mPgA0/PlFdS9BNaDjTSQ0
         Oe0rH7nBxHOpXz3qp76xn+L+O3nk3wFCsk9/hBQIVkkHNjY7DUTd9WokmU/g6M/fepiN
         Gw+JhW9z/BiqIymdOon4tm61QrtUpiPZFn/Uiaw5htXUxxQwMN621MCHo64aOOqIfpw3
         iFUnKywVudLZRcPWKkKM8b3ZuTYDm1bqVC5xrz5yziBSBeABgTM/dG0XTUz0EtpSZHf/
         obUA==
X-Gm-Message-State: APjAAAXd4h76tflwlTkmg/n6GC34KHPlulS/edfYi8+Z2mWtboz5rbCN
	+Ms+7YVqtFuOuG26Jk5MrRvRhCpSMBVdbWZsg2XH8Ow7sdoCEiQPSZWi/aBAKUqaBs/m4Zz+5nn
	FCgmcVE8ZGgJELaSJ2KjSqKjbXtstVSf/cEI8A69qWd1P27CPcOQkuSyd3poaw1mHbQ==
X-Received: by 2002:a63:5202:: with SMTP id g2mr37327121pgb.317.1557201974702;
        Mon, 06 May 2019 21:06:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxMiLqtTPyaRa8IBcFpcDf8oHdbeZQjrnCWoOSxcBZBVLd0BBzHJ4vue0IuOjSzX8O/GSmG
X-Received: by 2002:a63:5202:: with SMTP id g2mr37327014pgb.317.1557201973314;
        Mon, 06 May 2019 21:06:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557201973; cv=none;
        d=google.com; s=arc-20160816;
        b=OJiJICCNiOjCcbca2NyoUSNyHWuYc/Cp+HpivM46ZXwHBqDQDDTqyfYrQXACv9RLTF
         yFV/1CWcMNjpIaH1ttmxiQj6ylT/2T8Em78sm7lQozWmVauOwHBBiGVn55ZSjTdweOxN
         +9fPsQKNL/i51D7yFOghDH+4rE7k22AnYZm5F+OebceonFLd4JmnxG5NC93/teRMjGaN
         8s4lWx7ZrxxPx8my8WWcb7ZaG3vh/ET/JYkKFyQZGKjs5452yy4jz9s+P3fIReJRg81P
         Z37zuoUI4u05UBcVvHUIxo5z4zt84xFeny0PuGLif2sR5kxp5CsJi13fLDPBURGuzFIX
         fB2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=B2oLl3my7A6QZIWt7+S+OSBsACbrdesDlp/r7QymXXM=;
        b=MMlcWhOdZnc6B1AHttac+TDWSleUZZkUOvCEIMcFXVtzBBbJJaLmsuC4dq1JXD7JzW
         tdSswSI4er4TEKp+90b5beHb0rVlyLy+Newaai5rkYj0uH0yWSX/xTFWibm4KnOU7bTu
         RA4QH7zcG9C5bqmGCqU75f9Iv9/vCSxGazanw4AWokYq1JA/y7wkrEaFT89J/gX3EIyG
         fWP3YS6oQ47DKmtdbzX58Dj8fEJbq/vzxn/giGBQcpq2fYMMWpMnRQWKVzIehEIEs3Lj
         UKhf78GgGiheJWiK17moWAevbyuDHBLuS73hAbg8NH6OroJFdpVgeieHN833H50dGLzh
         PuNg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="O6bV/fR4";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id u190si16276184pgc.282.2019.05.06.21.06.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 06 May 2019 21:06:11 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="O6bV/fR4";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=References:In-Reply-To:Message-Id:
	Date:Subject:Cc:To:From:Sender:Reply-To:MIME-Version:Content-Type:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=B2oLl3my7A6QZIWt7+S+OSBsACbrdesDlp/r7QymXXM=; b=O6bV/fR4/iG3ZKevogg11I24C
	Q6vbVfe6kOQu6DLd3oq7uAZvW2YLrE6TBxc8FDWC4bXtHQbhGhzEf41bazibQBNw9fWbUua+ajaAb
	zYaX0PWpU8NzhGoXz77o20LGYo7+6oufxKg9C01DWQKTQPcKGZ4/2CeC7VFXqxgTJxi3Nagj+btlF
	qXFtFyaZE8DLuSEJtMO+NxehrCRZWCH73QQ4VXjcJ3yp3wV5AlICTWbpO95KA5klEc01iPF2ZMx/U
	+FnyYcDQZaSQsGc6EGM0wAIKkBlu4H3ZRLow41g++UpnfhGaPf3hw2oY3CyokK1t/Ksac1nwC7wOl
	tMzWDkCfw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hNrMp-0005hj-Ag; Tue, 07 May 2019 04:06:11 +0000
From: Matthew Wilcox <willy@infradead.org>
To: linux-mm@kvack.org
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>
Subject: [PATCH 02/11] mm: Pass order to __alloc_pages_nodemask in GFP flags
Date: Mon,  6 May 2019 21:06:00 -0700
Message-Id: <20190507040609.21746-3-willy@infradead.org>
X-Mailer: git-send-email 2.14.5
In-Reply-To: <20190507040609.21746-1-willy@infradead.org>
References: <20190507040609.21746-1-willy@infradead.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Matthew Wilcox (Oracle)" <willy@infradead.org>

Save marshalling an extra argument in all the callers at the expense of
using five bits of the GFP flags.  We still have three GFP bits remaining
after doing this (and we can release one more by reallocating NORETRY,
RETRY_MAYFAIL and NOFAIL).

Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
---
 arch/x86/events/intel/ds.c |  4 +--
 arch/x86/kvm/vmx/vmx.c     |  4 +--
 include/linux/gfp.h        | 51 ++++++++++++++++++++++----------------
 include/linux/migrate.h    |  2 +-
 mm/filemap.c               |  2 +-
 mm/gup.c                   |  4 +--
 mm/hugetlb.c               |  5 ++--
 mm/khugepaged.c            |  2 +-
 mm/mempolicy.c             | 30 +++++++++++-----------
 mm/migrate.c               |  2 +-
 mm/page_alloc.c            |  4 +--
 mm/shmem.c                 |  5 ++--
 mm/slub.c                  |  2 +-
 13 files changed, 63 insertions(+), 54 deletions(-)

diff --git a/arch/x86/events/intel/ds.c b/arch/x86/events/intel/ds.c
index 10c99ce1fead..82fee9845b87 100644
--- a/arch/x86/events/intel/ds.c
+++ b/arch/x86/events/intel/ds.c
@@ -315,13 +315,13 @@ static void ds_clear_cea(void *cea, size_t size)
 	preempt_enable();
 }
 
-static void *dsalloc_pages(size_t size, gfp_t flags, int cpu)
+static void *dsalloc_pages(size_t size, gfp_t gfp, int cpu)
 {
 	unsigned int order = get_order(size);
 	int node = cpu_to_node(cpu);
 	struct page *page;
 
-	page = __alloc_pages_node(node, flags | __GFP_ZERO, order);
+	page = __alloc_pages_node(node, gfp | __GFP_ZERO | __GFP_ORDER(order));
 	return page ? page_address(page) : NULL;
 }
 
diff --git a/arch/x86/kvm/vmx/vmx.c b/arch/x86/kvm/vmx/vmx.c
index ab432a930ae8..323a0f6ffe13 100644
--- a/arch/x86/kvm/vmx/vmx.c
+++ b/arch/x86/kvm/vmx/vmx.c
@@ -2380,13 +2380,13 @@ static __init int setup_vmcs_config(struct vmcs_config *vmcs_conf,
 	return 0;
 }
 
-struct vmcs *alloc_vmcs_cpu(bool shadow, int cpu, gfp_t flags)
+struct vmcs *alloc_vmcs_cpu(bool shadow, int cpu, gfp_t gfp)
 {
 	int node = cpu_to_node(cpu);
 	struct page *pages;
 	struct vmcs *vmcs;
 
-	pages = __alloc_pages_node(node, flags, vmcs_config.order);
+	pages = __alloc_pages_node(node, gfp | __GFP_ORDER(vmcs_config.order));
 	if (!pages)
 		return NULL;
 	vmcs = page_address(pages);
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index fb07b503dc45..e7845c2510db 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -219,6 +219,18 @@ struct vm_area_struct;
 /* Room for N __GFP_FOO bits */
 #define __GFP_BITS_SHIFT (23 + IS_ENABLED(CONFIG_LOCKDEP))
 #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
+#define __GFP_ORDER(order) ((__force gfp_t)(order << __GFP_BITS_SHIFT))
+#define __GFP_ORDER_PMD	__GFP_ORDER(PMD_SHIFT - PAGE_SHIFT)
+#define __GFP_ORDER_PUD	__GFP_ORDER(PUD_SHIFT - PAGE_SHIFT)
+
+/*
+ * Extract the order from a GFP bitmask.
+ * Must be the top bits to avoid an AND operation.  Don't let
+ * __GFP_BITS_SHIFT get over 27, or we won't be able to encode orders
+ * above 15 (some architectures allow configuring MAX_ORDER up to 64,
+ * but I doubt larger than 31 are ever used).
+ */
+#define gfp_order(gfp)	(((__force unsigned int)gfp) >> __GFP_BITS_SHIFT)
 
 /**
  * DOC: Useful GFP flag combinations
@@ -464,26 +476,23 @@ static inline void arch_alloc_page(struct page *page, int order) { }
 #endif
 
 struct page *
-__alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order, int preferred_nid,
-							nodemask_t *nodemask);
+__alloc_pages_nodemask(gfp_t gfp_mask, int preferred_nid, nodemask_t *nodemask);
 
-static inline struct page *
-__alloc_pages(gfp_t gfp_mask, unsigned int order, int preferred_nid)
+static inline struct page *__alloc_pages(gfp_t gfp_mask, int preferred_nid)
 {
-	return __alloc_pages_nodemask(gfp_mask, order, preferred_nid, NULL);
+	return __alloc_pages_nodemask(gfp_mask, preferred_nid, NULL);
 }
 
 /*
  * Allocate pages, preferring the node given as nid. The node must be valid and
  * online. For more general interface, see alloc_pages_node().
  */
-static inline struct page *
-__alloc_pages_node(int nid, gfp_t gfp_mask, unsigned int order)
+static inline struct page *__alloc_pages_node(int nid, gfp_t gfp)
 {
 	VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES);
-	VM_WARN_ON((gfp_mask & __GFP_THISNODE) && !node_online(nid));
+	VM_WARN_ON((gfp & __GFP_THISNODE) && !node_online(nid));
 
-	return __alloc_pages(gfp_mask, order, nid);
+	return __alloc_pages(gfp, nid);
 }
 
 /*
@@ -497,35 +506,35 @@ static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
 	if (nid == NUMA_NO_NODE)
 		nid = numa_mem_id();
 
-	return __alloc_pages_node(nid, gfp_mask, order);
+	return __alloc_pages_node(nid, gfp_mask | __GFP_ORDER(order));
 }
 
 #ifdef CONFIG_NUMA
-extern struct page *alloc_pages_current(gfp_t gfp_mask, unsigned order);
+extern struct page *alloc_pages_current(gfp_t gfp_mask);
 
 static inline struct page *
 alloc_pages(gfp_t gfp_mask, unsigned int order)
 {
-	return alloc_pages_current(gfp_mask, order);
+	return alloc_pages_current(gfp_mask | __GFP_ORDER(order));
 }
-extern struct page *alloc_pages_vma(gfp_t gfp_mask, int order,
-			struct vm_area_struct *vma, unsigned long addr,
-			int node, bool hugepage);
+extern struct page *alloc_pages_vma(gfp_t gfp_mask, struct vm_area_struct *vma,
+		unsigned long addr, int node, bool hugepage);
 #define alloc_hugepage_vma(gfp_mask, vma, addr, order) \
-	alloc_pages_vma(gfp_mask, order, vma, addr, numa_node_id(), true)
+	alloc_pages_vma(gfp_mask | __GFP_ORDER(order), vma, addr, \
+			numa_node_id(), true)
 #else
 #define alloc_pages(gfp_mask, order) \
-		alloc_pages_node(numa_node_id(), gfp_mask, order)
-#define alloc_pages_vma(gfp_mask, order, vma, addr, node, false)\
-	alloc_pages(gfp_mask, order)
+	alloc_pages_node(numa_node_id(), gfp_mask, order)
+#define alloc_pages_vma(gfp_mask, vma, addr, node, false) \
+	alloc_pages(gfp_mask, 0)
 #define alloc_hugepage_vma(gfp_mask, vma, addr, order) \
 	alloc_pages(gfp_mask, order)
 #endif
 #define alloc_page(gfp_mask) alloc_pages(gfp_mask, 0)
 #define alloc_page_vma(gfp_mask, vma, addr)			\
-	alloc_pages_vma(gfp_mask, 0, vma, addr, numa_node_id(), false)
+	alloc_pages_vma(gfp_mask, vma, addr, numa_node_id(), false)
 #define alloc_page_vma_node(gfp_mask, vma, addr, node)		\
-	alloc_pages_vma(gfp_mask, 0, vma, addr, node, false)
+	alloc_pages_vma(gfp_mask, vma, addr, node, false)
 
 extern unsigned long __get_free_pages(gfp_t gfp_mask, unsigned int order);
 extern unsigned long get_zeroed_page(gfp_t gfp_mask);
diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index e13d9bf2f9a5..ba4385144cc9 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -50,7 +50,7 @@ static inline struct page *new_page_nodemask(struct page *page,
 	if (PageHighMem(page) || (zone_idx(page_zone(page)) == ZONE_MOVABLE))
 		gfp_mask |= __GFP_HIGHMEM;
 
-	new_page = __alloc_pages_nodemask(gfp_mask, order,
+	new_page = __alloc_pages_nodemask(gfp_mask | __GFP_ORDER(order),
 				preferred_nid, nodemask);
 
 	if (new_page && PageTransHuge(new_page))
diff --git a/mm/filemap.c b/mm/filemap.c
index 3ad18fa56057..b7b0841312c9 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -945,7 +945,7 @@ struct page *__page_cache_alloc(gfp_t gfp)
 		do {
 			cpuset_mems_cookie = read_mems_allowed_begin();
 			n = cpuset_mem_spread_node();
-			page = __alloc_pages_node(n, gfp, 0);
+			page = __alloc_pages_node(n, gfp);
 		} while (!page && read_mems_allowed_retry(cpuset_mems_cookie));
 
 		return page;
diff --git a/mm/gup.c b/mm/gup.c
index 294e87ae5b9a..7b06962a4630 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1306,14 +1306,14 @@ static struct page *new_non_cma_page(struct page *page, unsigned long private)
 		 * CMA area again.
 		 */
 		thp_gfpmask &= ~__GFP_MOVABLE;
-		thp = __alloc_pages_node(nid, thp_gfpmask, HPAGE_PMD_ORDER);
+		thp = __alloc_pages_node(nid, thp_gfpmask | __GFP_PMD_ORDER);
 		if (!thp)
 			return NULL;
 		prep_transhuge_page(thp);
 		return thp;
 	}
 
-	return __alloc_pages_node(nid, gfp_mask, 0);
+	return __alloc_pages_node(nid, gfp_mask);
 }
 
 static long check_and_migrate_cma_pages(struct task_struct *tsk,
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 109f5de82910..f3f0f2902a52 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1401,10 +1401,11 @@ static struct page *alloc_buddy_huge_page(struct hstate *h,
 	int order = huge_page_order(h);
 	struct page *page;
 
-	gfp_mask |= __GFP_COMP|__GFP_RETRY_MAYFAIL|__GFP_NOWARN;
+	gfp_mask |= __GFP_COMP | __GFP_RETRY_MAYFAIL | __GFP_NOWARN |
+			__GFP_ORDER(order);
 	if (nid == NUMA_NO_NODE)
 		nid = numa_mem_id();
-	page = __alloc_pages_nodemask(gfp_mask, order, nid, nmask);
+	page = __alloc_pages_nodemask(gfp_mask, nid, nmask);
 	if (page)
 		__count_vm_event(HTLB_BUDDY_PGALLOC);
 	else
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index a335f7c1fac4..3d9267394881 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -770,7 +770,7 @@ khugepaged_alloc_page(struct page **hpage, gfp_t gfp, int node)
 {
 	VM_BUG_ON_PAGE(*hpage, *hpage);
 
-	*hpage = __alloc_pages_node(node, gfp, HPAGE_PMD_ORDER);
+	*hpage = __alloc_pages_node(node, gfp | __GFP_PMD_ORDER);
 	if (unlikely(!*hpage)) {
 		count_vm_event(THP_COLLAPSE_ALLOC_FAILED);
 		*hpage = ERR_PTR(-ENOMEM);
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 2219e747df49..bad60476d5ad 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -975,7 +975,7 @@ struct page *alloc_new_node_page(struct page *page, unsigned long node)
 		return thp;
 	} else
 		return __alloc_pages_node(node, GFP_HIGHUSER_MOVABLE |
-						    __GFP_THISNODE, 0);
+						    __GFP_THISNODE);
 }
 
 /*
@@ -2006,12 +2006,11 @@ bool mempolicy_nodemask_intersects(struct task_struct *tsk,
 
 /* Allocate a page in interleaved policy.
    Own path because it needs to do special accounting. */
-static struct page *alloc_page_interleave(gfp_t gfp, unsigned order,
-					unsigned nid)
+static struct page *alloc_page_interleave(gfp_t gfp, unsigned nid)
 {
 	struct page *page;
 
-	page = __alloc_pages(gfp, order, nid);
+	page = __alloc_pages(gfp, nid);
 	/* skip NUMA_INTERLEAVE_HIT counter update if numa stats is disabled */
 	if (!static_branch_likely(&vm_numa_stat_key))
 		return page;
@@ -2033,7 +2032,6 @@ static struct page *alloc_page_interleave(gfp_t gfp, unsigned order,
  *      %GFP_FS      allocation should not call back into a file system.
  *      %GFP_ATOMIC  don't sleep.
  *
- *	@order:Order of the GFP allocation.
  * 	@vma:  Pointer to VMA or NULL if not available.
  *	@addr: Virtual Address of the allocation. Must be inside the VMA.
  *	@node: Which node to prefer for allocation (modulo policy).
@@ -2047,8 +2045,8 @@ static struct page *alloc_page_interleave(gfp_t gfp, unsigned order,
  *	NULL when no page can be allocated.
  */
 struct page *
-alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
-		unsigned long addr, int node, bool hugepage)
+alloc_pages_vma(gfp_t gfp, struct vm_area_struct *vma, unsigned long addr,
+		int node, bool hugepage)
 {
 	struct mempolicy *pol;
 	struct page *page;
@@ -2060,9 +2058,10 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
 	if (pol->mode == MPOL_INTERLEAVE) {
 		unsigned nid;
 
-		nid = interleave_nid(pol, vma, addr, PAGE_SHIFT + order);
+		nid = interleave_nid(pol, vma, addr,
+				PAGE_SHIFT + gfp_order(gfp));
 		mpol_cond_put(pol);
-		page = alloc_page_interleave(gfp, order, nid);
+		page = alloc_page_interleave(gfp, nid);
 		goto out;
 	}
 
@@ -2086,14 +2085,14 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
 		if (!nmask || node_isset(hpage_node, *nmask)) {
 			mpol_cond_put(pol);
 			page = __alloc_pages_node(hpage_node,
-						gfp | __GFP_THISNODE, order);
+						gfp | __GFP_THISNODE);
 			goto out;
 		}
 	}
 
 	nmask = policy_nodemask(gfp, pol);
 	preferred_nid = policy_node(gfp, pol, node);
-	page = __alloc_pages_nodemask(gfp, order, preferred_nid, nmask);
+	page = __alloc_pages_nodemask(gfp, preferred_nid, nmask);
 	mpol_cond_put(pol);
 out:
 	return page;
@@ -2108,13 +2107,12 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
  *      	%GFP_HIGHMEM highmem allocation,
  *      	%GFP_FS     don't call back into a file system.
  *      	%GFP_ATOMIC don't sleep.
- *	@order: Power of two of allocation size in pages. 0 is a single page.
  *
  *	Allocate a page from the kernel page pool.  When not in
- *	interrupt context and apply the current process NUMA policy.
+ *	interrupt context apply the current process NUMA policy.
  *	Returns NULL when no page can be allocated.
  */
-struct page *alloc_pages_current(gfp_t gfp, unsigned order)
+struct page *alloc_pages_current(gfp_t gfp)
 {
 	struct mempolicy *pol = &default_policy;
 	struct page *page;
@@ -2127,9 +2125,9 @@ struct page *alloc_pages_current(gfp_t gfp, unsigned order)
 	 * nor system default_policy
 	 */
 	if (pol->mode == MPOL_INTERLEAVE)
-		page = alloc_page_interleave(gfp, order, interleave_nodes(pol));
+		page = alloc_page_interleave(gfp, interleave_nodes(pol));
 	else
-		page = __alloc_pages_nodemask(gfp, order,
+		page = __alloc_pages_nodemask(gfp,
 				policy_node(gfp, pol, numa_node_id()),
 				policy_nodemask(gfp, pol));
 
diff --git a/mm/migrate.c b/mm/migrate.c
index f2ecc2855a12..acb479132398 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1884,7 +1884,7 @@ static struct page *alloc_misplaced_dst_page(struct page *page,
 					 (GFP_HIGHUSER_MOVABLE |
 					  __GFP_THISNODE | __GFP_NOMEMALLOC |
 					  __GFP_NORETRY | __GFP_NOWARN) &
-					 ~__GFP_RECLAIM, 0);
+					 ~__GFP_RECLAIM);
 
 	return newpage;
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index deea16489e2b..13191fe2f19d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4610,11 +4610,11 @@ static inline void finalise_ac(gfp_t gfp_mask, struct alloc_context *ac)
  * This is the 'heart' of the zoned buddy allocator.
  */
 struct page *
-__alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order, int preferred_nid,
-							nodemask_t *nodemask)
+__alloc_pages_nodemask(gfp_t gfp_mask, int preferred_nid, nodemask_t *nodemask)
 {
 	struct page *page;
 	unsigned int alloc_flags = ALLOC_WMARK_LOW;
+	int order = gfp_order(gfp_mask);
 	gfp_t alloc_mask; /* The gfp_t that was actually used for allocation */
 	struct alloc_context ac = { };
 
diff --git a/mm/shmem.c b/mm/shmem.c
index a1e9f6194138..445e76e5c0c2 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1463,8 +1463,9 @@ static struct page *shmem_alloc_hugepage(gfp_t gfp,
 		return NULL;
 
 	shmem_pseudo_vma_init(&pvma, info, hindex);
-	page = alloc_pages_vma(gfp | __GFP_COMP | __GFP_NORETRY | __GFP_NOWARN,
-			HPAGE_PMD_ORDER, &pvma, 0, numa_node_id(), true);
+	page = alloc_pages_vma(gfp | __GFP_COMP | __GFP_NORETRY |
+				__GFP_NOWARN | __GFP_PMD_ORDER,
+			&pvma, 0, numa_node_id(), true);
 	shmem_pseudo_vma_destroy(&pvma);
 	if (page)
 		prep_transhuge_page(page);
diff --git a/mm/slub.c b/mm/slub.c
index a34fbe1f6ede..7504fa3f844b 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1497,7 +1497,7 @@ static inline struct page *alloc_slab_page(struct kmem_cache *s,
 	if (node == NUMA_NO_NODE)
 		page = alloc_pages(flags, order);
 	else
-		page = __alloc_pages_node(node, flags, order);
+		page = __alloc_pages_node(node, flags | __GFP_ORDER(order));
 
 	if (page && memcg_charge_slab(page, flags, order, s)) {
 		__free_pages(page, order);
-- 
2.20.1


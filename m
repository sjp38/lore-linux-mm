Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39AA8C04AB3
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 13:51:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D6398216C4
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 13:51:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="G+mHGCb2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D6398216C4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 31C846B02A4; Fri, 10 May 2019 09:50:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 27B9B6B02A7; Fri, 10 May 2019 09:50:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EAC686B02A4; Fri, 10 May 2019 09:50:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 92B2F6B02A4
	for <linux-mm@kvack.org>; Fri, 10 May 2019 09:50:56 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id g89so3738226plb.3
        for <linux-mm@kvack.org>; Fri, 10 May 2019 06:50:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=usjNBCQ+qj6LaoBc8jv6CR6/S12urfuggCLXdsJwxBs=;
        b=isO3lhy8RLf1EjU8uOYrHKV3TlRedMiemi519NDcZs3APO0PW57mA8fILyVhr/EW2y
         ZhlDBmSHmMWw5EziQRS3BV0f4T2hdjgo4D9AQZFUt4AFXb/FIwGJu1OxBYmp8/0eSWrd
         iuni6H/eTpTOsVpGucjPaKJjGBgqanA8Ooo3UtsZotMpO3aatkyu2w81ilJnopqr2Xrz
         tazo3q2JD97A80sY9WWgOn6V/qktyBEUl0whf53xW72kPd+tKeUYJqW+nTVdO0wEUQ+h
         rJInL3Mpml7uNa4e7sjX9xtZeg/IP3gtsupd7Ezqpqphcxzz/kIO2UtxvwH6gPTy+58P
         ktYA==
X-Gm-Message-State: APjAAAXynJY7oLlibvpAKQ22PC/IDrPk6PfJTjqGdN9Rt3P2ZSrUGPmz
	amRuoXN68Vw6H+vLOph0KNo+7FdwmRNyhzYIsRaYr6/Oz4EWA2aLyq9OtdFwC2y9uSOw74Bb0dH
	UyCd13HJpOHPt3R0cY7B1TsWFgupCTHYKZGQJXjyrt60KhRA37YqxE9ApCRVklRUL4A==
X-Received: by 2002:aa7:92c4:: with SMTP id k4mr14609526pfa.183.1557496256116;
        Fri, 10 May 2019 06:50:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyl96LhY7m53pPQ2GIrjl5yingaxwGHINxAzhFuANO+NsXbDYQRtRJQiBR7h8mJy84WJQYE
X-Received: by 2002:aa7:92c4:: with SMTP id k4mr14607596pfa.183.1557496241856;
        Fri, 10 May 2019 06:50:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557496241; cv=none;
        d=google.com; s=arc-20160816;
        b=lDZRek0fiJui13MSwxfEX/ncGpt5JmjWJZeZ1wWNeXZBZKjetteEJo2DFN11Vkd0LQ
         NEQgn5QkaB9QkNjoC4ngaQ0viDzW65vla5zfxef3EHxoCPYEnk9bsCKz/9ohAJsLxtvk
         Art9lZqGqEgnf/rnBwy4hgJuSa2DG/PoZXXqo2g9lrJMeIODlz2RZywuuBiIe55VIY1p
         fegMtMfXaQsPaOQYYKiyxiLIWoIM3cF4F+kLHONBUdpr/BJhS+Qs+vzHjOQLmbyGqQ9w
         A2CLBEdadsmWvoZYlo6or7+pVQshr5qnyk4rpRgduhqoNr3qElB67zoN+RiMMTw/a5Aj
         jfeQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=usjNBCQ+qj6LaoBc8jv6CR6/S12urfuggCLXdsJwxBs=;
        b=SVzUCL/sZTBISZTTs5qIrrlrJxKMIY0OcFo5iN87OBTcL+ZaeNPAub5geq+mYtY7XZ
         9z5P3Fs3FZ5jSrDp97D1pEOEi6BxT7CZ5/GS1nDqK9AfanV5pZ5vSTuSOxmS/IKvv6Rp
         SJnwSsu6ttRFyY8teKjwQxLv9qtOBInKGlknxkyoflwk4ArSgiTdkQi4S7BjKoEPF+Qe
         9s3m2gFHSnFrOkqa4Mava7zoJqOfOeI5VFz30y7R/fSwssA4zGCWvmOr+/gdmuKvlV9G
         5nSmHTdxDZcBvJqFQyqh5ODh1dDONCPPqJIGmOlVPs46qyUiC/HgG/Mo661g7LPlrPkj
         JVIg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=G+mHGCb2;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a73si7413113pfj.174.2019.05.10.06.50.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 10 May 2019 06:50:41 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=G+mHGCb2;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=References:In-Reply-To:Message-Id:
	Date:Subject:Cc:To:From:Sender:Reply-To:MIME-Version:Content-Type:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=usjNBCQ+qj6LaoBc8jv6CR6/S12urfuggCLXdsJwxBs=; b=G+mHGCb2x0Py+nLXWaodfIsqW
	dLtqiSN+rJibWNVtReM/UORuTFfzTu7CMZNQsO5FKQ+SHd2YNHRyiNIWrAAkxKY2QEbg/4hzU4jQ3
	/hPiec+bXw2lLgfsBePnqP0TwjT5e2KHMBOltlStFr2XQ3UdqnpYuuGDpAHp5vSZ5Kx3Tm0wLKCUr
	+zpjES4w/OPtT1K3eXqMjh7nOaNNn/iSqIS32F5hQFsllp8lWzrrQOTzJfAOj+4bQ180i3Yx9Tp3f
	yPd/tviMr+DNCEanaNSYX97yHUAoCEPPkgE84o2LPLHTfr9znFNCU9OCiSf5QHiZD5g2JMx5pUVre
	/cU3tFvOA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hP5v7-0004Ty-6g; Fri, 10 May 2019 13:50:41 +0000
From: Matthew Wilcox <willy@infradead.org>
To: linux-mm@kvack.org
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>
Subject: [PATCH v2 07/15] mm: Pass order to __alloc_pages_node in GFP flags
Date: Fri, 10 May 2019 06:50:30 -0700
Message-Id: <20190510135038.17129-8-willy@infradead.org>
X-Mailer: git-send-email 2.14.5
In-Reply-To: <20190510135038.17129-1-willy@infradead.org>
References: <20190510135038.17129-1-willy@infradead.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Matthew Wilcox (Oracle)" <willy@infradead.org>

Matches the change to the __alloc_pages_nodemask API.
Also switch the order of node and gfp to match the other memory
allocation APIs.

Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
---
 arch/ia64/kernel/uncached.c       | 6 +++---
 arch/ia64/sn/pci/pci_dma.c        | 4 ++--
 arch/powerpc/platforms/cell/ras.c | 5 ++---
 arch/x86/events/intel/ds.c        | 4 ++--
 arch/x86/kvm/vmx/vmx.c            | 4 ++--
 drivers/misc/sgi-xp/xpc_uv.c      | 5 ++---
 include/linux/gfp.h               | 9 ++++-----
 kernel/profile.c                  | 2 +-
 mm/filemap.c                      | 2 +-
 mm/gup.c                          | 4 ++--
 mm/khugepaged.c                   | 2 +-
 mm/mempolicy.c                    | 8 ++++----
 mm/migrate.c                      | 9 ++++-----
 mm/slab.c                         | 3 ++-
 mm/slob.c                         | 2 +-
 mm/slub.c                         | 2 +-
 16 files changed, 34 insertions(+), 37 deletions(-)

diff --git a/arch/ia64/kernel/uncached.c b/arch/ia64/kernel/uncached.c
index 583f7ff6b589..2e53b7311777 100644
--- a/arch/ia64/kernel/uncached.c
+++ b/arch/ia64/kernel/uncached.c
@@ -98,9 +98,9 @@ static int uncached_add_chunk(struct uncached_pool *uc_pool, int nid)
 
 	/* attempt to allocate a granule's worth of cached memory pages */
 
-	page = __alloc_pages_node(nid,
-				GFP_KERNEL | __GFP_ZERO | __GFP_THISNODE,
-				IA64_GRANULE_SHIFT-PAGE_SHIFT);
+	page = __alloc_pages_node(GFP_KERNEL | __GFP_ZERO | __GFP_THISNODE |
+				__GFP_ORDER(IA64_GRANULE_SHIFT-PAGE_SHIFT),
+				nid);
 	if (!page) {
 		mutex_unlock(&uc_pool->add_chunk_mutex);
 		return -1;
diff --git a/arch/ia64/sn/pci/pci_dma.c b/arch/ia64/sn/pci/pci_dma.c
index b7d42e4edc1f..77e24145189c 100644
--- a/arch/ia64/sn/pci/pci_dma.c
+++ b/arch/ia64/sn/pci/pci_dma.c
@@ -92,8 +92,8 @@ static void *sn_dma_alloc_coherent(struct device *dev, size_t size,
 	 */
 	node = pcibus_to_node(pdev->bus);
 	if (likely(node >=0)) {
-		struct page *p = __alloc_pages_node(node,
-						flags, get_order(size));
+		struct page *p = __alloc_pages_node(flags |
+					__GFP_ORDER(get_order(size)), node);
 
 		if (likely(p))
 			cpuaddr = page_address(p);
diff --git a/arch/powerpc/platforms/cell/ras.c b/arch/powerpc/platforms/cell/ras.c
index 2f704afe9af3..8d2dcb07bacd 100644
--- a/arch/powerpc/platforms/cell/ras.c
+++ b/arch/powerpc/platforms/cell/ras.c
@@ -123,9 +123,8 @@ static int __init cbe_ptcal_enable_on_node(int nid, int order)
 
 	area->nid = nid;
 	area->order = order;
-	area->pages = __alloc_pages_node(area->nid,
-						GFP_KERNEL|__GFP_THISNODE,
-						area->order);
+	area->pages = __alloc_pages_node(GFP_KERNEL | __GFP_THISNODE |
+						__GFP_ORDER(area->order), nid);
 
 	if (!area->pages) {
 		printk(KERN_WARNING "%s: no page on node %d\n",
diff --git a/arch/x86/events/intel/ds.c b/arch/x86/events/intel/ds.c
index 7a9f5dac5abe..2de66bd6fac5 100644
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
+	page = __alloc_pages_node(gfp | __GFP_ZERO | __GFP_ORDER(order), node);
 	return page ? page_address(page) : NULL;
 }
 
diff --git a/arch/x86/kvm/vmx/vmx.c b/arch/x86/kvm/vmx/vmx.c
index cbf66e23a1a6..b643057486ff 100644
--- a/arch/x86/kvm/vmx/vmx.c
+++ b/arch/x86/kvm/vmx/vmx.c
@@ -2379,13 +2379,13 @@ static __init int setup_vmcs_config(struct vmcs_config *vmcs_conf,
 	return 0;
 }
 
-struct vmcs *alloc_vmcs_cpu(bool shadow, int cpu, gfp_t flags)
+struct vmcs *alloc_vmcs_cpu(bool shadow, int cpu, gfp_t gfp)
 {
 	int node = cpu_to_node(cpu);
 	struct page *pages;
 	struct vmcs *vmcs;
 
-	pages = __alloc_pages_node(node, flags, vmcs_config.order);
+	pages = __alloc_pages_node(gfp | __GFP_ORDER(vmcs_config.order), node);
 	if (!pages)
 		return NULL;
 	vmcs = page_address(pages);
diff --git a/drivers/misc/sgi-xp/xpc_uv.c b/drivers/misc/sgi-xp/xpc_uv.c
index 0c6de97dd347..ed6c4f42ce8c 100644
--- a/drivers/misc/sgi-xp/xpc_uv.c
+++ b/drivers/misc/sgi-xp/xpc_uv.c
@@ -240,9 +240,8 @@ xpc_create_gru_mq_uv(unsigned int mq_size, int cpu, char *irq_name,
 	mq->mmr_blade = uv_cpu_to_blade_id(cpu);
 
 	nid = cpu_to_node(cpu);
-	page = __alloc_pages_node(nid,
-				      GFP_KERNEL | __GFP_ZERO | __GFP_THISNODE,
-				      pg_order);
+	page = __alloc_pages_node(GFP_KERNEL | __GFP_ZERO | __GFP_THISNODE |
+					__GFP_ORDER(pg_order), nid);
 	if (page == NULL) {
 		dev_err(xpc_part, "xpc_create_gru_mq_uv() failed to alloc %d "
 			"bytes of memory on nid=%d for GRU mq\n", mq_size, nid);
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 6133f77abc91..faf3586419ce 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -487,13 +487,12 @@ static inline struct page *__alloc_pages(gfp_t gfp, int preferred_nid)
  * Allocate pages, preferring the node given as nid. The node must be valid and
  * online. For more general interface, see alloc_pages_node().
  */
-static inline struct page *
-__alloc_pages_node(int nid, gfp_t gfp_mask, unsigned int order)
+static inline struct page *__alloc_pages_node(gfp_t gfp, int nid)
 {
 	VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES);
-	VM_WARN_ON((gfp_mask & __GFP_THISNODE) && !node_online(nid));
+	VM_WARN_ON((gfp & __GFP_THISNODE) && !node_online(nid));
 
-	return __alloc_pages(gfp_mask | __GFP_ORDER(order), nid);
+	return __alloc_pages(gfp, nid);
 }
 
 /*
@@ -507,7 +506,7 @@ static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
 	if (nid == NUMA_NO_NODE)
 		nid = numa_mem_id();
 
-	return __alloc_pages_node(nid, gfp_mask, order);
+	return __alloc_pages_node(gfp_mask | __GFP_ORDER(order), nid);
 }
 
 #ifdef CONFIG_NUMA
diff --git a/kernel/profile.c b/kernel/profile.c
index 9c08a2c7cb1d..1453ac0b1c21 100644
--- a/kernel/profile.c
+++ b/kernel/profile.c
@@ -359,7 +359,7 @@ static int profile_prepare_cpu(unsigned int cpu)
 		if (per_cpu(cpu_profile_hits, cpu)[i])
 			continue;
 
-		page = __alloc_pages_node(node, GFP_KERNEL | __GFP_ZERO, 0);
+		page = __alloc_pages_node(GFP_KERNEL | __GFP_ZERO, node);
 		if (!page) {
 			profile_dead_cpu(cpu);
 			return -ENOMEM;
diff --git a/mm/filemap.c b/mm/filemap.c
index 3ad18fa56057..9a4d0b6e5fc3 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -945,7 +945,7 @@ struct page *__page_cache_alloc(gfp_t gfp)
 		do {
 			cpuset_mems_cookie = read_mems_allowed_begin();
 			n = cpuset_mem_spread_node();
-			page = __alloc_pages_node(n, gfp, 0);
+			page = __alloc_pages_node(gfp, n);
 		} while (!page && read_mems_allowed_retry(cpuset_mems_cookie));
 
 		return page;
diff --git a/mm/gup.c b/mm/gup.c
index 2c08248d4fa2..8427ff9d42e4 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1316,14 +1316,14 @@ static struct page *new_non_cma_page(struct page *page, unsigned long private)
 		 * CMA area again.
 		 */
 		thp_gfpmask &= ~__GFP_MOVABLE;
-		thp = __alloc_pages_node(nid, thp_gfpmask, HPAGE_PMD_ORDER);
+		thp = __alloc_pages_node(thp_gfpmask | __GFP_PMD, nid);
 		if (!thp)
 			return NULL;
 		prep_transhuge_page(thp);
 		return thp;
 	}
 
-	return __alloc_pages_node(nid, gfp_mask, 0);
+	return __alloc_pages_node(nid, gfp_mask);
 }
 
 static long check_and_migrate_cma_pages(struct task_struct *tsk,
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index a335f7c1fac4..2f643ee74edc 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -770,7 +770,7 @@ khugepaged_alloc_page(struct page **hpage, gfp_t gfp, int node)
 {
 	VM_BUG_ON_PAGE(*hpage, *hpage);
 
-	*hpage = __alloc_pages_node(node, gfp, HPAGE_PMD_ORDER);
+	*hpage = __alloc_pages_node(gfp | __GFP_PMD, node);
 	if (unlikely(!*hpage)) {
 		count_vm_event(THP_COLLAPSE_ALLOC_FAILED);
 		*hpage = ERR_PTR(-ENOMEM);
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index e81d4a94878b..a2006e5e0f67 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -974,8 +974,8 @@ struct page *alloc_new_node_page(struct page *page, unsigned long node)
 		prep_transhuge_page(thp);
 		return thp;
 	} else
-		return __alloc_pages_node(node, GFP_HIGHUSER_MOVABLE |
-						    __GFP_THISNODE, 0);
+		return __alloc_pages_node(GFP_HIGHUSER_MOVABLE |
+						    __GFP_THISNODE, node);
 }
 
 /*
@@ -2084,8 +2084,8 @@ alloc_pages_vma(gfp_t gfp, struct vm_area_struct *vma, unsigned long addr,
 		nmask = policy_nodemask(gfp, pol);
 		if (!nmask || node_isset(hpage_node, *nmask)) {
 			mpol_cond_put(pol);
-			page = __alloc_pages_node(hpage_node,
-						gfp | __GFP_THISNODE, 0);
+			page = __alloc_pages_node(gfp | __GFP_THISNODE,
+					hpage_node);
 			goto out;
 		}
 	}
diff --git a/mm/migrate.c b/mm/migrate.c
index f2ecc2855a12..01466e82a387 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1880,11 +1880,10 @@ static struct page *alloc_misplaced_dst_page(struct page *page,
 	int nid = (int) data;
 	struct page *newpage;
 
-	newpage = __alloc_pages_node(nid,
-					 (GFP_HIGHUSER_MOVABLE |
-					  __GFP_THISNODE | __GFP_NOMEMALLOC |
-					  __GFP_NORETRY | __GFP_NOWARN) &
-					 ~__GFP_RECLAIM, 0);
+	newpage = __alloc_pages_node((GFP_HIGHUSER_MOVABLE | __GFP_THISNODE |
+					__GFP_NOMEMALLOC | __GFP_NORETRY |
+					__GFP_NOWARN) & ~__GFP_RECLAIM,
+			nid);
 
 	return newpage;
 }
diff --git a/mm/slab.c b/mm/slab.c
index 2915d912e89a..63c3a8a0d796 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1393,7 +1393,8 @@ static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
 
 	flags |= cachep->allocflags;
 
-	page = __alloc_pages_node(nodeid, flags, cachep->gfporder);
+	page = __alloc_pages_node(flags | __GFP_ORDER(cachep->gfporder),
+				nodeid);
 	if (!page) {
 		slab_out_of_memory(cachep, flags, nodeid);
 		return NULL;
diff --git a/mm/slob.c b/mm/slob.c
index 84aefd9b91ee..510f0941d032 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -194,7 +194,7 @@ static void *slob_new_pages(gfp_t gfp, int order, int node)
 
 #ifdef CONFIG_NUMA
 	if (node != NUMA_NO_NODE)
-		page = __alloc_pages_node(node, gfp, order);
+		page = __alloc_pages_node(gfp | __GFP_ORDER(order), node);
 	else
 #endif
 		page = alloc_pages(gfp, order);
diff --git a/mm/slub.c b/mm/slub.c
index e6ce13c54cb0..51453216a1ed 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1488,7 +1488,7 @@ static inline struct page *alloc_slab_page(struct kmem_cache *s,
 	if (node == NUMA_NO_NODE)
 		page = alloc_pages(flags, order);
 	else
-		page = __alloc_pages_node(node, flags, order);
+		page = __alloc_pages_node(flags | __GFP_ORDER(order), node);
 
 	if (page && memcg_charge_slab(page, flags, order, s)) {
 		__free_pages(page, order);
-- 
2.20.1


Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F1BAC04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 13:50:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 43F89216C4
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 13:50:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="KKpKmH9R"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 43F89216C4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 883806B0292; Fri, 10 May 2019 09:50:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 660086B0287; Fri, 10 May 2019 09:50:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 29ECD6B0289; Fri, 10 May 2019 09:50:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id C9B2F6B0289
	for <linux-mm@kvack.org>; Fri, 10 May 2019 09:50:42 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id a17so3733559pls.5
        for <linux-mm@kvack.org>; Fri, 10 May 2019 06:50:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=IH5sYaGTLmuEqV+PYxXcRKN75X7GsCPszHle6ldwerc=;
        b=CmpYIs285I9kyXot4r53nAbcmCwln1ZMFDR5rMcuzMJljNzYAy5TIzb4YVbpfkFekx
         yQnPGv8eBNPN/w+ZKrwgX2sWrmyuFw7H7JUJYQseB4awPgBt2JAY9gDiC0RYOKko4oTK
         P9GLAFKRmijtFT04jBxBTkkZ+WTch1n7TouUXGi2SUd7IN7LE/K7RVoiVqrmn+TliPst
         sEeskZXaal6YP0NSCa9dCMZPFKEEykMRW5NIU0f7Kw7n/rdPLSI770TtHIOm4UoPSPfv
         o0z64m0rkF1wK68SOaKuKkY+pybhOw7T5rrT65YvRMBnnN9BmgenI/tiy7TrQzQMZhnY
         u2vQ==
X-Gm-Message-State: APjAAAU4o95Kz5w91KDfIAfYMpyE3OQ1l4bJtjBSyKHD2uTJ86pSKMl3
	49oZGl/fOnIGT1p9A6S5Co9NKxmGaB/pzwwp9ekGS77q86SmhLCcYMq3MtnY1GqxnmL12bKPte+
	biEch+TMETlKR26CbsGs4Urd6UtdEs88uUyif/okCl5q4OtNsNTOG/eL/Yq8v11Tphw==
X-Received: by 2002:a62:528b:: with SMTP id g133mr14232383pfb.246.1557496242425;
        Fri, 10 May 2019 06:50:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyv8255UOkeh1lkBqE3LQhZaz7FlhbEfJKH2HlcmWv2YBEAGDL4GCXL47O6QvHd6lID/G21
X-Received: by 2002:a62:528b:: with SMTP id g133mr14232258pfb.246.1557496241525;
        Fri, 10 May 2019 06:50:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557496241; cv=none;
        d=google.com; s=arc-20160816;
        b=eWqWEItkG1PrdF3GImriOQO9at5OdJGEt0/zk9MqWOWkO+StTP2gonDP5FHXPmYX49
         90HqRkAXQY7Cg3NTGr5zTaFk9/i3zrt6hV3CAIGGKkT8qkWXCL8dhcUO6hdapzweIl3T
         v8ft0KyTb5sX4yWu38tQa3lj7UYni444PJ9kn3ORphZxQQ7bo2TejJuM7xZ1/kWA4Gmk
         bMWNR3MUvKz8RpdyXsH2wabMhWr05wgNfFtQ+w56WizvYkBguR+t03HQqavA+gj+TSCA
         GL/w7u4gUh+3OP6JLKAb+53Zk+F5JTb3Hz8H/MSl9SaMKmP9mkllKFT/XclRDvS1B6Ix
         imkg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=IH5sYaGTLmuEqV+PYxXcRKN75X7GsCPszHle6ldwerc=;
        b=RRNkuKpM8MGI8eplTyaFkYdXDBaQ3ngNLD3aVm7L5CJ6Uu2MKnJ2MQzOjNOfIoCO1A
         HnkyMzeKF/2EMmPntuJr6I156NEA1uGGNGytxgqmQ0jeKACH1B3mNgPd+Bgb3L25ilfL
         MhCiWrudndD23T3bTuwpwLzyzNmhCOqZ4tZ9QjUTJbJIrCd+91Lc4q5qz1GrPnyPwyeA
         2HknrsAZi8Gi4L3C5QwVKIqGETd7NU1n0Bync4MImvpw+607qf47LCR7e0BSC51LOhvo
         TRTY+aKVqMyqCu+W8YJlUr1b1RwzNnCWyfUiSa7Mmf9wHrUGlf82wNwd7m1D4HpPNxRN
         DJHg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=KKpKmH9R;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y9si7570588pgq.233.2019.05.10.06.50.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 10 May 2019 06:50:41 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=KKpKmH9R;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=References:In-Reply-To:Message-Id:
	Date:Subject:Cc:To:From:Sender:Reply-To:MIME-Version:Content-Type:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=IH5sYaGTLmuEqV+PYxXcRKN75X7GsCPszHle6ldwerc=; b=KKpKmH9Rmr9oBQhDLdvKxiel5
	H+CC9S9wN+/usTQouzfL8dMTFSxotJdL3h6pQrNLYkCx/6jikLD37bHF4Vgtcj7ibunr0DMLzVS8Z
	gDIIuzVFU8qkX5bfy0NGotuKP4nmPyMXRudKZi94+nvi0ApxjtcD1N4maAdcBREQSss/MmwcMm291
	IPxtgverV9/C1njFH+TpHOC6nOvdmgOMhT1CPHCICF0PaB+k/zWUJjbubzuACg/Pxd1zScGINLkEH
	EwKwCB0XUf2FW4aExnrEeIMrpWJX9BNYEBrECSvLf1mn0pHSp+MFnK0ylLrtMyTaj4swIOB9Aw5Xe
	0NhWCgORg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hP5v7-0004Tr-1v; Fri, 10 May 2019 13:50:41 +0000
From: Matthew Wilcox <willy@infradead.org>
To: linux-mm@kvack.org
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>
Subject: [PATCH v2 06/15] mm: Pass order to alloc_pages_vma in GFP flags
Date: Fri, 10 May 2019 06:50:29 -0700
Message-Id: <20190510135038.17129-7-willy@infradead.org>
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

Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
---
 include/linux/gfp.h | 20 ++++++++++----------
 mm/mempolicy.c      | 15 +++++++--------
 mm/shmem.c          |  5 +++--
 3 files changed, 20 insertions(+), 20 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 94ba8a6172e4..6133f77abc91 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -518,24 +518,24 @@ alloc_pages(gfp_t gfp_mask, unsigned int order)
 {
 	return alloc_pages_current(gfp_mask | __GFP_ORDER(order));
 }
-extern struct page *alloc_pages_vma(gfp_t gfp_mask, int order,
-			struct vm_area_struct *vma, unsigned long addr,
-			int node, bool hugepage);
-#define alloc_hugepage_vma(gfp_mask, vma, addr, order) \
-	alloc_pages_vma(gfp_mask, order, vma, addr, numa_node_id(), true)
+extern struct page *alloc_pages_vma(gfp_t gfp, struct vm_area_struct *vma,
+		unsigned long addr, int node, bool hugepage);
+#define alloc_hugepage_vma(gfp, vma, addr, order) \
+	alloc_pages_vma(gfp | __GFP_ORDER(order), vma, addr, numa_node_id(), \
+			true)
 #else
 #define alloc_pages(gfp_mask, order) \
-		alloc_pages_node(numa_node_id(), gfp_mask, order)
-#define alloc_pages_vma(gfp_mask, order, vma, addr, node, false)\
-	alloc_pages(gfp_mask, order)
+	alloc_pages_node(numa_node_id(), gfp_mask, order)
+#define alloc_pages_vma(gfp, vma, addr, node, false) \
+	alloc_pages(gfp, 0)
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
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index eec0b9c21962..e81d4a94878b 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2032,7 +2032,6 @@ static struct page *alloc_page_interleave(gfp_t gfp, unsigned nid)
  *      %GFP_FS      allocation should not call back into a file system.
  *      %GFP_ATOMIC  don't sleep.
  *
- *	@order:Order of the GFP allocation.
  * 	@vma:  Pointer to VMA or NULL if not available.
  *	@addr: Virtual Address of the allocation. Must be inside the VMA.
  *	@node: Which node to prefer for allocation (modulo policy).
@@ -2046,8 +2045,8 @@ static struct page *alloc_page_interleave(gfp_t gfp, unsigned nid)
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
@@ -2059,9 +2058,10 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
 	if (pol->mode == MPOL_INTERLEAVE) {
 		unsigned nid;
 
-		nid = interleave_nid(pol, vma, addr, PAGE_SHIFT + order);
+		nid = interleave_nid(pol, vma, addr,
+				PAGE_SHIFT + gfp_order(gfp));
 		mpol_cond_put(pol);
-		page = alloc_page_interleave(gfp | __GFP_ORDER(order), nid);
+		page = alloc_page_interleave(gfp, nid);
 		goto out;
 	}
 
@@ -2085,15 +2085,14 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
 		if (!nmask || node_isset(hpage_node, *nmask)) {
 			mpol_cond_put(pol);
 			page = __alloc_pages_node(hpage_node,
-						gfp | __GFP_THISNODE, order);
+						gfp | __GFP_THISNODE, 0);
 			goto out;
 		}
 	}
 
 	nmask = policy_nodemask(gfp, pol);
 	preferred_nid = policy_node(gfp, pol, node);
-	page = __alloc_pages_nodemask(gfp | __GFP_ORDER(order), preferred_nid,
-			nmask);
+	page = __alloc_pages_nodemask(gfp, preferred_nid, nmask);
 	mpol_cond_put(pol);
 out:
 	return page;
diff --git a/mm/shmem.c b/mm/shmem.c
index 1bb3b8dc8bb2..fdbab5dbf1fd 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1463,8 +1463,9 @@ static struct page *shmem_alloc_hugepage(gfp_t gfp,
 		return NULL;
 
 	shmem_pseudo_vma_init(&pvma, info, hindex);
-	page = alloc_pages_vma(gfp | __GFP_COMP | __GFP_NORETRY | __GFP_NOWARN,
-			HPAGE_PMD_ORDER, &pvma, 0, numa_node_id(), true);
+	page = alloc_pages_vma(gfp | __GFP_COMP | __GFP_NORETRY |
+					__GFP_NOWARN | __GFP_PMD,
+			&pvma, 0, numa_node_id(), true);
 	shmem_pseudo_vma_destroy(&pvma);
 	if (page)
 		prep_transhuge_page(page);
-- 
2.20.1


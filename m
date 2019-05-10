Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24C3AC04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 13:50:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A9BD4216C4
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 13:50:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="MF2iXPw7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A9BD4216C4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F5986B028B; Fri, 10 May 2019 09:50:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 07C006B028C; Fri, 10 May 2019 09:50:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E37F36B028B; Fri, 10 May 2019 09:50:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id AA4096B0287
	for <linux-mm@kvack.org>; Fri, 10 May 2019 09:50:42 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 5so4154433pff.11
        for <linux-mm@kvack.org>; Fri, 10 May 2019 06:50:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=yieLPTiJ/w5q+ZATwrCdQrxoQxWL2rhW/PBUbYFBM/8=;
        b=C0NNhDsEIlBLNAkVhe+OsyyKzpJyodq4zsew4ljsQfNKF7q/5O+hPTJ8lrsOpBmhRG
         uj/KJq/b9YEjAvi5dBbj8R97pWZR8Mv1u95wpGOCOTdWahRIi9cJUIBwFgZomKdA7yrK
         fe0hUdAnalfypY/bTev+DjwHbjArzwTy5lqQmAwXdnjZcEOYZrbHGAzjJdP/Yc5JzYXn
         C3h7Ewue3l1vYUA4C12SRtqPwTvgraNNVqL16yASlMqSxR1/QvOk2AJFKlAwIFWXwuPF
         rub+5OpsMCuDqH0zruCsBJP7/3/i/ScB4hUmBlB2FmzKLFGgAr3EVxYJtXrpvYXMupfT
         uf1w==
X-Gm-Message-State: APjAAAV4LJ04oRjBC+RFF2v1H7eGIEBnQjn5i++Qb17aY+kNAuEyEe3W
	7Ajx5AfOu6L0gAhUS5GY8SN0Bb9z43NPMWc5+XTpCeJ3hCRvDP2x7W5yB7B7MDBTRcX75iuOMVT
	ttwGX8NEKq0jjD2rbHBHsAnFjkIVj26vaT5FpRoVy/wPaZ9BjGI/+r1TrRgcshJ9gTA==
X-Received: by 2002:a17:902:7486:: with SMTP id h6mr13036872pll.58.1557496242196;
        Fri, 10 May 2019 06:50:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwlOfjURb50W7fAFMdbEhHOTPPc/cXiCQR01ezgYYUQg9Ac3OTkISaubH1md5nIHbxrljQ+
X-Received: by 2002:a17:902:7486:: with SMTP id h6mr13036729pll.58.1557496240902;
        Fri, 10 May 2019 06:50:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557496240; cv=none;
        d=google.com; s=arc-20160816;
        b=IjVz5GPJB5rSkuapUrUBMzIbAzjjyHsiEL8LccDZw6FRsgg1Z/MVgK7Z8BVd7wuDdA
         bGdItgHGrNgQo9pB7n75+oiaIh8WkP0cTTAtUHbM/mJWnKrtuIdPhE5xQp7kVkaZtsls
         vl6eRB/b0FRzyFpFTZEvEEWLD6YvxJZEqs3+A48gTEDdGtxTF4KMkcX5Ev+KylInRE9y
         X/v/VQTrrxz6w+zgiljyXBVv6vB0TqkZRgnwnGt8xej12bEp4QElOMehwUYzmLC5RWLx
         PysgLf4QWLMnlUel1eJCYu8VbykwFc4Q6UKYnmE87aVQ9tb9fUB0sT0IgGJpojjaVjzv
         dDIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=yieLPTiJ/w5q+ZATwrCdQrxoQxWL2rhW/PBUbYFBM/8=;
        b=jJZW6ME6rC5homL9l/eEDM6GtBVDi21tuREf3c0Ww1nFE5kBP4VCQXQrT/h/2qIRc4
         5keRsMBuaXn5NB4XVHpOEX2GgSvQh81FHF9f2warSAYcL+NsJbFrM6Xsah+xNjCxGDlc
         im3RmkBRfUYlr36yw2h4kVu/UNhBWuf3JblX0dgssbGgd8QPTIfCCT6XCUhuHQkeNHcD
         eK5HPimOcPW2WtwNdTYN+/qlxGvN/F2tEwWxew9oK0Zoppfi9LlXu4reMPhHcTUDFwVY
         iGTvrdCGdJY4WSYwZ5W232J33E/g1qe2A7sGKLEyR7a4h7E0gVvd2u+VBCNzatJGZ3de
         S13A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=MF2iXPw7;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c10si8097501pge.278.2019.05.10.06.50.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 10 May 2019 06:50:40 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=MF2iXPw7;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=References:In-Reply-To:Message-Id:
	Date:Subject:Cc:To:From:Sender:Reply-To:MIME-Version:Content-Type:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=yieLPTiJ/w5q+ZATwrCdQrxoQxWL2rhW/PBUbYFBM/8=; b=MF2iXPw7lxMPJw4ZofckmxXe5
	5vTSFP9+9VQApg9apttxp0tzYyuBmYas3yfKBrpCJzWn++vvcSptrSrX1+y9dBsys+RlP2T/ya5WQ
	eqL+euBAFQVP9grVc5RxtV/KpvSVozM/g7Faqunurm6esHvwzpUNnj3YWSRLXein1UJ58e7foFACs
	jVlwY0CFmsJ1Et8LMa+/DHEAzQx5xt/Z5eOwBPN0RszmUdDbGfh4uqu+rl30IR2jTLFsggy1bY47s
	A0v8Gub33AKP5st2JK+hbuo7mBUZ05745Le60VA42UV5fSyoCIrgHLmcXQyD1RhmCAYqCAR85rSUf
	1KIbNZhlQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hP5v6-0004TR-D9; Fri, 10 May 2019 13:50:40 +0000
From: Matthew Wilcox <willy@infradead.org>
To: linux-mm@kvack.org
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>
Subject: [PATCH v2 02/15] mm: Pass order to __alloc_pages_nodemask in GFP flags
Date: Fri, 10 May 2019 06:50:25 -0700
Message-Id: <20190510135038.17129-3-willy@infradead.org>
X-Mailer: git-send-email 2.14.5
In-Reply-To: <20190510135038.17129-1-willy@infradead.org>
References: <20190510135038.17129-1-willy@infradead.org>
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
 include/linux/gfp.h     | 18 +++++++++++++++---
 include/linux/migrate.h |  2 +-
 mm/hugetlb.c            |  5 +++--
 mm/mempolicy.c          |  5 +++--
 mm/page_alloc.c         |  4 ++--
 5 files changed, 24 insertions(+), 10 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index fb07b503dc45..c466b08df0ec 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -219,6 +219,18 @@ struct vm_area_struct;
 /* Room for N __GFP_FOO bits */
 #define __GFP_BITS_SHIFT (23 + IS_ENABLED(CONFIG_LOCKDEP))
 #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
+#define __GFP_ORDER(order) ((__force gfp_t)(order << __GFP_BITS_SHIFT))
+#define __GFP_PMD	__GFP_ORDER(PMD_SHIFT - PAGE_SHIFT)
+#define __GFP_PUD	__GFP_ORDER(PUD_SHIFT - PAGE_SHIFT)
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
@@ -464,13 +476,13 @@ static inline void arch_alloc_page(struct page *page, int order) { }
 #endif
 
 struct page *
-__alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order, int preferred_nid,
-							nodemask_t *nodemask);
+__alloc_pages_nodemask(gfp_t gfp_mask, int preferred_nid, nodemask_t *nodemask);
 
 static inline struct page *
 __alloc_pages(gfp_t gfp_mask, unsigned int order, int preferred_nid)
 {
-	return __alloc_pages_nodemask(gfp_mask, order, preferred_nid, NULL);
+	return __alloc_pages_nodemask(gfp_mask | __GFP_ORDER(order),
+			preferred_nid, NULL);
 }
 
 /*
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
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index bf58cee30f65..c8ee747ca437 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1409,10 +1409,11 @@ static struct page *alloc_buddy_huge_page(struct hstate *h,
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
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 2219e747df49..310ad69effdd 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2093,7 +2093,8 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
 
 	nmask = policy_nodemask(gfp, pol);
 	preferred_nid = policy_node(gfp, pol, node);
-	page = __alloc_pages_nodemask(gfp, order, preferred_nid, nmask);
+	page = __alloc_pages_nodemask(gfp | __GFP_ORDER(order), preferred_nid,
+			nmask);
 	mpol_cond_put(pol);
 out:
 	return page;
@@ -2129,7 +2130,7 @@ struct page *alloc_pages_current(gfp_t gfp, unsigned order)
 	if (pol->mode == MPOL_INTERLEAVE)
 		page = alloc_page_interleave(gfp, order, interleave_nodes(pol));
 	else
-		page = __alloc_pages_nodemask(gfp, order,
+		page = __alloc_pages_nodemask(gfp | __GFP_ORDER(order),
 				policy_node(gfp, pol, numa_node_id()),
 				policy_nodemask(gfp, pol));
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 57373327712e..6e968ab91660 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4622,11 +4622,11 @@ static inline void finalise_ac(gfp_t gfp_mask, struct alloc_context *ac)
  * This is the 'heart' of the zoned buddy allocator.
  */
 struct page *
-__alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order, int preferred_nid,
-							nodemask_t *nodemask)
+__alloc_pages_nodemask(gfp_t gfp_mask, int preferred_nid, nodemask_t *nodemask)
 {
 	struct page *page;
 	unsigned int alloc_flags = ALLOC_WMARK_LOW;
+	unsigned int order = gfp_order(gfp_mask);
 	gfp_t alloc_mask; /* The gfp_t that was actually used for allocation */
 	struct alloc_context ac = { };
 
-- 
2.20.1


Return-Path: <SRS0=Y66U=TD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D99FC04AAA
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 22:31:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E30152075C
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 22:31:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E30152075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5764A6B0007; Fri,  3 May 2019 18:31:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4D6C76B0006; Fri,  3 May 2019 18:31:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 377FB6B000A; Fri,  3 May 2019 18:31:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 121486B0006
	for <linux-mm@kvack.org>; Fri,  3 May 2019 18:31:50 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id l10so1711873qtr.1
        for <linux-mm@kvack.org>; Fri, 03 May 2019 15:31:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=GN51UgZc6Y09j3phTV9QjPDdlWRI/4+mWG6WvUJgDvY=;
        b=adXN8zYcxM2tHEpAxk4FJK6r5y2qVUpg3OafR/bJsbydUWcg7zLDwBMN5Gc8LG/H6f
         tOudZqYdXfdOAxHX0/MNQGloDs8xP18qXkun7fy/boO7l/FznkwvAxgVaH57aIG6gyNt
         RhMotWEd5IzuaddAYx2TdORS/YteiVsC8CqezOcXawLZ/8ser3Pi1c5mcTrJgt+MOp4w
         IJkEQCHMh6cG3Eae5eCUDaUMJihcLQJeG05rNsTnrKJg6IEGzJiy3iYhddCOsN3g2p/w
         wfw2LzLDj55OB10j+5Id5MW9nDG69d/aKVaO5JW3hkpTuE00xgEbFcKGRSuexUNmad63
         xvXw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW7UHke9kS/ga8GQ9YyG7ijG0Ey31PX5OlRJneToKZrYF8R4sbX
	tlN8RqZhSqyxzC6MKr28bM1mEtCiNCDFhHB+8uO9OstPmSHA9651lZUNn4ZMgjqT+9N5zNbA4aJ
	B2VvwMeTn7KxECzeu/Xc5sVetDnGquqzlnIe+n7x3lVrlMjvr63mDmSfDOoTuYt8FKg==
X-Received: by 2002:a37:4ad5:: with SMTP id x204mr10415492qka.324.1556922709796;
        Fri, 03 May 2019 15:31:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwFtYPKMxNGgwEi/PTY5k/ruaDlwsQcWSajZVQvavPoOflhbeGgswt4+DKHtmqNqd1+64wv
X-Received: by 2002:a37:4ad5:: with SMTP id x204mr10415407qka.324.1556922708716;
        Fri, 03 May 2019 15:31:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556922708; cv=none;
        d=google.com; s=arc-20160816;
        b=V4kqizA2PCJ4+7pWd4QclBxNgQIFYnbu3AdtErXDDz35P1hVzt/dXnDzRMVpxn6aO6
         reRIDhaHNwRiZjPO2h1Kf5C/hTkphgi1VXtoxZeBL8vvPljtgaaU74MPWMtKz5289iIw
         cTeimY0FjNjDiuFob30dGKYewTzmAKocMqL0dIb6IINz9hRAtMIVmOt2zSQvHroDOgU+
         mrj+8JdhAFe1qaXdFWNJKsZyJeKmZTmd4n+cj31uCFEOkTFqjyw9jgX73UvPte1M6ebN
         1prZAU6fBBlq0p4H7DFiMyTSsSAbu/eJofsirnpOzUK26PemhjdIy5BQB8AhVN452L0J
         LeqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=GN51UgZc6Y09j3phTV9QjPDdlWRI/4+mWG6WvUJgDvY=;
        b=lFFK+iIphwDI6VKp7dbRLKQzLz9CwY/kFKF2BffD9wmZyayfpADZC0SrDtoWeXoOuI
         21VCvDQ5qD/65i+91PPT6/jZ4M7t4RY2x9TYHMDfs6A9r665K+3nxBYL3g3Ly15c5H1b
         pm1ZTeoKykbHa8H17n1Qmqp3VwC9b4DwQY2YcX/urPTx1qjMQtOz3pH4yYQEx0MREiZp
         0Zmig9zgZMNe80UJGAFTb5jAcBzQi/L+xMU41N69HQKISBbsnhNh6tCvUk/1xQksRwkK
         QumAxvr8d1AaTEYYc1VP4kkBldKFKowUULyfAfi3Ppb8gJ0lh5t0GngyTWoInJtjB5hb
         gSFw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p31si747716qtj.314.2019.05.03.15.31.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 May 2019 15:31:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id CA66330832C8;
	Fri,  3 May 2019 22:31:47 +0000 (UTC)
Received: from ultra.random (ovpn-122-217.rdu2.redhat.com [10.10.122.217])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 477271001959;
	Fri,  3 May 2019 22:31:47 +0000 (UTC)
From: Andrea Arcangeli <aarcange@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>,
	Mel Gorman <mgorman@suse.de>,
	Vlastimil Babka <vbabka@suse.cz>,
	David Rientjes <rientjes@google.com>,
	Zi Yan <zi.yan@cs.rutgers.edu>,
	Stefan Priebe - Profihost AG <s.priebe@profihost.ag>,
	"Kirill A. Shutemov" <kirill@shutemov.name>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 1/2] Revert "Revert "mm, thp: consolidate THP gfp handling into alloc_hugepage_direct_gfpmask""
Date: Fri,  3 May 2019 18:31:45 -0400
Message-Id: <20190503223146.2312-2-aarcange@redhat.com>
In-Reply-To: <20190503223146.2312-1-aarcange@redhat.com>
References: <20190503223146.2312-1-aarcange@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Fri, 03 May 2019 22:31:48 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This reverts commit 356ff8a9a78fb35d6482584d260c3754dcbdf669.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/gfp.h | 12 ++++--------
 mm/huge_memory.c    | 27 ++++++++++++++-------------
 mm/mempolicy.c      | 32 +++-----------------------------
 mm/shmem.c          |  2 +-
 4 files changed, 22 insertions(+), 51 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index fdab7de7490d..e2a6aea3f8ec 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -510,22 +510,18 @@ alloc_pages(gfp_t gfp_mask, unsigned int order)
 }
 extern struct page *alloc_pages_vma(gfp_t gfp_mask, int order,
 			struct vm_area_struct *vma, unsigned long addr,
-			int node, bool hugepage);
-#define alloc_hugepage_vma(gfp_mask, vma, addr, order) \
-	alloc_pages_vma(gfp_mask, order, vma, addr, numa_node_id(), true)
+			int node);
 #else
 #define alloc_pages(gfp_mask, order) \
 		alloc_pages_node(numa_node_id(), gfp_mask, order)
-#define alloc_pages_vma(gfp_mask, order, vma, addr, node, false)\
-	alloc_pages(gfp_mask, order)
-#define alloc_hugepage_vma(gfp_mask, vma, addr, order) \
+#define alloc_pages_vma(gfp_mask, order, vma, addr, node)\
 	alloc_pages(gfp_mask, order)
 #endif
 #define alloc_page(gfp_mask) alloc_pages(gfp_mask, 0)
 #define alloc_page_vma(gfp_mask, vma, addr)			\
-	alloc_pages_vma(gfp_mask, 0, vma, addr, numa_node_id(), false)
+	alloc_pages_vma(gfp_mask, 0, vma, addr, numa_node_id())
 #define alloc_page_vma_node(gfp_mask, vma, addr, node)		\
-	alloc_pages_vma(gfp_mask, 0, vma, addr, node, false)
+	alloc_pages_vma(gfp_mask, 0, vma, addr, node)
 
 extern unsigned long __get_free_pages(gfp_t gfp_mask, unsigned int order);
 extern unsigned long get_zeroed_page(gfp_t gfp_mask);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 165ea46bf149..7efe68ba052a 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -641,30 +641,30 @@ static vm_fault_t __do_huge_pmd_anonymous_page(struct vm_fault *vmf,
  *	    available
  * never: never stall for any thp allocation
  */
-static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma)
+static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma, unsigned long addr)
 {
 	const bool vma_madvised = !!(vma->vm_flags & VM_HUGEPAGE);
+	const gfp_t gfp_mask = GFP_TRANSHUGE_LIGHT | __GFP_THISNODE;
 
 	/* Always do synchronous compaction */
 	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG, &transparent_hugepage_flags))
-		return GFP_TRANSHUGE | (vma_madvised ? 0 : __GFP_NORETRY);
+		return GFP_TRANSHUGE | __GFP_THISNODE |
+		       (vma_madvised ? 0 : __GFP_NORETRY);
 
 	/* Kick kcompactd and fail quickly */
 	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG, &transparent_hugepage_flags))
-		return GFP_TRANSHUGE_LIGHT | __GFP_KSWAPD_RECLAIM;
+		return gfp_mask | __GFP_KSWAPD_RECLAIM;
 
 	/* Synchronous compaction if madvised, otherwise kick kcompactd */
 	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_OR_MADV_FLAG, &transparent_hugepage_flags))
-		return GFP_TRANSHUGE_LIGHT |
-			(vma_madvised ? __GFP_DIRECT_RECLAIM :
-					__GFP_KSWAPD_RECLAIM);
+		return gfp_mask | (vma_madvised ? __GFP_DIRECT_RECLAIM :
+						  __GFP_KSWAPD_RECLAIM);
 
 	/* Only do synchronous compaction if madvised */
 	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG, &transparent_hugepage_flags))
-		return GFP_TRANSHUGE_LIGHT |
-		       (vma_madvised ? __GFP_DIRECT_RECLAIM : 0);
+		return gfp_mask | (vma_madvised ? __GFP_DIRECT_RECLAIM : 0);
 
-	return GFP_TRANSHUGE_LIGHT;
+	return gfp_mask;
 }
 
 /* Caller must hold page table lock. */
@@ -736,8 +736,8 @@ vm_fault_t do_huge_pmd_anonymous_page(struct vm_fault *vmf)
 			pte_free(vma->vm_mm, pgtable);
 		return ret;
 	}
-	gfp = alloc_hugepage_direct_gfpmask(vma);
-	page = alloc_hugepage_vma(gfp, vma, haddr, HPAGE_PMD_ORDER);
+	gfp = alloc_hugepage_direct_gfpmask(vma, haddr);
+	page = alloc_pages_vma(gfp, HPAGE_PMD_ORDER, vma, haddr, numa_node_id());
 	if (unlikely(!page)) {
 		count_vm_event(THP_FAULT_FALLBACK);
 		return VM_FAULT_FALLBACK;
@@ -1340,8 +1340,9 @@ vm_fault_t do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
 alloc:
 	if (__transparent_hugepage_enabled(vma) &&
 	    !transparent_hugepage_debug_cow()) {
-		huge_gfp = alloc_hugepage_direct_gfpmask(vma);
-		new_page = alloc_hugepage_vma(huge_gfp, vma, haddr, HPAGE_PMD_ORDER);
+		huge_gfp = alloc_hugepage_direct_gfpmask(vma, haddr);
+		new_page = alloc_pages_vma(huge_gfp, HPAGE_PMD_ORDER, vma,
+				haddr, numa_node_id());
 	} else
 		new_page = NULL;
 
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 2219e747df49..74e44000ad61 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1142,8 +1142,8 @@ static struct page *new_page(struct page *page, unsigned long start)
 	} else if (PageTransHuge(page)) {
 		struct page *thp;
 
-		thp = alloc_hugepage_vma(GFP_TRANSHUGE, vma, address,
-					 HPAGE_PMD_ORDER);
+		thp = alloc_pages_vma(GFP_TRANSHUGE, HPAGE_PMD_ORDER, vma,
+				address, numa_node_id());
 		if (!thp)
 			return NULL;
 		prep_transhuge_page(thp);
@@ -2037,7 +2037,6 @@ static struct page *alloc_page_interleave(gfp_t gfp, unsigned order,
  * 	@vma:  Pointer to VMA or NULL if not available.
  *	@addr: Virtual Address of the allocation. Must be inside the VMA.
  *	@node: Which node to prefer for allocation (modulo policy).
- *	@hugepage: for hugepages try only the preferred node if possible
  *
  * 	This function allocates a page from the kernel page pool and applies
  *	a NUMA policy associated with the VMA or the current process.
@@ -2048,7 +2047,7 @@ static struct page *alloc_page_interleave(gfp_t gfp, unsigned order,
  */
 struct page *
 alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
-		unsigned long addr, int node, bool hugepage)
+		unsigned long addr, int node)
 {
 	struct mempolicy *pol;
 	struct page *page;
@@ -2066,31 +2065,6 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
 		goto out;
 	}
 
-	if (unlikely(IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE) && hugepage)) {
-		int hpage_node = node;
-
-		/*
-		 * For hugepage allocation and non-interleave policy which
-		 * allows the current node (or other explicitly preferred
-		 * node) we only try to allocate from the current/preferred
-		 * node and don't fall back to other nodes, as the cost of
-		 * remote accesses would likely offset THP benefits.
-		 *
-		 * If the policy is interleave, or does not allow the current
-		 * node in its nodemask, we allocate the standard way.
-		 */
-		if (pol->mode == MPOL_PREFERRED && !(pol->flags & MPOL_F_LOCAL))
-			hpage_node = pol->v.preferred_node;
-
-		nmask = policy_nodemask(gfp, pol);
-		if (!nmask || node_isset(hpage_node, *nmask)) {
-			mpol_cond_put(pol);
-			page = __alloc_pages_node(hpage_node,
-						gfp | __GFP_THISNODE, order);
-			goto out;
-		}
-	}
-
 	nmask = policy_nodemask(gfp, pol);
 	preferred_nid = policy_node(gfp, pol, node);
 	page = __alloc_pages_nodemask(gfp, order, preferred_nid, nmask);
diff --git a/mm/shmem.c b/mm/shmem.c
index 2275a0ff7c30..ed7ebc423c6b 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1464,7 +1464,7 @@ static struct page *shmem_alloc_hugepage(gfp_t gfp,
 
 	shmem_pseudo_vma_init(&pvma, info, hindex);
 	page = alloc_pages_vma(gfp | __GFP_COMP | __GFP_NORETRY | __GFP_NOWARN,
-			HPAGE_PMD_ORDER, &pvma, 0, numa_node_id(), true);
+			HPAGE_PMD_ORDER, &pvma, 0, numa_node_id());
 	shmem_pseudo_vma_destroy(&pvma);
 	if (page)
 		prep_transhuge_page(page);


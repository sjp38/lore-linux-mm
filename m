Return-Path: <SRS0=h8p8=S5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27053C43218
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 01:40:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CCB26208CB
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 01:40:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="hk0UKNlK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CCB26208CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 80B9E6B0008; Fri, 26 Apr 2019 21:40:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7BD686B000A; Fri, 26 Apr 2019 21:40:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C0DE6B000C; Fri, 26 Apr 2019 21:40:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 24ECB6B0008
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 21:40:48 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id n63so3269830pfb.14
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 18:40:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=chT8OS7V7aG4kND6hPsqaJn82nGDD4o8uKrdvH1mxMY=;
        b=omWOCMZ8YfoHRfdkcPhQ0zRVrq8VUUiPUCYNejHgMOYLOmmh9djY+UwliojF8UL2G6
         htbkQhtTDWNjxs+CekPCAgFBRLRXY9ldKWqs5iPbEpMh8b97QRNeAyAJiF1bdkbKnvtT
         vcK8HdOg8qTD00jsIOWRJTlHz1nWzwtobku9lH3Z3fCPn8LOEVku6FWySc7KVKMTek2R
         XDEZi6aI2Lxf51R/TwWqyqJhX8nj/aeK9WZ0Fqe2h8445Ezm99I/5tIkk902oMwDQAQu
         q8dGe9LlO2h+xGqnxWlZkjyr4PCtqr8ofYZny73aq4yK4f0sYVFd5Og7YJiFMgQFkleJ
         wG8g==
X-Gm-Message-State: APjAAAWzYZVABNjn+xnQpXp+3p5m/vy8k5HWz6rPwC4ONwARvWIB5SWH
	i6smXN5WBlGW8bVAq8sq9SKEXNe2FGcnr+WksKwa8+qodB+hp9iTEIYltWPwwDKcEpac8wmhW5U
	ugu1qns876JVq3QIQXvvE9l5WK5Fu2Z3XksfnUrc/5xOukvO62mabQo9QTX3Xza8Znw==
X-Received: by 2002:a63:8dc9:: with SMTP id z192mr3472454pgd.6.1556329247802;
        Fri, 26 Apr 2019 18:40:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyLiJb2gzhD/aYXfpBcFAnha3gFUsIrBxIDyDtIJJChK4Lsq04/RX0ROsiSTuBkVZW2Mkrj
X-Received: by 2002:a63:8dc9:: with SMTP id z192mr3472411pgd.6.1556329246937;
        Fri, 26 Apr 2019 18:40:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556329246; cv=none;
        d=google.com; s=arc-20160816;
        b=Ak7s0rdfgPjt2OIM/vDTAJ+Hp50g9rixSBeFggQkcD/vef//xIktwpBAZjv2qwDTkO
         Cy121E9W+Oq35Uey1Y6dJ6RXnMmffu/O61kxIYiGGp5s6vKJFBdpDYjr5spVY4YMY6BC
         TZs4/RgKaiDSbozf7ss2oz7SulVIRiHEyLbmfWyvwQuFPxpFZffxPeL/9mtUe1vrB3yW
         3Dh3D/ToN83BF/SpO5pCRLBnWxaeZ4tK+Wg4NaZGPAHFRij5cPKOCcPOXWiQfDxYMsR2
         Sm8cw+Cm2oy234O4ZSNe2O3jdFe7kbqK8pitQuGJoyQb4rzw6meBzj9hqMp3g2DN6P3l
         uFrw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=chT8OS7V7aG4kND6hPsqaJn82nGDD4o8uKrdvH1mxMY=;
        b=KiH8I554nYYSFcXZajJHnbpl9/B65R3x0CX7AY3zoNn+LWOR+xWsRh823Dmznw8eMP
         stHeiRiA59Th5UBHYlEWpR1kkeJkNqzFlmMEMvDBvaMR85WshQtI9vFQc1mdyjJ3gDLI
         Lgtm+XbwIHQVPFWkrD4F0V66iR/bH1F1Z8Xfi256Ni+GEZBWWW9lp/tyNXiFhiLhBs9C
         g8qxdwnvNUZ99q81wFq/+U3aUb0RVTyCGRhCY/FxRP+RJEAepwIw4a1cyzU5iJg9PYzi
         JE6ePkkVKpuh91tCzx98oUYDNdyJpeOrXjVY7/GEQbjkxLImN5KAq4LBwVmIBN0eiyCo
         55lA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=hk0UKNlK;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id a13si25041143pgq.395.2019.04.26.18.40.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 18:40:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=hk0UKNlK;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id DBF72208CB;
	Sat, 27 Apr 2019 01:40:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1556329246;
	bh=Y0pgp+cW86eu1WvjuOqG11JMB9mYMKFomTMG0EnJlf8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=hk0UKNlKlJ9pnpiJRYN8QejQwxlwt3aoU53TNXZkfaxxqpFAM15wU+x11/Ma9h6gN
	 F7tAVPIvSMUt9PS/ze1JQwEga3mQ/9VW2RIAAuviI1pPgqRmtU/a7ukESOv0ANU8jJ
	 jKQn1thb/4U0Ry9ViIjCN8rdf6VuRZpr13/Css8Q=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	stable@kernel.org,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.0 78/79] mm: prevent get_user_pages() from overflowing page refcount
Date: Fri, 26 Apr 2019 21:38:37 -0400
Message-Id: <20190427013838.6596-78-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190427013838.6596-1-sashal@kernel.org>
References: <20190427013838.6596-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Linus Torvalds <torvalds@linux-foundation.org>

[ Upstream commit 8fde12ca79aff9b5ba951fce1a2641901b8d8e64 ]

If the page refcount wraps around past zero, it will be freed while
there are still four billion references to it.  One of the possible
avenues for an attacker to try to make this happen is by doing direct IO
on a page multiple times.  This patch makes get_user_pages() refuse to
take a new page reference if there are already more than two billion
references to the page.

Reported-by: Jann Horn <jannh@google.com>
Acked-by: Matthew Wilcox <willy@infradead.org>
Cc: stable@kernel.org
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/gup.c     | 48 ++++++++++++++++++++++++++++++++++++------------
 mm/hugetlb.c | 13 +++++++++++++
 2 files changed, 49 insertions(+), 12 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index 75029649baca..81e0bdefa2cc 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -157,8 +157,12 @@ retry:
 		goto retry;
 	}
 
-	if (flags & FOLL_GET)
-		get_page(page);
+	if (flags & FOLL_GET) {
+		if (unlikely(!try_get_page(page))) {
+			page = ERR_PTR(-ENOMEM);
+			goto out;
+		}
+	}
 	if (flags & FOLL_TOUCH) {
 		if ((flags & FOLL_WRITE) &&
 		    !pte_dirty(pte) && !PageDirty(page))
@@ -295,7 +299,10 @@ retry_locked:
 			if (pmd_trans_unstable(pmd))
 				ret = -EBUSY;
 		} else {
-			get_page(page);
+			if (unlikely(!try_get_page(page))) {
+				spin_unlock(ptl);
+				return ERR_PTR(-ENOMEM);
+			}
 			spin_unlock(ptl);
 			lock_page(page);
 			ret = split_huge_page(page);
@@ -497,7 +504,10 @@ static int get_gate_page(struct mm_struct *mm, unsigned long address,
 		if (is_device_public_page(*page))
 			goto unmap;
 	}
-	get_page(*page);
+	if (unlikely(!try_get_page(*page))) {
+		ret = -ENOMEM;
+		goto unmap;
+	}
 out:
 	ret = 0;
 unmap:
@@ -1393,6 +1403,20 @@ static void undo_dev_pagemap(int *nr, int nr_start, struct page **pages)
 	}
 }
 
+/*
+ * Return the compund head page with ref appropriately incremented,
+ * or NULL if that failed.
+ */
+static inline struct page *try_get_compound_head(struct page *page, int refs)
+{
+	struct page *head = compound_head(page);
+	if (WARN_ON_ONCE(page_ref_count(head) < 0))
+		return NULL;
+	if (unlikely(!page_cache_add_speculative(head, refs)))
+		return NULL;
+	return head;
+}
+
 #ifdef CONFIG_ARCH_HAS_PTE_SPECIAL
 static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 			 int write, struct page **pages, int *nr)
@@ -1427,9 +1451,9 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 
 		VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
 		page = pte_page(pte);
-		head = compound_head(page);
 
-		if (!page_cache_get_speculative(head))
+		head = try_get_compound_head(page, 1);
+		if (!head)
 			goto pte_unmap;
 
 		if (unlikely(pte_val(pte) != pte_val(*ptep))) {
@@ -1568,8 +1592,8 @@ static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
 		refs++;
 	} while (addr += PAGE_SIZE, addr != end);
 
-	head = compound_head(pmd_page(orig));
-	if (!page_cache_add_speculative(head, refs)) {
+	head = try_get_compound_head(pmd_page(orig), refs);
+	if (!head) {
 		*nr -= refs;
 		return 0;
 	}
@@ -1606,8 +1630,8 @@ static int gup_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
 		refs++;
 	} while (addr += PAGE_SIZE, addr != end);
 
-	head = compound_head(pud_page(orig));
-	if (!page_cache_add_speculative(head, refs)) {
+	head = try_get_compound_head(pud_page(orig), refs);
+	if (!head) {
 		*nr -= refs;
 		return 0;
 	}
@@ -1643,8 +1667,8 @@ static int gup_huge_pgd(pgd_t orig, pgd_t *pgdp, unsigned long addr,
 		refs++;
 	} while (addr += PAGE_SIZE, addr != end);
 
-	head = compound_head(pgd_page(orig));
-	if (!page_cache_add_speculative(head, refs)) {
+	head = try_get_compound_head(pgd_page(orig), refs);
+	if (!head) {
 		*nr -= refs;
 		return 0;
 	}
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 8dfdffc34a99..c220315dc533 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4298,6 +4298,19 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
 		pfn_offset = (vaddr & ~huge_page_mask(h)) >> PAGE_SHIFT;
 		page = pte_page(huge_ptep_get(pte));
+
+		/*
+		 * Instead of doing 'try_get_page()' below in the same_page
+		 * loop, just check the count once here.
+		 */
+		if (unlikely(page_count(page) <= 0)) {
+			if (pages) {
+				spin_unlock(ptl);
+				remainder = 0;
+				err = -ENOMEM;
+				break;
+			}
+		}
 same_page:
 		if (pages) {
 			pages[i] = mem_map_offset(page, pfn_offset);
-- 
2.19.1


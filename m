Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EBDD3C43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 00:49:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 918C82085A
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 00:49:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="MOHJiXeG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 918C82085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2B82F8E0004; Thu, 28 Feb 2019 19:49:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2669B8E0001; Thu, 28 Feb 2019 19:49:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 156F68E0004; Thu, 28 Feb 2019 19:49:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id DB6A28E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 19:49:15 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id q15so17580840qki.14
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 16:49:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=3zaAc4AkyYlmNHrBEr4XOgXYMne+k8U/cWFaLP79Juw=;
        b=Z/18at90miqRLEhmhM2KLXqVjJliF8U0CvT9zWdlfNlCIoYJ/jbyhaZUIBBHYY5WUk
         VOfAafMTEd5WJwCJhpRDbm2sq6A/9Wg8K3ccVp2WdgCrguaG8ATGiocoFzNOnuDZmcLf
         Sff29LeUNqOJ3UToKb/drztX0w5DLCua56MF9n6MVFnUQBrI9rmXAOR/7Z2PbYxQHpCd
         Pee2yBHjjiA5KW8dpeRvrkO8caIcrpSHPW1GNKO1eAGLTk6JSZz9cgPxXoVNn4FxtpUD
         whXv9CGajo8+5UGs16uFznNkdYuARWSr9/P+n5cX0BrxSchaHqvXnH2q8E9SitFe3Hmh
         Bb7Q==
X-Gm-Message-State: APjAAAXYgBDPWDOUw84D0hqPJPsHnvbBzjpNYHM/bvQEGDxaKAwbYLMy
	XsUsYC32gCCADS8mvmvlhgyZywG5jmt7mf7IXn3A8oQCL4ZYw78PZH1PRiVFZbMfzIjpaIlwReT
	KqPQc2Orbm6at18YcTtrJ/jhzfEpT4phQ1Ev4hI2nDAQrPIyown08DU5WMTXrdM1F3Okqv9SRkw
	nHBc8OrxH1KGU3WxG+IjCVGEPkb2qYQ6yF9WUuopcXGg5eHo7q2iHqsEfOuXj2lAfgl0Fxe1519
	3TGCd05oR8CRPOLGbBPkl0gKorORL8hLLDyR/uSpBJb2cEFZHueWLOWwBcTzMEfmk1zODovx2gw
	0u1HyIUpUVk8FrlGiRbc35ppy9pRxcT16hiSGzvw7473xr4scu6hkSZ0dKL+Dq2OAppMY3Z7xl9
	T
X-Received: by 2002:a0c:9428:: with SMTP id h37mr1699158qvh.42.1551401355594;
        Thu, 28 Feb 2019 16:49:15 -0800 (PST)
X-Received: by 2002:a0c:9428:: with SMTP id h37mr1699110qvh.42.1551401354538;
        Thu, 28 Feb 2019 16:49:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551401354; cv=none;
        d=google.com; s=arc-20160816;
        b=S0WMiM2BTpeqOQwbmRMMQukwwYJFspGN4a05v5h2i2xP8FrDE0huvybgBNGZCyjCTv
         1McGwHw6I7T//QauJm29OcOzmovhBEGBhezSnjdz+fRoT96iLO5UePwUDqp1uRJerYoe
         JrFWRLCsfNfhewKzVTX4jIA3VZHC13V0AcOJm7QnLlnu737p1x6MqqHvgEcSXg21DDjf
         xBVjLOvgqjz5salxo1s0XbH3ohYwa317GNCGW05jbCxPM9lChd10vpZklsPWLOdrlKZa
         IX4YSeBHv2YrzE3pf+O54NKMp0DG0WAQ03eK2YaP4ZDHtssMgBfdZIZ0u9P/kMg/7HGi
         6U5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=3zaAc4AkyYlmNHrBEr4XOgXYMne+k8U/cWFaLP79Juw=;
        b=l0NfdggXsCAHasgtpWX3alhc57EsSlgZkh707mHM4uHehGN2LgwIjf1jVgd0NwQ2Qf
         e4Ld3InV5uv5oTNq1yJD6hhSJZkm9l7S2yr3uDOSD9a2WUynxJb2EAHlZd1prcWdVqZB
         OSWiqPIeHYGHLBJaV55mToss+QFXKYg8CWd7OrjSMSBK4a6WuZ/IWdZLU8GY4C445zlt
         5zLEAcHoFlSAOxekVe83pB9+HbDvOwv0bYx2bswfOjq1FhkbukYb9INifEXwcPIL7W8l
         2RUgU4W63YK/8X29HIwY0qBBm0TuzuR0joM9VJHcWRiEmZdKa6RhRCPre+XB4rKlghSA
         9vHA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=MOHJiXeG;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f21sor7210696qta.68.2019.02.28.16.49.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Feb 2019 16:49:14 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=MOHJiXeG;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=3zaAc4AkyYlmNHrBEr4XOgXYMne+k8U/cWFaLP79Juw=;
        b=MOHJiXeGPN8iY0eIT5lF3Mxy5lun1L4+DZDbqOBS02rxnV+dZ1SiS6KZkGj++5xet+
         ZakVbbOHwWlivX0cZ4Vj441ijOwVIiRMfSVqrrgVxC+yP2MZ2HWJJ/TcfYGm55ht0hRo
         BjoXpyhEw3ppAAa8buPCteihj7kxVqNG6QYWfZBTNcQCOQ1wBFfkB+DxbAKc+Xl6jEYb
         kAyJH65nsKLaORU7CRygORAqKpaOpWs9zH8zYLlm3i+nZtuYRVXx7YL54B/2v+qQ0F11
         Xk6sQNKaXlPuyNQL7ti1oxL2MDAUgOMK/YUHUGOiyCg8fTITWaQltlTvSlPJi9uEerol
         Ozww==
X-Google-Smtp-Source: APXvYqwLalUyIj1++3RJLmJq+1Z9CujJWMbxVlRb9u6ZUDzfDCT+f3+pu+iAuj3b4e3ATUMDdQG6NA==
X-Received: by 2002:ac8:3464:: with SMTP id v33mr1839555qtb.65.1551401354288;
        Thu, 28 Feb 2019 16:49:14 -0800 (PST)
Received: from ovpn-120-151.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id v26sm12683985qtk.22.2019.02.28.16.49.13
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 16:49:13 -0800 (PST)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: willy@infradead.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH] mm/hugepages: fix "orig_pud" set but not used
Date: Thu, 28 Feb 2019 19:49:03 -0500
Message-Id: <20190301004903.89514-1-cai@lca.pw>
X-Mailer: git-send-email 2.17.2 (Apple Git-113)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The commit a00cc7d9dd93 ("mm, x86: add support for PUD-sized transparent
hugepages") introduced pudp_huge_get_and_clear_full() but no one uses
its return code, so just make it void.

mm/huge_memory.c: In function 'zap_huge_pud':
mm/huge_memory.c:1982:8: warning: variable 'orig_pud' set but not used
[-Wunused-but-set-variable]
  pud_t orig_pud;
        ^~~~~~~~

Signed-off-by: Qian Cai <cai@lca.pw>
---
 include/asm-generic/pgtable.h | 8 ++++----
 mm/huge_memory.c              | 4 +---
 2 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 05e61e6c843f..17b789557afe 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -167,11 +167,11 @@ static inline pmd_t pmdp_huge_get_and_clear_full(struct mm_struct *mm,
 #endif
 
 #ifndef __HAVE_ARCH_PUDP_HUGE_GET_AND_CLEAR_FULL
-static inline pud_t pudp_huge_get_and_clear_full(struct mm_struct *mm,
-					    unsigned long address, pud_t *pudp,
-					    int full)
+static inline void pudp_huge_get_and_clear_full(struct mm_struct *mm,
+						unsigned long address,
+						pud_t *pudp, int full)
 {
-	return pudp_huge_get_and_clear(mm, address, pudp);
+	pudp_huge_get_and_clear(mm, address, pudp);
 }
 #endif
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index faf357eaf0ce..9f57a1173e6a 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1979,7 +1979,6 @@ spinlock_t *__pud_trans_huge_lock(pud_t *pud, struct vm_area_struct *vma)
 int zap_huge_pud(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		 pud_t *pud, unsigned long addr)
 {
-	pud_t orig_pud;
 	spinlock_t *ptl;
 
 	ptl = __pud_trans_huge_lock(pud, vma);
@@ -1991,8 +1990,7 @@ int zap_huge_pud(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	 * pgtable_trans_huge_withdraw after finishing pudp related
 	 * operations.
 	 */
-	orig_pud = pudp_huge_get_and_clear_full(tlb->mm, addr, pud,
-			tlb->fullmm);
+	pudp_huge_get_and_clear_full(tlb->mm, addr, pud, tlb->fullmm);
 	tlb_remove_pud_tlb_entry(tlb, pud, addr);
 	if (vma_is_dax(vma)) {
 		spin_unlock(ptl);
-- 
2.17.2 (Apple Git-113)


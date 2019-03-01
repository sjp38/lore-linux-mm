Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BE8DCC43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 22:20:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6275A2083D
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 22:20:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="mYRUpQ85"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6275A2083D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DB7C48E0003; Fri,  1 Mar 2019 17:20:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D65FE8E0001; Fri,  1 Mar 2019 17:20:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C56858E0003; Fri,  1 Mar 2019 17:20:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9BBE38E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 17:20:11 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id v67so19788127qkl.22
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 14:20:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=iQozw9AJ+KagTRxIhD3lA5iUQt/T2sO/BmSDzwBmI0I=;
        b=ffm4gbaojVeM3wswfU75n0EmqN3tAmrINiY4SW90yJ3S5R54eK8WrA2DfFHccDeAjM
         gqVCZsaYxQEar9RNCfXwoUxJzOlpGY4isNCWtwf5UjT2EqC3ZIcV45SKXGalChmjdn0/
         nn08Gj9g7NSQ9FSTzhuyhfyBk6IyXejCsxYaen1qkQyWfvZOknD2PYW3ALbCSUT45k9Q
         Lkx0gASqrNmd26WvNfujEdV3iG8/nvpiN3+vvtCPqNgBu8s9S72m9kWswnsWnqG8kIHd
         +97gsybi8L0TGoM3Lq5+cNeyxXRCgCJDPNAxdKZIszhBvk8kEwFtEDssB62G5V+1RjWu
         3pMw==
X-Gm-Message-State: APjAAAU0SkwOio/wHiHtL0IrBLblw140ySPRPqiVp43ORjqbTBO6mAzw
	azHfNJ2IrLHjZZfCeERf6S06iNetYTXyOWJzLU60PdYOyYnwRNftg4lhRJYr0KqhiLGdzddYx4z
	kSXGvPivRNSbzm+Yxpxy0IgElSTREcbOu55TfZO01GnVq86Xh14hYZcSFYAlnQRcBrBWw+mjbzb
	TpCzHVRkMTiqDErNCJJpPfzCxTYo1eRjco4fBGuEKv8QgnVFquoTnPze/hYnd1M6yCZZ/hD0Gah
	kKvB8ZeExWfDst233FTL1qMyfNmsTeZ4emiGIoBDSEUS36knCOV5ZJ3zZV2tc0B8uuuZ01BC0Oe
	hExUmPollMkNVe16UPUsa1HA5k5nt0cNfx7DWPKW6oSim8o0V/3QpWfyvcxpWQCH8CKZKpxj8vZ
	l
X-Received: by 2002:a37:370c:: with SMTP id e12mr5596837qka.64.1551478811380;
        Fri, 01 Mar 2019 14:20:11 -0800 (PST)
X-Received: by 2002:a37:370c:: with SMTP id e12mr5596776qka.64.1551478810138;
        Fri, 01 Mar 2019 14:20:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551478810; cv=none;
        d=google.com; s=arc-20160816;
        b=BL9dg/Y1U4S1OVJu/Y6zpA1ug8qwK473CrfXXYYyyM6+1KbEaecQj2hFd60hLtdvc1
         nSooHq68ZsBTX/F17cr6Mbnpk/cEgK2wZ0DEz4khNLY403kzyvqi0x6z0eAlG1UGNcZK
         dsb4wF+OEwbZ0zgN0L5BlqQ/MD7yLzj+Bylk0lXs9gfYGfFGmDlU8lA58jwGasqNb05o
         69jYa7LH+YHrCUmeUvik2gm8pnwwtnrqBLhEKHqwVhuMy95DwMpsSqe0l1+1JPR+RZxd
         FEQQLe6xJD4Oghc3hoNOHbcXCBxEFxJysj3vNJ0FePmJEOeqYSBEQYVQhmWq4Kq0/Sqo
         /tqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=iQozw9AJ+KagTRxIhD3lA5iUQt/T2sO/BmSDzwBmI0I=;
        b=e7AYTtUkAVIDC+uOLz+3gJNS1a61VYl6DLXYm5f9BYjpVmGlG9qnZ+Zix62LY0IXT7
         0pYm2M8UMCFOHGCmlsxDH7jhef0Fjj4p1lmWlY6iXMPq7KGFarJhiNXVATVGtQ9rMyEk
         MJMGIGhRbyK1+D7sHP7erV2S6v9DrGZC93VCo0Zq9tx4cdMT+M+rM8RyjKkX5rUl4h31
         b0rB0KwWBdInUlszTwHOa275b1qt8e2MzLBNdjTyp6gBvQMoQuVasfBJrCRCnBQoN9Yv
         2XS7PAMZoe1HoYBhk8ztQ22kbnFmtzUr5aC76gXpDOuk9WdKm8qwB8IREV6pMOQtqxYs
         W8rg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=mYRUpQ85;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l7sor21143955qte.54.2019.03.01.14.20.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 01 Mar 2019 14:20:10 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=mYRUpQ85;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=iQozw9AJ+KagTRxIhD3lA5iUQt/T2sO/BmSDzwBmI0I=;
        b=mYRUpQ85kazeSJtNKWBFjpoQ0z+813L+c52GVx7Z1Wbn2Zgloz8PHCIM+/3IWZy8zG
         qcUh6dELXtCb3AckNCC5U4AxmDj+IXsJFnV0nHhJqZFR521wBhKRv7fro7YuxHoU6WKl
         09lIITb1V+71mPeAJKAFPKdyM+Q7O2FGiPchNe0NV7++VqYlOJZj/hgjxQXlHBeaaYxu
         as2BY/iZg4f4BWG3kicSAfmXlzlcmTPTKGNODk741KJQCgrN4VG5C0QnzECzEeI/Kw8q
         QUv/Y3yKe+SimYQk027lH3ynSOmiIpXb/8z5SrkZOvxK2ENEkuOL1rZFAiWHh6zHvv+d
         hJrw==
X-Google-Smtp-Source: APXvYqxG8gmw9QAG+TGB/Z7N2VKpO1wzDf+27D3H4y1MkNc3p8mhaYXLaHZMygfEg9ZbU6WUjjlOuQ==
X-Received: by 2002:aed:3574:: with SMTP id b49mr5864696qte.235.1551478809856;
        Fri, 01 Mar 2019 14:20:09 -0800 (PST)
Received: from ovpn-120-151.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id q23sm11364857qkc.64.2019.03.01.14.20.09
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Mar 2019 14:20:09 -0800 (PST)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: willy@infradead.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH v2] mm/hugepages: fix "orig_pud" set but not used
Date: Fri,  1 Mar 2019 17:19:56 -0500
Message-Id: <20190301221956.97493-1-cai@lca.pw>
X-Mailer: git-send-email 2.17.2 (Apple Git-113)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000245, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The commit a00cc7d9dd93 ("mm, x86: add support for PUD-sized transparent
hugepages") introduced pudp_huge_get_and_clear_full() but no one uses
its return code. In order to not diverge from
pmdp_huge_get_and_clear_full(), just change zap_huge_pud() to not assign
the return value from pudp_huge_get_and_clear_full().

mm/huge_memory.c: In function 'zap_huge_pud':
mm/huge_memory.c:1982:8: warning: variable 'orig_pud' set but not used
[-Wunused-but-set-variable]
  pud_t orig_pud;
        ^~~~~~~~

Signed-off-by: Qian Cai <cai@lca.pw>
---

v2: keep returning a code from pudp_huge_get_and_clear_full() for possible
    future uses.

 mm/huge_memory.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

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


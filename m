Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6ED4BC433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:52:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 24995208E4
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:52:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="oDf9sTqL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 24995208E4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DE2268E0011; Tue, 30 Jul 2019 01:52:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D4F0F8E0003; Tue, 30 Jul 2019 01:52:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B4AD78E0011; Tue, 30 Jul 2019 01:52:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 775378E0003
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 01:52:54 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id x18so40063564pfj.4
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 22:52:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=5I6cv8rPAulGunfRGkEsTPG6LGj3MyO3rpoe2rANz8U=;
        b=bOrhHktKEsf7Nwzj/OHp2M4lEH4oLHr9EkQkVq9SaYCzykzeOSTVDuMPagOmdOw81o
         KtmNXP0bcs/4q/0/WaGT6yDkKx4AoFch0VRuNpq4qiSSMYv1py/95Omvfku3b1N9zu3L
         U/Dke9+EgMvnm5fiOp2BVWhgu5sz5CGWptcYSytGs8OrT1n1V0E6bUbnHFYt6H+EOenk
         1STvi1WJCV4MO4a2VzwsjZHPlBqMSbtr8/juQZbPVCPUmFVGMeUvE0E0D0wF4aaHLLdr
         IS5ZBfyYwpJZPEL1aZNu0nMkSOjnjPL1w1u0bbM/staesf+SpDmucJUUwif3PkNBqf6J
         lu8A==
X-Gm-Message-State: APjAAAWGR+TZf0MbyCsyUp25IPDyQbeyRc928VgkSdQXHDmda9dHs+tS
	1jt59Yop56WCohC4gDigfj0G3eI8LLO3AqaDJq8C9S0Qv5QyEcMimRXY0mIGVJZIBF61tNygldh
	wF6rXxkKc+QWaOJ8o3zJ+3ofvCdcJ9IRxUCaM5YOZO9nPUEEGgjfQCraMPan6BfI=
X-Received: by 2002:aa7:9f1c:: with SMTP id g28mr39709666pfr.81.1564465974188;
        Mon, 29 Jul 2019 22:52:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwBE+5jeM39exGIT1N58jj2fnCspBwt/LKGaUWi6g15j0L3nuBg9OVOvqKUa1QKVyn9H2qw
X-Received: by 2002:aa7:9f1c:: with SMTP id g28mr39709636pfr.81.1564465973512;
        Mon, 29 Jul 2019 22:52:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564465973; cv=none;
        d=google.com; s=arc-20160816;
        b=RJrTyjeemju87G41jgj+YWacRKQFeuTlD5P7tmcNs0TtoYIN7hLl+DjTbbbDafJMWL
         7eQozSknYwJVdbO1LsXa6oJUzojTN5qZ26ZDEHhr8mDphgeb0bofBqqceUG80MIHzqmT
         PEYxuq1wFV5ADjV5gJFY6H6JcGxLIhb4LJF/b8Y8mzxMT4IzdNn8bRnWk2U1t8Tnld5e
         CFEX2KNLAJ4Q3QStB2Ep2opI/VMJGm6/iZo7oR4WdWNvDH725NMPW/HqkRdvrZ2xrjOz
         ZKMoAtnV0/leE4QAKUUEsi2Yl8zymKEBEQJYn44yURjfduFI1HgHLpuCldtRm5vxcZU3
         rhFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=5I6cv8rPAulGunfRGkEsTPG6LGj3MyO3rpoe2rANz8U=;
        b=Oj+vCpMgdddYjXvzUoOOssx6CIRrxfGlxMIQuEp8Z/IhF58eUDWXEwm4+uPOpKAfZZ
         I1eisLCopkano1XSsiAldguYhTZOAp4B9a7VpEKpXAfZ1FAtu3aIBjwwp3ZNXXsX+9MG
         0tVEYmTkTHP2pnIZsWnEMkwVF8qW/vcBwriKx597/eF4oTDedQGI6K7QodkChonBo2zW
         OtDm63nPy6EE/9S8jtr47JYFTKUBaTrf9wWq0wEI/KVGq9ZhPiD5KgFXd5CxdTLZRd8+
         EvI9EzhLyLVFc7Gu0HA7Dpg7B9qucgBHg1BliesSf7leefKD4wWVmhMgK9u7VwQx/egi
         C2jA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=oDf9sTqL;
       spf=pass (google.com: best guess record for domain of batv+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q23si27701135pff.103.2019.07.29.22.52.53
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 29 Jul 2019 22:52:53 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=oDf9sTqL;
       spf=pass (google.com: best guess record for domain of batv+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=5I6cv8rPAulGunfRGkEsTPG6LGj3MyO3rpoe2rANz8U=; b=oDf9sTqLOFXjgtQQfZeUNN/vp5
	lCVFV/7Tr8JxHR/pQ+/TMmCyjB6NjzjA2mMLkEkCi7jL4ivm6humWCpK5bUJBpgGkIVEIqxfqPwDM
	4YTgjZfSuNSKi4iH6bf2ix1BFnAHfKSiDJt5tuFXYnbRAPanFBN7galzFX5sH/RzaX/Ar5BkCfFvd
	41uRDFgvEN7sG3tRwMzHosXwxm3yjKdGtPSFyxJvDop/5dTh5Q/5Zvl1zocmST9V55oZcYCaE7QDT
	9yH7K0Mb6/P0GmUwfW3WtYnIUZ9WM04YEB6aiSTy77a+Q6/+Ce1zgMON+82ync3MS6VeeHv8iSw9J
	klDnrBYw==;
Received: from [195.167.85.94] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hsL46-0001T1-B3; Tue, 30 Jul 2019 05:52:50 +0000
From: Christoph Hellwig <hch@lst.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	amd-gfx@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 12/13] mm: cleanup the hmm_vma_walk_hugetlb_entry stub
Date: Tue, 30 Jul 2019 08:52:02 +0300
Message-Id: <20190730055203.28467-13-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190730055203.28467-1-hch@lst.de>
References: <20190730055203.28467-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Stub out the whole function and assign NULL to the .hugetlb_entry method
if CONFIG_HUGETLB_PAGE is not set, as the method won't ever be called in
that case.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 mm/hmm.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index f4e90ea5779f..2b56a4af1001 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -769,11 +769,11 @@ static int hmm_vma_walk_pud(pud_t *pudp, unsigned long start, unsigned long end,
 #define hmm_vma_walk_pud	NULL
 #endif
 
+#ifdef CONFIG_HUGETLB_PAGE
 static int hmm_vma_walk_hugetlb_entry(pte_t *pte, unsigned long hmask,
 				      unsigned long start, unsigned long end,
 				      struct mm_walk *walk)
 {
-#ifdef CONFIG_HUGETLB_PAGE
 	unsigned long addr = start, i, pfn;
 	struct hmm_vma_walk *hmm_vma_walk = walk->private;
 	struct hmm_range *range = hmm_vma_walk->range;
@@ -812,10 +812,10 @@ static int hmm_vma_walk_hugetlb_entry(pte_t *pte, unsigned long hmask,
 		return hmm_vma_walk_hole_(addr, end, fault, write_fault, walk);
 
 	return ret;
-#else /* CONFIG_HUGETLB_PAGE */
-	return -EINVAL;
-#endif
 }
+#else
+#define hmm_vma_walk_hugetlb_entry NULL
+#endif /* CONFIG_HUGETLB_PAGE */
 
 static void hmm_pfns_clear(struct hmm_range *range,
 			   uint64_t *pfns,
-- 
2.20.1


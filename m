Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4822EC28CC5
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 09:10:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 048F820866
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 09:10:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="k8PDFRD6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 048F820866
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A2F4C6B000C; Wed,  5 Jun 2019 05:10:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9B7C26B000D; Wed,  5 Jun 2019 05:10:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 880AE6B000E; Wed,  5 Jun 2019 05:10:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4A68D6B000C
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 05:10:49 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id d7so14390888pgc.8
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 02:10:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=qe2qEqCwB2kLhiPVN6wzjgcS8llGOmV8LcU4p/YtuR0=;
        b=ukgaMaQJK2K8qz7wXX71YKJof/r0esjhj/rbNRz2ReRaEhIr+fp7D2DIhGq6Yr2Sju
         yidaBQLpZ7eOn7+9qya5FfYTRYoY/YIu6qdQf1CovkPjNOk/0pCNqiQpZVtaVfvXcKKT
         h9PKi92YD8u8RC3GDThrlguFZkq/ZqJ37P8CSD3WQVCsCEdFxeci/F4wxQnblpILcdm6
         l4i2rf8kFnyxq3qVAMpEcrM1UM2HeeL/ntaR42EmT6EZCApjBFOmA0j3uiX1kWrFB9+4
         2AjsBPqVkyEbuHsuVDvtXTmA7I/+zyXyCL82t12uoK1ie01zyECp+LQaTbfmDyoZgXAF
         xTfQ==
X-Gm-Message-State: APjAAAXdDr7CVg6rLJ09hbUspFU+60InqzSXAPgsCt7mrHJX2lGvuSjh
	adjxXa6yhCeuNFCzgvdrupEUEMTDwPhPMKjRDw5NuzmfCRyIavO+gA8jw9DX8vxumrdCaw5qAum
	OyKyBFLRo7cN5mTfUHaK5YQPLVF/Oiq+yWVPNgrg8wYY/bL5tihpUuhJQGc1ErXZCrw==
X-Received: by 2002:a63:d008:: with SMTP id z8mr3018036pgf.335.1559725848733;
        Wed, 05 Jun 2019 02:10:48 -0700 (PDT)
X-Received: by 2002:a63:d008:: with SMTP id z8mr3017925pgf.335.1559725847458;
        Wed, 05 Jun 2019 02:10:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559725847; cv=none;
        d=google.com; s=arc-20160816;
        b=dxSU9jcq8uxgvNFC+KxRul4s6nBI89KAgi1UuIlymuo4xlAHsZrjuWB3n2PV+kpPV+
         rglEO1ED+3qsWh5KPqeWPfV4Ia38EXwKr3i4hgltDMhDj9Ls/7g+qlxsYe5Vp3aDf2E1
         uuJCgk+69kLlOAojwkaTRH6R+HszbY4ZLl4Gg74TIEAwsipEk1kkV3y/QRV3DNrH6A68
         ZelEgPfNd/180mKeb4cH8opx8cE1z8tqYD+DmZApZ62tk7pFidI4E9++GVnCHcnzuxCB
         +a5UhRsjxvX871FB/hsCvbRwQ/VomJmhcLvAmT0o4q1WLJa1qWHITQOE1zDDZH54m1OG
         kq5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=qe2qEqCwB2kLhiPVN6wzjgcS8llGOmV8LcU4p/YtuR0=;
        b=sOsGDsCuz7qMSdPBFlwHEGep3DBW+VJRddXRJuBCCOfa+8I8dK9tmQynn4xfLA4UXf
         0ROqNVCyJrTc6waOB7H6zxIy29rI70FaFt+Y7SM4vpISbfiexnMfiKi3OjM7XNqJPixL
         fld4sB1XTw3IB3Fb42Otf4E8h69vTxEuYgrVSbtkaA0XVMSZTxR36StYkTIU4BuzySOK
         8MP5jhAPPt17qeGF6pMonBBdTsNQTPaZP8nxscbqAx3LvZ8uZq7maTUG++jWMGaZYmhB
         323vm/N+2eK2yA459FPtQMplRLLIe+nCPVP+oG1Ip9olZXrQPz+Fn1Swq9ONhZg5tBFm
         OpRw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=k8PDFRD6;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j35sor20860994pgm.60.2019.06.05.02.10.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Jun 2019 02:10:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=k8PDFRD6;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=qe2qEqCwB2kLhiPVN6wzjgcS8llGOmV8LcU4p/YtuR0=;
        b=k8PDFRD65GfqIRKyHH1gKGhC28AUBf1rIqpRtBVKZkFOyfSofJ+xIM+bLtiUdsa1ig
         BfBeMXE4TTb+OvlBSRfaFAWMxhPvW7zD7u0gshBiyiG+f/AP+hFcw5/3p//x5e6yNF8i
         iPCPlE6TLiaKPZK4piGiEE9Pkzh5T8527HyNmPxS/jzZbdznDq+UHq0PUsYFS68PCjVH
         c6haPJ8Zsy54mqCByUbYktyztQAztfiraWDZZawfYhmUvogLTVoFiPHNA4cKvrB/L4eM
         ZBGGJxngz4OmNGVs5i1rAmncPcv9RqFAq3rg7aA50c5lr/VrCFjmg28FjvRrq5P13Hx3
         Xgog==
X-Google-Smtp-Source: APXvYqxhrX6wAssVXs2ZclXfwzF30GmChMOrWvQir8bDvycAg5gzUgp1/7H0hRmAZ6tIjdILLAT+Sg==
X-Received: by 2002:a63:4c54:: with SMTP id m20mr2997813pgl.316.1559725847045;
        Wed, 05 Jun 2019 02:10:47 -0700 (PDT)
Received: from mylaptop.nay.redhat.com ([209.132.188.80])
        by smtp.gmail.com with ESMTPSA id w36sm11844525pgl.62.2019.06.05.02.10.42
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 02:10:46 -0700 (PDT)
From: Pingfan Liu <kernelfans@gmail.com>
To: linux-mm@kvack.org
Cc: Pingfan Liu <kernelfans@gmail.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	John Hubbard <jhubbard@nvidia.com>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Keith Busch <keith.busch@intel.com>,
	Christoph Hellwig <hch@infradead.org>,
	linux-kernel@vger.kernel.org
Subject: [PATCHv3 2/2] mm/gup: rename nr as nr_pinned in get_user_pages_fast()
Date: Wed,  5 Jun 2019 17:10:20 +0800
Message-Id: <1559725820-26138-2-git-send-email-kernelfans@gmail.com>
X-Mailer: git-send-email 2.7.5
In-Reply-To: <1559725820-26138-1-git-send-email-kernelfans@gmail.com>
References: <1559725820-26138-1-git-send-email-kernelfans@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

To better reflect the held state of pages and make code self-explaining,
rename nr as nr_pinned.

Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Rapoport <rppt@linux.ibm.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Keith Busch <keith.busch@intel.com>
Cc: Christoph Hellwig <hch@infradead.org>
Cc: linux-kernel@vger.kernel.org
---
 mm/gup.c | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index 0e59af9..9b3c8a6 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -2236,7 +2236,7 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
 			unsigned int gup_flags, struct page **pages)
 {
 	unsigned long addr, len, end;
-	int nr = 0, ret = 0;
+	int nr_pinned = 0, ret = 0;
 
 	start &= PAGE_MASK;
 	addr = start;
@@ -2251,28 +2251,28 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
 
 	if (gup_fast_permitted(start, nr_pages)) {
 		local_irq_disable();
-		gup_pgd_range(addr, end, gup_flags, pages, &nr);
+		gup_pgd_range(addr, end, gup_flags, pages, &nr_pinned);
 		local_irq_enable();
-		ret = nr;
+		ret = nr_pinned;
 	}
 
-	if (unlikely(gup_flags & FOLL_LONGTERM) && nr)
-		nr = reject_cma_pages(nr, pages);
+	if (unlikely(gup_flags & FOLL_LONGTERM) && nr_pinned)
+		nr_pinned = reject_cma_pages(nr_pinned, pages);
 
-	if (nr < nr_pages) {
+	if (nr_pinned < nr_pages) {
 		/* Try to get the remaining pages with get_user_pages */
-		start += nr << PAGE_SHIFT;
-		pages += nr;
+		start += nr_pinned << PAGE_SHIFT;
+		pages += nr_pinned;
 
-		ret = __gup_longterm_unlocked(start, nr_pages - nr,
+		ret = __gup_longterm_unlocked(start, nr_pages - nr_pinned,
 					      gup_flags, pages);
 
 		/* Have to be a bit careful with return values */
-		if (nr > 0) {
+		if (nr_pinned > 0) {
 			if (ret < 0)
-				ret = nr;
+				ret = nr_pinned;
 			else
-				ret += nr;
+				ret += nr_pinned;
 		}
 	}
 
-- 
2.7.5


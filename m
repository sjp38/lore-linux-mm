Return-Path: <SRS0=oA8h=PB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 03A2BC43612
	for <linux-mm@archiver.kernel.org>; Mon, 24 Dec 2018 13:17:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AFE9321850
	for <linux-mm@archiver.kernel.org>; Mon, 24 Dec 2018 13:17:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="i2KO5MMx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AFE9321850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 60DCE8E0004; Mon, 24 Dec 2018 08:17:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5BC938E0001; Mon, 24 Dec 2018 08:17:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4ADD18E0004; Mon, 24 Dec 2018 08:17:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 081328E0001
	for <linux-mm@kvack.org>; Mon, 24 Dec 2018 08:17:48 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id e89so12400253pfb.17
        for <linux-mm@kvack.org>; Mon, 24 Dec 2018 05:17:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=MMGJzHhmNthI9sRZkbXZ1iYyH2jshJ0o/VQkgO88tcs=;
        b=iVkb/jNCs6s1nqC7HoBfHu4L6SqOK+5ReEiKlQXlW2IZGNQnZsX/cuM66wa4xYJMOR
         15VQRpmLo7bL/meQalKnifXLN7+e9hXqo+XD6Rsqg64FGkQ/ab1IEKxMZThwB/5DeHuE
         gh0R3HAngRFqW8OZXCc07aMfdOh077i3te1Nd5I2qZfJ9IoBZN6jRh53TvOLiuUkpWcI
         fkX3OTX7DW/CXwu9mbR8sxwHJhUkfsyC7T7PTXfUXPN7KjEt3gQchnVHlOZ7A8ftps05
         5FJVzYlB2e/HUNZ1PcjGPcfEUTVjIUx4JwsJ73EzH/Z64dVd2xRA/lR28WpQKfoajmna
         Iqmg==
X-Gm-Message-State: AJcUukfO+49A5VW5hglQRj5q2G9iyKquqCXN3lWsOwsA/yCaKBknNDy9
	X2rPjgEQrLLykDKFecj57LCF8dCXDBd7PIGrxZkkF4TaG3sLSD39f52X4ImlUejAhxpD8BvzzP3
	FihGIi2IvbndpJ37hZn35E1MGv4voDXNgfKmuUstrJXhzYgod/u2EyEmHTvyZHd+bs1IZytz/K9
	qPWN13u6O+2KBN14ROJ61UOy8yvdS9DqhXzKHt4muSJT9LMcYB2qBiT5Qz2pRH/4lBGcSPQkWGq
	938G7JDrkBYJIpY2cu5aRNSEHE5cE3psiJDxvcF8iFuUPfWgR3gZ6m2gusowOHT8RcSauoGpmBI
	QnC3O5xWRjxDeZkfXpg+Be8SILOutzzlvd9GVNbalGWR587yg7rUFcTzOj9kESus8ejbTt1oeGB
	5
X-Received: by 2002:a63:235f:: with SMTP id u31mr12300708pgm.122.1545657467707;
        Mon, 24 Dec 2018 05:17:47 -0800 (PST)
X-Received: by 2002:a63:235f:: with SMTP id u31mr12300667pgm.122.1545657467016;
        Mon, 24 Dec 2018 05:17:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545657466; cv=none;
        d=google.com; s=arc-20160816;
        b=RqZO6k7PLxRLUuqzMouEayrVEYiXc3hHw/gNWpmwZO7/Lz/Mz/PP3fIsN9iHXFNzDC
         YswaXGSPYW1ma4/qZgiMphFmyLZG1hEi9PtnqM9lmRoH5nKxHsHYs1RCDu/cn8ZEE7Jf
         msSRATAnU2rA0vcOe198jVYhXaWSMyUDJsd+x0q+bUPwHJTmih+hF/6Q+bv8Vj7fb6uG
         OL1bHk+NrbXhRMXD+QDrXt9wNzK3xGRBUBZrGnZ2rjaUcrKVKY2kSXl6o3CLnlVXIMqB
         5WRLBOHJrLVTttrLaXYBGNpLpsROwX1J0+ekQteXO4IskahVbH6qatFVT2yhegTxlU+Y
         lzOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=MMGJzHhmNthI9sRZkbXZ1iYyH2jshJ0o/VQkgO88tcs=;
        b=wYNbxENAB6DOUqMXLnJlMCUSFIT2476tJrY2wE13GSt2RbQuI9VtCFvnualo6g6NI3
         mIdtISoS2C3OHjQc7QuskBMYnS9FoAM/OGrdaORo4m+dT1t45IOJAMmhUSOR0gzqNfJD
         MWmJbrk6IaafUWA71aPvmKIeZ3BO31WkJBCDWr0ZuxdLtK0HOfyODn/80yPeG+7+8Jl4
         L48MeI+qYD3pXNZfC6c9wNv2GOj9PiEn2p/oWHzLCHOw8xJjaR2VqXoXGKYE0yqyOOSQ
         22mmh5Ci+EzXtZtpPa4CH6Vbx+2BenybMoC3R612+Al6eA+2G2ye7jRpsXpT1qX/IRTu
         YfxA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=i2KO5MMx;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v28sor52754443pfk.14.2018.12.24.05.17.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Dec 2018 05:17:46 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=i2KO5MMx;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=MMGJzHhmNthI9sRZkbXZ1iYyH2jshJ0o/VQkgO88tcs=;
        b=i2KO5MMxJo3/5LWrPLeNLGeva3Ne1DqGYNQmkVfffqJy/7Blwc1ZQTxF5q7/4cdbVK
         vIexInnWRoT/V11j7MMRf8p2pNk7N6+FKaVdWJPsVT0PJ7MRGJWCmKDRYYVgzm9PVFZR
         7Kz4JADaRzoTvV+K+ajZHPtgb0txgVU5jA3CliuIeqyf9MC+6XxOOcepTV0uLQH9GDeU
         B5bw7Mj0iLy6LrkPqE9j4pev1wfm6d67jrKNbReUFngf1M0upuqrGUYdICcRDO0tsAEw
         f+JmsDBaFgTBiSI+JannbW3PzQBDJacAB8VRitF1ub03PgJ8p0gttKrXb8wKIRMKAK35
         /Ikg==
X-Google-Smtp-Source: AFSGD/UmasEKtYGJVvYE7ECLRPqA3+g1rUsYqcP4hh5vWWnPBQkurqM+K4wJcBIT4twxElNbufrYjA==
X-Received: by 2002:a62:e0d8:: with SMTP id d85mr12901342pfm.214.1545657466691;
        Mon, 24 Dec 2018 05:17:46 -0800 (PST)
Received: from jordon-HP-15-Notebook-PC ([106.51.18.181])
        by smtp.gmail.com with ESMTPSA id c23sm39254231pfi.83.2018.12.24.05.17.45
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 24 Dec 2018 05:17:45 -0800 (PST)
Date: Mon, 24 Dec 2018 18:51:42 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com,
	linux@armlinux.org.uk, robin.murphy@arm.com, iamjoonsoo.kim@lge.com,
	treding@nvidia.com, keescook@chromium.org, m.szyprowski@samsung.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org
Subject: [PATCH v5 2/9] arch/arm/mm/dma-mapping.c: Convert to use
 vm_insert_range
Message-ID: <20181224132142.GA22070@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181224132142.UnVpnYaPE8RSltk7XiUDa0PMKGMLx0A6mVFBvae1WHg@z>

Convert to use vm_insert_range() to map range of kernel
memory to user vma.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
---
 arch/arm/mm/dma-mapping.c | 18 ++++++------------
 1 file changed, 6 insertions(+), 12 deletions(-)

diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index 661fe48..63467b6 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -1582,11 +1582,12 @@ static int __arm_iommu_mmap_attrs(struct device *dev, struct vm_area_struct *vma
 		    void *cpu_addr, dma_addr_t dma_addr, size_t size,
 		    unsigned long attrs)
 {
-	unsigned long uaddr = vma->vm_start;
 	unsigned long usize = vma->vm_end - vma->vm_start;
+	unsigned long page_count = vma_pages(vma);
 	struct page **pages = __iommu_get_pages(cpu_addr, attrs);
 	unsigned long nr_pages = PAGE_ALIGN(size) >> PAGE_SHIFT;
 	unsigned long off = vma->vm_pgoff;
+	int err;
 
 	if (!pages)
 		return -ENXIO;
@@ -1595,18 +1596,11 @@ static int __arm_iommu_mmap_attrs(struct device *dev, struct vm_area_struct *vma
 		return -ENXIO;
 
 	pages += off;
+	err = vm_insert_range(vma, vma->vm_start, pages, page_count);
+	if (err)
+		pr_err("Remapping memory failed: %d\n", err);
 
-	do {
-		int ret = vm_insert_page(vma, uaddr, *pages++);
-		if (ret) {
-			pr_err("Remapping memory failed: %d\n", ret);
-			return ret;
-		}
-		uaddr += PAGE_SIZE;
-		usize -= PAGE_SIZE;
-	} while (usize > 0);
-
-	return 0;
+	return err;
 }
 static int arm_iommu_mmap_attrs(struct device *dev,
 		struct vm_area_struct *vma, void *cpu_addr,
-- 
1.9.1


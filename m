Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0420C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 02:23:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B98720700
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 02:23:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="h7fWh3XQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B98720700
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 22AE36B0008; Mon, 18 Mar 2019 22:23:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1DBE66B000A; Mon, 18 Mar 2019 22:23:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F2846B000C; Mon, 18 Mar 2019 22:23:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id C605A6B0008
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 22:23:46 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id f19so21269460pfd.17
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 19:23:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=XQSNSZywn2J5tIibcMqEyCRYg0DoENdsUd09NDa1qxo=;
        b=dEIKrnU3wDb2tJ9IbLAVH/e4a91ErDrM9v9gL67O0GguqMInOVPsook2gc5cZAQBQi
         ex3Jmfbfydxntk+lXFlglJbLF0UWJXLxX25EUd4vdwrzFQAzDQNyM49wFqb0+33MhWJQ
         bV8yKhrbwLUO8oVgbyKO/ptdRj1zmAn0/AAVoqBqbG4VxHJI+rhuoTZuwUeBaRk5vpYl
         2guiEvV3JwAGC+OOlZnUpU9svjvDE3eZnn4H8ww+rGRSiD0lm5u/meD59lcl2CUCJy0q
         Ic1qECyzDj/xHC1FrGq7AjMZG7VyWyRtBMhG2W32vfIiXopbzB3S6wjUEUjWGCeR1H/K
         lepg==
X-Gm-Message-State: APjAAAX+yDa1mum2yRlnYJzXW215Xs9MJBx4cdWH2ZL2iPSCFqPcEkjF
	7CLsY1zAfDqK/20q7xuzTWLDvYyxTdHMQIl9hsmwwXIFWZt2M0hmOcDd5d+AyFnlpo+adyZS+M1
	IfSvFyQIiJFc2tGgZq0/RRoNUMCWp8mWuza5fyhv6l0v6zgSMCht6PaByniemJqZ8Jw==
X-Received: by 2002:aa7:8156:: with SMTP id d22mr22369177pfn.230.1552962226480;
        Mon, 18 Mar 2019 19:23:46 -0700 (PDT)
X-Received: by 2002:aa7:8156:: with SMTP id d22mr22369129pfn.230.1552962225541;
        Mon, 18 Mar 2019 19:23:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552962225; cv=none;
        d=google.com; s=arc-20160816;
        b=DTbfxng0YDE4YE8rpHw6lr7YyLfT9uDCWYoh07xZW2oLV62IN0jzn498nCptrA5UQ6
         qsZ+QlnWxaZDm55ipuzhXfnfzKPa/No0oLHq+iRG4JDlJyvcIhJvSEgWEEBEmB+FEVzI
         jIDS/zikHPrUvwZU3i5q8UkMMbPqE5L6E4FzAlvpIrjCDpw2xFczVD7pMBgfuAGhhUN7
         Vj2k3PHA+1H1Ub4Yxt87DGgEgHauYcTVlbS++09WnGfl5FFVZAvKDn1YkHtXhbGgtqGZ
         qeYlpB2NqRnExmTvVdTG4OwzvrQuI1R/bb3dIJDvOaevTQjzah/NrB2KcCnQ2N8SHXu2
         mSUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=XQSNSZywn2J5tIibcMqEyCRYg0DoENdsUd09NDa1qxo=;
        b=mUX4qowcAoujmlp7Kl6SyRoSy9X35HkhXVTbLvjjPGEQrzfcMiBD5l1JhpriDAOTtB
         h2QsI3JVrn/40077trW44rRJGYRjS3PnS2PiQpV095cJTlBCW2c2WX6txf/uoceDHfGP
         +5m95KebTSAbNg7I/HHE8fuBaxxHYrO5WyNd2TD92ZtlUzd4ffjjeEbLgU5LIjXKR8wN
         1/8Ji775Ul9kutueW+ma2jTqAELjZlxTCqNadPm06/ua/9kZL12uXLBPQ7nCPPWHNNlN
         6aKSRbmwnyCEmV1u9z2BrzPMRWlSqZmNPSSt6QaAdzaxkM7fDTgnua15y5shR2t3Mt1L
         dKeg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=h7fWh3XQ;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l15sor18539555pfi.1.2019.03.18.19.23.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Mar 2019 19:23:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=h7fWh3XQ;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=XQSNSZywn2J5tIibcMqEyCRYg0DoENdsUd09NDa1qxo=;
        b=h7fWh3XQpVCLdL4ftW6K8821+fJbEx9xiv4LfYg8iyWm8RxxMuoyzBhxnRKFxjxUcq
         T00TBWmApNpUpw4//HK7pQV+dp2QRHXRCZqdh0C4p/XOt0vMVPqv8y9pxYhS5XaLRXY0
         xbmZqlxg6214GIOQaYXE7n82moU19epkFZRVWW6xQE6lGim/TRg5EoDRPgyHXH2mKts7
         x2gkkiNvERV3obQbyAvupx4A+T4a5Nf2iXPzS6etde+Tm1wXD7oEWNRmbHfKYuitdgwx
         RomL7+lV4OdxCefjaQnh0zE7naaN78p9NgU11I1wQeM3wEg2qFNj9J40w0uky0Bn7ogr
         AmXw==
X-Google-Smtp-Source: APXvYqwa8wXt+mz7i6FijqBLeIp49F1z3IgvodvcaTTDVoxNESr8D3k+zbgwuMkbbyfNEcSvmrRV0A==
X-Received: by 2002:a62:ab13:: with SMTP id p19mr2373901pff.131.1552962224852;
        Mon, 18 Mar 2019 19:23:44 -0700 (PDT)
Received: from jordon-HP-15-Notebook-PC ([106.51.22.39])
        by smtp.gmail.com with ESMTPSA id p6sm18728397pgd.69.2019.03.18.19.23.43
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 18 Mar 2019 19:23:44 -0700 (PDT)
Date: Tue, 19 Mar 2019 07:58:19 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com,
	joro@8bytes.org, linux@armlinux.org.uk, robin.murphy@arm.com
Cc: iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: [RESEND PATCH v4 6/9] iommu/dma-iommu.c: Convert to use
 vm_map_pages()
Message-ID: <80c3d220fc6ada73a88ce43ca049afb55a889258.1552921225.git.jrdr.linux@gmail.com>
References: <cover.1552921225.git.jrdr.linux@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1552921225.git.jrdr.linux@gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Convert to use vm_map_pages() to map range of kernel
memory to user vma.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
---
 drivers/iommu/dma-iommu.c | 12 +-----------
 1 file changed, 1 insertion(+), 11 deletions(-)

diff --git a/drivers/iommu/dma-iommu.c b/drivers/iommu/dma-iommu.c
index d19f3d6..bacebff 100644
--- a/drivers/iommu/dma-iommu.c
+++ b/drivers/iommu/dma-iommu.c
@@ -620,17 +620,7 @@ struct page **iommu_dma_alloc(struct device *dev, size_t size, gfp_t gfp,
 
 int iommu_dma_mmap(struct page **pages, size_t size, struct vm_area_struct *vma)
 {
-	unsigned long uaddr = vma->vm_start;
-	unsigned int i, count = PAGE_ALIGN(size) >> PAGE_SHIFT;
-	int ret = -ENXIO;
-
-	for (i = vma->vm_pgoff; i < count && uaddr < vma->vm_end; i++) {
-		ret = vm_insert_page(vma, uaddr, pages[i]);
-		if (ret)
-			break;
-		uaddr += PAGE_SIZE;
-	}
-	return ret;
+	return vm_map_pages(vma, pages, PAGE_ALIGN(size) >> PAGE_SHIFT);
 }
 
 static dma_addr_t __iommu_dma_map(struct device *dev, phys_addr_t phys,
-- 
1.9.1


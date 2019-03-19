Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34FA0C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 02:20:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E819020700
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 02:20:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="VOnhA/MD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E819020700
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F9C06B0008; Mon, 18 Mar 2019 22:20:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7AA856B000A; Mon, 18 Mar 2019 22:20:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 624BC6B000C; Mon, 18 Mar 2019 22:20:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1E16C6B0008
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 22:20:16 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id f6so20815170pgo.15
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 19:20:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=cNyFM0J2DfW9voxw9FzV7E7Y/LrzsWkGDKLqwe0d5pk=;
        b=TIyVJuK8toGrmMKZUivzwRplLJBLsss1tDk6E6aEfMowfNYK3Dff1opQbRZ3qxBhif
         w8LyR4MmYj82oTFCfmD8mavq8/wGH7EEgn/NukE/UP0P2z0RmQAJB3QCYK9XllT59U1M
         aKnqVdZciSq/NCQq00T3zf9TeFoLpH0+J9PFOg0QFsUY5fGmebA3JCKyZIwGEwMoqppX
         DaC16LSQM6PTjKWB8m7GM8GgYWXN832B8EhtVdlywUelbsQFMHBSnS+cwPJd1pPlaufK
         0nti/M6f8vQaOn9Ogfi5+IeRO9Yt36wSM1ZL80HC/33YAH8J44+7uE7nPlECfcAPTtU+
         xK4Q==
X-Gm-Message-State: APjAAAXFC0PC20QdnN3yZDmzLUsTVRqa9k7v/SN2MCdyPa3IMcirdJWZ
	Yxa/L0ei23AikCmcZjHeP+TUY2MGa9Is6L92Y1VNCpxTPlrPg2626HbQE4eRI1cRMU9hN/tEV+T
	ZQ9dOl/+0ScWtGiPJL8uuiq8vmnbBhFE4zVdAAPfQjiU2D2fCTRYzdPtJgYe7cy+05g==
X-Received: by 2002:a65:6203:: with SMTP id d3mr20776521pgv.109.1552962015772;
        Mon, 18 Mar 2019 19:20:15 -0700 (PDT)
X-Received: by 2002:a65:6203:: with SMTP id d3mr20776455pgv.109.1552962014577;
        Mon, 18 Mar 2019 19:20:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552962014; cv=none;
        d=google.com; s=arc-20160816;
        b=CHhT/Le27aIKcaPzcbv2RxCXzKoescq01BGac1/ZeOvC/XJJ01W0RGQY219m2kZZrC
         t4YyvzNdtFBNhLfYy55muHeKaf1jGgjW8x82NZBboDFsko1ty3l/UP6RW7wCyAZYvFP2
         /PTSPP2y+XlchjmQdbVwz227ysaA7ikQjVOmllgQ8P6FNAxvbtv6l+zzeTjUXwq3cegA
         AardC0uByD4KwdtBE+ZJQbx9FVfV9NzOgtXq6nEh9SIl/P8Yi0s4mdY7CxH2YOn+IhOh
         RMI6abAECgeiFRBUIuCjAFYorlRtaCTH/wTwch2tt4mMsJq3/Vpx9kNFHagM4DdVp5Bm
         LuJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=cNyFM0J2DfW9voxw9FzV7E7Y/LrzsWkGDKLqwe0d5pk=;
        b=LcIF2WzVLG/N7K9CdrmFc65y5G8IdYC4Q/ys/mWiaZHGgJxzQMzmGcLHcZP9AEq/Dg
         4hAHNme2wvBMyXG18QIkMNwd+n54+fwH8FVmWt7FWg6zr+gLSiDfH3zG6Z0QNzEHIB0V
         rKAnWA+ALEeL/i/i+VKffL/brbUoZTOIugTXTihW9/89f6dywJVALKj+InC1pngUtrti
         RiCJ4Vf0Amx19jKy3iWFL01f19ePzSEW2nCnI6FZP447qURQ1c13ZYRT5pInojr507sq
         dwDANkvBNF1Y4PK7Qy4DeCkAzhvTJKtasRVCKEQD7imTmwVEAV7q9kiRoTfAXUQkSm11
         nUgg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="VOnhA/MD";
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s7sor17539759plp.27.2019.03.18.19.20.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Mar 2019 19:20:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="VOnhA/MD";
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=cNyFM0J2DfW9voxw9FzV7E7Y/LrzsWkGDKLqwe0d5pk=;
        b=VOnhA/MDlDMHBFaInuaNe3cfsXYmEZjRFVXoCsCvPASLnJY77sdXAjcR8dnJyvEra/
         TctQPyWRtZk4YYyZ8MIJMWVLbuxLBqhmhabEiwwbgGT22L9zx6wJM1NyS3EbxPR0m1vO
         X1EMKve1wDE+kmcyF4z6OLcEOvxaBXx3c7JeyHCNY6qxhg6sbFQy5YI6I2cUilB20+X+
         upbL3vjIJWgjyifYZeK72e0KMXcdOn/0wnixdqV3N06lQW5R1d83nf+aGOSo3Dcnj4/e
         z8nH3wy4Aj5SPh7W3RVqkHa5jes7LSVPc6mfTcFP1dhEAt5OZSn17jRrX6azuxOWythp
         dctQ==
X-Google-Smtp-Source: APXvYqwnpYkFRUlh9SBEWyxbj77gYEMqcn8K1StKeULFpbauHJB0wxPLdatqpQh1Gi/kI9riB6lg3g==
X-Received: by 2002:a17:902:864a:: with SMTP id y10mr862592plt.76.1552962014189;
        Mon, 18 Mar 2019 19:20:14 -0700 (PDT)
Received: from jordon-HP-15-Notebook-PC ([106.51.22.39])
        by smtp.gmail.com with ESMTPSA id 20sm8457175pfp.98.2019.03.18.19.20.12
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 18 Mar 2019 19:20:13 -0700 (PDT)
Date: Tue, 19 Mar 2019 07:54:48 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com,
	linux@armlinux.org.uk, robin.murphy@arm.com, iamjoonsoo.kim@lge.com,
	treding@nvidia.com, keescook@chromium.org, m.szyprowski@samsung.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org
Subject: [RESEND PATCH v4 2/9] arm: mm: dma-mapping: Convert to use
 vm_map_pages()
Message-ID: <936e5e107c746a7310e3a3c471188ca3ac8f9754.1552921225.git.jrdr.linux@gmail.com>
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
 arch/arm/mm/dma-mapping.c | 22 ++++++----------------
 1 file changed, 6 insertions(+), 16 deletions(-)

diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index f1e2922..de7c76e 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -1575,31 +1575,21 @@ static int __arm_iommu_mmap_attrs(struct device *dev, struct vm_area_struct *vma
 		    void *cpu_addr, dma_addr_t dma_addr, size_t size,
 		    unsigned long attrs)
 {
-	unsigned long uaddr = vma->vm_start;
-	unsigned long usize = vma->vm_end - vma->vm_start;
 	struct page **pages = __iommu_get_pages(cpu_addr, attrs);
 	unsigned long nr_pages = PAGE_ALIGN(size) >> PAGE_SHIFT;
-	unsigned long off = vma->vm_pgoff;
+	int err;
 
 	if (!pages)
 		return -ENXIO;
 
-	if (off >= nr_pages || (usize >> PAGE_SHIFT) > nr_pages - off)
+	if (vma->vm_pgoff >= nr_pages)
 		return -ENXIO;
 
-	pages += off;
-
-	do {
-		int ret = vm_insert_page(vma, uaddr, *pages++);
-		if (ret) {
-			pr_err("Remapping memory failed: %d\n", ret);
-			return ret;
-		}
-		uaddr += PAGE_SIZE;
-		usize -= PAGE_SIZE;
-	} while (usize > 0);
+	err = vm_map_pages(vma, pages, nr_pages);
+	if (err)
+		pr_err("Remapping memory failed: %d\n", err);
 
-	return 0;
+	return err;
 }
 static int arm_iommu_mmap_attrs(struct device *dev,
 		struct vm_area_struct *vma, void *cpu_addr,
-- 
1.9.1


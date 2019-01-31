Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83A26C282D7
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 03:04:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 320A0218AF
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 03:04:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="PiHYjKk4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 320A0218AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B431D8E0002; Wed, 30 Jan 2019 22:04:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ACBC38E0001; Wed, 30 Jan 2019 22:04:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 970978E0002; Wed, 30 Jan 2019 22:04:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 55D618E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 22:04:01 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id e89so1384680pfb.17
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 19:04:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=r3ZyznqxsnQ3TNNkU3/a+vc/4Jb+njKidr9y0sWTaqQ=;
        b=D0NHnKUCIUZWKu6zUvwV47NCTRQlk4xPBiS8tLUc3cf8gtMj27i+2A0y7B1ozfTvH5
         JbvfQS3kWBLpVlojNagesCDDeX5+blOzI44hqqjrJPWhieVbveEi/Ie7wKKsMJAOEGlT
         5bK51KbDaDGdRn+W9xm+kOD+hKZPLV+dbSy35acihfISdEiecFEKMmYAgCHs1igopIv3
         KsFiQJ1YUrAIklqvBElDNRenD2rNvAgMtQu70k+bRsSEU3UEHBN6DkPZFURa6es1VF73
         FsZkVl/p4MTHA6QA3Rl7YZZJaWLEuZHiRxpyJwpOFcMJUkDnovkWqqHDXZ7Bf9VCJuLE
         NKkw==
X-Gm-Message-State: AJcUukfiYE5Bva2rNQ4QdHOqC9pDJQM1yVhk7PQIBgJOaQ8sWz38dFPk
	ronETWhpxOEdGl4vgjHzTAQsP9E4fHQNg2ElLUYgQwmB5pTwCz5w0EVAF/9bTDTggbSOrbcGPav
	pybcTMNrWv+3YOs8wDg6wnTqZBYJoG+rf4sgvtCzMoJ5TRqyJK/hyyTHLcfPPh50VdzkHIC+by2
	4cJmlvHdTgWMDkYN2sx9f9ttZ67GVPClN8OXaT0xitN/zRckrz4HQsds34iDAE8bVvdCP84LvI9
	StjWV0fFBOSTP2WWr0etRcyqJLt6gkvB27+kFwM3iCueRMoOwyKl/0/q4CR74hgRwIchZofM+Lp
	TiYQiTL5tWoWns2wYETGO498CkQJDrnE5kLyvz9RxgCpxQ5xV4ZhUns31hvRTi005YiWELhAmJn
	u
X-Received: by 2002:a17:902:a586:: with SMTP id az6mr32958666plb.298.1548903840868;
        Wed, 30 Jan 2019 19:04:00 -0800 (PST)
X-Received: by 2002:a17:902:a586:: with SMTP id az6mr32958597plb.298.1548903839863;
        Wed, 30 Jan 2019 19:03:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548903839; cv=none;
        d=google.com; s=arc-20160816;
        b=D+gpuu9Nta98IKLdSj3k68jC6bjxBQu7yqGfS1HE0tsgIQq5Aiy/W/BLztiVRMksfc
         HmywtOsIni37QmkgHCkMIQBIhJDS+HXMHo8ZZgUwOMJZ7jx5lxeUvVmLQk0vjiOSK9Su
         pyH32grM83QVdI2x4GQpqy1u7WK0dG5//MNndHYmpwElvvglfwfERWd5FMlUSGDVmFiy
         2WydygWd021sJ5ENJbNGZvxz6uZSI8WyDj+fte9kCBDMVHiNXe/PEwOVyqsYTb7MHZ/s
         LsZp6h3PXfKpii/wVUlh9wqBM78QykyZloSNFybLAg26oxGJ9EodyqLk5+ZL1GcxQA2R
         Qiaw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=r3ZyznqxsnQ3TNNkU3/a+vc/4Jb+njKidr9y0sWTaqQ=;
        b=qd4DrFIb+jpHw3VvqsMMvEKssVGPV18zrGwpGfAGe7z5c8WgBLiOhhbP7+vTAKWIAI
         fq2wqnN15wEV+J+g09eThjeQS94FOZrKgmV9NjhhaiEwJa7jnHy9R76ZxhQMQIdQPnfm
         KQa+xhhJ4pHR+YJ9Mh6BWlK0qehjZREFroSTLvf6P2qbUHUhVqby7JwBRvtPJFqpu0E1
         tvEHZnqacg1F+EMQg2VW9SuhWla3Bpw2d2/968tZABnaYPrzWhU/ldPX/0SsfvCCxvfy
         gZhV1OrI+AY09Am/cHtfy/TZDYDjHxE/FX6s5Yw61XGfKOxuOGN164aVXnLnxPctxNco
         sz7A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=PiHYjKk4;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 88sor4850343plb.63.2019.01.30.19.03.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 Jan 2019 19:03:59 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=PiHYjKk4;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=r3ZyznqxsnQ3TNNkU3/a+vc/4Jb+njKidr9y0sWTaqQ=;
        b=PiHYjKk4ZcYPCaHbgsFEKUnh3fVN4+u8o9GLS7YZQGeXUDDsXHAER0sbMrp2Nx10cO
         UbY9aiFmB+MSAtIADsbHRqLXyiSDw3GJK9fy286dp1LrInyNT31Ix6VrFQ9eNvYUnSiq
         9WAFwTyV++sklgSo+DnkLuAFdcVJyc+p8fUh8+sunYlUazhewyRWPKv5kYFVMTmG7+oM
         kj03ngQ9CVzkxbfAeUvXTzpjoYCuSRZAeHl4zSHmtfC+OXoFWoECDc/g/G0jh3uGDDSF
         1k1EJLOVh6E93hB2QYmTnqC/2vjgRM8HXm4sbhalGPXQb4ZmR3xkRUNg7kVPZITgPO3c
         NSCg==
X-Google-Smtp-Source: ALg8bN77ulDzMTd0u5w2yF1CIUMFdckIxmL4CuhfCBgk9u/Rrp9Yr7EoBKetWq6gkN0hMfNxE8FzMw==
X-Received: by 2002:a17:902:4225:: with SMTP id g34mr33628031pld.152.1548903839516;
        Wed, 30 Jan 2019 19:03:59 -0800 (PST)
Received: from jordon-HP-15-Notebook-PC ([106.51.20.103])
        by smtp.gmail.com with ESMTPSA id l184sm5303074pfc.112.2019.01.30.19.03.57
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 30 Jan 2019 19:03:58 -0800 (PST)
Date: Thu, 31 Jan 2019 08:38:12 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com,
	kirill.shutemov@linux.intel.com, vbabka@suse.cz, riel@surriel.com,
	sfr@canb.auug.org.au, rppt@linux.vnet.ibm.com, peterz@infradead.org,
	linux@armlinux.org.uk, robin.murphy@arm.com, iamjoonsoo.kim@lge.com,
	treding@nvidia.com, keescook@chromium.org, m.szyprowski@samsung.com,
	stefanr@s5r6.in-berlin.de, hjc@rock-chips.com, heiko@sntech.de,
	airlied@linux.ie, oleksandr_andrushchenko@epam.com, joro@8bytes.org,
	pawel@osciak.com, kyungmin.park@samsung.com, mchehab@kernel.org,
	boris.ostrovsky@oracle.com, jgross@suse.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org,
	linux1394-devel@lists.sourceforge.net,
	dri-devel@lists.freedesktop.org, linux-rockchip@lists.infradead.org,
	xen-devel@lists.xen.org, iommu@lists.linux-foundation.org,
	linux-media@vger.kernel.org
Subject: [PATCHv2 1/9] mm: Introduce new vm_insert_range and
 vm_insert_range_buggy API
Message-ID: <20190131030812.GA2174@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Previouly drivers have their own way of mapping range of
kernel pages/memory into user vma and this was done by
invoking vm_insert_page() within a loop.

As this pattern is common across different drivers, it can
be generalized by creating new functions and use it across
the drivers.

vm_insert_range() is the API which could be used to mapped
kernel memory/pages in drivers which has considered vm_pgoff

vm_insert_range_buggy() is the API which could be used to map
range of kernel memory/pages in drivers which has not considered
vm_pgoff. vm_pgoff is passed default as 0 for those drivers.

We _could_ then at a later "fix" these drivers which are using
vm_insert_range_buggy() to behave according to the normal vm_pgoff
offsetting simply by removing the _buggy suffix on the function
name and if that causes regressions, it gives us an easy way to revert.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
Suggested-by: Russell King <linux@armlinux.org.uk>
Suggested-by: Matthew Wilcox <willy@infradead.org>
---
 include/linux/mm.h |  4 +++
 mm/memory.c        | 81 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/nommu.c         | 14 ++++++++++
 3 files changed, 99 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 80bb640..25752b0 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2565,6 +2565,10 @@ unsigned long change_prot_numa(struct vm_area_struct *vma,
 int remap_pfn_range(struct vm_area_struct *, unsigned long addr,
 			unsigned long pfn, unsigned long size, pgprot_t);
 int vm_insert_page(struct vm_area_struct *, unsigned long addr, struct page *);
+int vm_insert_range(struct vm_area_struct *vma, struct page **pages,
+				unsigned long num);
+int vm_insert_range_buggy(struct vm_area_struct *vma, struct page **pages,
+				unsigned long num);
 vm_fault_t vmf_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 			unsigned long pfn);
 vm_fault_t vmf_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
diff --git a/mm/memory.c b/mm/memory.c
index e11ca9d..0a4bf57 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1520,6 +1520,87 @@ int vm_insert_page(struct vm_area_struct *vma, unsigned long addr,
 }
 EXPORT_SYMBOL(vm_insert_page);
 
+/**
+ * __vm_insert_range - insert range of kernel pages into user vma
+ * @vma: user vma to map to
+ * @pages: pointer to array of source kernel pages
+ * @num: number of pages in page array
+ * @offset: user's requested vm_pgoff
+ *
+ * This allows drivers to insert range of kernel pages they've allocated
+ * into a user vma.
+ *
+ * If we fail to insert any page into the vma, the function will return
+ * immediately leaving any previously inserted pages present.  Callers
+ * from the mmap handler may immediately return the error as their caller
+ * will destroy the vma, removing any successfully inserted pages. Other
+ * callers should make their own arrangements for calling unmap_region().
+ *
+ * Context: Process context.
+ * Return: 0 on success and error code otherwise.
+ */
+static int __vm_insert_range(struct vm_area_struct *vma, struct page **pages,
+				unsigned long num, unsigned long offset)
+{
+	unsigned long count = vma_pages(vma);
+	unsigned long uaddr = vma->vm_start;
+	int ret, i;
+
+	/* Fail if the user requested offset is beyond the end of the object */
+	if (offset > num)
+		return -ENXIO;
+
+	/* Fail if the user requested size exceeds available object size */
+	if (count > num - offset)
+		return -ENXIO;
+
+	for (i = 0; i < count; i++) {
+		ret = vm_insert_page(vma, uaddr, pages[offset + i]);
+		if (ret < 0)
+			return ret;
+		uaddr += PAGE_SIZE;
+	}
+
+	return 0;
+}
+
+/**
+ * vm_insert_range - insert range of kernel pages starts with non zero offset
+ * @vma: user vma to map to
+ * @pages: pointer to array of source kernel pages
+ * @num: number of pages in page array
+ *
+ * Maps an object consisting of `num' `pages', catering for the user's
+ * requested vm_pgoff
+ *
+ * Context: Process context. Called by mmap handlers.
+ * Return: 0 on success and error code otherwise.
+ */
+int vm_insert_range(struct vm_area_struct *vma, struct page **pages,
+				unsigned long num)
+{
+	return __vm_insert_range(vma, pages, num, vma->vm_pgoff);
+}
+EXPORT_SYMBOL(vm_insert_range);
+
+/**
+ * vm_insert_range_buggy - insert range of kernel pages starts with zero offset
+ * @vma: user vma to map to
+ * @pages: pointer to array of source kernel pages
+ * @num: number of pages in page array
+ *
+ * Maps a set of pages, always starting at page[0]
+ *
+ * Context: Process context. Called by mmap handlers.
+ * Return: 0 on success and error code otherwise.
+ */
+int vm_insert_range_buggy(struct vm_area_struct *vma, struct page **pages,
+				unsigned long num)
+{
+	return __vm_insert_range(vma, pages, num, 0);
+}
+EXPORT_SYMBOL(vm_insert_range_buggy);
+
 static vm_fault_t insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 			pfn_t pfn, pgprot_t prot, bool mkwrite)
 {
diff --git a/mm/nommu.c b/mm/nommu.c
index 749276b..21d101e 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -473,6 +473,20 @@ int vm_insert_page(struct vm_area_struct *vma, unsigned long addr,
 }
 EXPORT_SYMBOL(vm_insert_page);
 
+int vm_insert_range(struct vm_area_struct *vma, struct page **pages,
+			unsigned long num)
+{
+	return -EINVAL;
+}
+EXPORT_SYMBOL(vm_insert_range);
+
+int vm_insert_range_buggy(struct vm_area_struct *vma, struct page **pages,
+				unsigned long num)
+{
+	return -EINVAL;
+}
+EXPORT_SYMBOL(vm_insert_range_buggy);
+
 /*
  *  sys_brk() for the most part doesn't need the global kernel
  *  lock, except when an application is doing something nasty
-- 
1.9.1


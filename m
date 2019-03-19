Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2623C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 02:19:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66EF520700
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 02:19:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jm1r7D/r"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66EF520700
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1960F6B0007; Mon, 18 Mar 2019 22:19:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1430B6B0008; Mon, 18 Mar 2019 22:19:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F25046B000A; Mon, 18 Mar 2019 22:19:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id AE9F76B0007
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 22:19:22 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id s8so11482538pfe.12
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 19:19:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=QS3mWzK39q3lW8WqJHFL6wuRYacMcGaOmOmP8soCdrs=;
        b=m8W7B34oG3Xbq4qqR8/XybOHgC+5QNT2s/sKRCBHDvvCkJ2mt5P/I/smk35jVs+2BX
         E3YXvbcf7QkrJ+fqEfUgXekrrMl2ThtbgAEQ9dTP7L5LE8/r0EUcr/IV1skwQbiNHi18
         J1aayXoLq7lBH2fDATchaSV+cr2eVIN176/5yNLqJkLkDlI5UKlekLVZ7JUD5XwQZ9EK
         Qk4T5XVgnsGAr+86JqReQIm1NFhDgbAFS0l0DRZzsOvhy6MkLOCBHk69h40yYBvIZmPc
         3RNFIMLF3FdUE7zNluxtHX3enI/Rb5BimEdLDk0K24F7Uo8Y6hob7C5VjCZr1yiYmB6u
         O55g==
X-Gm-Message-State: APjAAAURxmZOItDq4F2yl+PBrbx/wrjz1wIXeKn69glbOqprRXMoDgaY
	fFMp6aJx0RJUi+Zcm7UkHdgb5mUivShelpo+x0yRYXt1KZxreafU+aoO5U9//rTiJPRNONUb5Ls
	5CAFBNSFHBEsBpPYL/v3dpeSJVRiMs5JkNBihQG6q5mR/5b5vVUyIN9c0oQpgz1xcKg==
X-Received: by 2002:a63:d04f:: with SMTP id s15mr20691048pgi.80.1552961962335;
        Mon, 18 Mar 2019 19:19:22 -0700 (PDT)
X-Received: by 2002:a63:d04f:: with SMTP id s15mr20690978pgi.80.1552961961159;
        Mon, 18 Mar 2019 19:19:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552961961; cv=none;
        d=google.com; s=arc-20160816;
        b=Lo4T3VRiYiE4tl+AJGODZFmq5XVdkD3w+8vh1+9XxGI02YYhTaGqRW0K0No34+EJNF
         7mJI8upqYF2Vurv++FCEqHH7E3/HmtSnd8utgV9+YnBJG3a6RIxxHc0cacWeNXillhoh
         jCyvkeAP9Ytg0d5+CKA679XLJznXySGrN0MkrAmkKWfuwgNdGhLkXkC8EoQR5ZxEpY3S
         mFTToCVqkvc+NmtCTcv0YLqZ7CUFL6A+obMgBtKZUYBJKCmE2NU9tl8BpPqm7WyKXuf8
         p8t+/nRY2zYr5F9mqgn0oCBr5DDmoO1lWQQYOzrrqyI0qH/J6DLVK6SaLBa/dDGfj17k
         ykhg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=QS3mWzK39q3lW8WqJHFL6wuRYacMcGaOmOmP8soCdrs=;
        b=0JRXfDXcqmu2guNpQ8u7Sm9DX6JN3Z7y/I9lEsSf/RVcR3Hl+y3RgD1UIMVRu5PNau
         4WsN2HMu7zjo+TYpPFNy+s+c+dn62fQhBdXM7UinWytC5Lb1TDXzGAxzG2hhfXHz1wqO
         vs3yC5g/8IuUbnt1dpUpC6dicOcoLbWkzidqE5dY6C6MYsavprdyIhPFhy1LKiKcAJwR
         Is1356MxvKArpvHzvHcfvbZM7thx0Yseml58Vxc4hj4w1zyItpuGCulS/AjYdPS1mEkg
         +TkCfIQ1PQID62TLxMEA6aou5vjib54WuqIFoDG7LZ6zMqwXlumW/omyNLwNpawwi7vw
         Z32w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="jm1r7D/r";
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 91sor17984139ply.0.2019.03.18.19.19.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Mar 2019 19:19:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="jm1r7D/r";
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=QS3mWzK39q3lW8WqJHFL6wuRYacMcGaOmOmP8soCdrs=;
        b=jm1r7D/rts2BI9YcnuOGIHlHQpyxSGz4aZOvJE/yi+Xo4uNlBnfqja0VcY+FpX9fSD
         28+KDFT/SwkBAZZ1o4TLSIUGewjtegnrMoy3LszzvJ2CwtfqOtcuC7wJMFFFvVyHlntf
         uVBrnde4SmEejwST8D2NZ4eGXPi4DunUxkLIHtZ751AARCv/ODl5lir046VNuABgvsGw
         ZJyDyGnygvc719vLtey2Vx/RTxTJZUmAHCZjnD1cfEDxhYMw8LC/WDb1WQdzBkzOb/W1
         DSw3Z0nbuStKECnh1LO8ozlsCAfA6F5QmcQvncr/iEYxCA4scPRMbXzNynH1JZmbcdsw
         XsMw==
X-Google-Smtp-Source: APXvYqz9KjQMMuck4sjrn6Sq3LDJfmEoJ+bGuZkApQa2UhKviptEqmVda9dABsOdlmGAuvojp7es6Q==
X-Received: by 2002:a17:902:20e8:: with SMTP id v37mr2843228plg.168.1552961960808;
        Mon, 18 Mar 2019 19:19:20 -0700 (PDT)
Received: from jordon-HP-15-Notebook-PC ([106.51.22.39])
        by smtp.gmail.com with ESMTPSA id q18sm14908138pgv.9.2019.03.18.19.19.19
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 18 Mar 2019 19:19:20 -0700 (PDT)
Date: Tue, 19 Mar 2019 07:53:54 +0530
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
Subject: [RESEND PATCH v4 1/9] mm: Introduce new vm_map_pages() and
 vm_map_pages_zero() API
Message-ID: <751cb8a0f4c3e67e95c58a3b072937617f338eea.1552921225.git.jrdr.linux@gmail.com>
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

Previouly drivers have their own way of mapping range of
kernel pages/memory into user vma and this was done by
invoking vm_insert_page() within a loop.

As this pattern is common across different drivers, it can
be generalized by creating new functions and use it across
the drivers.

vm_map_pages() is the API which could be used to mapped
kernel memory/pages in drivers which has considered vm_pgoff

vm_map_pages_zero() is the API which could be used to map
range of kernel memory/pages in drivers which has not considered
vm_pgoff. vm_pgoff is passed default as 0 for those drivers.

We _could_ then at a later "fix" these drivers which are using
vm_map_pages_zero() to behave according to the normal vm_pgoff
offsetting simply by removing the _zero suffix on the function
name and if that causes regressions, it gives us an easy way to revert.

Tested on Rockchip hardware and display is working, including talking
to Lima via prime.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
Suggested-by: Russell King <linux@armlinux.org.uk>
Suggested-by: Matthew Wilcox <willy@infradead.org>
Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>
Tested-by: Heiko Stuebner <heiko@sntech.de>
---
 include/linux/mm.h |  4 +++
 mm/memory.c        | 81 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/nommu.c         | 14 ++++++++++
 3 files changed, 99 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 80bb640..e0aaa73 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2565,6 +2565,10 @@ unsigned long change_prot_numa(struct vm_area_struct *vma,
 int remap_pfn_range(struct vm_area_struct *, unsigned long addr,
 			unsigned long pfn, unsigned long size, pgprot_t);
 int vm_insert_page(struct vm_area_struct *, unsigned long addr, struct page *);
+int vm_map_pages(struct vm_area_struct *vma, struct page **pages,
+				unsigned long num);
+int vm_map_pages_zero(struct vm_area_struct *vma, struct page **pages,
+				unsigned long num);
 vm_fault_t vmf_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 			unsigned long pfn);
 vm_fault_t vmf_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
diff --git a/mm/memory.c b/mm/memory.c
index e11ca9d..cad3e27 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1520,6 +1520,87 @@ int vm_insert_page(struct vm_area_struct *vma, unsigned long addr,
 }
 EXPORT_SYMBOL(vm_insert_page);
 
+/*
+ * __vm_map_pages - maps range of kernel pages into user vma
+ * @vma: user vma to map to
+ * @pages: pointer to array of source kernel pages
+ * @num: number of pages in page array
+ * @offset: user's requested vm_pgoff
+ *
+ * This allows drivers to map range of kernel pages into a user vma.
+ *
+ * Return: 0 on success and error code otherwise.
+ */
+static int __vm_map_pages(struct vm_area_struct *vma, struct page **pages,
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
+ * vm_map_pages - maps range of kernel pages starts with non zero offset
+ * @vma: user vma to map to
+ * @pages: pointer to array of source kernel pages
+ * @num: number of pages in page array
+ *
+ * Maps an object consisting of @num pages, catering for the user's
+ * requested vm_pgoff
+ *
+ * If we fail to insert any page into the vma, the function will return
+ * immediately leaving any previously inserted pages present.  Callers
+ * from the mmap handler may immediately return the error as their caller
+ * will destroy the vma, removing any successfully inserted pages. Other
+ * callers should make their own arrangements for calling unmap_region().
+ *
+ * Context: Process context. Called by mmap handlers.
+ * Return: 0 on success and error code otherwise.
+ */
+int vm_map_pages(struct vm_area_struct *vma, struct page **pages,
+				unsigned long num)
+{
+	return __vm_map_pages(vma, pages, num, vma->vm_pgoff);
+}
+EXPORT_SYMBOL(vm_map_pages);
+
+/**
+ * vm_map_pages_zero - map range of kernel pages starts with zero offset
+ * @vma: user vma to map to
+ * @pages: pointer to array of source kernel pages
+ * @num: number of pages in page array
+ *
+ * Similar to vm_map_pages(), except that it explicitly sets the offset
+ * to 0. This function is intended for the drivers that did not consider
+ * vm_pgoff.
+ *
+ * Context: Process context. Called by mmap handlers.
+ * Return: 0 on success and error code otherwise.
+ */
+int vm_map_pages_zero(struct vm_area_struct *vma, struct page **pages,
+				unsigned long num)
+{
+	return __vm_map_pages(vma, pages, num, 0);
+}
+EXPORT_SYMBOL(vm_map_pages_zero);
+
 static vm_fault_t insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 			pfn_t pfn, pgprot_t prot, bool mkwrite)
 {
diff --git a/mm/nommu.c b/mm/nommu.c
index 749276b..b492fd1 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -473,6 +473,20 @@ int vm_insert_page(struct vm_area_struct *vma, unsigned long addr,
 }
 EXPORT_SYMBOL(vm_insert_page);
 
+int vm_map_pages(struct vm_area_struct *vma, struct page **pages,
+			unsigned long num)
+{
+	return -EINVAL;
+}
+EXPORT_SYMBOL(vm_map_pages);
+
+int vm_map_pages_zero(struct vm_area_struct *vma, struct page **pages,
+				unsigned long num)
+{
+	return -EINVAL;
+}
+EXPORT_SYMBOL(vm_map_pages_zero);
+
 /*
  *  sys_brk() for the most part doesn't need the global kernel
  *  lock, except when an application is doing something nasty
-- 
1.9.1


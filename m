Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95646C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 06:55:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 50E9E24DB4
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 06:55:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="kV1L0jbz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 50E9E24DB4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA6C56B000D; Tue,  4 Jun 2019 02:55:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E0B146B0010; Tue,  4 Jun 2019 02:55:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CAC036B0266; Tue,  4 Jun 2019 02:55:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 942046B000D
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 02:55:16 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id o184so4878805pfg.1
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 23:55:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=/4JrYgSgHdndUDJKcPMt28vvDvs6001/lFYfiqCR+8k=;
        b=LhgHoYp92iI5vePLZEKK1E9QldMiuwsenbTEC2N2g1YbAo1vg+IzcIr+8OmiD70Ig1
         L7ibx8LXFSFKajiPvgLKUNQoG2V3JVhNMBjaFZYUcqZ6dPBgkUtkVdjmPPvJmxCrL/jD
         gwGjYuk+LXsvAWcewBw+uZviZ8piYEl4KMDeQPkt///w/RzEOng8nkh597UI29rPIE2l
         OyBU6gJZcgXhUk2/iXDzt+muRIYUWokG9ee/rKbXIGuyR3T/BKECwROeqcHccL04uMt0
         D9oFsN74q2kev4h5ZEg4Qjpsd8KzT8QtErQv9KnybqRx8JZZUOF+RvgEfN9NIx9Pife/
         ufNQ==
X-Gm-Message-State: APjAAAUVmLpGIHn+WaJxbeqXuNxdiENN8tu4BiRDRXpoBf30KH7UntXK
	y3Pixq8gAwX4yyyDNCyGlSRDG10X0Az84KuxqRRKdDnmiFMNYNzgpOIwRJGDvr9E78iUcz+y6Z/
	dH8RbQ5XOiDyUmKD7xW54LGqQabs51aEnhDIJUohHGSmU7Q7Kp5FR6cpyxn/2k6o=
X-Received: by 2002:aa7:80d2:: with SMTP id a18mr1043540pfn.152.1559631316056;
        Mon, 03 Jun 2019 23:55:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyb0M0Lfr8tzHpR3jOKYxF760yIDOWAj/LoqbXpSt67qM/v+3JU9TYPEWepLKv+4Ri1BYl1
X-Received: by 2002:aa7:80d2:: with SMTP id a18mr1043499pfn.152.1559631314981;
        Mon, 03 Jun 2019 23:55:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559631314; cv=none;
        d=google.com; s=arc-20160816;
        b=hO/oSjMKAGtbtLuv1vl7WU6HsxigGxenUMnSpuY8jOT+yiTrxSP3WLtHP8MKPaULhu
         1PFFe67C3uS/QAe1FOCjG8VxQZSV16m9noNQt1ZjaowY8C8eo+mSltGyoBP1PZ7CJ0UR
         7uTwQLpGkwg+wAbG5OdtNabTvTpwgX0zW6NCsUMwIdA6LwQj6Lw/ccPRcYYF13oVlIts
         oeiyXr046ozIVqtowHYBRVPPKxnDlGEWq0pQmELSNNvHMlggWd2X90e1R/C0YDboSgTu
         V1Ms30q4rkq+ogf+Z6BZBuxG60TURB7S22dg6Y2ITW7uSUheW6VVlpZb92yrdfzeFJwU
         uLwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=/4JrYgSgHdndUDJKcPMt28vvDvs6001/lFYfiqCR+8k=;
        b=eJqXEYsrOYbullfnJ95GiORBatsw9dLpG00jjXUFRRrkGHA9Ln9GxuPk7TtKgDikXZ
         HSdCCTcRajzy5hkAaJdEG3XahoDPHL342idS8YZ8pBUfQRU5Q5hO3za2YbQtoeenaXxc
         7t+3fbHsVqtp0xe6tice4qOSQegSXC58eAgpqtFIvZxXIvaBXBBWbVIFceX/GOzipNRX
         ZZirbxVvKFBcOUl3uIlrhYiZtGPc9IiOFDXw5sQ1Kb7KDD6ylQWCdGiN3FmpDVzMcX7D
         oUQjTG6zEhZq2wWGfvJwLwmGb3EYbnr8iG+pTsW6GQ8YXX3GMMU/AU17GXetPZcJmf6w
         JNQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=kV1L0jbz;
       spf=pass (google.com: best guess record for domain of batv+8160fb773a6c716236a8+5763+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+8160fb773a6c716236a8+5763+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q8si7956775pgp.333.2019.06.03.23.55.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Jun 2019 23:55:14 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+8160fb773a6c716236a8+5763+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=kV1L0jbz;
       spf=pass (google.com: best guess record for domain of batv+8160fb773a6c716236a8+5763+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+8160fb773a6c716236a8+5763+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=/4JrYgSgHdndUDJKcPMt28vvDvs6001/lFYfiqCR+8k=; b=kV1L0jbzTM25ktTT2kTpM8el2N
	0kEj0MDtBMvQ2Ljyct5xMT7zRuh/lxfzgeJCJZn27WeJtVLTV3o8lUSWvtB0zBuzbaIDvGl3Uk8fl
	myqFCYZEeVauOQYpeDd1h2dsq+n4px0Cufobx5V3ujQyBVOQEsdHxnU7OrTaQMWzdgs8jFg/WMvcc
	XceS4APlrhd2eDhESp3fNgLYsU23nUUmwMuPyTevnPN5QlcN21pl1bpt+BBxixZIkbLFhIwEo/bm2
	l2So5bkiWzmPtqeGbTLzviqP5Y+s4TjOkkq9ZE4wpHw4wX+NIzdzyqKyOGB5s5G4YXCtbKLa7UAv5
	uw+TV+Nw==;
Received: from 089144193064.atnat0002.highway.a1.net ([89.144.193.64] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hY3Li-0003ST-8n; Tue, 04 Jun 2019 06:55:10 +0000
From: Christoph Hellwig <hch@lst.de>
To: iommu@lists.linux-foundation.org
Cc: Russell King <linux@armlinux.org.uk>,
	Robin Murphy <robin.murphy@arm.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-xtensa@linux-xtensa.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 1/3] vmalloc: lift the arm flag for coherent mappings to common code
Date: Tue,  4 Jun 2019 08:55:02 +0200
Message-Id: <20190604065504.25662-2-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190604065504.25662-1-hch@lst.de>
References: <20190604065504.25662-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The arm architecture had a VM_ARM_DMA_CONSISTENT flag to mark DMA
coherent remapping for a while.  Lift this flag to common code so
that we can use it generically.  We also check it in the only place
VM_USERMAP is directly check so that we can entirely replace that
flag as well (although I'm not even sure why we'd want to allow
remapping DMA appings, but I'd rather not change behavior).

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/arm/mm/dma-mapping.c | 22 +++++++---------------
 arch/arm/mm/mm.h          |  3 ---
 include/linux/vmalloc.h   |  2 ++
 mm/vmalloc.c              |  5 ++++-
 4 files changed, 13 insertions(+), 19 deletions(-)

diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index 0a75058c11f3..e197b028e341 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -360,19 +360,13 @@ static void *
 __dma_alloc_remap(struct page *page, size_t size, gfp_t gfp, pgprot_t prot,
 	const void *caller)
 {
-	/*
-	 * DMA allocation can be mapped to user space, so lets
-	 * set VM_USERMAP flags too.
-	 */
-	return dma_common_contiguous_remap(page, size,
-			VM_ARM_DMA_CONSISTENT | VM_USERMAP,
+	return dma_common_contiguous_remap(page, size, VM_DMA_COHERENT,
 			prot, caller);
 }
 
 static void __dma_free_remap(void *cpu_addr, size_t size)
 {
-	dma_common_free_remap(cpu_addr, size,
-			VM_ARM_DMA_CONSISTENT | VM_USERMAP);
+	dma_common_free_remap(cpu_addr, size, VM_DMA_COHERENT);
 }
 
 #define DEFAULT_DMA_COHERENT_POOL_SIZE	SZ_256K
@@ -1387,8 +1381,8 @@ static void *
 __iommu_alloc_remap(struct page **pages, size_t size, gfp_t gfp, pgprot_t prot,
 		    const void *caller)
 {
-	return dma_common_pages_remap(pages, size,
-			VM_ARM_DMA_CONSISTENT | VM_USERMAP, prot, caller);
+	return dma_common_pages_remap(pages, size, VM_DMA_COHERENT, prot,
+			caller);
 }
 
 /*
@@ -1472,7 +1466,7 @@ static struct page **__iommu_get_pages(void *cpu_addr, unsigned long attrs)
 		return cpu_addr;
 
 	area = find_vm_area(cpu_addr);
-	if (area && (area->flags & VM_ARM_DMA_CONSISTENT))
+	if (area && (area->flags & VM_DMA_COHERENT))
 		return area->pages;
 	return NULL;
 }
@@ -1630,10 +1624,8 @@ void __arm_iommu_free_attrs(struct device *dev, size_t size, void *cpu_addr,
 		return;
 	}
 
-	if ((attrs & DMA_ATTR_NO_KERNEL_MAPPING) == 0) {
-		dma_common_free_remap(cpu_addr, size,
-			VM_ARM_DMA_CONSISTENT | VM_USERMAP);
-	}
+	if ((attrs & DMA_ATTR_NO_KERNEL_MAPPING) == 0)
+		dma_common_free_remap(cpu_addr, size, VM_DMA_COHERENT);
 
 	__iommu_remove_mapping(dev, handle, size);
 	__iommu_free_buffer(dev, pages, size, attrs);
diff --git a/arch/arm/mm/mm.h b/arch/arm/mm/mm.h
index 6b045c6653ea..6ec48188ef9f 100644
--- a/arch/arm/mm/mm.h
+++ b/arch/arm/mm/mm.h
@@ -68,9 +68,6 @@ extern void __flush_dcache_page(struct address_space *mapping, struct page *page
 #define VM_ARM_MTYPE(mt)		((mt) << 20)
 #define VM_ARM_MTYPE_MASK	(0x1f << 20)
 
-/* consistent regions used by dma_alloc_attrs() */
-#define VM_ARM_DMA_CONSISTENT	0x20000000
-
 
 struct static_vm {
 	struct vm_struct vm;
diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 51e131245379..500fa4fb06f0 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -18,6 +18,7 @@ struct notifier_block;		/* in notifier.h */
 #define VM_ALLOC		0x00000002	/* vmalloc() */
 #define VM_MAP			0x00000004	/* vmap()ed pages */
 #define VM_USERMAP		0x00000008	/* suitable for remap_vmalloc_range */
+#define VM_DMA_COHERENT		0x00000010	/* dma_alloc_coherent */
 #define VM_UNINITIALIZED	0x00000020	/* vm_struct is not fully initialized */
 #define VM_NO_GUARD		0x00000040      /* don't add guard page */
 #define VM_KASAN		0x00000080      /* has allocated kasan shadow memory */
@@ -26,6 +27,7 @@ struct notifier_block;		/* in notifier.h */
  * vfree_atomic().
  */
 #define VM_FLUSH_RESET_PERMS	0x00000100      /* Reset direct map and flush TLB on unmap */
+
 /* bits [20..32] reserved for arch specific ioremap internals */
 
 /*
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 233af6936c93..c4b5784bccc1 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -2948,7 +2948,7 @@ int remap_vmalloc_range_partial(struct vm_area_struct *vma, unsigned long uaddr,
 	if (!area)
 		return -EINVAL;
 
-	if (!(area->flags & VM_USERMAP))
+	if (!(area->flags & (VM_USERMAP | VM_DMA_COHERENT)))
 		return -EINVAL;
 
 	if (kaddr + size > area->addr + get_vm_area_size(area))
@@ -3438,6 +3438,9 @@ static int s_show(struct seq_file *m, void *p)
 	if (v->flags & VM_USERMAP)
 		seq_puts(m, " user");
 
+	if (v->flags & VM_DMA_COHERENT)
+		seq_puts(m, " dma-coherent");
+
 	if (is_vmalloc_addr(v->pages))
 		seq_puts(m, " vpages");
 
-- 
2.20.1


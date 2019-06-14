Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3BC5AC46477
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 13:47:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E8EC2217D9
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 13:47:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="O+TbJCIv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8EC2217D9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8A0FD6B0003; Fri, 14 Jun 2019 09:47:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8521D6B000A; Fri, 14 Jun 2019 09:47:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 719876B000D; Fri, 14 Jun 2019 09:47:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3C7286B0003
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 09:47:45 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id 71so1620622pld.17
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 06:47:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=8y6h8N73FB5NENGJmXuBWpySrRWBuNuuherB6ijj6q8=;
        b=VGo3+AkwSLwlSO87Htg6NWYRzgitQf4kl1DhbIzvgJ5MBxGXff9x4s7luJp3Xh/R0R
         IAL9+SoqknfJQuG7ATKF2gGKD058fzHbbUQ9244tMQeSeAwrSCS7IkzC4bF8pECPFdz2
         GL2d/WFJ5ZVx1YLaI5WMuI68SlBiAC72UJhN0eJkCbiB4VgKA1Wwrxtb6MLhU+/Kp87h
         em+Up2fuGRg9T2MWbd43jvSovU9YrAluVeYJhyfffTTH5BmvAh6z6ACTfeN33FLE7AqM
         SInzNuwbtUMDVUwKUGrKUJIKdMeZZ5jykL7C7TKgtji5PcDdY+qEO3mV5F0DiuWEW+Lu
         RbMQ==
X-Gm-Message-State: APjAAAW4c29BbYt0TZ+tm7SQh9FZIGvsIuynbIGoc8NyQZyJZVroDt8m
	Hu5A3FUd6CtAcWliM9CuZJ9AgCZObKunqsO0NYGjYywTApvz6EL6mTvCTf62x0ETrTDBzJRPYp2
	u0p7ZU2YafrVjY5tiMDl2PFwR/tZOXw/q8b+x5qYqHffsp0YJarhM4PTSUqMtH1A=
X-Received: by 2002:a63:4a20:: with SMTP id x32mr32765561pga.107.1560520064706;
        Fri, 14 Jun 2019 06:47:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzZmOJDFcktinAfdU57Yr5pK1bSnay/wxVqF4N4w+Yvdysj5lIv710WzB5VdVVwZcT3cVbL
X-Received: by 2002:a63:4a20:: with SMTP id x32mr32765508pga.107.1560520063812;
        Fri, 14 Jun 2019 06:47:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560520063; cv=none;
        d=google.com; s=arc-20160816;
        b=vME/1cKNjShtZCNVs2IXKQ0R5Z3Vcy1+TeN3lfExcg6Psz/SWRimmcymnDQUroG8YP
         TMuBqjkpmxBzA9iIMKYiIpHMjfpsDYb9E7DvDNdCFL3vkiPLhD4y9hyS6HH4hW5Ckz64
         WSwvk76hebw16t9YOCr17SSnbLesIX8gy7BCjPDsfp/j8sK47GKyWyqNlOu+3gX/dKan
         cBifJiwbILms4d7K5IJ00pICCO1dUZvHtl/XqY1qzJzBpIdq7Wt5+FbZCbwTU/Awoiyu
         JudGjPMemVDSP+4hHTN5HZLE75TMSgB6SnpCpCKrEXuEJGLYeex9S70nLEI1N/TObAce
         a0uQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=8y6h8N73FB5NENGJmXuBWpySrRWBuNuuherB6ijj6q8=;
        b=JKxSHhAzR2ARg/S8bv8d3UHwSV2cnXzlurjtLxApp7yCR951R62Gmjvxqn7/It9GvK
         EakoS7QyrSIvcY4qULK4aOKPgpFhMsas3+LfliCjhMW92HXj+iZQivi5c0AKa/OqQCCE
         kRsIodf2P9kXm9pboq7zsQLJpAxp+KP8zEnXEPxkGlPJEgNC5UN2sLpyXUHvlkMD438v
         MQdCPmyQP7aj+Zc8104Ug7nIBevfoc2K7TZUf6mQgzOuoPgSk00wDVULzMVG9+/zmFXh
         m24u6kBhmBAJepbU3xZfEoL4wFB6TM1/+iW5Se/+urEm48rt4EujvArU0/Ndae/ZMcPl
         c3gg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=O+TbJCIv;
       spf=pass (google.com: best guess record for domain of batv+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c128si2549638pfa.221.2019.06.14.06.47.43
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 14 Jun 2019 06:47:43 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=O+TbJCIv;
       spf=pass (google.com: best guess record for domain of batv+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=8y6h8N73FB5NENGJmXuBWpySrRWBuNuuherB6ijj6q8=; b=O+TbJCIvZxITqhhJGk19PgKDVb
	zP/cXr3k3gVNVyNuIZZ1EUainJIi7wVTUxXsQtP55j6fTBfcF7Sa+btFSjlOoBpdFax1u6ZazzUaz
	FPx/YcvbrcmM0hj9iSxxr66wiPpIo2CQcbBfULKCswmUhdFlmoDtWAaHV5c6chhQgW7u9cc4uUrYi
	+YgK5P2yi8DIc4PxIDTgNB0H2HMyfDDjSri1AD09oFbVupeMjadiOSOnAJwBO5Fva8F5W4du1//3V
	PC6NEPWuGSXf3Iz9K+nbMDUlMTGN745meRSObE6d5NxDDUuRnYJGChXPFHVxfA6Pw0enVfuoGJDnu
	q+P8IvBA==;
Received: from 213-225-9-13.nat.highway.a1.net ([213.225.9.13] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbmYJ-0004Xw-Il; Fri, 14 Jun 2019 13:47:36 +0000
From: Christoph Hellwig <hch@lst.de>
To: Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
	Maxime Ripard <maxime.ripard@bootlin.com>,
	Sean Paul <sean@poorly.run>,
	David Airlie <airlied@linux.ie>,
	Daniel Vetter <daniel@ffwll.ch>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>,
	Ian Abbott <abbotti@mev.co.uk>,
	H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: Intel Linux Wireless <linuxwifi@intel.com>,
	linux-arm-kernel@lists.infradead.org (moderated list:ARM PORT),
	dri-devel@lists.freedesktop.org,
	intel-gfx@lists.freedesktop.org,
	linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	linux-s390@vger.kernel.org,
	devel@driverdev.osuosl.org,
	linux-mm@kvack.org,
	iommu@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 01/16] media: videobuf-dma-contig: use dma_mmap_coherent
Date: Fri, 14 Jun 2019 15:47:11 +0200
Message-Id: <20190614134726.3827-2-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190614134726.3827-1-hch@lst.de>
References: <20190614134726.3827-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

dma_alloc_coherent does not return a physical address, but a DMA
address, which might be remapped or have an offset.  Passing this
DMA address to vm_iomap_memory is completely bogus.  Use the proper
dma_mmap_coherent helper instead, and stop passing __GFP_COMP
to dma_alloc_coherent, as the memory management inside the DMA
allocator is hidden from the callers.

Fixes: a8f3c203e19b ("[media] videobuf-dma-contig: add cache support")
Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/media/v4l2-core/videobuf-dma-contig.c | 23 +++++++------------
 1 file changed, 8 insertions(+), 15 deletions(-)

diff --git a/drivers/media/v4l2-core/videobuf-dma-contig.c b/drivers/media/v4l2-core/videobuf-dma-contig.c
index e1bf50df4c70..a5942ea38f1f 100644
--- a/drivers/media/v4l2-core/videobuf-dma-contig.c
+++ b/drivers/media/v4l2-core/videobuf-dma-contig.c
@@ -39,11 +39,11 @@ struct videobuf_dma_contig_memory {
 
 static int __videobuf_dc_alloc(struct device *dev,
 			       struct videobuf_dma_contig_memory *mem,
-			       unsigned long size, gfp_t flags)
+			       unsigned long size)
 {
 	mem->size = size;
-	mem->vaddr = dma_alloc_coherent(dev, mem->size,
-					&mem->dma_handle, flags);
+	mem->vaddr = dma_alloc_coherent(dev, mem->size, &mem->dma_handle,
+			GFP_KERNEL);
 
 	if (!mem->vaddr) {
 		dev_err(dev, "memory alloc size %ld failed\n", mem->size);
@@ -260,8 +260,7 @@ static int __videobuf_iolock(struct videobuf_queue *q,
 			return videobuf_dma_contig_user_get(mem, vb);
 
 		/* allocate memory for the read() method */
-		if (__videobuf_dc_alloc(q->dev, mem, PAGE_ALIGN(vb->size),
-					GFP_KERNEL))
+		if (__videobuf_dc_alloc(q->dev, mem, PAGE_ALIGN(vb->size)))
 			return -ENOMEM;
 		break;
 	case V4L2_MEMORY_OVERLAY:
@@ -280,7 +279,6 @@ static int __videobuf_mmap_mapper(struct videobuf_queue *q,
 	struct videobuf_dma_contig_memory *mem;
 	struct videobuf_mapping *map;
 	int retval;
-	unsigned long size;
 
 	dev_dbg(q->dev, "%s\n", __func__);
 
@@ -298,23 +296,18 @@ static int __videobuf_mmap_mapper(struct videobuf_queue *q,
 	BUG_ON(!mem);
 	MAGIC_CHECK(mem->magic, MAGIC_DC_MEM);
 
-	if (__videobuf_dc_alloc(q->dev, mem, PAGE_ALIGN(buf->bsize),
-				GFP_KERNEL | __GFP_COMP))
+	if (__videobuf_dc_alloc(q->dev, mem, PAGE_ALIGN(buf->bsize)))
 		goto error;
 
-	/* Try to remap memory */
-	size = vma->vm_end - vma->vm_start;
-	vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
-
 	/* the "vm_pgoff" is just used in v4l2 to find the
 	 * corresponding buffer data structure which is allocated
 	 * earlier and it does not mean the offset from the physical
 	 * buffer start address as usual. So set it to 0 to pass
-	 * the sanity check in vm_iomap_memory().
+	 * the sanity check in dma_mmap_coherent().
 	 */
 	vma->vm_pgoff = 0;
-
-	retval = vm_iomap_memory(vma, mem->dma_handle, size);
+	retval = dma_mmap_coherent(q->dev, vma, mem->vaddr, mem->dma_handle,
+			vma->vm_end - vma->vm_start);
 	if (retval) {
 		dev_err(q->dev, "mmap: remap failed with error %d. ",
 			retval);
-- 
2.20.1


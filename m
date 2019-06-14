Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3894C31E4C
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 13:48:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5A56820866
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 13:48:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="cf3JZA+Z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A56820866
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 680A66B0274; Fri, 14 Jun 2019 09:48:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5E2736B0275; Fri, 14 Jun 2019 09:48:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 40C4B6B0276; Fri, 14 Jun 2019 09:48:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 06AB46B0274
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 09:48:42 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id y7so1819442pfy.9
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 06:48:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Gz4Xhr4GKX8cgnBiH4+BILh020IQOylUizPJRjDHE/E=;
        b=a3OftsEIAN3BdV3wt8J5CYVLzNv2q/McEqwy857OucbLWjOOwRuCdDDdaFzOoGTroP
         W2EyyvcDZ3xaAxd8pPmBCSRS7MDU1jfwvrutrJaKnxZ106aToSXhRVEfg6/G+5i/tZ3l
         JOEj5X/gb3uQa3ZmY+83jlcQfuVRybxuqo268bwvNvgG6q3rTYXkG/iK3jGGSovbl5Oo
         sMnCOK7RJtt/qmuK1X1G5eGnoCyr2/p98T2JCavKAZuTXnKz11UnckvV84Hxd+5eLJZ/
         rSmH4dKHIGBlioMqxIx1D0y++qb/1LIZiL6cAZUGEtQj7dwP27nsmW7yunhTE4Nilxlx
         h1pw==
X-Gm-Message-State: APjAAAUaHMgq6aHbKdp8XEx7ay0kn1SwKkj413R0AoRLQIc+VKjsDrWB
	3yUsyH71FcHHQNE2wI1SQ/PiUQyM/TusY4mfl3kRDd2L6SNX1qKDa58XPwINBOyZU28fpazfaax
	NPRBONNzRbxFENoq1Kv4TewHJJ0Fpe9ddFIcUXxMoscFoZ/c6n+aUfj+lSZNGjxg=
X-Received: by 2002:a63:5d45:: with SMTP id o5mr36419154pgm.40.1560520121568;
        Fri, 14 Jun 2019 06:48:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzdopmA470xDu8fjuyeSXz2sSw74fFz6rW51aIkPMC7Z8PWU38VO5mSS1LvcXGPW3xYofBD
X-Received: by 2002:a63:5d45:: with SMTP id o5mr36419090pgm.40.1560520120723;
        Fri, 14 Jun 2019 06:48:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560520120; cv=none;
        d=google.com; s=arc-20160816;
        b=YVid7O7rKn+WAioHoJ7HwVgDa7zQckT6tLzu/JceinomFsCxuoBf5oEGS7HJL4leJF
         QxKnn8zbOf+9GOWA4muP5J5fJaZxW8GmU5LvYJjDuV1xmVAA4aPGeXfye8glJTTAIsCj
         x+lC2CKfx+ZAym5yd2cDV1hmbsAGkJlQZwM/iPI3OfVOEvM+72UpkhfQ3YpNKrh6zD4i
         Xlbvuyn/XmkT/cTtNLVWznYfwd2JvDfPkYfFLxIxDP0mOCuSbMkXYuh9Hhl6MUDqwz3O
         6fCo+FHhNawyg2dXNX6Zb+mTPtkn/bL5YSulJ7EJ6c1p71NXeCk4/+RYq75ix/Qoff7n
         duEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Gz4Xhr4GKX8cgnBiH4+BILh020IQOylUizPJRjDHE/E=;
        b=ApxKzgqbvFBcVkd6FRB+PmcwsVV/B4VTX1Na9mBWyAZuyvznfBo41y7RLlycFrMokn
         cMgv+JhPHSGrtc72h7rtiZCJgCnJpbB9XGZy72U+T3SHqau42onrx4SMjEw+19u2NFO5
         81pe2Qbs3T7FRpRXVhPBsk27BcO5WX8tSMFSlLLvEcPf3opqUdUOv/8CO2yfdL7Q2pDl
         +YXuyp7ZSRbn9RqyYzC/s5EeQ0jYOvSRpwYWsa56OLAGt2rwYg+n4yqOUDpnPb1XIhr9
         hmZPv2vQ4z1Ax0Jg6iccVyPYkzjn7Av1gmLplCrjK6g/zphvlP136ROaZJq8NBbMxLTs
         Trlg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=cf3JZA+Z;
       spf=pass (google.com: best guess record for domain of batv+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t7si2644104pgu.3.2019.06.14.06.48.40
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 14 Jun 2019 06:48:40 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=cf3JZA+Z;
       spf=pass (google.com: best guess record for domain of batv+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=Gz4Xhr4GKX8cgnBiH4+BILh020IQOylUizPJRjDHE/E=; b=cf3JZA+ZRH3KX860kHpnPR8oA/
	bqAxf2wdh/kYQFTTiXQ/cfGIHFtkzi1Q6IAe9eh8VXYnYOyFEmHCCu4FhR+BvSXtpAx5ApdhZC2tL
	eqsB5EioSDc9+R5gTT7rMPzafsusILIBU05BomvsIAKlHCVNuXOq2PanGax2oHqCJpo1ef3+4E/WO
	eAvSS6Dx80B05dalPw/wekrBppUw3IEJLxzJHpuSGlVG4QM3kKSs6MrdGwLQEd0MHw3LaJPiqt54p
	Ec8ghntYydM0pKm2+mAy/RaUMsAIhlCtQMD+RUDzu5uz1USZRuoH2TqfwRFQkKEzx7x86HBrZfST/
	CbsAG57g==;
Received: from 213-225-9-13.nat.highway.a1.net ([213.225.9.13] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbmZ3-0005hB-Ky; Fri, 14 Jun 2019 13:48:22 +0000
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
Subject: [PATCH 14/16] mm: use alloc_pages_exact_node to implement alloc_pages_exact
Date: Fri, 14 Jun 2019 15:47:24 +0200
Message-Id: <20190614134726.3827-15-hch@lst.de>
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

No need to duplicate the logic over two functions that are almost the
same.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/gfp.h |  5 +++--
 mm/page_alloc.c     | 39 +++++++--------------------------------
 2 files changed, 10 insertions(+), 34 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 4274ea6bc72b..c616a23a3f81 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -530,9 +530,10 @@ extern struct page *alloc_pages_vma(gfp_t gfp_mask, int order,
 extern unsigned long __get_free_pages(gfp_t gfp_mask, unsigned int order);
 extern unsigned long get_zeroed_page(gfp_t gfp_mask);
 
-void *alloc_pages_exact(size_t size, gfp_t gfp_mask);
 void free_pages_exact(void *virt, size_t size);
-void * __meminit alloc_pages_exact_node(int nid, size_t size, gfp_t gfp_mask);
+void *alloc_pages_exact_node(int nid, size_t size, gfp_t gfp_mask);
+#define alloc_pages_exact(size, gfp_mask) \
+	alloc_pages_exact_node(NUMA_NO_NODE, size, gfp_mask)
 
 #define __get_free_page(gfp_mask) \
 		__get_free_pages((gfp_mask), 0)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index dd2fed66b656..dec68bd21a71 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4859,34 +4859,6 @@ static void *make_alloc_exact(unsigned long addr, unsigned int order,
 	return (void *)addr;
 }
 
-/**
- * alloc_pages_exact - allocate an exact number physically-contiguous pages.
- * @size: the number of bytes to allocate
- * @gfp_mask: GFP flags for the allocation, must not contain __GFP_COMP
- *
- * This function is similar to alloc_pages(), except that it allocates the
- * minimum number of pages to satisfy the request.  alloc_pages() can only
- * allocate memory in power-of-two pages.
- *
- * This function is also limited by MAX_ORDER.
- *
- * Memory allocated by this function must be released by free_pages_exact().
- *
- * Return: pointer to the allocated area or %NULL in case of error.
- */
-void *alloc_pages_exact(size_t size, gfp_t gfp_mask)
-{
-	unsigned int order = get_order(size);
-	unsigned long addr;
-
-	if (WARN_ON_ONCE(gfp_mask & __GFP_COMP))
-		gfp_mask &= ~__GFP_COMP;
-
-	addr = __get_free_pages(gfp_mask, order);
-	return make_alloc_exact(addr, order, size);
-}
-EXPORT_SYMBOL(alloc_pages_exact);
-
 /**
  * alloc_pages_exact_node - allocate an exact number of physically-contiguous
  *			   pages on a node.
@@ -4894,12 +4866,15 @@ EXPORT_SYMBOL(alloc_pages_exact);
  * @size: the number of bytes to allocate
  * @gfp_mask: GFP flags for the allocation, must not contain __GFP_COMP
  *
- * Like alloc_pages_exact(), but try to allocate on node nid first before falling
- * back.
+ * This function is similar to alloc_pages_node(), except that it allocates the
+ * minimum number of pages to satisfy the request while alloc_pages() can only
+ * allocate memory in power-of-two pages.  This function is also limited by
+ * MAX_ORDER.
  *
- * Return: pointer to the allocated area or %NULL in case of error.
+ * Returns a pointer to the allocated area or %NULL in case of error, memory
+ * allocated by this function must be released by free_pages_exact().
  */
-void * __meminit alloc_pages_exact_node(int nid, size_t size, gfp_t gfp_mask)
+void *alloc_pages_exact_node(int nid, size_t size, gfp_t gfp_mask)
 {
 	unsigned int order = get_order(size);
 	struct page *p;
-- 
2.20.1


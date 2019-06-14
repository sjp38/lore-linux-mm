Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09502C31E4B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 13:48:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AE4FB20866
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 13:48:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="UntrdW5G"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AE4FB20866
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4F84C6B0269; Fri, 14 Jun 2019 09:48:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 480CB6B026A; Fri, 14 Jun 2019 09:48:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 322866B026B; Fri, 14 Jun 2019 09:48:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id E89286B0269
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 09:48:06 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 14so1906626pgo.14
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 06:48:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=GC9Gboqptsed7WVs/myU7Q6vnMi9vBxIwQ2uPA5D0pw=;
        b=asTbacolRUNuHjP/8KksCAyNyFkiIZ83uNjiwCiJKIa61MD8qJxl3uyOxUEOujGW9X
         FR5JuzLDku9Zvys7E2GsOi6pNzmnbpNm+hPGZBn2PpGmPlCkda/5tkz0kzaCQA7Mt/Qj
         GbDTnWRGJymjzwIhaZWw6QnYB22/1TGO3DxBwlgSLUQxLzOMLUAXuNi+MJZiRz4pRUZU
         KSTBnkTchM+S4RrcqVXXy76TbJ1LSaRP8eUfyoyFyZ/iRJBYx+OcwVOiYGX25EZU++yB
         wF4XS+DSKv6aAwy3lG77wR7aChNIkJqEkFdFRyDmCssHRSOdxFvvJ8GLuOMgQg979rh+
         1qpA==
X-Gm-Message-State: APjAAAX1yKseAQaUad+2vQkitFBBAyupdFUQ2KCxfBsM8+jkP0r8VPlM
	xmYSRdJyTG6QffQdT0FxSFpffPIwI3ETsl2+03/5uAQmgg1yINnQcxZCTEp+uGALfSSgTDk2NI3
	Vc4zrwBd7bMbd+6z9OGcaN0x824Z++0xfHcZWmjkBqksT/9YeVhe6Ie5UIX36L90=
X-Received: by 2002:a63:f54c:: with SMTP id e12mr36043886pgk.62.1560520086499;
        Fri, 14 Jun 2019 06:48:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx4uONsHOt2J8SAnOGDY/m/RYfyHuxTkg/MHfo4RUAH6TjhJzuK0lvl5kgHZyaPEykyE3+V
X-Received: by 2002:a63:f54c:: with SMTP id e12mr36043842pgk.62.1560520085810;
        Fri, 14 Jun 2019 06:48:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560520085; cv=none;
        d=google.com; s=arc-20160816;
        b=TwG73POjyFcKYMeyK6GxmbGNaU8tOtA4Grtd71c03oQttehMas2jfnlu4dZLXtD45t
         LnAcDyrSdt0tBn2V8t6VHJDuW+kEhmV17aglVI4rMjaOB6RFPvhGxPOO3fDgefuPIVZ9
         KpyYJvI5cGebF1tKt9MduVTDDl+QgujMi+dkIW9zWO3g0Va6SjplpddQR5+LrwZpc9VG
         rCFjSC8RVtDg38kjR4Bn3hfcpzERt+JkHBZOvNRO9+jH69QX3dHicoUtP7PvIg8d9GdV
         vfGsT/xcCsKYNlkSzOXYH7XRh2OVVSSGZAH1tZmprOqUz80HzIwH/X6LzG3nmrGCwJBf
         OyTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=GC9Gboqptsed7WVs/myU7Q6vnMi9vBxIwQ2uPA5D0pw=;
        b=WIdmqNATr6lIZXzikbCuDYUihquGbCyDJVFjTnPM3JvmBIQwianmbmzlxgA5ZAohbh
         4hjkw1IW2FpewWpSI/AH7WufQmAfEQ/gj6eGyir/As6FhR5M3qzucUc4GxNbtH89CuXE
         tPvIsDw/ghDreF9jrUlhxoHp+BsUFAMsjUS4t3XpgM26YfDVVcX5y8VGjIJwiNNsdyMe
         wM4L9KxsMLtCkUG+J9tY8eLM0nMLBpzuomOWJW/rApxmqBD0AOHjKBZQN3LDvxBHnTsw
         iCnBKDDVUbue1UqtUlGEXROh0HVce/aGLIa3try7Xo6m8WL4kON1KuyKroKQjofwWGcS
         lduQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=UntrdW5G;
       spf=pass (google.com: best guess record for domain of batv+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m5si2327013pls.18.2019.06.14.06.48.05
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 14 Jun 2019 06:48:05 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=UntrdW5G;
       spf=pass (google.com: best guess record for domain of batv+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=GC9Gboqptsed7WVs/myU7Q6vnMi9vBxIwQ2uPA5D0pw=; b=UntrdW5G2+b49vgfbJaGUDLN0E
	6yE3PpGKvsuDOwoXcyXIdlGC5PZ5Rx2/rsrnwuL8rTHEvIhh9QW1GU17v1tVNFho0ne9tn/Z4eT54
	OswJKEO4vsr1FvbWuovnG6n4mY8AwbgfvU32igpwJyhrRibTzRGYZ0pS+zdU9gFhrv4TTezoxvPTg
	hlLUh5YHvDGvTCdMXXQ7VhKjApYDYfxlL3VT+nNwtwNQkVPOAXwAW1qubfFu1o+AsbdCjGKbzv2rR
	p+QnqhNY4+X8ZCNtkVbeuJ4T0148xhaiU0PQmlP12f+mNEdx8mMY/AvPPLm2vvkGBNkm80UQVHowq
	4Bj27y3g==;
Received: from 213-225-9-13.nat.highway.a1.net ([213.225.9.13] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbmYa-0004vN-2H; Fri, 14 Jun 2019 13:47:52 +0000
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
Subject: [PATCH 06/16] drm: don't pass __GFP_COMP to dma_alloc_coherent in drm_pci_alloc
Date: Fri, 14 Jun 2019 15:47:16 +0200
Message-Id: <20190614134726.3827-7-hch@lst.de>
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

The memory returned from dma_alloc_coherent is opaqueue to the user,
thus the exact way of page refcounting shall not matter either.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/gpu/drm/drm_bufs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/gpu/drm/drm_bufs.c b/drivers/gpu/drm/drm_bufs.c
index b640437ce90f..7a79a16a055c 100644
--- a/drivers/gpu/drm/drm_bufs.c
+++ b/drivers/gpu/drm/drm_bufs.c
@@ -70,7 +70,7 @@ drm_dma_handle_t *drm_pci_alloc(struct drm_device * dev, size_t size, size_t ali
 	dmah->size = size;
 	dmah->vaddr = dma_alloc_coherent(&dev->pdev->dev, size,
 					 &dmah->busaddr,
-					 GFP_KERNEL | __GFP_COMP);
+					 GFP_KERNEL);
 
 	if (dmah->vaddr == NULL) {
 		kfree(dmah);
-- 
2.20.1


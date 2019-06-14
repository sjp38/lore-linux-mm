Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A480C31E4E
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 13:48:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B9333217D7
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 13:48:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ty9usQOn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B9333217D7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4D3B66B026D; Fri, 14 Jun 2019 09:48:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 438346B026F; Fri, 14 Jun 2019 09:48:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 239686B0270; Fri, 14 Jun 2019 09:48:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id D74E96B026D
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 09:48:23 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id x3so1920241pgp.8
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 06:48:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=OBOS8iCVbCKavrjNtD9grYbIza6qqnOVd5RpWueyj/M=;
        b=FFifYwuSjN3r5gS6RJZ+9clUtQmgycIEFvpt9oAoXdulGvuz3fwKOmr343VCQngAGa
         3jhIp23eCSVv6RoA856IlrZnGNEU/Y8uqHFKWassrag6VveQJtze/DFitbDXul4OhnrQ
         iFUxcKGZ1gVW+vffiILm5zoq9BPDe0qHXyzJ35B47uqel7n47/bBJZc8k/mIT5J3zGeU
         pFcwdMlC91/Egj7MTpTqrr9xEyrGCEM/+h23IfP/lcLhLFCyhhGL7M8Bh57Wzy3iRCOR
         IM3eh+JtPvldrjX4KLtBOfxUCu9NPiYu1BX3ZeGvV6vyrxxyloGGukatcr5goI9nTR/S
         KRpQ==
X-Gm-Message-State: APjAAAU6sEKz5OmEZKoUI+u6T4s31fcmkSIpsf5abtAaBdn4+hH6jiiL
	zcr3hzw1fsghrTKwW2fwYoGCo5V6XESEYPT0u656u/ubQuiUJREz5fKm8GI+SKFhHBdwpBR9iWk
	Ss27mNroxwGFG9jdyjYbGSinV7EPu5hBiNSkLThUcg9EGZo5gLESAeiZfWXjZVgs=
X-Received: by 2002:a63:5d54:: with SMTP id o20mr34293422pgm.97.1560520103484;
        Fri, 14 Jun 2019 06:48:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzE0CKZ2N1CDPAoGvYVEm8UPP0TLsBam6nVX6QerMQfn7JR048x4KyPN5xC/UTtXMZ9PvfG
X-Received: by 2002:a63:5d54:: with SMTP id o20mr34293366pgm.97.1560520102683;
        Fri, 14 Jun 2019 06:48:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560520102; cv=none;
        d=google.com; s=arc-20160816;
        b=yDPLcDlxqkL4ZhKaLUR797q7YNdL6Ucip1aCZcqpSF3gFf402gB7J9CG6IeZIe9YCI
         3UmCWhH8FT00cKiBMHL+ewJYnqj+XQJdgKYzf2BNgIszsC3h5p+0G0tQlsaNzEDue1Tj
         tgxvyqtaa3uhUP5VS4P2w3seU8cUXUEtPFXjmK2X0I/MlL9jwq2nWDu8Hd3uW62Bd0Vo
         B0zt9P2QfHcnNaUF/qbM0ITlgw+pC4d3o46eRYHG/1SVa8mkdrQ2aUF8POrb3ZqN/7N9
         YPhGWfKxncgH9EjG7lqEgCv+CypcLoEDtcXcEYuxgrj41GXtdPOIIAHaMq/jKflbjAtN
         hcTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=OBOS8iCVbCKavrjNtD9grYbIza6qqnOVd5RpWueyj/M=;
        b=bHXMTyu/trV91uZ6lDSp7wN/h8yBtfjUPOvLEteuWQwwruu9Ycb/jT11ilC4OC2Twu
         VLGnvtAitV/HPgqUCZY2y8BV/34hn/skPpSg4Va5NBb/3jScAoJlhcQj+53JdU7wWtSu
         HSzt04np9QOFVkEX+HP4ygKy4ejUck7MUj6hx8vB/Fnft4NPdjBATqNHUuJcWi01t2mf
         Vw7PCRPJnC1FxKLnbDMziYSAibjty+I4LGdk0iZlSXZjfXtBF6ibivXbsWvNnPomBOiS
         mt/taWI67wm64REC5OJ6wxsWTsRER1H8dDHFuVqTbhGvhCjwJEqzK0PH07Mr3E+JCMIR
         llcQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ty9usQOn;
       spf=pass (google.com: best guess record for domain of batv+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m11si2408819pjl.64.2019.06.14.06.48.22
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 14 Jun 2019 06:48:22 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ty9usQOn;
       spf=pass (google.com: best guess record for domain of batv+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=OBOS8iCVbCKavrjNtD9grYbIza6qqnOVd5RpWueyj/M=; b=ty9usQOn48ryjo/yA+LI46GxnP
	KU+hV8DMp9K1AiYIp8CEWPCsYTVt0fa2fCx5FsgZtmFG+oZvda4iGOisvCu0KEUqYodtwwPbJHVPw
	Db2/6G2kesXnDnAn6z45JeeW3RlmDj87Wy6HfqWc00nj35RFlVFkRRZqPO0HsFrH99HI5YZOdnRTJ
	tHa9SDSKcyyo8FiIMQIwPBhvOKYxNIVJw/YdoAgm7jutOjnHItVUz1dXoVckleKMabuzqyEvJHykt
	ISIIujsBNMPIb0GXNcbQX1pr9F5xfFC5uZwG+WNcNlp5UaVPCWtpvsAYlg/ngmgqOUWtijss40PJa
	oxHQO6Tw==;
Received: from 213-225-9-13.nat.highway.a1.net ([213.225.9.13] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbmYn-0005Ie-J2; Fri, 14 Jun 2019 13:48:06 +0000
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
Subject: [PATCH 10/16] iwlwifi: stop passing bogus gfp flags arguments to dma_alloc_coherent
Date: Fri, 14 Jun 2019 15:47:20 +0200
Message-Id: <20190614134726.3827-11-hch@lst.de>
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

dma_alloc_coherent is not just the page allocator.  The only valid
arguments to pass are either GFP_ATOMIC or GFP_ATOMIC with possible
modifiers of __GFP_NORETRY or __GFP_NOWARN.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/net/wireless/intel/iwlwifi/fw/dbg.c     | 3 +--
 drivers/net/wireless/intel/iwlwifi/pcie/trans.c | 3 +--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/intel/iwlwifi/fw/dbg.c b/drivers/net/wireless/intel/iwlwifi/fw/dbg.c
index 5f52e40a2903..323dc5d5ee88 100644
--- a/drivers/net/wireless/intel/iwlwifi/fw/dbg.c
+++ b/drivers/net/wireless/intel/iwlwifi/fw/dbg.c
@@ -2361,8 +2361,7 @@ iwl_fw_dbg_buffer_allocation(struct iwl_fw_runtime *fwrt, u32 size)
 
 	virtual_addr =
 		dma_alloc_coherent(fwrt->trans->dev, size, &phys_addr,
-				   GFP_KERNEL | __GFP_NOWARN | __GFP_ZERO |
-				   __GFP_COMP);
+				   GFP_KERNEL | __GFP_NOWARN);
 
 	/* TODO: alloc fragments if needed */
 	if (!virtual_addr)
diff --git a/drivers/net/wireless/intel/iwlwifi/pcie/trans.c b/drivers/net/wireless/intel/iwlwifi/pcie/trans.c
index 803fcbac4152..22a47f928dc8 100644
--- a/drivers/net/wireless/intel/iwlwifi/pcie/trans.c
+++ b/drivers/net/wireless/intel/iwlwifi/pcie/trans.c
@@ -210,8 +210,7 @@ static void iwl_pcie_alloc_fw_monitor_block(struct iwl_trans *trans,
 	for (power = max_power; power >= min_power; power--) {
 		size = BIT(power);
 		cpu_addr = dma_alloc_coherent(trans->dev, size, &phys,
-					      GFP_KERNEL | __GFP_NOWARN |
-					      __GFP_ZERO | __GFP_COMP);
+					      GFP_KERNEL | __GFP_NOWARN);
 		if (!cpu_addr)
 			continue;
 
-- 
2.20.1


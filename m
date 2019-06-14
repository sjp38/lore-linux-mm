Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 03318C31E4B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 13:48:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B7F3E21744
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 13:48:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Tpc9x4lP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B7F3E21744
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 59FB46B0271; Fri, 14 Jun 2019 09:48:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F6626B0272; Fri, 14 Jun 2019 09:48:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 349A76B0274; Fri, 14 Jun 2019 09:48:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id E9F646B0271
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 09:48:37 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id x3so1920601pgp.8
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 06:48:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=uJddLBdDNaWL4wSSvZ2YhjeFWIY1bS4Okt/V8tHSUJw=;
        b=Kl4rRludQGjPauPhvZ9Mnx52sdF1zzGdpuXgyxHXSKbBLXna6pF89N/MPvKDbRAaRN
         MsMktq7QtUF71djdcZqfrL76B761fSKAlUeSmIWcXYvcZsoMXkTTj8foY5IgSuco4f3y
         fNlIjuAzjncKSSR+/D3nH/eEQzoNUkoYC6Js7sdfxeOhB2n/FWjwUdPADbmXQbQkjVEc
         S6OAZPUXzC/G2AYgVKPHWrdIEcJx4QdvIDwXuU2448f/xsUwW2ITzUocLXeZrMI8PH9O
         PsXh4izQolZE30gRoDBvXBpSAEBO5MCUXlvQOv/opOFDNwJpRGQzGJbVHyAv6WiJ+3xI
         VU9Q==
X-Gm-Message-State: APjAAAWEFRBTuZsUOM5kQ1eaylgX0NnipMi67neyAO2gi8D4qSzN97Vq
	0XfNoL+fTwyz7D0vlJoMCy4l+VWnAjCVCHADw3Fpj5tlqhKxGmpZpXFk8zXAshFIL73rQkoJw/m
	S5QQU3b85Yv26QDF1zGYBGxVYRNAk7jcd/T7l72ZMXus0jI9Te8IvlDh/BiuxsnQ=
X-Received: by 2002:a65:638a:: with SMTP id h10mr5336636pgv.64.1560520117427;
        Fri, 14 Jun 2019 06:48:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx4eHa8Nabo4iIhodtfZa29niGBId3BqRyDEPNENH8gfxH2yNRUb8wcO4wtuimnxiTnfvRY
X-Received: by 2002:a65:638a:: with SMTP id h10mr5336578pgv.64.1560520116700;
        Fri, 14 Jun 2019 06:48:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560520116; cv=none;
        d=google.com; s=arc-20160816;
        b=asdK8jAYLBxHpawnZljEmfar37K4eNPzGB0LNwNP0pJMoH/Fuo17ajdFH3ZjFmX87N
         j54tH3oIafJK1+UYO145mJkJWcCb6uZh0YA8OxuEBn9D8UALKPTg2cRHPVeOb4YvVHtM
         S1sTA9pEHAaxL8kN3ffjxPN3TcUfxcqVAZVLfr+nlAPP7OfmELpxiWsxwT0p7XMdi5OD
         6YmxzPi4OISPkr2Qq5hB2HNAgHJensLmAR6d7mnbyinbKKlK2aPGXjPQwdx31ZJKlD1J
         F01O1udBSyveAe2Jw6YDCCc5QQRG5gGNvkaGABlh8rBNCts1r4VBo3+Au2mZFMTvV0Ro
         GuGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=uJddLBdDNaWL4wSSvZ2YhjeFWIY1bS4Okt/V8tHSUJw=;
        b=pEie0tuzGG1Z3UHCXrLipr+Fm/ICRKLlYl0+BsNg6u7w8A7cozHTrPJs42qdGg+UCg
         vVywJSZAmIlvv6tW+BZM38BUm30iD+I+P3ZxBcbEv6nlpZHlNIxzMCPnOjEFWmOE7Hdk
         OHjJTMDt2TEvWQzqRItgpM10jxPhHp1NHk7LQDcvZ5jHgZnoLzMzN+tpftRPMpQSX/gr
         XkdUCxlbhsO0tpOxaVuRb2b0tnXvbC/7Y6OLb94mbDeatLQzRXB4oSCkeGq9xghVnook
         5TUT3zeiejcDBAjMy3S+3D1F9XtaW6HfRDblt5MYK41qhYsGB84ej/97sSkXcyQZ+8mZ
         nBuQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Tpc9x4lP;
       spf=pass (google.com: best guess record for domain of batv+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k7si2273375pll.145.2019.06.14.06.48.36
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 14 Jun 2019 06:48:36 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Tpc9x4lP;
       spf=pass (google.com: best guess record for domain of batv+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=uJddLBdDNaWL4wSSvZ2YhjeFWIY1bS4Okt/V8tHSUJw=; b=Tpc9x4lPYqhK3XjIXO4GqJY9rv
	9rJeQeQNbim7ZbrvzWwlYZe6uviPZA8B8PnxWsyT6JGwXhhBWJVdSZXfCFQexWetdjj9pyjlFh9xF
	NNuQWOD5YMIca+yt05/XIg8Wkq6pGz0Z85GD2RuHezWtfbKqQOoREoRWCESCbTHgW7AMp5BbVshrc
	pEh3xewVIl6LVjW2c5Fh7o0QsoPF6TFPCQBrS9GLC8RQ30e45tR99TsjbM05NZ0+J3y0gAw3KzjRt
	lGDsivXtuD6ZbALT0tjqUJ7bWzADYRpbOi1VBP2HP7AECc7ayAViL+6MV1bLNQPDXazLoyPeSUXcq
	WTLTT30Q==;
Received: from 213-225-9-13.nat.highway.a1.net ([213.225.9.13] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbmYv-0005Sj-P5; Fri, 14 Jun 2019 13:48:14 +0000
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
Subject: [PATCH 12/16] staging/comedi: mark as broken
Date: Fri, 14 Jun 2019 15:47:22 +0200
Message-Id: <20190614134726.3827-13-hch@lst.de>
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

comedi_buf.c abuse the DMA API in gravely broken ways, as it assumes it
can call virt_to_page on the result, and the just remap it as uncached
using vmap.  Disable the driver until this API abuse has been fixed.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/staging/comedi/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/staging/comedi/Kconfig b/drivers/staging/comedi/Kconfig
index 049b659fa6ad..e7c021d76cfa 100644
--- a/drivers/staging/comedi/Kconfig
+++ b/drivers/staging/comedi/Kconfig
@@ -1,6 +1,7 @@
 # SPDX-License-Identifier: GPL-2.0
 config COMEDI
 	tristate "Data acquisition support (comedi)"
+	depends on BROKEN
 	help
 	  Enable support for a wide range of data acquisition devices
 	  for Linux.
-- 
2.20.1


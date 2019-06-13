Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7F7FAC31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 09:44:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3AF0C21473
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 09:44:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="lGnynT1H"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3AF0C21473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D1EED6B0278; Thu, 13 Jun 2019 05:44:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CCD7E6B0279; Thu, 13 Jun 2019 05:44:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B7B9C6B027A; Thu, 13 Jun 2019 05:44:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 73D976B0278
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 05:44:31 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id s22so7618338plp.5
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 02:44:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=FtWCNVd4QOpMTthKbNz1MFUxeFEvCSuwTqmj0Q74N1M=;
        b=hpP1MzufFndfsonGKFVMF9dL5zEmM39yBHpAn6tRFrZ+kDrg2hVV1waJwdjSqiZgLi
         9gOm/JVLFQ6xRZTbmh66K/5/aFvnc3Y7Kg4d2nd9iSHgrRgsqpT5/HRVqRJ4/KCSPT0b
         vsPpA9GFOBJRxXBbQgqt6iUo8TvD3TSsOaVnYExjwuJSltxP80y3uJklQOizvHLcXdnt
         jd0ZqqV8Rp2UeN7jMWtIQXcVpmogzkyhmkUBI7Kaypa/ReLN/0jdxn4ztqCnh+3QoSIc
         vUfft2ERfxPMRuH4CBzWm5uaQlu6x++RzndXVK6N/qXoSy0aUZP2AbsVL9BRJRou/pSR
         +Skg==
X-Gm-Message-State: APjAAAU2eFnY4iaK7sFpCzHQIHxAfpPqlTT5+y8L60mIQUvyBdFhpEoE
	STL3ZiTHSV3bssIRagRNWSKrdJt4zS7p8gO7gFXxWMPTrT3a0kDWdxB3jnsilt4IJjQiQrb10Md
	JGKyGUssFqVQrQKhOrL++YZ7UKhW1qRp876cRcJoruPkZD2JLVhUIVhNi5WEOoXk=
X-Received: by 2002:a17:902:7883:: with SMTP id q3mr85626226pll.89.1560419071130;
        Thu, 13 Jun 2019 02:44:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxjrF0dhI7ZdXYcwQN2TGvAmwUNuOJ6Rsqy/ClWB9/fWHiwjbaTU0VHN/T1zf1fmdI90Z+a
X-Received: by 2002:a17:902:7883:: with SMTP id q3mr85626146pll.89.1560419070367;
        Thu, 13 Jun 2019 02:44:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560419070; cv=none;
        d=google.com; s=arc-20160816;
        b=d3+IR1enH3wAEZ5+C+Qs/E2Z3BppP9OIV+WyBEpkBx4RA12o6GtZ6fWeYb0Vy1OuGw
         eQwBz1TR3zMk8U/IZPuChuUiKmpDzKe3+ofliNHAdOSvL8rBA5//KxdftUYWhSEbDJ3w
         RIRg1OlwAF09ASj+gwVc2ae8+4w6xbdL3szjKIE/HDNtyuvLWtRnaLJZB/PJqERJrJdT
         dC3j9GqlwRuy/CRUob0n9lwbHv+eCSoAi2PT61dsEoEMPUKewJ4rR3VYlI6GyJ0XkYQw
         ZPv/ZQduyi56/8y/wjpo6iYCm0WoVbOGtfX8fr/wCtPkoxaYBjKhUlTlUo58OSPfNSja
         rNzg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=FtWCNVd4QOpMTthKbNz1MFUxeFEvCSuwTqmj0Q74N1M=;
        b=tyd0RP8cJ2RqqEqfFctGk5u/rebEzKTnLTJQWAqd7fS8bPDH93kjNFltP6YpPRzq46
         Px+ShK1b3hhnScabMEw5VSiB49RTFtoJeGSsdZdxaTOm7266GysWUi2BSRDPkQlXOg0h
         dz82mZEFObA8cw7Qc95jmEC059etCuGgP42kix0H8UYLicYkeECHssiPtxMz+sijf606
         tJx+QonJ6jjsUxS6V36GWoWKulxCveeF1jrCIwBSYzGzNQq/JVe2dnHJCMpqedYwbpQP
         TovFi4trXbKdTsrmRJfyFiMkj9S852IJjHdruQa3hy/eB6E+RtbQEPXgVj5Ek+UI8UeT
         oSVg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=lGnynT1H;
       spf=pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l11si2529786pgp.438.2019.06.13.02.44.30
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 13 Jun 2019 02:44:30 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=lGnynT1H;
       spf=pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=FtWCNVd4QOpMTthKbNz1MFUxeFEvCSuwTqmj0Q74N1M=; b=lGnynT1HToRc+NaRbBtuR81QYR
	NemOaLZIDgAQej+KaIa1UxM9jdzyIje1zBDkPe1VX9Ai3Z8hZ/9xJPbgJt4zVuMpEcWMze36SAPe8
	jadfF1tnyC53GvHJN+XmEhIe1jarXKgqt4YOPBypOu+e8vTxzEa3yDupP2NKBlUg2R8XoiT+70txr
	XjVnT4tikVWG9g+QrpVgLj/2IWv0sdZQEPOrc3z1nIk8VZ3R1YxTTaO5R14SWaIYcAO2xKeDnsgkf
	BG35saHwjH85vx0W3/7W5L524Osw05sNZ5JeAjweKs/0jw6m5MZxo8PHbgl0DcrLc6CYCGDX6R30L
	Li0+Fu8g==;
Received: from mpp-cp1-natpool-1-198.ethz.ch ([82.130.71.198] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbMHS-0001wn-Qc; Thu, 13 Jun 2019 09:44:27 +0000
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 20/22] mm: sort out the DEVICE_PRIVATE Kconfig mess
Date: Thu, 13 Jun 2019 11:43:23 +0200
Message-Id: <20190613094326.24093-21-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190613094326.24093-1-hch@lst.de>
References: <20190613094326.24093-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The ZONE_DEVICE support doesn't depend on anything HMM related, just on
various bits of arch support as indicated by the architecture.  Also
don't select the option from nouveau as it isn't present in many setups,
and depend on it instead.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/gpu/drm/nouveau/Kconfig | 2 +-
 mm/Kconfig                      | 5 ++---
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/Kconfig b/drivers/gpu/drm/nouveau/Kconfig
index dba2613f7180..6303d203ab1d 100644
--- a/drivers/gpu/drm/nouveau/Kconfig
+++ b/drivers/gpu/drm/nouveau/Kconfig
@@ -85,10 +85,10 @@ config DRM_NOUVEAU_BACKLIGHT
 config DRM_NOUVEAU_SVM
 	bool "(EXPERIMENTAL) Enable SVM (Shared Virtual Memory) support"
 	depends on ARCH_HAS_HMM
+	depends on DEVICE_PRIVATE
 	depends on DRM_NOUVEAU
 	depends on STAGING
 	select HMM_MIRROR
-	select DEVICE_PRIVATE
 	default n
 	help
 	  Say Y here if you want to enable experimental support for
diff --git a/mm/Kconfig b/mm/Kconfig
index 406fa45e9ecc..4dbd718c8cf4 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -677,13 +677,13 @@ config ARCH_HAS_HMM_MIRROR
 
 config ARCH_HAS_HMM
 	bool
-	default y
 	depends on (X86_64 || PPC64)
 	depends on ZONE_DEVICE
 	depends on MMU && 64BIT
 	depends on MEMORY_HOTPLUG
 	depends on MEMORY_HOTREMOVE
 	depends on SPARSEMEM_VMEMMAP
+	default y
 
 config MIGRATE_VMA_HELPER
 	bool
@@ -709,8 +709,7 @@ config HMM_MIRROR
 
 config DEVICE_PRIVATE
 	bool "Unaddressable device memory (GPU memory, ...)"
-	depends on ARCH_HAS_HMM
-	select HMM
+	depends on ZONE_DEVICE
 	select DEV_PAGEMAP_OPS
 
 	help
-- 
2.20.1


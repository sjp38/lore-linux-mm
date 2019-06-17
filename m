Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA942C31E59
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:28:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 64F5E2084D
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:28:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Z78KcWBb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 64F5E2084D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B6F48E001A; Mon, 17 Jun 2019 08:28:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 33D388E000B; Mon, 17 Jun 2019 08:28:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 18B1F8E001A; Mon, 17 Jun 2019 08:28:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id DC5F08E000B
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 08:28:33 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id r7so5912541plo.6
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 05:28:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=FtWCNVd4QOpMTthKbNz1MFUxeFEvCSuwTqmj0Q74N1M=;
        b=Tmtgu0jZ7czIj7uQOfoao76WsQ14+xBZSuMa5UxcWclgdZSlEqLrmtg9ksdwual903
         rBa8t3YdBD4UJiFRcGinp833xLn0m//L+cSu/an7OG9kvWlM/vpuwojyf716yr7V67PL
         4UyCGJpdhMDCFZmXQinAgtKmgoi8ZrVCMnx7nqy59hrgYBpMF+zoSnMW26GxKvmrZpft
         IZYL4EasyZzbo7K2HXZZaIRbyxSmkuRvSrHDBQWWTzA6GMmLqvZiCrk3wMGQEv6a/b3u
         j3/xlqYWwgcXqr4OjG2eYV1hw5F5a6U/xp6E5pZ4RhmESD3U0Pxav38m+sVeHPVh4BwZ
         Vz3g==
X-Gm-Message-State: APjAAAVBR6n6dIie1p8Jgi0f5I3Hpswn98MuvSDZWXGn13W7kyspmEUW
	H/5s7H0zJLi4DxH7JZR37iNF0UyAPH7yFOWDwudXOylIj3Ip69cRcAfi9J7e/QKG2JCop6qczZg
	ADbLnMVaQdirEEIy7dzVBEVGMHNeDYMPqcwd+ZbQAnAqU8xM0PfkCEBjLEPCc3Sc=
X-Received: by 2002:a63:c508:: with SMTP id f8mr11074701pgd.48.1560774513528;
        Mon, 17 Jun 2019 05:28:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyzbX5fRkzbxkxPGEaQgk0SqfwO21rDVGtQCNwXwkm1tdjdT2AM77Xa2jf88otbPlKI7g/g
X-Received: by 2002:a63:c508:: with SMTP id f8mr11074648pgd.48.1560774512799;
        Mon, 17 Jun 2019 05:28:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560774512; cv=none;
        d=google.com; s=arc-20160816;
        b=KkMSf7cZUoK4nChwQkOqWun16UXdT3CooHuGkEDXZ2SoPF0AlNbplwa6zefl/7bufW
         yQHR66B7TR/UCvZqSZsYy/r93rC8qw/SwWmr9aFfPUymyPWF0u2vMYK8BeMqYrR6skqG
         e3oGF0w2Mp+1rwUgF5cFFwwO59+yZDNQ+Cjj0MYEnyCuKcADix4UI543tpZA12oWYOIp
         z9jRVYwKZkHYjw4qsHuh3M3pi1gvOz861es+x8U0ov2sZ54/2BZ1TVhC2sVlMmBW6yZM
         gVNfKPadjgPbHJGpSoo4sCyWC3ZxIznVG+EHXsKizI2vz/UlXu1jDS0h4RLFdU1zT7iT
         LNTg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=FtWCNVd4QOpMTthKbNz1MFUxeFEvCSuwTqmj0Q74N1M=;
        b=MuFXV7DN+YRyjfiVe0vfpSaTKtAtKGcOx85hCxwdvAJDHgGRfUrMsjk7uv7cxZ43e0
         EpFSsQj61ykKgGcC0Nss1SIaC1MHKAAUojt+ev0fLOPnXVkgbKOIU+oD2eSZTMq8NtE8
         inygApdzT8LYehby6pfjCgvzB2C0rbc6rBhr1ZO+KKxjGbeSqL/YGL7VGN5+Vd9eJx5v
         LUnU917hOqc1l+8lKPQpDdwbEVSKYqfvdbph5p4907Wu9lFD2g08hHCSeZgSD2wSfK4B
         s4XLUwAfmnQ3habgmcslIdbD/pX47wYQeaHVS4iQIvwvTWiPbCHl8vSnEP2gwscam9Ht
         zGog==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Z78KcWBb;
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id i11si10240914pfa.240.2019.06.17.05.28.32
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 17 Jun 2019 05:28:32 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Z78KcWBb;
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=FtWCNVd4QOpMTthKbNz1MFUxeFEvCSuwTqmj0Q74N1M=; b=Z78KcWBbsFX3gceHor7ikVE3Xz
	qTbuNA7cIzuIpzZqGXtGE+PWrq6MRN37GCRxbiHzeUrB8YXse/T2hIbfv5I/Nv94RL8TYyWumUDzY
	Iwhm/tvNNL22C4RRe6kUEw81nHAOzzaxylSaaEWyW9ggqOXKvgFWxPGzMDqRHyaofiDatgcCj/5jQ
	Kvok1nykqb8M0G7lY7ijcHY/VUiKcCkrkMVX5UPZWWWOwl17xrUk8W/xkoS+uAm5nyLGxOuV6JtVy
	qXd+BOjdKQ6KhZOBIxzhndIT5fce88/KzVDayE/YLhkBFFe8J+LNBG12buYQ7TZ26ZY5Ax0HIR1u9
	Kbdo8lXg==;
Received: from clnet-p19-102.ikbnet.co.at ([83.175.77.102] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hcqkO-0000Xg-C5; Mon, 17 Jun 2019 12:28:28 +0000
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
Subject: [PATCH 23/25] mm: sort out the DEVICE_PRIVATE Kconfig mess
Date: Mon, 17 Jun 2019 14:27:31 +0200
Message-Id: <20190617122733.22432-24-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190617122733.22432-1-hch@lst.de>
References: <20190617122733.22432-1-hch@lst.de>
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


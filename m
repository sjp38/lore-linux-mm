Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC1D2C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 09:44:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A495A21473
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 09:44:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="RICVtgPD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A495A21473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AAC206B0273; Thu, 13 Jun 2019 05:44:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A35CD6B0274; Thu, 13 Jun 2019 05:44:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8D5A96B0275; Thu, 13 Jun 2019 05:44:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 56CEC6B0273
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 05:44:25 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id q6so11596595pll.22
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 02:44:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=CRiADhhFQCJg9nNjQAj6fEu4785skzNOaJQJ8kIUJ84=;
        b=jAqALvcckuRGtpA2NpwSejoMK7oRU+P2jtK15a2xWUPUvpqIWPUqHUjTbsmeGDyyUK
         x0UyJgTjj+syQZJ/QmScUXV0ZYekMXJ2+XvrbeQ4iAxTl0QXHPyiosV9LxYbCkDoj7Yn
         1nsloner2CTdo20ULghR6hH08Pf5EgPDfYZUsKpWG51kZ3ZCuzOC8InxY0DUojbHBaei
         z+RfY0kIZo5EbsZymzTly8RvITribL+v2w+uN9/YU906VP4i3cZOyd8mdYVaBs3G2ZI+
         +Yv/UrYmAgkPvHKM3EJJuWOei3SkaaHXtoKWJSAKvpTe9/4VgCxZjF2KKsFQj899Qwfy
         BWmg==
X-Gm-Message-State: APjAAAWKqfQUXwiGxIoyJgOcFTVH04vpYQymyXqnHGGJYKHza3YjKES+
	JHgA5Op/HbnbrfSmp5/jgftXc4dpGSjI+dot2OPK2MvEXSIGysOu2E2f0MZ3vU6oDxeiJv2AW7g
	BWr4UWXMBZn+DRUcIK0bZf9L12O0W3n3ATyaX6ePl/iGHpzKgajss2uNoI8NXThA=
X-Received: by 2002:a17:902:8a87:: with SMTP id p7mr69851672plo.124.1560419065011;
        Thu, 13 Jun 2019 02:44:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwHzTqq3JNNxe8NiEBeuV6lbn0j6jzM5ZtFvWZCiEr0ZetlXmM4GDzmQSRfbLIN7c5atb5j
X-Received: by 2002:a17:902:8a87:: with SMTP id p7mr69851602plo.124.1560419064411;
        Thu, 13 Jun 2019 02:44:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560419064; cv=none;
        d=google.com; s=arc-20160816;
        b=cesCSlAw57dVs9z3pDWsOCE/b60iKtQztdjlRRQ47XbzbBHW/6/A5AbQ7un4WCnGIY
         GYONiGX4TAM9Krp+1odAerjSSau8QVPtlojWOUjgyT8Xhp+GB9Tm1/tIN0xDfHhdoxns
         7pci0wyMZwoj4CIg9bTcBMURxvH0PrIgriFVZhRaAoUG0mJfi7koH7gCXlT6ibeDWBTM
         r35AisrNqBzwBawye13WJML4e7MaOu4NYgRJ4e0Ok5sJB6JSneSVzqaW4tcPtF2Sl3oW
         yLpn/L4seglAFdwOmjC7eo0PB9uZY5MMhjp4+6ChnAYyaCc1ShqnMLbrSr9+CeaxMFAa
         nSJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=CRiADhhFQCJg9nNjQAj6fEu4785skzNOaJQJ8kIUJ84=;
        b=mDeibn7AI6HGWMUQTuev2Rl7WXgc6lrxzv7Nzz70o0OOF4vocEp1tLdY4IxG8NmMBu
         3HyxpKf2yqp/Jo07wJwwm+H5kcq/NA+HkPkaBsyymKhHUn0T+CKqfs+jyyZl46D+FGCJ
         ztDUs3YR1T4TwOfBV8XEakNaBG/50k7ZdpdPuUz53KqFxy9Oxjow+3Q2ab/Yq67ALTGP
         +ehUHY8LDYePeZ43zFsi0lRgbVXXy/ibQZQCFKFD9wgptfKK8dfhDR9BDio4RxYJF9Ro
         1nl2jWYPRXMe9apLkdtmelYNyMTHUeIr+kAlzln29fe319GHpzbl9PP3ipV078MUsjwf
         LEcA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=RICVtgPD;
       spf=pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a2si2716920pgj.54.2019.06.13.02.44.24
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 13 Jun 2019 02:44:24 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=RICVtgPD;
       spf=pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=CRiADhhFQCJg9nNjQAj6fEu4785skzNOaJQJ8kIUJ84=; b=RICVtgPD9yRZZLP5zsYav1rSx/
	4WdeVXj2hZit21ZRFFahZ0/Xb9mrzF4vFMbjwhHwZzDxsHyjhAYAjmS4CGJjsNQ74TT7TZO+AoiA8
	+ykg9PdHRyJwz/zj0+/7ArN0Je2Zw3qhosZvIyWbnFjQtkiduRtXyxNYuw04kKoGUORMz6fHpxLtZ
	YTsDeVucQ5ychr3mWksaSDMicYxSgVYHcYqX1CuoizhG/ngsFEwRbS6GP4xrZvfELvZso8ubWK1Qy
	sTIETQwqU64lawnEds6n1N2gMvIX74tlW7hKHlfT8cTH89GLpVOhPBfu2I9eGuksdH2m3MVGivwF/
	Hf1LW1Lg==;
Received: from mpp-cp1-natpool-1-198.ethz.ch ([82.130.71.198] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbMHM-0001vf-Vf; Thu, 13 Jun 2019 09:44:21 +0000
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
Subject: [PATCH 18/22] mm: mark DEVICE_PUBLIC as broken
Date: Thu, 13 Jun 2019 11:43:21 +0200
Message-Id: <20190613094326.24093-19-hch@lst.de>
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

The code hasn't been used since it was added to the tree, and doesn't
appear to actually be usable.  Mark it as BROKEN until either a user
comes along or we finally give up on it.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 mm/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/Kconfig b/mm/Kconfig
index 0d2ba7e1f43e..406fa45e9ecc 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -721,6 +721,7 @@ config DEVICE_PRIVATE
 config DEVICE_PUBLIC
 	bool "Addressable device memory (like GPU memory)"
 	depends on ARCH_HAS_HMM
+	depends on BROKEN
 	select HMM
 	select DEV_PAGEMAP_OPS
 
-- 
2.20.1


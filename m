Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BBCBDC282DD
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 21:11:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 847462183E
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 21:11:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 847462183E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1537B6B0005; Wed, 17 Apr 2019 17:11:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 102C66B0006; Wed, 17 Apr 2019 17:11:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F33DE6B0007; Wed, 17 Apr 2019 17:11:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id D2B416B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 17:11:50 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id z34so133671qtz.14
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 14:11:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=iGBJJba8peJ5n44elK1fXeo275MMPljSawDoaPq2kiU=;
        b=PZanUTdnrMdW6wipGPF6eto7oFJFn6C8pfN71bAeRuF/9nvp6idWs3ZB87WWzGIFg9
         eA0oWLk3cMnuJeN3WIL+SsrsU81PFvi/ypmyGanC+/j2LOKShM18AtPg61VxLGAHFlk4
         NoGFUG/Hwoeb2vb6DuIw7jp8TbTsiDlDQ2z4viUJGOqaYt6cVoArqg15jY7Nc0dT6sOP
         Zc8UAUAF0zvNJ5gljsMK5DAlSsv2soPZSzJmBkD46ZVZjJqyHjakf51do6jZ9fEDd7Tw
         qnslXwMnS0UyPOSax1V3/6SeMfZwN/MBBJF2rtDulzp79LCQUqrHDU1dDMU1vZLBHntf
         MJtA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW4ZXMuAqUzn6FkAsvamLlQUXVEVzplaZutZ9gSH7aSap4X9s52
	pGShBnfc1eR2k6fFw5ATi0fyZi8FuNVhwcE+5BALEC0Ly1p4lpivQctYBOm5t0Bb+bpch1aIQgH
	wX9MMhnae0fpCvZT7Tvgs1fXYGjVEzkFf7pAvsb2s71nqs9BoAgNRAKFOEquQwTtC5Q==
X-Received: by 2002:a05:620a:1659:: with SMTP id c25mr34874561qko.44.1555535510639;
        Wed, 17 Apr 2019 14:11:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzsnwKMpv1FIoz/2hLtIcx9y9V4XkI1P75wT5dJeczEutAIXn0URKB/1zRPolBAQ55s/rdw
X-Received: by 2002:a05:620a:1659:: with SMTP id c25mr34874509qko.44.1555535509956;
        Wed, 17 Apr 2019 14:11:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555535509; cv=none;
        d=google.com; s=arc-20160816;
        b=FW6nAki6Cm+bdXItYZVbtj696A4E39gFRsok5UD+W4nxlfChIAmvypCnN4SRopHLKO
         SWO5xGMV03yvgPnFDKza/F8Z+qj6Ap1keavJPGXP3EtyrDsvA/D8bGLWS7CvmEOiTCwu
         UDuNgtShHwEtIIsKKorIEC0o58AOArMioz6wZJ6COjtvjd9prtrDavn2CP7KqmVBt0BS
         2bFE9GDAtZXWWf3hgArlWxIJz2rCROWK14OEwReKOH6kYel3JFxSUtqd3EQo1USBJbMu
         rvWnTQbyPLYcl/ia1Iy2G4WNOR/ekYOSZaWa7/wdY+SnZj2ko0BQIb9icrMkCLoamKJX
         2LWg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=iGBJJba8peJ5n44elK1fXeo275MMPljSawDoaPq2kiU=;
        b=pAL33vJ0deNcX1rohpnMhxN4jjAZektbOkuYX9cnC8k7oUzX9yvGD1A71GonXgME8T
         NPRutnvZtu6dKDx1/ANnrZcJREqPvE2iYiy7gYxMeKoNQh8Q5T2ai4kGIkix1sGMhIMe
         Qo+Q8NSPjU3vhTn4iF8Wu0Z+amxJlLsXzlZA9Qoz4oA3WpBdXqdsXO3hHv7hWhP10YC9
         3/ar5jTnHEj0rtNSAHt9SZVpfGJhRdNG7SlYljybA8Pc56D65qbyKauwExAGg6r+132x
         nb7eTVCBMnZDJjOpR7ULvtlqNV9XcQsQ0pCM1KFHvaY4aHeWhG28gVx9+vLwJOQKIHwA
         yyow==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h12si5517634qtb.51.2019.04.17.14.11.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 14:11:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 2E1503003199;
	Wed, 17 Apr 2019 21:11:49 +0000 (UTC)
Received: from localhost.localdomain.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTP id E852A5C205;
	Wed, 17 Apr 2019 21:11:46 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Leon Romanovsky <leonro@mellanox.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>
Subject: [PATCH] mm/hmm: add ARCH_HAS_HMM_MIRROR ARCH_HAS_HMM_DEVICE Kconfig
Date: Wed, 17 Apr 2019 17:11:41 -0400
Message-Id: <20190417211141.17580-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Wed, 17 Apr 2019 21:11:49 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

This patch just add 2 new Kconfig that are _not use_ by anyone. I check
that various make ARCH=somearch allmodconfig do work and do not complain.
This new Kconfig need to be added first so that device driver that do
depend on HMM can be updated.

Once drivers are updated then i can update the HMM Kconfig to depends
on this new Kconfig in a followup patch.

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Cc: Guenter Roeck <linux@roeck-us.net>
Cc: Leon Romanovsky <leonro@mellanox.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
---
 mm/Kconfig | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/mm/Kconfig b/mm/Kconfig
index 25c71eb8a7db..daadc9131087 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -676,6 +676,22 @@ config ZONE_DEVICE
 
 	  If FS_DAX is enabled, then say Y.
 
+config ARCH_HAS_HMM_MIRROR
+	bool
+	default y
+	depends on (X86_64 || PPC64)
+	depends on MMU && 64BIT
+
+config ARCH_HAS_HMM_DEVICE
+	bool
+	default y
+	depends on (X86_64 || PPC64)
+	depends on MEMORY_HOTPLUG
+	depends on MEMORY_HOTREMOVE
+	depends on SPARSEMEM_VMEMMAP
+	depends on ARCH_HAS_ZONE_DEVICE
+	select XARRAY_MULTI
+
 config ARCH_HAS_HMM
 	bool
 	default y
-- 
2.20.1


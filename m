Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B190C5B578
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 21:58:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EE23A20652
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 21:58:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=wdc.com header.i=@wdc.com header.b="HiaK+qya"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EE23A20652
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=wdc.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A173E8E0007; Mon,  1 Jul 2019 17:58:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9C85D8E0002; Mon,  1 Jul 2019 17:58:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B7858E0007; Mon,  1 Jul 2019 17:58:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f206.google.com (mail-pl1-f206.google.com [209.85.214.206])
	by kanga.kvack.org (Postfix) with ESMTP id 553D38E0002
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 17:58:12 -0400 (EDT)
Received: by mail-pl1-f206.google.com with SMTP id bb9so7899142plb.2
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 14:58:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:ironport-sdr:ironport-sdr:from:to
         :cc:subject:date:message-id:in-reply-to:references;
        bh=yhezopFiPHG0c2M8IFRRD4+hJzOPOYJ+sB8spnfElWM=;
        b=XsYBVwnw4RM4czMMlBgh4wU/A+pkL5tuOKXnaqge+45Zp87fE2TWBcZnZmxn969x15
         LcDoociQWn777db20YDIulOI/YL2W7Xk3mbDv2rUQjB4fo/B252MXQRRPk/6H+5jjxqs
         jre1RaVMlNVuxVIInRDtfgpkibGKdonUcHmsAHBu2mR8ezlPfEKB2ZdjT/iuk2wze1x5
         m2gOPk7Nu9whqxYy7wdDNdOLnB0ECnkqL6p4FtPnjj8Pkif0zehTof3sXAD36jIXOO1y
         u0srrq/yfBIDzOqw/mR0iXNZDkC7SouzNJyrHA5vY9pqCpfc7+zfaTP3YfISm80viM9D
         tf6A==
X-Gm-Message-State: APjAAAVfYMeP43SGFpVTBXU48gxiQJFeBGLYD2vVxQepz3/l6KZ5DtFD
	+B0rqtNdiYhogClc+p4tXBNsYM/+LdNtHI5+oL9IDJe226j+ARJ8UvGeJpTsdbUHOtRJpUcjRsw
	kQijeLZr5uwApm54ZBMM8oKYMpBdK2UShM0VsYFgVVPP1XrCcw+4ommsgNiv4zDdBrQ==
X-Received: by 2002:a17:902:ea:: with SMTP id a97mr31154025pla.182.1562018292018;
        Mon, 01 Jul 2019 14:58:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwY3U+sW1zE+6KCQMEUI+brsOgh+vj5B/75KxGDh7Y0udBHzpWv0L5R4PGU/OZQoxs+3fNB
X-Received: by 2002:a17:902:ea:: with SMTP id a97mr31153986pla.182.1562018291277;
        Mon, 01 Jul 2019 14:58:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562018291; cv=none;
        d=google.com; s=arc-20160816;
        b=Vc3qn2rC8Ib5tXBRtAo4ecabULoWB3mWmnx8+h3lZmw8lFORXUy39LLnFlDrsVLGVl
         tFbgdWaG9tP80zaX8JMeBq6dM/FSUSZxqLg8mZ2uHIK+haWjEzU0tkJ58Ht6VzyIYdjP
         omMbSroXCCCqIkl3/jYf92hCWcodOCbQ2Wq+cZ24mejecV5pXyda88ly/1Iy9QSe+oD5
         MC5clswKS58eHlNFYeoDJs5zY1LUgNrEnB/j6k3Cj7FFvXzTAR7jXavAVFgqb/S+aTpA
         wWGHunusvBlvPm89Jzyjq9FJ0DrJDtC5yOCeVbbvu93wYDQPHrjxYEOjoWsEerawtIdh
         QPEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :ironport-sdr:ironport-sdr:dkim-signature;
        bh=yhezopFiPHG0c2M8IFRRD4+hJzOPOYJ+sB8spnfElWM=;
        b=aJs0vyCmQzfp2uKrP0XiyPkHe7YLDE50kPjc0lpAceZA/qucl86rSFNLJbGidwnKvJ
         HRRSDVbze2/KfbLW1+0ftYHAD9UIuuCSmlYHqAq/XF+NwN8Gkz3KDfwYYRFotAQo/+CU
         Iz0wfAZF7IszvvWn90re348ntWA9lOZ1xRwJ6Uz0D09suCLlJeEKU29AUuuxvCdOCbpO
         eO6d+CNo8D+kJGm9gmAx7SksJg7gzepTWIj/WNTZn273AyZtvKBetzIO3NLLIzdIcWU4
         iuiLehiKzSMx82XyZfUYf5DMXVX3N6sBxg8n3/zX6qJRhoNzAByIRdjzCIILLxwXKZu1
         1/iw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@wdc.com header.s=dkim.wdc.com header.b=HiaK+qya;
       spf=pass (google.com: domain of prvs=0789f8ff9=chaitanya.kulkarni@wdc.com designates 216.71.153.141 as permitted sender) smtp.mailfrom="prvs=0789f8ff9=chaitanya.kulkarni@wdc.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=wdc.com
Received: from esa3.hgst.iphmx.com (esa3.hgst.iphmx.com. [216.71.153.141])
        by mx.google.com with ESMTPS id a36si598675pje.14.2019.07.01.14.58.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 14:58:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=0789f8ff9=chaitanya.kulkarni@wdc.com designates 216.71.153.141 as permitted sender) client-ip=216.71.153.141;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@wdc.com header.s=dkim.wdc.com header.b=HiaK+qya;
       spf=pass (google.com: domain of prvs=0789f8ff9=chaitanya.kulkarni@wdc.com designates 216.71.153.141 as permitted sender) smtp.mailfrom="prvs=0789f8ff9=chaitanya.kulkarni@wdc.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=wdc.com
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple;
  d=wdc.com; i=@wdc.com; q=dns/txt; s=dkim.wdc.com;
  t=1562018292; x=1593554292;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references;
  bh=b0wGW7WtfWxUwKfj2wVFwZxNHKIT6iMJAeEE2CY/GA4=;
  b=HiaK+qyawfwTkLlcPMFVDdCO+lbjrQkpvs+W88RVRTrk7UkD5jqF+XMl
   FUuaIi6FU7s45v/ReDlqXJQ+xuXtDeEFqwLY7P/JmH9fxex7PHOYNqpPG
   dv/NwWi80UAnlCc6tzXFKkafNxNJJJ7sYLf1RCS8hsS59/iOg5hUMSJhm
   Y73uBoiyDaVNCjoYPuNlfSteuZa4lhbZNeApRlcDxTOmW9Vrx7j6SkUBi
   J0jEH4NLFUxNmCltShAlRsLmli92W2W468Z2Ew0ERITyl+BJf+FG+Ri0W
   KsIKxesHFngPEYCxCoVW6ybKfVx9brWgJJ4GWoYwv7qTls1SfzygSkcjI
   w==;
X-IronPort-AV: E=Sophos;i="5.63,440,1557158400"; 
   d="scan'208";a="116844043"
Received: from h199-255-45-15.hgst.com (HELO uls-op-cesaep02.wdc.com) ([199.255.45.15])
  by ob1.hgst.iphmx.com with ESMTP; 02 Jul 2019 05:58:11 +0800
IronPort-SDR: sTyeICXNyASzqaVJh/x7bFc71ryJtwPmzGpR6ru3C844qtZvkTh15I2z1yZJOKlx5WvGRIF2ia
 4Ekb7RBw2k4iNBRuDl0TSB0d+caVgWvxr82XzfshorCuGE7XkrsrM5L+hJWR5yFB3MBu1Xz+N9
 3eE4B1pE9bII76EphGGieLowwe3oRpyrEICrFP8WtmqBrxTFlN7NVvjR8YQPW7pOlP8qP5/s2V
 2q46hZvehEGbFftDa+L4wAoUrQUInkLu1aF8zt6GMWek2bvXMDDv7zxu7pQv1cd1hixhB/L0kt
 4i4yK8PAlDYMykR4+tJROiba
Received: from uls-op-cesaip02.wdc.com ([10.248.3.37])
  by uls-op-cesaep02.wdc.com with ESMTP; 01 Jul 2019 14:57:13 -0700
IronPort-SDR: AABjtBQ8ZjxtlIypq0AuDMGuICj3Ru7OQR6RTokwwI5NwnheQDs9XZu6EHSysDkGvnSbjLSLzk
 svQHsZ3L9KuVfcFTjFKgPOsuSl7tPlG11lsjBb8z5kXGyUSeWfzv8y2JNrHN9XFqAP9GIoh801
 6/k7//Wxd+PiVP+eMja3fbegfEx0pWIXUEx/YSComqBkOzV5tvEeCB40Ty18Wl8YUlGpamcA0W
 YnMn0/OE8nFdC37M/MT1FRhMxXORwaN4jwQ92KCK2O3IsgCDvM1qCknYbY7bB2yB2W4O2NYyqp
 t5U=
Received: from cvenusqemu.hgst.com ([10.202.66.73])
  by uls-op-cesaip02.wdc.com with ESMTP; 01 Jul 2019 14:58:10 -0700
From: Chaitanya Kulkarni <chaitanya.kulkarni@wdc.com>
To: linux-mm@kvack.org,
	linux-block@vger.kernel.org
Cc: bvanassche@acm.org,
	axboe@kernel.dk,
	Chaitanya Kulkarni <chaitanya.kulkarni@wdc.com>
Subject: [PATCH 5/5] Documentation/laptop: add block_dump documentation
Date: Mon,  1 Jul 2019 14:57:26 -0700
Message-Id: <20190701215726.27601-6-chaitanya.kulkarni@wdc.com>
X-Mailer: git-send-email 2.17.0
In-Reply-To: <20190701215726.27601-1-chaitanya.kulkarni@wdc.com>
References: <20190701215726.27601-1-chaitanya.kulkarni@wdc.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch updates the block_dump documentation with respect to the
changes from the earlier patch for submit_bio(). Also we adjust rest of
the lines to fit with standaed format.

Signed-off-by: Chaitanya Kulkarni <chaitanya.kulkarni@wdc.com>
---
 Documentation/laptops/laptop-mode.txt | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/Documentation/laptops/laptop-mode.txt b/Documentation/laptops/laptop-mode.txt
index 1c707fc9b141..d4d72ed677c4 100644
--- a/Documentation/laptops/laptop-mode.txt
+++ b/Documentation/laptops/laptop-mode.txt
@@ -101,14 +101,14 @@ a cache miss. The disk can then be spun down in the periods of inactivity.
 
 If you want to find out which process caused the disk to spin up, you can
 gather information by setting the flag /proc/sys/vm/block_dump. When this flag
-is set, Linux reports all disk read and write operations that take place, and
-all block dirtyings done to files. This makes it possible to debug why a disk
-needs to spin up, and to increase battery life even more. The output of
-block_dump is written to the kernel output, and it can be retrieved using
-"dmesg". When you use block_dump and your kernel logging level also includes
-kernel debugging messages, you probably want to turn off klogd, otherwise
-the output of block_dump will be logged, causing disk activity that is not
-normally there.
+is set, Linux reports all disk I/O operations along with read and write
+operations that take place, and all block dirtyings done to files. This makes
+it possible to debug why a disk needs to spin up, and to increase battery life
+even more. The output of block_dump is written to the kernel output, and it can
+be retrieved using "dmesg". When you use block_dump and your kernel logging
+level also includes kernel debugging messages, you probably want to turn off
+klogd, otherwise the output of block_dump will be logged, causing disk activity
+that is not normally there.
 
 
 Configuration
-- 
2.21.0


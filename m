Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 774D8C5B578
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 21:58:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C3F320652
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 21:58:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=wdc.com header.i=@wdc.com header.b="ZZIFA9HV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C3F320652
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=wdc.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D4BF18E0006; Mon,  1 Jul 2019 17:58:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CFBF88E0002; Mon,  1 Jul 2019 17:58:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B9DD58E0006; Mon,  1 Jul 2019 17:58:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f205.google.com (mail-pl1-f205.google.com [209.85.214.205])
	by kanga.kvack.org (Postfix) with ESMTP id 82E728E0002
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 17:58:05 -0400 (EDT)
Received: by mail-pl1-f205.google.com with SMTP id 59so7879648plb.14
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 14:58:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:ironport-sdr:ironport-sdr:from:to
         :cc:subject:date:message-id:in-reply-to:references;
        bh=Rz22BLRkwdteKQIL4HVAbq/33QcMnCT9Tx0pA4ANBrI=;
        b=Np02RTCLz2YepTAo79p+6W6lwkDb7Z8uXIqu47YCjBL43A9vXIZSG7/YXBNBwW/jAM
         QM0T4HMZZGDhumUhPnVxepI8NrEJglP4QhEusC7O8lfYmIkfENqDQcfqobcMeT6AakGh
         e0ZCAJqWaO5EtayfPIqNcXUpC9z8dEYDL74vKGTMabLKB4vBL4AE/2/9DEopIrP9TlmR
         eHmAZkDIOHSVOwwccIZomLzi8EMwYnioAhwCVPMoCHbJiz3LHs3dOuejphJzdiIfGRh3
         qtxvHr19U/om+zGLLmbDENCtNpeomxawYGIceDdFR/2lPpPETqPG2m+MjFM7L8HRmGls
         nf7A==
X-Gm-Message-State: APjAAAXT41HR7Bd9cjHlf1QqWr6PhAaLQiBOfiebMbBarASm/mX7FyWR
	/hueh3jknOSUs3BwPm4veMG5rLWA+I252M+lzSK34Pyd8SePxqiMMBPJj3o3aWTyvsDNaXZNTas
	ILYfWXrgMzrTaJyt0bc90RGwgxvmsZ4GJJah0/hg8hfuoJFH4O+9Jt3i4QOXRqaLc8w==
X-Received: by 2002:a17:90a:2525:: with SMTP id j34mr1654170pje.11.1562018285223;
        Mon, 01 Jul 2019 14:58:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwqum+Gbt12hxHcva0fVt5dsQ6pppzAkwOt4H8WM777VVqoy8YE/TiWzALlf5CAHmLOwDcu
X-Received: by 2002:a17:90a:2525:: with SMTP id j34mr1654130pje.11.1562018284595;
        Mon, 01 Jul 2019 14:58:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562018284; cv=none;
        d=google.com; s=arc-20160816;
        b=jlK3vX2J36hOa1E4kijG9dmR5KEhBgom4SWZV0b7q42sZcmCgucuSIIhAyQWA7QHa9
         GcmVKzBrEBRU8xQ+SKfRvI93xAQmha1f6UcZjWqrLOkPEiDWFFr3360eQtbEPGds5tM7
         pk3G5kUh4TF3L3bXn+VSd2dhGp7Vw/FbNu1tjsUR4z4B+x0X/OFY7I09MNdYrdV805h3
         vUcwEe8II7TU1m0A3PeM8FsDFPLXxE4AjjMPLPoQ5tCJ74ftgsVd3QbMrbRL1hs/3ke+
         YZJHu3B0nP5iCIkHQd5WYV6LPtbR79et2GkpidmVX5khlG/YiFYEZAAnswPufYlBdqzQ
         j4Zg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :ironport-sdr:ironport-sdr:dkim-signature;
        bh=Rz22BLRkwdteKQIL4HVAbq/33QcMnCT9Tx0pA4ANBrI=;
        b=MD7hSnfHwwltYlCCei+Sk5AdJQWkaBecSLhEtCIYWlvFf+/t6LoBUOuKq7hMsGdDAg
         Um41qwhwU5yzu8pXlTV3awECVj+cBmBIj9ioB6qVkBfkWIzOjn+Y245zNe1EFkcvo6e2
         wJWmMG74/a5KM58SKtf7lZnqBNA4/cBBk9rQBj2XVpE/liNSji6pjhhxe+6VK++qh/aN
         8joRJwWcAr1zuN4Vi8heAHPulJVkaWzig2x7jwN8ORJbUP2gXRGwQotgRafBYVEQ8xOf
         uJ8Qyd/a768X82OpeL1Jxrj5z0PMytnRWQEDIBeOQJsyDkyQYesZx/JTLePnHxaYDkog
         +EUQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@wdc.com header.s=dkim.wdc.com header.b=ZZIFA9HV;
       spf=pass (google.com: domain of prvs=0789f8ff9=chaitanya.kulkarni@wdc.com designates 216.71.153.144 as permitted sender) smtp.mailfrom="prvs=0789f8ff9=chaitanya.kulkarni@wdc.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=wdc.com
Received: from esa5.hgst.iphmx.com (esa5.hgst.iphmx.com. [216.71.153.144])
        by mx.google.com with ESMTPS id q39si596559pjc.55.2019.07.01.14.58.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 14:58:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=0789f8ff9=chaitanya.kulkarni@wdc.com designates 216.71.153.144 as permitted sender) client-ip=216.71.153.144;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@wdc.com header.s=dkim.wdc.com header.b=ZZIFA9HV;
       spf=pass (google.com: domain of prvs=0789f8ff9=chaitanya.kulkarni@wdc.com designates 216.71.153.144 as permitted sender) smtp.mailfrom="prvs=0789f8ff9=chaitanya.kulkarni@wdc.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=wdc.com
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple;
  d=wdc.com; i=@wdc.com; q=dns/txt; s=dkim.wdc.com;
  t=1562018284; x=1593554284;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references;
  bh=SM4vBhjIMuIjQIIkPMmNSjGDUMbO4rTKMZzMc8UskaU=;
  b=ZZIFA9HVeSYt9Y8HlXxKic9FrxKeWNYAzpDjhnh8guDtK9L7jXKwK6Wm
   w105ZKNaZzep5NMpbluGb1G7bojNk5D90MDLORDtaqMxz16dShWHpfPON
   THSSTYs7mCdkLDF9LxOpdZ5tWTpzwaP6fBLVAvRUjeKlYfh8FMhDmSXEE
   8Sz084LfWBifFBxlMbxMBv0Ox0PquI8W/UbS8Xalo+TYS2RBCRY+polIS
   t68MZQDLxytiaRyPN9TPjSYGcNVX0Cfzt6diGVhrp8NR2Jh8Bq8KeUzzg
   dUzY7QPNKoq7mvHYHrsn3koDjEwSu5eoF4qzAkFAuJKICs9uFek1/Yx7b
   Q==;
X-IronPort-AV: E=Sophos;i="5.63,440,1557158400"; 
   d="scan'208";a="113190459"
Received: from h199-255-45-15.hgst.com (HELO uls-op-cesaep02.wdc.com) ([199.255.45.15])
  by ob1.hgst.iphmx.com with ESMTP; 02 Jul 2019 05:58:04 +0800
IronPort-SDR: Pe/XRq8dFo9R6f/s3JFaCg3zrjbfWhREBV6UkkVkJIhqpxpMiIQOUexbyjMbj1u7HPSi8AB4SQ
 D6TWFgq1urJHsH1CJ6zQzU4zODA/uAO+JZ5bm45f6xOitB6RV5MfkQI+qfDSafdozLThxVnpWD
 rJbhy4bJs1zVbNxUdmOMdYmWzfOtm5VBW80jPKKgqMtg52XBPuTip+82c+g3T+t6caT9OdPEst
 nMSpftaHYAQX3NTYF9y0hoNw1jULxMCg8IrgxOZvnRIPaBjL3s/W8g0Grl7YQ9MjVf7fgqCpEG
 tc4oxyMGwiBr0H97PCECmpYY
Received: from uls-op-cesaip02.wdc.com ([10.248.3.37])
  by uls-op-cesaep02.wdc.com with ESMTP; 01 Jul 2019 14:57:07 -0700
IronPort-SDR: e+BRmQAwH57/flmFvsQ6Pi8GWmwJl0oZ71gtjgNdmCq2EN3CldpqQ1InjNWVtGq0B1oBeOBsd+
 kFszZuOSH18RLPIwDQuKI4Xt94EU0l8vAv40wQPezVoRtOtGcS3DhfqFKo3eZoEEF7cqOlXdaL
 bv1kLKT8vZz+a1WGE8clxQDtDrXl/ApwMerjBGhUmCmmTEmTFNhoRp6K1sboM6C2xXyBHPjxmY
 h9eYIBUbtUcMBrxqcroJweQRK4ZibJt9YOvzlfmlJ5tyPVhAc+V2PrYsnrLymBfxnDADKmxVAS
 QQI=
Received: from cvenusqemu.hgst.com ([10.202.66.73])
  by uls-op-cesaip02.wdc.com with ESMTP; 01 Jul 2019 14:58:04 -0700
From: Chaitanya Kulkarni <chaitanya.kulkarni@wdc.com>
To: linux-mm@kvack.org,
	linux-block@vger.kernel.org
Cc: bvanassche@acm.org,
	axboe@kernel.dk,
	Chaitanya Kulkarni <chaitanya.kulkarni@wdc.com>
Subject: [PATCH 4/5] mm: update block_dump comment
Date: Mon,  1 Jul 2019 14:57:25 -0700
Message-Id: <20190701215726.27601-5-chaitanya.kulkarni@wdc.com>
X-Mailer: git-send-email 2.17.0
In-Reply-To: <20190701215726.27601-1-chaitanya.kulkarni@wdc.com>
References: <20190701215726.27601-1-chaitanya.kulkarni@wdc.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

With respect to the changes in the submit_bio() in the earlier patch
now we report all the REQ_OP_XXX associated with bio along with
REQ_OP_READ and REQ_OP_WRITE (READ/WRITE). Update the following
comment for block_dump variable to reflect the change.

Signed-off-by: Chaitanya Kulkarni <chaitanya.kulkarni@wdc.com>
---
 mm/page-writeback.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index bdbe8b6b1225..ef299f95349f 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -109,7 +109,7 @@ EXPORT_SYMBOL_GPL(dirty_writeback_interval);
 unsigned int dirty_expire_interval = 30 * 100; /* centiseconds */
 
 /*
- * Flag that makes the machine dump writes/reads and block dirtyings.
+ * Flag that makes the machine dump block layer requests and block dirtyings.
  */
 int block_dump;
 
-- 
2.21.0


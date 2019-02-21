Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD52AC4360F
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 04:01:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D1D92086C
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 04:01:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="XeML6GAJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D1D92086C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BA3EC8E005B; Wed, 20 Feb 2019 23:01:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B518F8E0002; Wed, 20 Feb 2019 23:01:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A187F8E005B; Wed, 20 Feb 2019 23:01:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5B8838E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 23:01:54 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id t26so18426372pgu.18
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 20:01:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=fmc0FktNOAYy91ZtfGNCQgBWKC58zFVetvBTsAojWus=;
        b=QpriHXfvB4gE+LEBTRFZklzjryRnWMm8uMd48iuvd9bf7uweh1eo6Is9zRyo0Ws613
         U61xdTGpG4EJv8l+6Wx87aSHgFR40M5e+pnkf4piWWfUzgAFDYavg3NfkIfZ4aaow861
         rqNbHi+kAYMZU15l+URYQswL6DOUwRjQP7ERNiOfTJvo3Up9wtKkCgV54gsguExdkKN4
         YT+LdGYA0hAkUKK3hsVsonFhlluwNCjq/I4Brk/5FCqlcZsKdbtzAcTxkkw/ec/au9f+
         95uPuceocUh0/iJGtc4jns32BesJScMBVTt3/FLUg24b0dD+d6sTl/gSYwMio4kcjw7U
         527w==
X-Gm-Message-State: AHQUAuZ08F66iImm+9wHupw37skt+ZlvvR8G4tsypdBG2AGIscYo5WGW
	AiGVUnxTCdscOlscqs8MyhfJu2pyiiKwZQOu7jo2SKYIPr86A+4S/Tn5zu++5hq7lP+WDqqvfgO
	w8LogYSgGuKZORlYbZPU3Sz7ztD5gh/cQt7+3o44wZvmg/W/ZNEgw9b8sGrAEttrNJJpOKBteS+
	CXYirE04WKEB4wc2Lh+kYBzWsXEam0qfrJklQ46eqh7lUmmTEcBivvr6/DRZp7oB7wd7c0aFPhW
	k97UHlQLJXqGz+/TzuVnk2H4utUyqIe4hKTp5qPfQ/zqLQqISbNICvqDvdvKHL4rTssf4YqKUNv
	vEyze7iiWvfhsRBfPfLta/jHacx6arlOTUkcpjHvC1lUgRH7ceBi+dTURBN58/fmTIF+VnHwF9J
	n
X-Received: by 2002:a17:902:129:: with SMTP id 38mr40498617plb.140.1550721713892;
        Wed, 20 Feb 2019 20:01:53 -0800 (PST)
X-Received: by 2002:a17:902:129:: with SMTP id 38mr40498425plb.140.1550721711644;
        Wed, 20 Feb 2019 20:01:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550721711; cv=none;
        d=google.com; s=arc-20160816;
        b=bUHyLMEZz8qhAZYSlUCWjlPrpdV2Mb51JFR5gl81fVAmD/UAvv+nl24jiUK92BUzfa
         NJf+7/CydAoBiWTrSvnW8RiJNIPiTIU/SDB7NI1KMJeIclGUgrjNCeifBlIY0+DIyCBC
         nKZNgb0axc7oDNmJElNZRx/g26NcmvRxHC070DFpB5oRQfjQp4druq4Wge582e5/oyTN
         C63hR655zM9H/83sndfwFIaCWQfb8fuSESMb05zOuQBwwywIiyns28ONKip3fOt3ZGEk
         eL4DSSuFUh/udlO/sKcfUE4zp5aZyIzXt02j2Bqvqb5z4i1mCxBtYMjORI4OVu4rd4Td
         MrPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=fmc0FktNOAYy91ZtfGNCQgBWKC58zFVetvBTsAojWus=;
        b=m0Mf9ow9fn5SIy4AxXuKdYENCMJ1b8tkSL/wi8ntlChwvernAin7Em2WqXb6vdPkNi
         bagHAbWM1hy/MC8wkmUp6w40ZrMDch4bsUH6fwcw5NaCNYP/s270PaYY5Vwp2J1QGUcc
         MdoKS2sEQwPPM4BmTl9UvqIesatX3ni70yaKxjNPx4YHdxQ8FSnjr6oCwlm4mtklfOdA
         JKf0IJfX3A1aLL83kK66HYnfXQd3iTnaYV1TPu/sAj2VXsvuRhWAZQHmRwMRSiM0JJVf
         SYvUyzLTFHYd+x22tIkK6y0il+5Rs4F2k+7I5+2y1fcTaUp1Tlj3jNdfNll3IAHcCrXD
         AHkg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=XeML6GAJ;
       spf=pass (google.com: domain of zbestahu@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=zbestahu@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r75sor30361243pgr.31.2019.02.20.20.01.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Feb 2019 20:01:51 -0800 (PST)
Received-SPF: pass (google.com: domain of zbestahu@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=XeML6GAJ;
       spf=pass (google.com: domain of zbestahu@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=zbestahu@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=fmc0FktNOAYy91ZtfGNCQgBWKC58zFVetvBTsAojWus=;
        b=XeML6GAJzog9qr8l+qyE21xzSXTnC3ABj0HGTs0BvRp2jNaC+L2wshdZFJfvRSfvdZ
         2tzJt1jYa/bqPbm/FW5eCKxH9xpkGxpEgTrkEBzHLlFNakDKDL6lTImYamzUP3npmxXB
         ItzzpsQ4j4AznRF5je0jiNGgOMEOyez/PMBWN6BhKTBh9HMzhs9IUD4tk8ZIc7oXuA0v
         0umyqRiByQNb4GuJ90SmpzztsGCJYYBteeynuoyRuFH8qIbfsiiGH/0aoosqUntC+fxN
         /nsTBcAIJz6ZnMHgi3L4/1ffCT/ZNC1hDGJla0p+zNQfHxbt4RbLy74pTU/jVDYapOK2
         MSpg==
X-Google-Smtp-Source: AHgI3Iag5XZ3eeaB6/H/+Pi3iZDnLFwCUQRneiOqChDNIzBsDsTWSkGivzLDNQ9Q3dpB3AQaZi4Yug==
X-Received: by 2002:a63:8b4b:: with SMTP id j72mr32477993pge.100.1550721711275;
        Wed, 20 Feb 2019 20:01:51 -0800 (PST)
Received: from huyue2.ccdomain.com ([218.189.10.173])
        by smtp.gmail.com with ESMTPSA id e9sm48836730pfb.52.2019.02.20.20.01.48
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 20:01:50 -0800 (PST)
From: Yue Hu <zbestahu@gmail.com>
To: akpm@linux-foundation.org,
	mhocko@suse.com,
	rientjes@google.com,
	joe@perches.com
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	huyue2@yulong.com
Subject: [PATCH] mm/cma_debug: Avoid to use global cma_debugfs_root
Date: Thu, 21 Feb 2019 12:01:29 +0800
Message-Id: <20190221040130.8940-1-zbestahu@gmail.com>
X-Mailer: git-send-email 2.17.1.windows.2
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Yue Hu <huyue2@yulong.com>

Currently cma_debugfs_root is at global space. That is unnecessary
since it will be only used by next cma_debugfs_add_one(). We can
just pass it to following calling, it will save global space. Also
remove useless idx parameter.

Signed-off-by: Yue Hu <huyue2@yulong.com>
---
 mm/cma_debug.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/mm/cma_debug.c b/mm/cma_debug.c
index f234672..2c2c869 100644
--- a/mm/cma_debug.c
+++ b/mm/cma_debug.c
@@ -21,8 +21,6 @@ struct cma_mem {
 	unsigned long n;
 };
 
-static struct dentry *cma_debugfs_root;
-
 static int cma_debugfs_get(void *data, u64 *val)
 {
 	unsigned long *p = data;
@@ -162,7 +160,7 @@ static int cma_alloc_write(void *data, u64 val)
 }
 DEFINE_SIMPLE_ATTRIBUTE(cma_alloc_fops, NULL, cma_alloc_write, "%llu\n");
 
-static void cma_debugfs_add_one(struct cma *cma, int idx)
+static void cma_debugfs_add_one(struct cma *cma, struct dentry *root_dentry)
 {
 	struct dentry *tmp;
 	char name[16];
@@ -170,7 +168,7 @@ static void cma_debugfs_add_one(struct cma *cma, int idx)
 
 	scnprintf(name, sizeof(name), "cma-%s", cma->name);
 
-	tmp = debugfs_create_dir(name, cma_debugfs_root);
+	tmp = debugfs_create_dir(name, root_dentry);
 
 	debugfs_create_file("alloc", 0200, tmp, cma, &cma_alloc_fops);
 	debugfs_create_file("free", 0200, tmp, cma, &cma_free_fops);
@@ -188,6 +186,7 @@ static void cma_debugfs_add_one(struct cma *cma, int idx)
 
 static int __init cma_debugfs_init(void)
 {
+	struct dentry *cma_debugfs_root;
 	int i;
 
 	cma_debugfs_root = debugfs_create_dir("cma", NULL);
@@ -195,7 +194,7 @@ static int __init cma_debugfs_init(void)
 		return -ENOMEM;
 
 	for (i = 0; i < cma_area_count; i++)
-		cma_debugfs_add_one(&cma_areas[i], i);
+		cma_debugfs_add_one(&cma_areas[i], cma_debugfs_root);
 
 	return 0;
 }
-- 
1.9.1


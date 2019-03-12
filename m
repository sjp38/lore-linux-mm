Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E417C10F00
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 13:29:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 50D6D2171F
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 13:29:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=bgdev-pl.20150623.gappssmtp.com header.i=@bgdev-pl.20150623.gappssmtp.com header.b="GxwhhnRw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 50D6D2171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bgdev.pl
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E9FBC8E0004; Tue, 12 Mar 2019 09:29:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E4D2F8E0002; Tue, 12 Mar 2019 09:29:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D3D998E0004; Tue, 12 Mar 2019 09:29:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7C91F8E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 09:29:12 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id x9so443300wmj.9
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 06:29:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=sXUXVXlvAdVAFUbmGrPp3Y++cwC7YAn6ufejqo4y85E=;
        b=WQlq1N0G+QeBr54TfhsZVo/oVkOnn8jazzMS5+nMNoS1Osb+67sNDu9dXwFoTGiEcJ
         XsIyzw4yfZ6xwPAnaoCO013N4KXFute/j1E3QdVI7bgJEUi/1Ir7ZgSqhFMb7448u0sn
         UGEPrIsNLfCp9NlZ4jRNgcybBT/Ql/CXHD8HhbpwjLO+UGh8bjJIZNfN+EumNuDwe7XS
         AO0KqAm5LSAC+kks4AsO1pexAIN/wpuyeBb7qjIZTy5uQOIDlizjRuRzkXx530lsP3Za
         EMIXQIFPpZNvLRwdmNVEXvXWFLa1mz/7Kgv10cH11A+3xapyOnfktzBLAeFb7th89pgc
         yqRg==
X-Gm-Message-State: APjAAAXDIclwFrl+bO/DOuduoQR86sUr8a364SRkZ3fvw7VSuzZqbCmh
	0kcKcunTwFsxwOXX0xpQvILmFvRqrwnxfETZEoVh8bPBG/MrN4rKYtuUklMajj8HmP2DWxkyA0K
	6zs+0QaSprdhpDsgqQNZmzkTRMwjJi37ivhHzvHc8KK5lNCY3SfoW4AWBMDrsQOzCuQ==
X-Received: by 2002:a7b:c056:: with SMTP id u22mr2382487wmc.5.1552397351632;
        Tue, 12 Mar 2019 06:29:11 -0700 (PDT)
X-Received: by 2002:a7b:c056:: with SMTP id u22mr2382404wmc.5.1552397350135;
        Tue, 12 Mar 2019 06:29:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552397350; cv=none;
        d=google.com; s=arc-20160816;
        b=bF85rGYM6vCDdl8W3PQXdauGLLhhEn2nF4fQ0Hs/5xF92mprGLaV2wqBc/E3kNt+D6
         +DVb6z8gAqxBvN+VSL6bbCze9VyI6qclB7884TKaaM9OEzvQ2zSkXv3eWHxpW1scBKyw
         RwCv04D2P8qUaMWqULexMWDy7QJCjfpNPwMujb1jYajkjAaVf2pgCaaBiXEfMp2jcx8c
         6L5/62d59U2FjIi1OjSaJUNstZfWQt12VeUtCz46lc8lKlzEaOoQ8vsUtGl6wXu7l40R
         bmLl4QrrLb/1APmE0zuvgPlkvfx3QhPumdk5fvWZNciLu7924Nwk0h1GN9b7UP++M1GP
         Bg/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=sXUXVXlvAdVAFUbmGrPp3Y++cwC7YAn6ufejqo4y85E=;
        b=d1X7/RB3AUxEKUf1uSLXJt2GKihoMMKc2FPJZGmUnAWk++D/IKaUlaAxNyvlC3quyw
         E7YiRvszE0UEvx756QuQbQ+slz/SlciWrOSBmeBKWZOo6NU01RZDSqVvnbjVri15Hyny
         j/dFSBZ61s2NXGDWSNAy0XS4aFG0negAYYVh0clrilptXx3XVsOzF898he97kQjkDF6R
         xDezOlAwkvSarcrBi4kEPcul2WhH5xPKSaXEG1NC+UvKqYWpXRmXW9pmpQRwXpSsFwuL
         XLQJGr+VrX/UkNoIv9btEYEQFDk3V/eCG2g5xGA2xsnmpdG3BLA92Vgau1f/T5ccmqqs
         wzWg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@bgdev-pl.20150623.gappssmtp.com header.s=20150623 header.b=GxwhhnRw;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of brgl@bgdev.pl) smtp.mailfrom=brgl@bgdev.pl
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v18sor5946503wrd.4.2019.03.12.06.29.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Mar 2019 06:29:10 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of brgl@bgdev.pl) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@bgdev-pl.20150623.gappssmtp.com header.s=20150623 header.b=GxwhhnRw;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of brgl@bgdev.pl) smtp.mailfrom=brgl@bgdev.pl
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=bgdev-pl.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=sXUXVXlvAdVAFUbmGrPp3Y++cwC7YAn6ufejqo4y85E=;
        b=GxwhhnRwAI0mQHn3+AajPHEAD5qHfVqJPCTFDxTXDwSUADjGv7hxGYdhiKXd2O8MO0
         TRdtTKDgC6x3/Z7AgmZZ854ynfWnJ+6gsJ+3qJmsmWRsf/GJugTYGWiw3RjAil6zBpSz
         bZpwn2umdbdREZOzE0WZsYyh/4TPyBPdk4kDzGFOpUWQ761lw2uDkl1iPuCOed6c4fhj
         xRdMVASza2YeZE07e76lkq+ogwY7yQteiyuIco6P1GFnkMX5yfOFy/P5xnxFpYB2qbrc
         2ftNr64IrwKUk33E9RD9x7cVG+Npzw1AhW1DoUzQJIXXiRWIkc3up6Ze6dU0UCC7C6ch
         lcCw==
X-Google-Smtp-Source: APXvYqyDMMU4JGKeldvw1hUSjmGm8MTelCfenfBNg9tvci4kOGrW1HU8vJ+50w18UmQ6InjasI0jxg==
X-Received: by 2002:a5d:5386:: with SMTP id d6mr22774771wrv.104.1552397349635;
        Tue, 12 Mar 2019 06:29:09 -0700 (PDT)
Received: from localhost.localdomain (aputeaux-684-1-27-140.w90-86.abo.wanadoo.fr. [90.86.252.140])
        by smtp.gmail.com with ESMTPSA id d9sm19953173wrn.72.2019.03.12.06.29.08
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 06:29:08 -0700 (PDT)
From: Bartosz Golaszewski <brgl@bgdev.pl>
To: Andrew Morton <akpm@linux-foundation.org>,
	Anthony Yznaga <anthony.yznaga@oracle.com>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	"Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Bartosz Golaszewski <bgolaszewski@baylibre.com>
Subject: [PATCH] mm: remove unused variable
Date: Tue, 12 Mar 2019 14:28:52 +0100
Message-Id: <20190312132852.20115-1-brgl@bgdev.pl>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Bartosz Golaszewski <bgolaszewski@baylibre.com>

The mm variable is set but unused. Remove it.

Signed-off-by: Bartosz Golaszewski <bgolaszewski@baylibre.com>
---
 mm/mprotect.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/mprotect.c b/mm/mprotect.c
index 028c724dcb1a..130dac3ad04f 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -39,7 +39,6 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 		unsigned long addr, unsigned long end, pgprot_t newprot,
 		int dirty_accountable, int prot_numa)
 {
-	struct mm_struct *mm = vma->vm_mm;
 	pte_t *pte, oldpte;
 	spinlock_t *ptl;
 	unsigned long pages = 0;
-- 
2.20.1


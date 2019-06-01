Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B11DEC28CC1
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:25:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 79935273AC
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:25:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="l6dAie1I"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 79935273AC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 19C3B6B02B6; Sat,  1 Jun 2019 09:25:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 01B9E6B02B8; Sat,  1 Jun 2019 09:25:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E1AFC6B02B9; Sat,  1 Jun 2019 09:25:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9CFA16B02B6
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 09:25:25 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id j26so6577021pgj.6
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 06:25:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ZHCDO/R5cj0kWGPw6LwvMxR7O3lxnlczTQU07mH4LJs=;
        b=Jwg1PG9evFerB9etUJA2aZ3BgkUCx9FoermVWZ5211Xfc73MuR30YAedhS9QLLEQ3D
         9fgCS9gkJnFFg6DERTQ5Stxh1K4A9ydRHpgjr72xxeHeIku45lW5L9HS9gV2eGa1YMaS
         8wQR/ggrpIX/+99w6bSbL6bXe9sOxeVUuKE6bZK6gycLvPQ5L7raXSivXOeFS1ZHS79z
         FbsK02LxeLFRP0zyU/ibUU9vz/FxP7cAndsrmfsEbKbh7OJCH+gAJ+j0DgIFLs1KoOpa
         ZTDTGr0dNpZxYRu4LJNDx80/TcnduxyOmszZqX44yve9HqcfLuwd/GUfmWMg7QTAEBaJ
         CbwQ==
X-Gm-Message-State: APjAAAUEO+wnC0F0hMzxc9eDHkAv0IOM6i/mQPITGecSE/Oex4Oz0d0m
	NJl0LCBcWJtrif7SjjFKCCkHIC8o7TZQOYS0b2jM4xXQ09URpRBmWg+fO/f6qn6aHLl86OOFPIa
	tg7SOV+Gu/VRSen0cnVI35vjAUJdPrn8fcyRWWk14yCCTNinnGJ5PAFlAWHaeCz7HOg==
X-Received: by 2002:a63:31d8:: with SMTP id x207mr14644069pgx.403.1559395525272;
        Sat, 01 Jun 2019 06:25:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxKkE6bS20wcMc4pllNVSSL0ts5rXoIVvDIGjttflgW23XF7gPmm/cf5R4egFsxns5PJUMo
X-Received: by 2002:a63:31d8:: with SMTP id x207mr14644013pgx.403.1559395524702;
        Sat, 01 Jun 2019 06:25:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559395524; cv=none;
        d=google.com; s=arc-20160816;
        b=eLl7JcWzb/Powrq4bxcROv0g1tmicxzcpLvD5QhOAlgsZww7mYkRAJs1dfVC1P2VRi
         qjsRJ0fYV17E9jwZxhmui0ZNwTs3R/kJ0ZMHHstOHOtu77W8SOkEx62MhSWG1ifBvek1
         2H8q7Jgy2cXaQF8/JYkOPExEhlmyCTAJmq8fTA9X0/xbZXMyUKhWqvLMhoYELT0cQuqa
         AsCdtF19/9qihk/b3KUhP74nsdtjH8TaZIc3F90fg1453TM//Au1Tzls3AgAWLr8nzxq
         Wq4EYdvhedpkfoNgUQvIR6e2PD9LK0vnQZb7BJLur4o+XatejhKQlS5KTWnGbG6usNZh
         XxfA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=ZHCDO/R5cj0kWGPw6LwvMxR7O3lxnlczTQU07mH4LJs=;
        b=0/I6Vmy2YOadMK9WNgAdU2kzEsuNeJf7YXdcEICxG88BlRXzVQ8NAqXcgIUDeGmuPH
         pAYRoeG+871e7NUbdmdytYnMmvlm3QPYVNHL2VGvY5Qw307FHcwh4A/NO791gm7yks7L
         CvPCYxQR4XGWIqzvbKz/c9/wLW4CmjIEQ9sX9NEQh4rGre05i3f3DApKj76vJwFGTQat
         4fVcBXOy23DmqEDuotz3U5u3FSxK7c0Kf1Ak2H6v7AHaN4UIk2EVbnGGuGJ++Qi+dJXE
         /hCyqcj6x+v7gCdpqf5BHBWDArxDkSbgonzYO/Wvxt/0nuCwm7DPL7jsTbk9UcmdCcPE
         W4vw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=l6dAie1I;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id cj11si2731226plb.373.2019.06.01.06.25.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 06:25:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=l6dAie1I;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 2DC5427385;
	Sat,  1 Jun 2019 13:25:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559395524;
	bh=VYVk60ZNb1aOiekkl7kRqZCFF3W/BmPDLd0VQkFddJU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=l6dAie1I51GFOjUg5YEXVURvqpsTmN+QmbwdXy2xSyxJxUxEEItSOSRPQo1ZYkX9D
	 FvaYlbC5TkK+kzKbaj5aYtYBqRD7ivzAQhdtzTA8lL6Vq9Nm8g1zZfbd+9RH+i/eKu
	 G9cJTPAStdYAr5Ug1amrMR01ySew1loMGMWbXGhM=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Yue Hu <huyue2@yulong.com>,
	Anshuman Khandual <anshuman.khandual@arm.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Laura Abbott <labbott@redhat.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Randy Dunlap <rdunlap@infradead.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.9 08/74] mm/cma.c: fix crash on CMA allocation if bitmap allocation fails
Date: Sat,  1 Jun 2019 09:23:55 -0400
Message-Id: <20190601132501.27021-8-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190601132501.27021-1-sashal@kernel.org>
References: <20190601132501.27021-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Yue Hu <huyue2@yulong.com>

[ Upstream commit 1df3a339074e31db95c4790ea9236874b13ccd87 ]

f022d8cb7ec7 ("mm: cma: Don't crash on allocation if CMA area can't be
activated") fixes the crash issue when activation fails via setting
cma->count as 0, same logic exists if bitmap allocation fails.

Link: http://lkml.kernel.org/r/20190325081309.6004-1-zbestahu@gmail.com
Signed-off-by: Yue Hu <huyue2@yulong.com>
Reviewed-by: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Laura Abbott <labbott@redhat.com>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Randy Dunlap <rdunlap@infradead.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/cma.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/cma.c b/mm/cma.c
index b5d8847497a3e..4ea0f32761c1a 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -100,8 +100,10 @@ static int __init cma_activate_area(struct cma *cma)
 
 	cma->bitmap = kzalloc(bitmap_size, GFP_KERNEL);
 
-	if (!cma->bitmap)
+	if (!cma->bitmap) {
+		cma->count = 0;
 		return -ENOMEM;
+	}
 
 	WARN_ON_ONCE(!pfn_valid(pfn));
 	zone = page_zone(pfn_to_page(pfn));
-- 
2.20.1


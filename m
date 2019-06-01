Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7504FC28CC1
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:26:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 38EB6273C7
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:26:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="IR8ROffj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 38EB6273C7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D2EE56B02BE; Sat,  1 Jun 2019 09:26:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CDEFE6B02C0; Sat,  1 Jun 2019 09:26:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BA7896B02C1; Sat,  1 Jun 2019 09:26:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7CCF06B02BE
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 09:26:14 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id d2so8222116pla.18
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 06:26:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=nnKUSxJT32k1hKh38qCe9uGL0mNDs94ROiTLsLvdLKc=;
        b=rE3iyxa1ca6Omz5cbl6Jf1zSpPCuGkKDeAtmackSv96hj2lkpwG3nXtJr/WcZiycR7
         fodXUDKlqIuXYxsIsrzO/y030+bLu3etBsz/EyEjrONN3OqeoQHFLYxo2DDhkRL2mUNi
         Sndqqc5h5fGY5n2Ie7XLRIs0e8VpgkyUuMvrb0uHUYh8xHBSZf+qrd1hwSW6n4SQa3ME
         3RZiLQd+iYhOQguPUe8YoefDFJR6NaU9wql3udvzg3s8+tUWinq3J92tKLYriYdCAW0V
         assqj/2bmR7L/GODckjLdDFYA25Yb51OjN6mmJmx4dVwVoUBYk2+URhAapq8wM4Zjsl/
         C4Ww==
X-Gm-Message-State: APjAAAX8VM8pgM5l0TzPn8h9cF9hmDZ6Vk7XmmrtIhPlqYCTOQQBmp9S
	xw/304g27o9PzIL4mVsDctD8GWrHlns4unygkLhzkhiA8sRQG/TpIII5frT8nQeVoUVdy0HQ5ZG
	2P8/6tBeNW1x/nlimDUdHJTIA7Q80aKiYRCvJspDHriwyCJLkj+NwnchI6U6HiTyTOA==
X-Received: by 2002:a17:90a:bd8b:: with SMTP id z11mr16432086pjr.45.1559395574189;
        Sat, 01 Jun 2019 06:26:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyO6/lLiwjfULNhfhrswrru/5fVCCsv0lhuY7HLita8A84bR/dheYovpTrHfvUxQrB7vfk6
X-Received: by 2002:a17:90a:bd8b:: with SMTP id z11mr16432011pjr.45.1559395573576;
        Sat, 01 Jun 2019 06:26:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559395573; cv=none;
        d=google.com; s=arc-20160816;
        b=CdqRObRAthzD2/xgG3hEIYlNQDF1ZqKUmvjWzaMwvAEG+JbBpqxay3XjIm42pZbZO2
         KzO2zNfvmCpc8g1ZkRnksZ89a5qNUCqt+I/K5ufGGg2+zfkWCtdf1d9b2SUWLuH8/PSy
         GlEBhSFg4EyGXlP2QT4ixMHb3Vep0SGyAELF6RKU/Wygs6xwoxM0dJ5Ieqh0iS9FBBZV
         ujo3ctEvmpH8El4T9FDMONCn3DK0IPoNUSS3YcUBwbVmN3fOQJK5Q7gZbttVDaEQtWvx
         E+dWYKYIyeVMAGGGLCZECgSrjkpz/1Z9GF0wfoyPMGqkngpLgEmKK776VswIvnPUEpld
         Vc0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=nnKUSxJT32k1hKh38qCe9uGL0mNDs94ROiTLsLvdLKc=;
        b=qmR+w2igGWG+KNSYmhFqnmJqxnK8r/Kkb5hHlAB+0EbUtNJnJe9DKl4KGUIiPuOrMX
         HdJmXVnU11nCfh7VRenPVENPDrCc+weoJ6YLRWLpQHbvt78HGRAv9A5lkPpDCHQB7FyR
         Ue5S465c/lXXXGq6PckkxwJORq2VqLYTVkacOqj7aPQeOBsVAtKHSu09h07utvI3YJr7
         oD47EvmkO9RsT+Q9NMauel+SXtuo9BKc5G2Kh6WJxDOvNa/yV5WkycwI6dZku4pI490P
         YhuuHRi8uJzGvBQGZIuvpGOeiCcZNWMQhHjoUQMM5e3mWnbfHDQIaIFkI2ProhPAiarH
         qkSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=IR8ROffj;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p13si10190872pgd.347.2019.06.01.06.26.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 06:26:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=IR8ROffj;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 015AD273C1;
	Sat,  1 Jun 2019 13:26:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559395573;
	bh=bw8UDpgDObzmuy67BHmUvWs9daSIpWqkdGgNmdcHcac=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=IR8ROffjBLFFr7zB32B+4s7Soynpc9nOORheIaHrzHfRUioXLlEhVJA1rwiXCbVyc
	 w8Ddh5ll5AAPciGmjsUzyT5efQ77asBJvgYT7ckDg3hy3+xJ4ac00KLwYrm8VqcuCo
	 5Q2wh0g1IvjyglDZhICh/qOI9yvdtJdx6qTmDk1w=
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
Subject: [PATCH AUTOSEL 4.4 05/56] mm/cma.c: fix crash on CMA allocation if bitmap allocation fails
Date: Sat,  1 Jun 2019 09:25:09 -0400
Message-Id: <20190601132600.27427-5-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190601132600.27427-1-sashal@kernel.org>
References: <20190601132600.27427-1-sashal@kernel.org>
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
index f0d91aca5a4cd..5ae4452656cdf 100644
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


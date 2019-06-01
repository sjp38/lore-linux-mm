Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43CA3C28CC6
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:17:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0909524870
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:17:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="bwlNeDEW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0909524870
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6F49E6B0269; Sat,  1 Jun 2019 09:17:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A48E6B026A; Sat,  1 Jun 2019 09:17:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4AB8F6B026B; Sat,  1 Jun 2019 09:17:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 10CB46B0269
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 09:17:42 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id r12so9411780pfl.2
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 06:17:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=t7BiCuQVUm0eGyupyVDolC8vmiFAwNn1hoWAceAZ65M=;
        b=oWUIdjl0IhIQ/pXaKoR7BR2tulh5XfmuKkv6jRIXUrW4GL05LiubX2KC14KtngRTHN
         dd5B2W/n9V/L8zveZAMXMzcOTzgs37LiMcS6rznWgpHc5xeq1AhTm3pWgy7+jMF0w+JI
         fiFIJHi8yIul6GHLQsBlldEMfZ6Umt6wEz/eo8N2L/Cp3wHDZxYrhRj/1yFpZ4FbvgG5
         xI4BzAZZMRW5w0d2QrYLlRljcRWpJtuXJEWA732FdyX2HNW+anVBQntHLKU3UhduuBxO
         KJVJluTsszUHnL1cZRl3zGyUVbaLvA3SqbRWpeWaRAXvy7nPxht8UnF7Iw693kQWLx4I
         vz4A==
X-Gm-Message-State: APjAAAWLqOLtkNodICVNyRAK77DVvMac6uIzBBwFjHsWafUiuem3/FEI
	tDFjgu04VFGEzoGEQtgIZj/DvTPYqfZ918ZqLILREf4mlOiusv+u4wk0nIfjs4Xx3g+FryYw+og
	dbjk+IsLEa5MZnpQ5ocFRiVlNC6A/N1Yno0YlPBo2vQnYFkCpL7wppy9pgZFeGbrgYg==
X-Received: by 2002:a17:90a:d803:: with SMTP id a3mr16218637pjv.48.1559395061742;
        Sat, 01 Jun 2019 06:17:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxw8bM3D+s2hFLhYxFO/aMneNb+LKNeQVI0fF6dZU/swFoxwkW9GvJPpXUqbzMKcRvWG0Ar
X-Received: by 2002:a17:90a:d803:: with SMTP id a3mr16218557pjv.48.1559395061092;
        Sat, 01 Jun 2019 06:17:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559395061; cv=none;
        d=google.com; s=arc-20160816;
        b=0u2Gi4KQ5R/iP90C5+QRvw2paLB16eoPkPUxcaOy3VinK07tKcVCVnhiv5D3dzTRW+
         zeAtdnyQWeZLb54KF+0EUVvdJiFaOAv5QWtxQyGoU+3a29MGJeI1qPAM2MT5OLsj7lrZ
         +PN0r0kDSQDfsqGJt68nxgF0GKBPrFa/TUL90tSgbghckvW9tWmiFUq5VQJYznFoWWpL
         Ea1+1w9FQ/AY5myx0mcZTdXpVtSN4N3ltXACWRSd/q1yT9x/cG/57bffa+NIqDpJNnni
         iu9hXOSl4LnvFyxCiQ+BUKLLDxjBW0X09Wkaxf990OtO2GwJdno6iFEiScVoVxAOABrJ
         ZjOA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=t7BiCuQVUm0eGyupyVDolC8vmiFAwNn1hoWAceAZ65M=;
        b=xOxyqzbXkWrZntn9a5xZssOfCQvXFfxlADSJB+JUDweIxOqILTSh/h9KBeUdwuJQa7
         jtpMORmGgH2p6CVdmGJq6bHwiVAy/M1BTn4+0IiPKgWSsjXws7SFZvJqWs+ereIgFzXa
         UGIDBEK91Y4HPx0Sub5HgZ8k9njAZ4/FvClqefEQCbFg5NucoeheOqVS4pj0hVf7wLI8
         mnkX9H9+4ttldfx3VoxSa9WYGmzUiCGkLJHd+CrGyrv3+IydaKlZplzonXME2qVm00Ch
         A7+AqLyuXDVihmw1dFML1Uf0u/LCvjkmQozs00yDvLfh4aOns/YMP7XAqXN7P9hqawlE
         hXKg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=bwlNeDEW;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id k1si9327689pll.317.2019.06.01.06.17.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 06:17:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=bwlNeDEW;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 9033023AC9;
	Sat,  1 Jun 2019 13:17:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559395060;
	bh=vU6wNY5LtxP5An2zvGCVfUW69gc6W4zPVyDE//3WybY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=bwlNeDEWG6onBXfiZ4NDE+MedcfcMeVhpJ4pP90vpqEqm3RfQFKZOgCZHLMAD94gM
	 d/Aq23qeRcx8hHDEc5kRH5hyw4sVbXRAJHaplVDkfXaPFOYiyxUwqEc3LqKf/guWo5
	 +OOg86b0d4IrMweXY5LGSd/DlI+ADnztOeJ8YXpI=
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
Subject: [PATCH AUTOSEL 5.1 015/186] mm/cma.c: fix crash on CMA allocation if bitmap allocation fails
Date: Sat,  1 Jun 2019 09:13:51 -0400
Message-Id: <20190601131653.24205-15-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190601131653.24205-1-sashal@kernel.org>
References: <20190601131653.24205-1-sashal@kernel.org>
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
index bb2d333ffcb31..8cb95cd1193a9 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -106,8 +106,10 @@ static int __init cma_activate_area(struct cma *cma)
 
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


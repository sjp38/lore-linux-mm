Return-Path: <SRS0=QF98=XN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09D65C4CEC4
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 13:12:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D69CC2067B
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 13:12:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D69CC2067B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=126.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6B6CD6B02AE; Wed, 18 Sep 2019 09:12:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 640D56B02B0; Wed, 18 Sep 2019 09:12:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 52FB46B02B1; Wed, 18 Sep 2019 09:12:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0232.hostedemail.com [216.40.44.232])
	by kanga.kvack.org (Postfix) with ESMTP id 280E56B02AE
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 09:12:41 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id B80F4180AD802
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 13:12:40 +0000 (UTC)
X-FDA: 75948080880.21.cars53_345a6921f875d
X-HE-Tag: cars53_345a6921f875d
X-Filterd-Recvd-Size: 1674
Received: from mail142-12.mail.alibaba.com (mail142-12.mail.alibaba.com [198.11.142.12])
	by imf41.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 13:12:39 +0000 (UTC)
X-Alimail-AntiSpam:AC=CONTINUE;BC=0.2977127|-1;CH=green;DM=CONTINUE|CONTINUE|true|0.151228-0.00972801-0.839044;FP=0|0|0|0|0|-1|-1|-1;HT=e01a16370;MF=liu.xiang@zlingsmart.com;NM=1;PH=DS;RN=3;RT=3;SR=0;TI=SMTPD_---.FX0WcNh_1568812325;
Received: from localhost(mailfrom:liu.xiang@zlingsmart.com fp:SMTPD_---.FX0WcNh_1568812325)
          by smtp.aliyun-inc.com(10.194.98.226);
          Wed, 18 Sep 2019 21:12:05 +0800
From: Liu Xiang <liuxiang_1999@126.com>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	liuxiang_1999@126.com
Subject: [PATCH] mm: vmalloc: remove unnecessary highmem_mask from parameter of gfpflags_allow_blocking()
Date: Wed, 18 Sep 2019 21:11:59 +0800
Message-Id: <1568812319-3467-1-git-send-email-liuxiang_1999@126.com>
X-Mailer: git-send-email 1.9.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

gfpflags_allow_blocking() does not care about __GFP_HIGHMEM,
so highmem_mask can be removed.

Signed-off-by: Liu Xiang <liuxiang_1999@126.com>
---
 mm/vmalloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 7ba11e1..143c636 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -2432,7 +2432,7 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 			goto fail;
 		}
 		area->pages[i] = page;
-		if (gfpflags_allow_blocking(gfp_mask|highmem_mask))
+		if (gfpflags_allow_blocking(gfp_mask))
 			cond_resched();
 	}
 	atomic_long_add(area->nr_pages, &nr_vmalloc_pages);
-- 
1.9.1



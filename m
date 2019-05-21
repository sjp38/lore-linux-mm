Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C4D0C04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 09:41:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D894921479
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 09:41:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D894921479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 505A86B0006; Tue, 21 May 2019 05:41:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 440256B0007; Tue, 21 May 2019 05:41:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2E04D6B0008; Tue, 21 May 2019 05:41:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id E5A936B0006
	for <linux-mm@kvack.org>; Tue, 21 May 2019 05:41:10 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 21so2689339pgl.5
        for <linux-mm@kvack.org>; Tue, 21 May 2019 02:41:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=F9jLr7E6ybNI1fkIgVeHaMd4FGlTJ4UQFZV93ZenQVg=;
        b=LeVMlu1Favc3F6fIp0Qh7CzfUUhcKmVGBbkG5Lqd/UGeCR9AWhtT2+lYeDfN9GDr2A
         fxhjYtq2z2P86UIXTS0Ywr7VE/47orHjbVABSbUQfkQZIVa654+gCOhr5L2PDhUkBVO4
         2CDLfSlz+E5niVAJPJr190oAkTzz58XPZQe9dRxQgUV9I5KRmf+24FMw8SkIB9JGLtMK
         xwQi0HTsw+I+0SXR+mMQmF9JzdSc6bQzwUsMXuhE0QSNGtYZyCmmolrX3IlAxR+iO5uu
         hvDQrul2RnxAI1yGjvP6yhTXbjL0ilgUuLsugldR40tWrBUbgdM9WBpejfPeLeJB3jpx
         PqLg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWaMmrIB9JZyVIA72dEVAYSoHXPlppNsOpr0QS7201g3xYVD1gR
	tnMn4DgoY2zSqBH6uI266UGk3427nF+sHQhAJlHsxW6rQmNeODIrEEudkRD2R2/TwmXEVbkYcml
	CIlj5zcE1+gq3pxrw/sLgv66W8UY8NILHrFdukfQsBEXIvU3aXBGpiTg+fSssJLLZ6w==
X-Received: by 2002:a62:ed1a:: with SMTP id u26mr79825318pfh.229.1558431670510;
        Tue, 21 May 2019 02:41:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyfkJ7GMqpjATYbSKP6Y1dXDhDrCBL7Rq0gtlFaLSHDulsEIV3l4w9Ef4ZhNJ5ye7ThQ+iq
X-Received: by 2002:a62:ed1a:: with SMTP id u26mr79825240pfh.229.1558431669390;
        Tue, 21 May 2019 02:41:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558431669; cv=none;
        d=google.com; s=arc-20160816;
        b=dpZ0Cn57/25ZY9tpV2RelQQ0N1uq4LLpJoCLeEeRYMS2dLinjyckqmGd9W9k7NY0fT
         mn/BJmUVlahPGFLiD1+nU1bBs4XAf09TZ8NIonhaH4t7p6X/7mRB0cefUbIWjM18Ymru
         0DHaRguo6GWN4JGyzxVA0r5LlnyJFuVn+tPwjiXxgljLCpW79lkiAjBXKxFTIEVFihd2
         b3CwGxBU4rQDzzOvvlTtLoava0Y7cZCyn21INQg+zEnTDq6gnomgcNLZHAteC/DjTIo0
         9rNOQcaWrqKE8E4DpyvcrIy0PNovDbgtnfooXzL8ii6XgzlAYCM/RImV31JJYOvwbDOi
         61zA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=F9jLr7E6ybNI1fkIgVeHaMd4FGlTJ4UQFZV93ZenQVg=;
        b=UW0wLCJRc0DPUTD9bnmdcwEDJGU/pFT+EwjCdkbOXkwwngHZr9QpnGDZWR+Ut+TzND
         gX39QOLdk3VVaCwjKlcli94IwujQmcpRPV1azQceoi/r9fRCBcKECgAt1c1z/o1vpWll
         jK9803EvXsgq1wmFJXdCpiyj98psFtCZBAnASgfwyoG24fGOd4K8QR9TdFsDOANrsFgN
         n5Ez2M7vhANRGVlB65/BruN75TpKX6svbHtr8EwwipIF2kect7u9taMGStY3Pm9/jBWf
         iUmgMwB+M2F3x4NAnBoSUEthQkRsM+bQcrAq9X62Bn13SxaiH9vl+xOX79lwaargqWJH
         Dcdg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id q12si21211204pgh.594.2019.05.21.02.41.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 02:41:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) client-ip=47.88.44.37;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R131e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07486;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=12;SR=0;TI=SMTPD_---0TSIe59t_1558431642;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TSIe59t_1558431642)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 21 May 2019 17:40:55 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: ying.huang@intel.com,
	hannes@cmpxchg.org,
	mhocko@suse.com,
	mgorman@techsingularity.net,
	kirill.shutemov@linux.intel.com,
	josef@toxicpanda.com,
	hughd@google.com,
	shakeelb@google.com,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [v3 PATCH 1/2] mm: vmscan: remove double slab pressure by inc'ing sc->nr_scanned
Date: Tue, 21 May 2019 17:40:41 +0800
Message-Id: <1558431642-52120-1-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The commit 9092c71bb724 ("mm: use sc->priority for slab shrink targets")
has broken up the relationship between sc->nr_scanned and slab pressure.
The sc->nr_scanned can't double slab pressure anymore.  So, it sounds no
sense to still keep sc->nr_scanned inc'ed.  Actually, it would prevent
from adding pressure on slab shrink since excessive sc->nr_scanned would
prevent from scan->priority raise.

The bonnie test doesn't show this would change the behavior of
slab shrinkers.

				w/		w/o
			  /sec    %CP      /sec      %CP
Sequential delete: 	3960.6    94.6    3997.6     96.2
Random delete: 		2518      63.8    2561.6     64.6

The slight increase of "/sec" without the patch would be caused by the
slight increase of CPU usage.

Cc: Josef Bacik <josef@toxicpanda.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 mm/vmscan.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7acd0af..b65bc50 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1137,11 +1137,6 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		if (!sc->may_unmap && page_mapped(page))
 			goto keep_locked;
 
-		/* Double the slab pressure for mapped and swapcache pages */
-		if ((page_mapped(page) || PageSwapCache(page)) &&
-		    !(PageAnon(page) && !PageSwapBacked(page)))
-			sc->nr_scanned++;
-
 		may_enter_fs = (sc->gfp_mask & __GFP_FS) ||
 			(PageSwapCache(page) && (sc->gfp_mask & __GFP_IO));
 
-- 
1.8.3.1


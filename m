Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 261F6C282CE
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 02:28:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CB2B820881
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 02:28:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CB2B820881
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B71666B0003; Wed, 22 May 2019 22:28:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B1E1F6B0006; Wed, 22 May 2019 22:28:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 997BF6B000A; Wed, 22 May 2019 22:28:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6FFB06B0003
	for <linux-mm@kvack.org>; Wed, 22 May 2019 22:28:03 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id n21so2208692otq.16
        for <linux-mm@kvack.org>; Wed, 22 May 2019 19:28:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=fTV9+QJ3Qlr+eWA8hqTAepwEMa3PO/pXGof/Ta/9BdY=;
        b=lQ7RBjw12gpOvketQBIX1VoFPgRLIciy31Ke+Q/kAoYLxJVyKLjtibHaZEl09vTWnq
         m7dERu9wcoS/L3zQ19FrzrOgC0KBMFUHgNcFLAcQq+2f46YSFcgL8YUuHGEuwBEPhNcY
         zMRddksY1CiVZA4zlNL8FCma+RCiVQKX72rvFbMeanpXF4sF3GwcWF1ZxBBztyN2B8QY
         WfdZxZ3Xn5zXXEdpuUyPZNAUO1d8osQy9cmfDeP6Utr9YmvREgiSxmrzSGBabcMBmyVQ
         9L46bjJr+lGyy7i7StllwiMCSUngqDwsWpFQuI8YfUaOJkKlIbXOEUdJ+Qnj5waeGbwH
         DU2w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWigepJkCCtObak4tR9NIYwYgXBwCv9H5plamOOSdWuIqTIFmUt
	FFV/GxTP+pnHXANwXKsAmsIrWea6Hbb9IV1IAo3fPHj1JFc0M3bUy+Dw3DZALiw7mWFH2St77Mo
	1ZtRS/j5HwJ8ztu7yZIGYy3AanbqNVxbwGGqHaIGvjcwMfcxP305jLBPJmmhy9ZJ4YQ==
X-Received: by 2002:aca:f007:: with SMTP id o7mr1256983oih.59.1558578483099;
        Wed, 22 May 2019 19:28:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw1LPpR0uL6WwUfuGpgHxSB4uBSXErmczlUkMR06teM1igg/Br+JEGiTni1UlE/kEaOehXJ
X-Received: by 2002:aca:f007:: with SMTP id o7mr1256947oih.59.1558578482104;
        Wed, 22 May 2019 19:28:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558578482; cv=none;
        d=google.com; s=arc-20160816;
        b=wOp0dBMN7HA40O/KAerferbmtSAOZsV1FM7114zw7r58wpX00EshMJ3XHHmkNDvrNs
         yG3WUgqFduEFM8QMKSm2StycGeTRwuoAfYOa8xZD9YFp/SCc3ve2WT8E+ydeh5RNsp8z
         PHXNg0+0SgO0JCErJBsL9jtWxXo8/n5tGgknNmCvdZhYP3AR1hfC+nfYeXLP2zxRYmTl
         L05tPRBgcu4ctAL3shhF8EJkjP9cwV6FUORssz5Rjjanw0+MQmgIBxoQJMJkmyk8qqL+
         1ttxS6USG4pGWORbcu5pQBXsMDkgxvAMoCvpAEf+Gte7hYWR6OFZBcI7m+QlPBbqAF4m
         Rfhg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=fTV9+QJ3Qlr+eWA8hqTAepwEMa3PO/pXGof/Ta/9BdY=;
        b=AwFknq1/n8Mabl7jwpf6KAC95p/MU8i4tJS3JFBxAUYDipHV4swfcXM5XFOAhhG4o8
         PiFloDWsSTdvrD2bC7AZSW0Ruo2V5oNyMle84uln/oYUcJwSjmWaLWoGrsl5vqFkG0bM
         Gb8KnKjHqWQZfv6pq3wqIQNlWrnbroWL3iNmCFTVYCU69v0GYhYImvBRMOY/2sRCyF1k
         lWfvNMEHXNp8KzH0zNf9M2nG+Vd6n+gz7zEAcpZG4Gt5MTOvI3TGZ+hGs+17RnqXCO1D
         4NuVlXyudc2zX+XN4qQZNfn8dUjtofcpwKK/8IzlmLzwhrgkGNvR2PVBtZ2JMkZRmfB+
         g4PA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-45.freemail.mail.aliyun.com (out30-45.freemail.mail.aliyun.com. [115.124.30.45])
        by mx.google.com with ESMTPS id k29si15960294otf.306.2019.05.22.19.28.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 May 2019 19:28:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) client-ip=115.124.30.45;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R201e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e01422;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=12;SR=0;TI=SMTPD_---0TSQws5W_1558578458;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TSQws5W_1558578458)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 23 May 2019 10:27:45 +0800
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
Subject: [v4 PATCH 1/2] mm: vmscan: remove double slab pressure by inc'ing sc->nr_scanned
Date: Thu, 23 May 2019 10:27:37 +0800
Message-Id: <1558578458-83807-1-git-send-email-yang.shi@linux.alibaba.com>
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
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
v4: Added Johannes's ack

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


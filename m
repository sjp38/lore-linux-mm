Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED013C04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 06:44:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A252E208C3
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 06:44:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A252E208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3C7476B0270; Tue, 28 May 2019 02:44:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 377E06B0276; Tue, 28 May 2019 02:44:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 219066B0278; Tue, 28 May 2019 02:44:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id DED196B0270
	for <linux-mm@kvack.org>; Tue, 28 May 2019 02:44:44 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 91so618424pla.7
        for <linux-mm@kvack.org>; Mon, 27 May 2019 23:44:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=fTV9+QJ3Qlr+eWA8hqTAepwEMa3PO/pXGof/Ta/9BdY=;
        b=t9aYiQBDdhGvCuyn3n/fOxb8XYKtWvbDiCqKiAAH4Olp7bo5h1ycdiNWlYEGAazk70
         biAjPMtGQikknI+Fs0b8sxqYjGw6uGBq5zKEUK8uGS3G6W3N82fa5yeaAc4r8qbvUCQw
         8qb0dKtDIMHOQhoaMtBcwbHIKD8mwXxboxn7FqyYuzIh/+pyCYfw/CeiCdd79qxgV6rR
         6YAyoWCX9p9ifQasGugr6X2WLqo6Wujq35QKMdkTReJOtQ2Yj/Oau2eExOHyBKlO6aAG
         JyQwY5Bv/k6kIBT3pDTdVYlGwhWtGesZI26jS2o4PNTly3xONJsRwZK+S6KsWdiwTfN3
         +BdA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAV2Mun/qzUV7pYDrgwGEJY8yslUgHKTlE7Hx3pcl5QJEBW/f4IA
	Jw1dZk2cjkDYaBveq34EHdAJaK/MBttoQjH6Bru5/JhAZXN1f6JgOwJmVsQuAPzO2bovjKn0ghf
	2tSrd58xgyvP3hzqjxG6at96qHMI5Z1NfYv7/ghmCH5g8BtkG91foC7jKygloeHKdPw==
X-Received: by 2002:a62:2b94:: with SMTP id r142mr50818620pfr.184.1559025884549;
        Mon, 27 May 2019 23:44:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxnieoFpuNpWC+jB5HXx/L5rr8yPHfKsjbRUeI/PqbIZkQQhq1dla9O4Euv9VO8ISKj39Dc
X-Received: by 2002:a62:2b94:: with SMTP id r142mr50818528pfr.184.1559025883224;
        Mon, 27 May 2019 23:44:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559025883; cv=none;
        d=google.com; s=arc-20160816;
        b=emfC/Rmzod0JVyXGfR8lb+dtKO89GL8Wkpzv5Ozd7WM91x59CLlitCM4uEIHVbJoXd
         WJkOVRfq7YKnD2f1cvKFf4XA7dTHeJpD2JSGWR0ejpcJBsYGeedBhnlPwxwCSTm/7Qyt
         RUjKUeoqGmyuuPI7TJ7t2CZ7gYqVvqSbVuKYxI7UbCTQmSRnv22KpBp3rKpixg5FBzMf
         85KjtCi49DcTaI7FcXZZiG3lbAhSJtbMKi/8+1C8PuN6thMiXceg0dUA3MZALXKOpWcr
         Y9cfPNgupiFSi+QjO6zNBzxDRV3QY4NlUu+pVvkFsESvhFHizW1xyXC3iRlml85KU5X+
         zksg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=fTV9+QJ3Qlr+eWA8hqTAepwEMa3PO/pXGof/Ta/9BdY=;
        b=hwKRMi8yOY2AenKn/mdBC1EXDtOUCihFXr7Q6X4/wUzgC9rAuUYPsvif82EHtePLNy
         OImebKOY8ENSnMTNpkyJsU/UYiS0jycwCrQT24CtINNqHYVr+i/DZYAVzf+VjD3Ryw1w
         L3+ucBJ6dgqXqRMZfWpM99P7m5yugw/u0gNAhdokA+WhhNzhKZtVjfjA3S8xbdZovS4k
         tOUxTEullk5TcW0csDVdN1HIVZn3Tm/WdrUQHCRZwyXzX3xgcXihFhhlyipuFK9mOynb
         fyQiYjwIYCZwpeHzky8ZKdS4RrGYY9bFicf0KOJ398Pc4GArgKWjCty+q6gR8yBtUUXW
         97pQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id n129si23508102pfn.106.2019.05.27.23.44.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 23:44:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) client-ip=47.88.44.37;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R841e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04420;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=13;SR=0;TI=SMTPD_---0TSrpwyt_1559025859;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TSrpwyt_1559025859)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 28 May 2019 14:44:28 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: ying.huang@intel.com,
	hannes@cmpxchg.org,
	mhocko@suse.com,
	mgorman@techsingularity.net,
	kirill.shutemov@linux.intel.com,
	josef@toxicpanda.com,
	hughd@google.com,
	shakeelb@google.com,
	hdanton@sina.com,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [v7 PATCH 1/2] mm: vmscan: remove double slab pressure by inc'ing sc->nr_scanned
Date: Tue, 28 May 2019 14:44:18 +0800
Message-Id: <1559025859-72759-1-git-send-email-yang.shi@linux.alibaba.com>
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


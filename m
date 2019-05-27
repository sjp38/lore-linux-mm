Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55568C282E3
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 01:58:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF0A820815
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 01:58:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF0A820815
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1347A6B026F; Sun, 26 May 2019 21:58:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0ED9F6B0270; Sun, 26 May 2019 21:58:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F3C9F6B0271; Sun, 26 May 2019 21:58:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id C9C706B026F
	for <linux-mm@kvack.org>; Sun, 26 May 2019 21:58:19 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id k63so3183700oih.15
        for <linux-mm@kvack.org>; Sun, 26 May 2019 18:58:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=fTV9+QJ3Qlr+eWA8hqTAepwEMa3PO/pXGof/Ta/9BdY=;
        b=nRM/ic/392njJ/Bh73rKUj15gJsB+bnNvyAtIPD2qbPBAoSCEEcpGak6PeIoUtC5lE
         AOVHPk81sy3kqnc1SRGnMOtUR1r/RMTL65duiHYZqSybLJbUTCYn1ucXefwmgtPDhyvm
         Vs5y3+teUE8TmLfNYfCC1IKwA6YCdi6jE5DREUPQPzOwWqUlyDxSkOYXv4FamL32Dpkl
         JBLTM61qZU3EW5HYAPGljgoCWZmY5v8m0GByJP0hW2YY+oYDQAxoPOZy1s8LEE3tMFa0
         EID5sRO0aMBP12yqOUziKlPIFZ7CQGeGOqqoXUbVIuffAlYchdCMpzFPhKu9//DbfiVu
         UWPg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAV0ihcrmNH7zfkdQwzneOlKMAfDRT2Sx3cG1rjLDUJxJ74Inquw
	jiRBn5XPoCqAAhiVpxLbgznp0IN7pwwPoSH1rmnThz3lhjYEAj1WngIzmk4e6QhfPIVVkKR2vGc
	qsAu6Qx/M5rzGUkvH2NAuMnExu/6kqdy+/IwSV+sU6UDrKgjLjPObYTlgz/LiRoxeEA==
X-Received: by 2002:a9d:6013:: with SMTP id h19mr67314840otj.215.1558922299386;
        Sun, 26 May 2019 18:58:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy6sOJsyVyzalR3yTeDTR/dWwdp+lGq3dXZwYAneO+MvE9xylXx7WtzpVeAqi6niije2gEL
X-Received: by 2002:a9d:6013:: with SMTP id h19mr67314799otj.215.1558922298136;
        Sun, 26 May 2019 18:58:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558922298; cv=none;
        d=google.com; s=arc-20160816;
        b=YoCqJ559KiZZ5MiTeUJ7fN8aaaTOHHYO7Jvf3BZhQNN8om94IzJN2XtgDtfAxADXev
         +enuCAl18Rt/LAQTILsZnsYKSLT/tUsntK1WaG4+oUAJHueJpZK2+4jijUJNTO0MTLGU
         47FqzujaCA6mfDA4bPlPGtgzMp1j0izommL/lMJyr8XAF6WDYlgRgAjDu1ZC4DUF8gas
         1X45OjK3hOEe2c5z5jRSh+snRkHHzJQkngshZRSY/EZTvivhwgZkEzsz7D+szGLjiYqv
         o9RW/pLagLv1j2eV/cXhbre501tfBbednl/pn9UTTrZ6tIxZkgHg9Rfn0cRNCNtJuorj
         gdVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=fTV9+QJ3Qlr+eWA8hqTAepwEMa3PO/pXGof/Ta/9BdY=;
        b=DZ/praRjcnowHKo38ne7z5F/vB9/VENf7E8R/JlAt7jK1V2iMCLX+Ggxzx7x8rnzQn
         Q1WSlT3FZcBR5xPgxxB2sGNcec/Ayo6QooEG3PoGeOQJ7IOcE3THLrdpm7R+2xh3zEil
         ZjsaATZHFdnFaeftnPEvlr/EkoLJ0Wayf8XyG3jwepIzYVj8tk7cXs06laDQO5F/lOvh
         3lPtZMRy6QF2/b/mEuFS14U4Qs1Eo8+luA3+lQ6OXJzlezZY9eJZynP+1toyXII9gYee
         VtqbkvvoddlkO90fotyoQfTSOZ8rAVmNaUyeVeUveWpye1zFdRjBzo+hzi8ZM7Y2wVIx
         AIOA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-43.freemail.mail.aliyun.com (out30-43.freemail.mail.aliyun.com. [115.124.30.43])
        by mx.google.com with ESMTPS id g8si5615704otp.236.2019.05.26.18.58.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 May 2019 18:58:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) client-ip=115.124.30.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R191e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04391;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=13;SR=0;TI=SMTPD_---0TSlLoRp_1558922275;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TSlLoRp_1558922275)
          by smtp.aliyun-inc.com(127.0.0.1);
          Mon, 27 May 2019 09:58:04 +0800
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
Subject: [RESEND v5 PATCH 1/2] mm: vmscan: remove double slab pressure by inc'ing sc->nr_scanned
Date: Mon, 27 May 2019 09:57:54 +0800
Message-Id: <1558922275-31782-1-git-send-email-yang.shi@linux.alibaba.com>
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


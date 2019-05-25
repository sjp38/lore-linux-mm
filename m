Return-Path: <SRS0=GxOJ=TZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8E81C282E5
	for <linux-mm@archiver.kernel.org>; Sat, 25 May 2019 03:28:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D53A12075C
	for <linux-mm@archiver.kernel.org>; Sat, 25 May 2019 03:28:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D53A12075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1BEB56B0010; Fri, 24 May 2019 23:28:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 16FB96B0266; Fri, 24 May 2019 23:28:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 036976B0269; Fri, 24 May 2019 23:28:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id C045D6B0010
	for <linux-mm@kvack.org>; Fri, 24 May 2019 23:28:47 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id e16so7589130pga.4
        for <linux-mm@kvack.org>; Fri, 24 May 2019 20:28:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=fTV9+QJ3Qlr+eWA8hqTAepwEMa3PO/pXGof/Ta/9BdY=;
        b=SJMAsOBcF9RoTOIf8WiSglzrsOnSpDGYYF+YBn4yBoGGE4RA1blbkEYv9u0dcq1weG
         Lafob1f8Xlxzy00fcNDX3QbNi2OXvBy3Rq3ZGpjjogvqwKjlcD9lk7e/KrAh5ljRbJxl
         6/40z3SgezBRtv97Nrsi693uoAt5onHbK7BOop5exFh5fcP1WhHPMyeFbI7WBz+MzC75
         bp0qw9h+QCy+MsXv/cBtFkSCNZNH+IUZCDpIaWVeslNtO9z/hTDsUSL4f8bqXU1gDtih
         GNgXoVDIs5C9ubVzCRNVfhgN5QglWIjfBuKtbRSu02cxMO2a6mlMITwhXIGLJwZSflY2
         kTWQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWpxKgwgrjh/7bhwcinIHmB1THj5Z7BgQHoewQQqnoJr9cgvgEG
	ot7nClcWU6i56l05A1QFqaBuhJPK7/fPIyMwJjQdxk2RezwXd3S1i1vvtxFDlnyoO830NPtW/ai
	fsQDkIvwLCue0CgP9h74PStbfEKbhNqE8NAmZteUAbLcO/fw4a5DpZuEym3LfPaM3KA==
X-Received: by 2002:a17:902:6ac8:: with SMTP id i8mr42545812plt.27.1558754927239;
        Fri, 24 May 2019 20:28:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzPcW8xCv2aUs2T2vePvm6ZT7b/L5sbcze27fx8Zx4gNFaTsEPHqlE9cDet5gjG2vNoq+or
X-Received: by 2002:a17:902:6ac8:: with SMTP id i8mr42545745plt.27.1558754925824;
        Fri, 24 May 2019 20:28:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558754925; cv=none;
        d=google.com; s=arc-20160816;
        b=VFcOlwTusMK4gTaSmJ6oHBuiHDv5/a080tBo9+He10LS5M1SPBJaCMSeEPNNbZjoW+
         Wt9utQGXBLIcVti5OjTpXolggsV0kYdEonf2r1k+xKz4VgYTI89hj9dbzwzuJiiokhOM
         IZ1Ewq6lCEHZhdqrBjJfN5k0LoCndQdZYpajAtS0va+wwBZEvk5V2er5uxa3ZZJID/LF
         lFd8k6gUreHXsCKOeFUPWxdhG0tbtIyG+BEOyhSp38t9jOze18Uk7j5jZocGeXKmvQ6S
         Onj9yshYN+RCWgrY/o/EFDgGm1RE5x4FLtmwiqQNBq8rMh/d5HrSdpfLx4+bHc1i3uiV
         toHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=fTV9+QJ3Qlr+eWA8hqTAepwEMa3PO/pXGof/Ta/9BdY=;
        b=HOUMc4Qs0fVXhSIn9HIEQ+eiCGu/i66UrMqLAnImOAvDF1ZFkkRHdbPpI6V78AVn7i
         +ME3Ubwc1sXTJt/kDuKnOp8rWf+qykdKmp91eGpsdMJEktO3MjJy+YZH99IbBzrWGs4F
         Xz1VPCW892WVDDjN9ARCFZ8yVg2W05qWze0XQeui+e/dXUgwc1VqY1stgi56AgYls2Tu
         oVglCQaWR/6Ts2kwQVdX+LpsFBTj7/Oqw3SqtfcGON4hOaMIg09c5e0Rsvko1l71ycJU
         XUCU7z5Xuf+yC4L+WrxqxMR0hi4nhJbhxWAHBOnc5ScU69RnoB/j2WBm+zOoI3S7g1Ar
         yNgA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-43.freemail.mail.aliyun.com (out30-43.freemail.mail.aliyun.com. [115.124.30.43])
        by mx.google.com with ESMTPS id h3si6434249pjb.19.2019.05.24.20.28.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 May 2019 20:28:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) client-ip=115.124.30.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R111e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04400;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=12;SR=0;TI=SMTPD_---0TScWUY1_1558754913;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TScWUY1_1558754913)
          by smtp.aliyun-inc.com(127.0.0.1);
          Sat, 25 May 2019 11:28:42 +0800
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
Subject: [v5 PATCH 1/2] mm: vmscan: remove double slab pressure by inc'ing sc->nr_scanned
Date: Sat, 25 May 2019 11:28:32 +0800
Message-Id: <1558754913-96989-1-git-send-email-yang.shi@linux.alibaba.com>
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


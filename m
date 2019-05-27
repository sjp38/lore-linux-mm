Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BEE05C07542
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 03:53:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4721E2075C
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 03:53:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4721E2075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C7BCE6B026B; Sun, 26 May 2019 23:53:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C000B6B026C; Sun, 26 May 2019 23:53:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AF06F6B026D; Sun, 26 May 2019 23:53:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 745BD6B026B
	for <linux-mm@kvack.org>; Sun, 26 May 2019 23:53:07 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id a21so3098603pgh.11
        for <linux-mm@kvack.org>; Sun, 26 May 2019 20:53:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=fTV9+QJ3Qlr+eWA8hqTAepwEMa3PO/pXGof/Ta/9BdY=;
        b=IsEV5a7cl/IxVQ/CJXhKOVwD5S5Ogtm2toiH5OnW3viXTmIdOQllUPiLgV8pTj1k3e
         rvwLMBDFfllEiTE95ItvRRDyXE9lcFzgllBjj7tOE1+AdeIfZ8aaDZ4xVm+NE2WgMG0N
         8t1WEVGmjE+mZiFTUnIQkIQ4YxS3GGsrkT3S6ATn28Yw5bcr+bHAH7ggWSdryA3Owxns
         G0qEuvi4EMNidb0NzvwoCc3g6WfsUiQmCoS7+N+Tht79IqYprvfjeMY2beflFlnDn2fF
         40Vbabi36yo2P0h89+zKeeDieJXZqIX/A4d8zMJbLM7k/dsHqoWuzSga+WdjHQpbM/vK
         +aOA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAULTuwFdRvLgUgBy1Nwq+uJ0Rtr9KmlY8NypR14sV62U4BTfr6u
	C1a4ILr53V6uY4+MlWJkrbkPeTTxLzEIRFfHqthKOsnm51SdxE7QRjW72Xr66V72Dk3YblmDaF2
	qD0Qw6KV2Qt+Ip9qmLjzZL9hI2BF41Xgs7ZYL/PbnMYrGZxSEdv+2RMIcLSuAAlCIKQ==
X-Received: by 2002:a63:e54d:: with SMTP id z13mr28085705pgj.132.1558929187044;
        Sun, 26 May 2019 20:53:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxBHPqDYt+JLXB3HwXeML6xKfzKGf8a7Bj76qkVC5TomZAk/NGLiwDnr9fDHxDeuEm5AMRa
X-Received: by 2002:a63:e54d:: with SMTP id z13mr28085649pgj.132.1558929186020;
        Sun, 26 May 2019 20:53:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558929186; cv=none;
        d=google.com; s=arc-20160816;
        b=QcGsmJjQg0Ilq+aALK2PAjiNrNwD+gy6jFPUK24t0RejnCfDzx2vG0juplsR5IA8g0
         4Do9FBN0SnS7CQ1rx4s5kBnjDyPvj1Ddm82jMblFlGQH4T0cm2Cl5M3rmqasWz00/34Y
         jlPGlZBzju+quQ8U06FT4GaNk6JBXKjU3hOLR08uSpdt8v9vNfMeVc8O8LFY/86cTrz8
         FPsMqzVCDn+3HPK/IW6a/AEfMm1pnRXBDKGLXnN2v9/l6AvUC4IEgBDJryoYLRkfO765
         /egPl/wDQJpTUmhEkupGve+PW+cwLGGK70a2XGb6NYXwCc1WIrFfJ0g6aLPsgazDPi67
         Ey8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=fTV9+QJ3Qlr+eWA8hqTAepwEMa3PO/pXGof/Ta/9BdY=;
        b=J5iH6iF981K3iFree4uwO8G320C4KXC4tv3/FHL5rj2g6P8s1Epzfq2RXcvlNenIOy
         5SB9leGbxZ8QHRii+ceeHKbfdQ2XEP887L9fpqMyGBctqImImDFdnSNq9v4SZNSRyz+1
         F+XtkxY0ncdhkVTG1TUzvH9oJnyeK0CyVSq8sgKaV/cHvkLx7VAzA2oIIx7WYwm+CQNH
         +PCPN7Ovhawhyn3jhL26nPNx26e6aNNWk4+E0I2dFvS3sB/lBTZQMMbVdwERQjs0hHdz
         tsen3670yJlF/kYNsMK8YoMhDZhM//00jqjwjVF1KpWlMv8I72nsI8rz8MAO/NViEICZ
         y3mQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id z7si15945346pgi.365.2019.05.26.20.53.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 May 2019 20:53:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) client-ip=115.124.30.132;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R141e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07487;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=13;SR=0;TI=SMTPD_---0TSm38VC_1558929166;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TSm38VC_1558929166)
          by smtp.aliyun-inc.com(127.0.0.1);
          Mon, 27 May 2019 11:53:03 +0800
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
Subject: [v6 PATCH 1/2] mm: vmscan: remove double slab pressure by inc'ing sc->nr_scanned
Date: Mon, 27 May 2019 11:52:45 +0800
Message-Id: <1558929166-3363-1-git-send-email-yang.shi@linux.alibaba.com>
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


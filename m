Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5ECF2C04AB1
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 08:08:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 20D5F216C4
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 08:08:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="H4jVh1+n"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 20D5F216C4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C20406B0007; Thu,  9 May 2019 04:08:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BCF286B0008; Thu,  9 May 2019 04:08:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ABEE76B000A; Thu,  9 May 2019 04:08:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7754A6B0007
	for <linux-mm@kvack.org>; Thu,  9 May 2019 04:08:12 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id c12so1087458pfb.2
        for <linux-mm@kvack.org>; Thu, 09 May 2019 01:08:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=zE1IYQhkRVrv69+xXa1Vu4sJkBuCxayvya+FzxecnN4=;
        b=V0O2ZsHSqKvNqVBkEsuNjFaNPZkBJJU0B8/XUM4mhKb7e3n+zeJ0GE8fVCCf1PErFE
         IpzTnA3CAhDbRTZBG2TsPgaBcRCEDsipu7FsUgcy9+ArjdLHvql4Hfgt3oGhqRAOipz/
         md3fwv0uKh6SlpkPIZNwKm6o56Omi6DczRYEKgBFTbFwXwiVS8DFQ2TarlEfDsfHmXZ8
         uTA1zlGQKJcw1DDJxjAZHotwpEHTk9OxPjZHeqz+TFpWMrvolt6ca7fJS3XrIodfyAfH
         BTTvgXMEGJxhOSL+/6REmkoQyUaeQrCk5VT4QhRMksIzI5SPM17kGlbRU1KdiSs4AJ1M
         re0g==
X-Gm-Message-State: APjAAAU2vnzw1fkBoBEyhkke8SpXUkVCjn9WE5v8ihk8m+0zWZSOD+Y9
	BU0xnDYD8dNJPUZxEkTo/Pc8+yqc8tCHKpW34YDedYCBukE5lB3sL+XOws9IUD4CbWZXkhGRQXF
	E3wK9O7fuEwbzMALh9FXVUos1dzrdMhBz1GgEn7zJplFHCrhOmclPRU2SAMnP/3yEEQ==
X-Received: by 2002:a63:4c26:: with SMTP id z38mr3676959pga.425.1557389292149;
        Thu, 09 May 2019 01:08:12 -0700 (PDT)
X-Received: by 2002:a63:4c26:: with SMTP id z38mr3676880pga.425.1557389291058;
        Thu, 09 May 2019 01:08:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557389291; cv=none;
        d=google.com; s=arc-20160816;
        b=hiruvKa7mmoxUOgYJRHKUu8+PtNR+aFya58J9lN+pSRH9HQ2xxNsrIOlYl2K9aEBO0
         eRGmrz724IQrJ1GPsfOLAtf7PXenFcQCFCj/HjdWXwrZiMCfxlyYaFyBahChwb0oHcmT
         q13T1zwC5618R2+wvFlI/JKYEcnLOLqIWEIn1H+d6V3jahqfXSuiPyfpPOaWezvwZul8
         o8e4FHPHr8Te1+XvhPpjKMFDn2gEz+Wy33zNAk3TWpPS67++wcbcHwUAiJYKiFqaVHPp
         9XptejZfw4xvYibyLUlrDzRY7c0mbrMfzuI+RqON+ly1/rt9lvAiT1cdetA2J7PYFDEe
         iKQA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=zE1IYQhkRVrv69+xXa1Vu4sJkBuCxayvya+FzxecnN4=;
        b=mvh8+DYb+bAYH4ByNzkJaaPGW2JvuAeEJ6mAIoLxyROyqc5umWTHHB6YCq7sYQsT4h
         NQt3ChfvH3j4/fZA9Da8lJjRQjmGI+DfyeV/WsIP1Lfu7rHbTwsSGj1cbfOoy8iuz3Gz
         m2benIgDUVwB5pSQj9RD+100dDpmpflo2wpwwasuGOOgCuYGWZsFHCuL3q7muT7HXquI
         IoPnhTNJd/dqX/hzKYS0oSLY7fNx020mQTy/rrO4jZtEI7WnbhI9e2RI7WAnbp21yaaE
         5H8iekoZzFsTkD/LyHbwHpPbCD8465SpaFotc1K2pEy5l0krjm9e/XfuA8muS5wiRma+
         +I7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=H4jVh1+n;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 30sor1316262pgo.39.2019.05.09.01.08.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 09 May 2019 01:08:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=H4jVh1+n;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=zE1IYQhkRVrv69+xXa1Vu4sJkBuCxayvya+FzxecnN4=;
        b=H4jVh1+nvpWWdebin0Y0sDnVshQi50d0495HR7MrLtTby4cCV4Mwvvu4pI8sVMX9dI
         XI7EX+LDqJItIr94JxsO6jms+MqmWhC+pRDIK06gscx6etwYn4Jz6v7t7KeySigE0jmc
         WCVJp1TS/JtRWfraauWahbQ5A63fHW9JlXnrVQhoeNASWxOVJH8UY3w8rreTFfbYTL8s
         f9ZOvwrdraDgR7iaJI9iCRXGwfjxuGtk5TXAYY5Mv4LwkhPcMBShjc3zMe6H4SBvJqNB
         lpycR7k7rY8+l4hZRPEmj6qnVttLZZ3DrzwHaelCqTQjV3odZuNsWoI+5yAL03z6I3gk
         fZxw==
X-Google-Smtp-Source: APXvYqwXkhhugnBjs1CmjQRx6KIxv3pohcZmSaIBWj27neW7/8K1IcXRbGSyZ6BDywTlm+2cjginpA==
X-Received: by 2002:a65:6497:: with SMTP id e23mr3742728pgv.18.1557389290835;
        Thu, 09 May 2019 01:08:10 -0700 (PDT)
Received: from localhost.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id d186sm1620900pgc.58.2019.05.09.01.08.08
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 May 2019 01:08:09 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: mhocko@suse.com,
	akpm@linux-foundation.org
Cc: linux-mm@kvack.org,
	shaoyafang@didiglobal.com,
	Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH 2/2] mm/vmscan: shrink slab in node reclaim
Date: Thu,  9 May 2019 16:07:49 +0800
Message-Id: <1557389269-31315-2-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1557389269-31315-1-git-send-email-laoar.shao@gmail.com>
References: <1557389269-31315-1-git-send-email-laoar.shao@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In the node reclaim, may_shrinkslab is 0 by default,
hence shrink_slab will never be performed in it.
While shrik_slab should be performed if the relcaimable slab is over
min slab limit.

This issue is very easy to produce, first you continuously cat a random
non-exist file to produce more and more dentry, then you read big file
to produce page cache. And finally you will find that the denty will
never be shrunk.

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
---
 mm/vmscan.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index d9c3e87..2c73223 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -4141,6 +4141,8 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
 		.may_unmap = !!(node_reclaim_mode & RECLAIM_UNMAP),
 		.may_swap = 1,
 		.reclaim_idx = gfp_zone(gfp_mask),
+		.may_shrinkslab = node_page_state(pgdat, NR_SLAB_RECLAIMABLE) >
+				  pgdat->min_slab_pages,
 	};
 
 	trace_mm_vmscan_node_reclaim_begin(pgdat->node_id, order,
@@ -4158,15 +4160,13 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
 	reclaim_state.reclaimed_slab = 0;
 	p->reclaim_state = &reclaim_state;
 
-	if (node_pagecache_reclaimable(pgdat) > pgdat->min_unmapped_pages) {
 		/*
 		 * Free memory by calling shrink node with increasing
 		 * priorities until we have enough memory freed.
 		 */
-		do {
-			shrink_node(pgdat, &sc);
-		} while (sc.nr_reclaimed < nr_pages && --sc.priority >= 0);
-	}
+	do {
+		shrink_node(pgdat, &sc);
+	} while (sc.nr_reclaimed < nr_pages && --sc.priority >= 0);
 
 	p->reclaim_state = NULL;
 	current->flags &= ~PF_SWAPWRITE;
-- 
1.8.3.1


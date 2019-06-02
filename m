Return-Path: <SRS0=2YS/=UB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74B7AC282DC
	for <linux-mm@archiver.kernel.org>; Sun,  2 Jun 2019 09:23:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2B4DF278A6
	for <linux-mm@archiver.kernel.org>; Sun,  2 Jun 2019 09:23:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Ta5/6PDF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B4DF278A6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ABF6A6B000C; Sun,  2 Jun 2019 05:23:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A6F9B6B000D; Sun,  2 Jun 2019 05:23:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9389E6B000E; Sun,  2 Jun 2019 05:23:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5AD0A6B000C
	for <linux-mm@kvack.org>; Sun,  2 Jun 2019 05:23:32 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id r12so10938465pfl.2
        for <linux-mm@kvack.org>; Sun, 02 Jun 2019 02:23:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=KUxFJsUduib/8dQMMXEXYzMoxtrq/7ohcGiPCj1I+E8=;
        b=cXCYCP8xbdmyNBEpCkWHZ22zobxBS6yNyAOHp4B23PCmcCephV/7BYjz4LNngeTwx8
         oWeQX0jODrXS0z4iCDTjjzbb8kQtXP1khRf7yAjt+d2IIkAbKPCbrbJFIsJP45OH8sgX
         hZB2RXLs4pSuzPXZf0Re2zuMcfGEkd/M7vthDkvxM/S42CeHw31Z1Q29H5D/8dToMMjC
         JkTGEau1DKroYsKcwj3nuIU6BdvvfJvSJgrRlKNVY+7NTedQ0HFiCJsqKGQKnTVG0IiD
         P1IMfcve6ui8jIz9uQ8tFi4f44pX4FC7R2tVSvH/wdW/2QoFS25y4o5htlMbbKPQUqux
         Shlw==
X-Gm-Message-State: APjAAAVU9Rv2f9L3mCy8OUKZ0Jv1gvUjNCcgU6aMUvTDqiXd2j4HRYL2
	lFy1yfkXyUmIwPRfUjVqz3VSj3DL9savWXgfzl58GeaqnC1dfqb6kJsXxs7KEFU/FoG9mS5cRnm
	aSOvYzRqh2UVAkgc8OpGfnkSs3Yp5VnrNlNP9wO635IjZLfRri/nA758M0nETuC6VYg==
X-Received: by 2002:a17:902:7295:: with SMTP id d21mr10035025pll.299.1559467411873;
        Sun, 02 Jun 2019 02:23:31 -0700 (PDT)
X-Received: by 2002:a17:902:7295:: with SMTP id d21mr10034974pll.299.1559467410620;
        Sun, 02 Jun 2019 02:23:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559467410; cv=none;
        d=google.com; s=arc-20160816;
        b=O+dKXXPU1bJOrM3hZpPJBJmHlZNa1VyXooGoaNTFo9SJmbSQRm2a6u5Q3KBtlTh+Hs
         SAbshMOXzc8T3VTxc5YPh11271j2x3VRIAbJ3yPhlR0A7RfLLgPNSgfooj+iN5qi2m+p
         oViXRf2yZygK41ftRRS06gH4poIc0b5fP1NNjbI0er1VoJU7J+vauFtbbVmpoOZGZVbX
         JUZyp8WkYdiJEK0t9uymLZxcRWa3qnnMH4SuOKe5FtNyyud8bAcHZ3WJfPEi6FXpfxf7
         4tRGZQOuIG7PFFEsHZuzJeVYLZQglmCBAvh4ozopHPHb2QBaiw+x6O0IMugrLAtq838k
         VIzg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=KUxFJsUduib/8dQMMXEXYzMoxtrq/7ohcGiPCj1I+E8=;
        b=haF0K5G5PYhmGPO/GKHvFkQ0CTCjvFPkEZslwO3VHTJ0P0mgNdU91Fh/RB9Hm6wOQs
         MPy7NKBz7waz06Viyf2RGqNFRw400n4Frc5Zvufbmx/Q3du9sHll28ELe/HkIuACQh8u
         xJtO3aqvdVM7HRlGxpWFMb98JkiGngIyrg+csfuRivB6EEaPl5Ijk/LBg+tDOzlBxozi
         jxACEVo7cxQiLQFv8UVh5HXCMkOpI1PnSCk2XadBugDH+UumLqpQN83/+5wcVcIaWUus
         EEOSEHpR2GSqAxPWAggOMzg8Plrxk3yb0c7uPSzs1ieOmTye9lf90ginY6+yOlRAawHu
         8pbg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="Ta5/6PDF";
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k13sor12552298pfi.31.2019.06.02.02.23.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 02 Jun 2019 02:23:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="Ta5/6PDF";
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=KUxFJsUduib/8dQMMXEXYzMoxtrq/7ohcGiPCj1I+E8=;
        b=Ta5/6PDFxOcyoSc38+MK2T9C0GY6y8hB6BrK46AUxxvC8YScIHO9FG23TS3QUE2JZW
         y4ockxXOJRMOVwzqQaLuosQkreMZ8iZFwDPDvMHKbw9KKtrJ8P3dVlKOzeNcYv5Is6Fo
         CqMlWJVwJ/faUuh8xCxIPdyyPPrdVEdhLCkvxAUOG9+65/0jr3hyMi8op5IEQ0/iC0Q8
         /wlCavloQQ44LB47dzzGYAfZaWOboMjj5OBxouMK6lFV9kTGxYut391eBPNdYerCcHmb
         /cfx1kGd+v9wODrIve6qKRbtVSeys8UBUchaiWczEjeFXMnc6P1pcYIDcQysgjt8xiUx
         y2SA==
X-Google-Smtp-Source: APXvYqzUbBkWq620fD5OxQkEna2WC9+RfBsuglfBTn/q4uST8rpXP/uobCBruDOZLyENt02MzHYxsQ==
X-Received: by 2002:a62:5306:: with SMTP id h6mr23404255pfb.29.1559467410349;
        Sun, 02 Jun 2019 02:23:30 -0700 (PDT)
Received: from localhost.localhost ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id t124sm11633191pfb.80.2019.06.02.02.23.28
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 02 Jun 2019 02:23:29 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: mhocko@suse.com,
	akpm@linux-foundation.org
Cc: linux-mm@kvack.org,
	shaoyafang@didiglobal.com,
	Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH v3 3/3] mm/vmscan: shrink slab in node reclaim
Date: Sun,  2 Jun 2019 17:23:00 +0800
Message-Id: <1559467380-8549-4-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1559467380-8549-1-git-send-email-laoar.shao@gmail.com>
References: <1559467380-8549-1-git-send-email-laoar.shao@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In the node reclaim, may_shrinkslab is 0 by default,
hence shrink_slab will never be performed in it.
While shrik_slab should be performed if the relcaimable slab is over
min slab limit.

If reclaimable pagecache is less than min_unmapped_pages while
reclaimable slab is greater than min_slab_pages, we only shrink slab.
Otherwise the min_unmapped_pages will be useless under this condition.

reclaim_state.reclaimed_slab is to tell us how many pages are
reclaimed in shrink slab.

This issue is very easy to produce, first you continuously cat a random
non-exist file to produce more and more dentry, then you read big file
to produce page cache. And finally you will find that the denty will
never be shrunk.

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
---
 mm/vmscan.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index e0c5669..d52014f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -4157,6 +4157,8 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
 	p->reclaim_state = &reclaim_state;
 
 	if (node_pagecache_reclaimable(pgdat) > pgdat->min_unmapped_pages) {
+		sc.may_shrinkslab = (pgdat->min_slab_pages <
+				node_page_state(pgdat, NR_SLAB_RECLAIMABLE));
 		/*
 		 * Free memory by calling shrink node with increasing
 		 * priorities until we have enough memory freed.
@@ -4164,6 +4166,28 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
 		do {
 			shrink_node(pgdat, &sc);
 		} while (sc.nr_reclaimed < nr_pages && --sc.priority >= 0);
+	} else {
+		/*
+		 * If the reclaimable pagecache is not greater than
+		 * min_unmapped_pages, only reclaim the slab.
+		 */
+		struct mem_cgroup *memcg;
+		struct mem_cgroup_reclaim_cookie reclaim = {
+			.pgdat = pgdat,
+		};
+
+		do {
+			reclaim.priority = sc.priority;
+			memcg = mem_cgroup_iter(NULL, NULL, &reclaim);
+			do {
+				shrink_slab(sc.gfp_mask, pgdat->node_id,
+					    memcg, sc.priority);
+			} while ((memcg = mem_cgroup_iter(NULL, memcg,
+							  &reclaim)));
+
+			sc.nr_reclaimed += reclaim_state.reclaimed_slab;
+			reclaim_state.reclaimed_slab = 0;
+		} while (sc.nr_reclaimed < nr_pages && --sc.priority >= 0);
 	}
 
 	p->reclaim_state = NULL;
-- 
1.8.3.1


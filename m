Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D289C28EBD
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 02:36:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 31CFF207E0
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 02:36:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="sb+JjlJc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 31CFF207E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A87EE6B026E; Thu,  6 Jun 2019 22:36:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A37E26B0303; Thu,  6 Jun 2019 22:36:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 926C36B0306; Thu,  6 Jun 2019 22:36:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5D3BE6B026E
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 22:36:10 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id f1so460698pfb.0
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 19:36:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=k0l9U+sWxSO3Dg0lLraseLlI8mAPkbXeLIQciOlURR0=;
        b=O0zVXVKukh925uwvVmV9ABDr4AkqAhuRRHidf7kvNFcSy0FH6h33hqCqE2S2JP5DBK
         aNlgvpgkTl/MIUMeMdVrgE85fvHRtYlJreAB189x5O+C6bN9qVEquFpeFGMGpl4WrJ3q
         n1FDnDOnEE5f/UQr5GSY+Bx80Uw6wbCPx6FW6z8AMIGMnGF/K8Hn349TIhu/WGzTYxGo
         akO4nwH/b1v0JuB9lE5gz3LBrQu+K7jwXWvnCYk9W45HXxn1qkkZ+E+L5sOi/Lndm6xc
         1crbtXnzZJvT0abOFyn5FajoK/0W4PWQ+IX6WYMRXS7LpnoJdQOFa35suupwVVdqhfOa
         JIIg==
X-Gm-Message-State: APjAAAW8K5QYxqPyJUhVYkYxomgcB8YmOr/hl9c0CDscqYAcl7emJxNd
	X4/f2rGdVbju2b0hYXgY7hTBrUznx/5S0WZ3rGkzKz+8stS/7z8l+fRVgAQELmiAr8KWxd6vBpp
	CvX0viwO/o2526og8nhd1yJTNOYn5InToysscxMYUTrnrJk/lqkM/3HWj2HXRBJVmFg==
X-Received: by 2002:a65:60d9:: with SMTP id r25mr798050pgv.228.1559874969733;
        Thu, 06 Jun 2019 19:36:09 -0700 (PDT)
X-Received: by 2002:a65:60d9:: with SMTP id r25mr797982pgv.228.1559874968102;
        Thu, 06 Jun 2019 19:36:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559874968; cv=none;
        d=google.com; s=arc-20160816;
        b=l3e9lZ6lDfuzupHdR20z/tgsCugBCgHytU6lFHEs/yR4xVttYs5MuzQ90tosVkl36R
         z7gHf7zj2FdkyfZ3+fSv6nqLZsXMPGchugkSfp5UQL6KwdCb3+q+1Gi1uSFKpa4zCLr4
         B+QSW/hRrUDX7Ak3Lh5+QnuI6s78VbWsIvcBPHG5fS/hOh9RDg4/1LonLEG6z3ZL43rv
         AF+zHLUI5BsWyopvP3kmyQSLJN6jtra8Q5nGXWeHuKt97HbmzEXjpOC6ViY0M5mxQkIq
         2cZ6Y2QMKnxkbDzVZd+NS8pejsv2dW6RplTy3AazDcJDPWj3wy/T0foDvISu78J8CiE8
         k+2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=k0l9U+sWxSO3Dg0lLraseLlI8mAPkbXeLIQciOlURR0=;
        b=tl4hGA4gTbdKRTwYUDG07BTzYcgwlK9X4YDldR/IIVloh8iBretBCgfC+tZAKRu//v
         jDGqvCuBKLBAVXAjv1jEJ8tJDtJ2/+GhG8bZxDIcwZW7lRjH1mEjwBUo2LB1PTxfliiN
         Gp1QccLt/Kpt8Z0tt9nddK35O5mLUi4WrEeh9/aXF7WbsBDuDvTz3AMCGXaeieoJoxkV
         Cu22Y6rtwueSeJ22fBzTwc9gQxJ4WwUthen9T3MFRwloHlowIaJIOh1pTRUvrw4THmCN
         bvwgQKu1KiYb/Ddr4VNz/4kT6f+Z7WK/T7GGViB2mtmAcDcCtUr7sVgm5JwpbNmHwN/y
         WBKg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=sb+JjlJc;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h42sor929221pjb.11.2019.06.06.19.36.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 19:36:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=sb+JjlJc;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=k0l9U+sWxSO3Dg0lLraseLlI8mAPkbXeLIQciOlURR0=;
        b=sb+JjlJcd5mJ5HNDyl0qgaePDmBk3pibYjr9NsM34MidcwryLSw4GBRQWvb2PSfzP6
         ZSRPk9BaYyxutGLFBQ9BKW/vyzNfz2usP8QjnKPdjsk/fy2sjQJVOFC9KFvHm8r4F3Yk
         yxJsfxRYrkNqIZmipg9Uy0ay2eGRxukgd4lGYrwQSWfaHgQQDlk6dSymZE987/lnDamR
         SdNFERGrgSoGbsgAI4b6bS4oPBzrLGVqP/zu2H2sakNREFNQGbgfdXfGBwN1UAWlUn5l
         NjgY0ujZjp+zqfWQ9/wRwqGRPgbC4gcCIWTg8P8xYntFykRNbVo4VhF0soaHCOKD/qGd
         rloQ==
X-Google-Smtp-Source: APXvYqyYmbI5/WXj7lu4fv/XeovksaJ2ThsihcyBi31enEe/YjwEejmJrXDLphvBRGCZAJPwXickQA==
X-Received: by 2002:a17:90a:af8a:: with SMTP id w10mr3091492pjq.132.1559874967732;
        Thu, 06 Jun 2019 19:36:07 -0700 (PDT)
Received: from localhost.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id p65sm490461pfb.146.2019.06.06.19.36.05
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 19:36:06 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: akpm@linux-foundation.org,
	mhocko@suse.com,
	linux.bhar@gmail.com
Cc: linux-mm@kvack.org,
	shaoyafang@didiglobal.com,
	Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH] mm/vmscan: shrink slab in node reclaim
Date: Fri,  7 Jun 2019 10:35:46 +0800
Message-Id: <1559874946-22960-1-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
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
A new bitmask no_pagecache is introduced in scan_control for this
purpose, which is 0 by default.

reclaim_state.reclaimed_slab will tell us how many pages are
reclaimed in shrink slab.

This issue is very easy to produce, first you continuously cat a random
non-exist file to produce more and more dentry, then you read big file
to produce page cache. And finally you will find that the denty will
never be shrunk in node reclaim.

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
---
 mm/vmscan.c | 27 +++++++++++++++++----------
 1 file changed, 17 insertions(+), 10 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 281bfa9..da53ed6 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -91,6 +91,9 @@ struct scan_control {
 	/* e.g. boosted watermark reclaim leaves slabs alone */
 	unsigned int may_shrinkslab:1;
 
+	/* in node relcaim mode, we may shrink slab only */
+	unsigned int no_pagecache:1;
+
 	/*
 	 * Cgroups are not reclaimed below their configured memory.low,
 	 * unless we threaten to OOM. If any cgroups are skipped due to
@@ -2744,7 +2747,9 @@ static void shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 
 			reclaimed = sc->nr_reclaimed;
 			scanned = sc->nr_scanned;
-			shrink_node_memcg(pgdat, memcg, sc);
+
+			if (!sc->no_pagecache)
+				shrink_node_memcg(pgdat, memcg, sc);
 
 			if (sc->may_shrinkslab) {
 				shrink_slab(sc->gfp_mask, pgdat->node_id,
@@ -4176,6 +4181,10 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
 		.may_writepage = !!(node_reclaim_mode & RECLAIM_WRITE),
 		.may_unmap = !!(node_reclaim_mode & RECLAIM_UNMAP),
 		.may_swap = 1,
+		.may_shrinkslab = (node_page_state(pgdat, NR_SLAB_RECLAIMABLE) >
+				  pgdat->min_slab_pages),
+		.no_pagecache = !(node_pagecache_reclaimable(pgdat) >
+				pgdat->min_unmapped_pages),
 		.reclaim_idx = gfp_zone(gfp_mask),
 	};
 
@@ -4194,15 +4203,13 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
 	reclaim_state.reclaimed_slab = 0;
 	p->reclaim_state = &reclaim_state;
 
-	if (node_pagecache_reclaimable(pgdat) > pgdat->min_unmapped_pages) {
-		/*
-		 * Free memory by calling shrink node with increasing
-		 * priorities until we have enough memory freed.
-		 */
-		do {
-			shrink_node(pgdat, &sc);
-		} while (sc.nr_reclaimed < nr_pages && --sc.priority >= 0);
-	}
+	/*
+	 * Free memory by calling shrink node with increasing
+	 * priorities until we have enough memory freed.
+	 */
+	do {
+		shrink_node(pgdat, &sc);
+	} while (sc.nr_reclaimed < nr_pages && --sc.priority >= 0);
 
 	p->reclaim_state = NULL;
 	current->flags &= ~PF_SWAPWRITE;
-- 
1.8.3.1


Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E888C282D0
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 04:17:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BEB4D21848
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 04:17:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BEB4D21848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7320D8E0003; Tue, 29 Jan 2019 23:17:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 70D9C8E0001; Tue, 29 Jan 2019 23:17:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 583708E0003; Tue, 29 Jan 2019 23:17:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 18FE68E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 23:17:19 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id 74so18696551pfk.12
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 20:17:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=8Q997Rl4ZH7D4iZIqIGbV0pd1Ue7utgCKr6lu5VJOr4=;
        b=qbg7IqsIoUH7mJ4FsH9hGRNDL2f8KlAgs6J5Pb42LvEK8g9NmOKpQ20ivp4VlBnRx8
         g0tQT1OHtnvpmNqo6fSrxjaHSHJP5wMVBSPG2xGN6vkrSRTZYEu+n2lH21j9tmmNVUHy
         bGqEDpODfk9aS7pRl/h9VMCEIFrJvmmb2uFL8DBVHwTu83vApU/rcdLIO1z63/W+AOur
         VekbdTXH2urrmUsJGdQNRIE0yl3NqshTcN5qNsWT5KYXeyM28kdvDqEnb5LoCCIL8j24
         ERKtwGTHeXwn6I2/rfee9dRW6AIQL4cIKYkcwLwMW5sfG3tg/vwwz8Oux9qzDdhLP9kl
         xBDA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 150.101.137.131 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: AJcUukeO/Rxy4RKT/bhh1RScXXdnXfHir4P34WhtMD8kb1n3C7zU45Sd
	yxhlqBWWZgcTKZ9u7tkP1mx1CR3UrdoGIsmBP6CIO2xeLE7mwc5MJUzWuN4qUdTUlSVSL+HFKY7
	ciGswjgc83JtjbTQB1EYQePFHNoXGLLzKoKTaMD5P8qqbJB6LEBeKpCeltc2mQY4=
X-Received: by 2002:a17:902:bd0a:: with SMTP id p10mr27893028pls.322.1548821838746;
        Tue, 29 Jan 2019 20:17:18 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5O1DHcDv+9BP5CM1/S3Hp2GiE7LeWmEnp1xImX1fKaNlSxHsT54YppYt/3m5Jp0ui2P+W1
X-Received: by 2002:a17:902:bd0a:: with SMTP id p10mr27893007pls.322.1548821838041;
        Tue, 29 Jan 2019 20:17:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548821838; cv=none;
        d=google.com; s=arc-20160816;
        b=tMKIvf92pA4h+srugTwG1QdKnjuGQINfxP9wmwTRB3+RJtYKybHznOg7zdA/DqQ1HB
         JLG6ZlM4bDK9oig+7uBL27qaBfqU4Y/rDFx2xTcnw+N8whxlR0GwZF3qFh+Tz4qJ48Gn
         FFQFlYAneZo3lduIvy9mq9eNSfyk1Z4rU68o4ZBZs9LDH4ZiOi4j8xloh8NWqCJ7LCi8
         v8L2srzl4MQlmFJ0vxfBvZU3mWP4rn31WWG9hQJB01KfrfVQwJotYYl/lJydzO1xm/vi
         GGACwwOXVEtS1odK1QUbGamAHlthvxr2grQsXYF3/VY8O1nufvSuU9twIjeWuJD5uYdp
         2idQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=8Q997Rl4ZH7D4iZIqIGbV0pd1Ue7utgCKr6lu5VJOr4=;
        b=mcn997Lupqr7TCSlT4+w5v7h8MRkwueEwGrqvXn2LA2UgSOun+wzQvzd23Iz66DUDY
         WlExB4Q/VgqnnA12ij3TM3KvKJb3VrePcexsdogUVRsENlpEP9jDJFusCRvhZJjCCJOu
         /2H6Bl7JH2/SSkYxmYTsm6WhN53MQElztjMLsMooUKUD8IuA2pq4aAwqLr9T7AZ5vusW
         N0BaEmraFOrsw67Fg8bULG7CV+yIoYd3nCHUj9gTfPLv0Sc5Gdilk6Y+WJFobc5JpEub
         lJy0aSqIBoEh6BicDzZWFI63Mnb2y+CG4dvxRtumuh8gb+QPdh+hM+Qvbcs/sRBaEZT9
         Pckg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 150.101.137.131 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id m7si489222pfc.118.2019.01.29.20.17.17
        for <linux-mm@kvack.org>;
        Tue, 29 Jan 2019 20:17:18 -0800 (PST)
Received-SPF: neutral (google.com: 150.101.137.131 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=150.101.137.131;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 150.101.137.131 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail07.adl2.internode.on.net with ESMTP; 30 Jan 2019 14:47:14 +1030
Received: from discord.disaster.area ([192.168.1.111])
	by dastard with esmtp (Exim 4.80)
	(envelope-from <david@fromorbit.com>)
	id 1gohJJ-0000dS-L5; Wed, 30 Jan 2019 15:17:13 +1100
Received: from dave by discord.disaster.area with local (Exim 4.92-RC4)
	(envelope-from <david@fromorbit.com>)
	id 1gohJJ-0007eF-JI; Wed, 30 Jan 2019 15:17:13 +1100
From: Dave Chinner <david@fromorbit.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-xfs@vger.kernel.org
Cc: guro@fb.com,
	akpm@linux-foundation.org,
	mhocko@kernel.org,
	vdavydov.dev@gmail.com
Subject: [PATCH 1/2] Revert "mm: don't reclaim inodes with many attached pages"
Date: Wed, 30 Jan 2019 15:17:06 +1100
Message-Id: <20190130041707.27750-2-david@fromorbit.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190130041707.27750-1-david@fromorbit.com>
References: <20190130041707.27750-1-david@fromorbit.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Dave Chinner <dchinner@redhat.com>

This reverts commit a76cf1a474d7dbcd9336b5f5afb0162baa142cf0.

This change causes serious changes to page cache and inode cache
behaviour and balance, resulting in major performance regressions
when combining worklaods such as large file copies and kernel
compiles.

https://bugzilla.kernel.org/show_bug.cgi?id=202441

This change is a hack to work around the problems introduced by
changing how agressive shrinkers are on small caches in commit
172b06c32b94 ("mm: slowly shrink slabs with a relatively small
number of objects"). It creates more problems than it solves, wasn't
adequately reviewed or tested, so it needs to be reverted.

cc: <stable@vger.kernel.org>
Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/inode.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index 0cd47fe0dbe5..73432e64f874 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -730,11 +730,8 @@ static enum lru_status inode_lru_isolate(struct list_head *item,
 		return LRU_REMOVED;
 	}
 
-	/*
-	 * Recently referenced inodes and inodes with many attached pages
-	 * get one more pass.
-	 */
-	if (inode->i_state & I_REFERENCED || inode->i_data.nrpages > 1) {
+	/* recently referenced inodes get one more pass */
+	if (inode->i_state & I_REFERENCED) {
 		inode->i_state &= ~I_REFERENCED;
 		spin_unlock(&inode->i_lock);
 		return LRU_ROTATE;
-- 
2.20.1


Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8579C07542
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 11:53:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7FFD920883
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 11:53:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="DoCDRXYe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7FFD920883
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 123226B0279; Mon, 27 May 2019 07:53:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0D3DD6B027A; Mon, 27 May 2019 07:53:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB8AD6B027B; Mon, 27 May 2019 07:53:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id B22106B0279
	for <linux-mm@kvack.org>; Mon, 27 May 2019 07:53:29 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 205so6672601pfx.2
        for <linux-mm@kvack.org>; Mon, 27 May 2019 04:53:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=6hNHcE4oGqFxwrfpSxXRKzyk8c9yiV7fnMbtPM3g9Wc=;
        b=K+RlRtUysDWfuuseXoNUk/SdA2E8RJSXLR7dnUz877mmUcuxUKqESZ6rpB3C7e0ANF
         N2MAJdLeMarHbMVFVhA6G5lOleJbDDPTRtfnCqhthIBnHIFruSdfSPGr8dJO6pq95KyG
         LKbIoiqJmqdBLTySuB6Cl+ZlTW/bxHTm9NlCyMqPLTFYjW8b1kEp5KOW6uzjmghXSjsp
         oLnIkT3SEmvD1nEoZ2UIGjsRqSfWoumaJ+DwojLLcbGerDgThUQV8gULBhd54qInN0UP
         YeftniHsFch0eVFDxXQ5G98GqVK6xNvUqrAlJuShaJW/lSzzsyHtLQ/L9rIDYIL7Rhj5
         8ITA==
X-Gm-Message-State: APjAAAWv9l0lGJbRLi3AGl7JCI7aTVxkwzrirNKl6bwsOu3XuCHJmI5u
	kLDUqAc9zkxMNTwEC20BsHkdGQAYIG+HBxOSsnQvYnWSXjEZExz4KNPwvdNZwkKOerrOfXpukqC
	avjg7JWmk+wsXIaFlogPZQZZJa7wPdLo12Huf8ULYUbfd8TyR9zY5cvzLDzsJNNJe1Q==
X-Received: by 2002:a17:90b:d97:: with SMTP id bg23mr31213671pjb.87.1558958009377;
        Mon, 27 May 2019 04:53:29 -0700 (PDT)
X-Received: by 2002:a17:90b:d97:: with SMTP id bg23mr31213609pjb.87.1558958008234;
        Mon, 27 May 2019 04:53:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558958008; cv=none;
        d=google.com; s=arc-20160816;
        b=Ww2URthC7POzTMCNHf+Yv2yNq8XqXC3sx7wzwvaXjuKN27FnjJ74mws/9biPEyOe2O
         3uKwiwAkyFgt/6eDnwYzZ72wg1J/nK625LJRSHshauNjAyTBUy4bA++8cBpS2mjSlUMl
         gZICHc8on2RoEPyLONVQugVw6w7nb0A+U62LFRgEhSkdxjLNnW7iNbS8SKhfH5Z0CcdC
         A0xBCdFgK2/T7qWoTvxPEqExdpQIIzXYG0iJQjCXgt4conbCuhHN2Morho7do/K6TfZZ
         9i7mVVyoaKPu+Z1dMra1YyR1IOxpDa+M3kAzlKXe9ZrJKI4RyAOzu7krtTcHf0xqwy6i
         nByw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=6hNHcE4oGqFxwrfpSxXRKzyk8c9yiV7fnMbtPM3g9Wc=;
        b=YM2xC36CUfPWOZObVYctvIhA++6ZIFpt0dyYAaBSj0UpJWdJkMgwa0OM7OtO6JFa8P
         1bO6wEW3UJ5JkxyDqBBX+M5PfxxpwP8mHM9cl5ydEOUnAYPfd8TU6f7vbr37mvxHxFok
         IqnyRuyzOYkSpU+KMurYoIsRHzDrKi1UwbHnvzT2XkExixKboR2m2MiCEW0wYaQrdeby
         BqgU6ZeS16a8Ox3RsPp8toffbESrdy4ClfW5aTeWQoudyJpCDBHVlYxgcJh5bFFJQKx5
         yRkzbUOPiWZXsVBSk0p4Sf6CzrO+peVK6mYSkKirT6yciyB7QLtedwj8PwLF2gTpeJG2
         wsIw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=DoCDRXYe;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m4sor12371147pjs.16.2019.05.27.04.53.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 May 2019 04:53:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=DoCDRXYe;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=6hNHcE4oGqFxwrfpSxXRKzyk8c9yiV7fnMbtPM3g9Wc=;
        b=DoCDRXYe1dxPitPJWeBaPbykZRlApwkFZ1D8nxrIa660U0HSFp8r7lFHNci3aS6Rzh
         +RsmyRGs4tLIRriV/yMTxCmidgXbp5VKcKux4ThLUFWh3NgcwV+I/JFk1utUKJCVnmei
         HvWh+QFpcL3ld8ukLgFX38RcNhgXQ0xADyMTO9Z4DpS6WRPcIuYpkWSbpJoQ1vHPZ6yW
         KQZk7hSX70iak6ZgdFaMBglo3MpozNi9YdJ8MqEcttu3aCaH+CNA5BNRtdNKRAkeM2Ue
         17jjF1qYJiu8RmuENxZ0UpV1Jx23Ste2mvyk4mtZp++Bo3k9sTbf5avOgEeKkMEDbn88
         h5Vg==
X-Google-Smtp-Source: APXvYqwEhV0Swghh+z3ThQ7hRC6suR0VWsLJFlE6Fb+IZE0SYYh92Ew2cnIvc3ADmrf18T4a9PS05Q==
X-Received: by 2002:a17:90a:9a89:: with SMTP id e9mr29786210pjp.110.1558958007989;
        Mon, 27 May 2019 04:53:27 -0700 (PDT)
Received: from localhost.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id e24sm9797738pgl.94.2019.05.27.04.53.25
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 04:53:27 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: mhocko@suse.com,
	akpm@linux-foundation.org
Cc: linux-mm@kvack.org,
	shaoyafang@didiglobal.com,
	Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH v2 3/3] mm/vmscan: shrink slab in node reclaim
Date: Mon, 27 May 2019 19:52:54 +0800
Message-Id: <1558957974-23341-4-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1558957974-23341-1-git-send-email-laoar.shao@gmail.com>
References: <1558957974-23341-1-git-send-email-laoar.shao@gmail.com>
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
index e0c5669..c624f59 100644
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
+			.priority = sc.priority,
+		};
+
+		do {
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


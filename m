Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5190C282CD
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 04:17:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3F7CC21852
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 04:17:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3F7CC21852
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 908A78E0002; Tue, 29 Jan 2019 23:17:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8B6838E0001; Tue, 29 Jan 2019 23:17:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7CC4D8E0002; Tue, 29 Jan 2019 23:17:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3CB978E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 23:17:18 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id l9so15881940plt.7
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 20:17:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=W1FE2bpb5OpVzPkW6sAIQNI2BbpKiJHL6X2rHy29RYg=;
        b=raWotJxUzPBIJZo7QSDTVDdatEJZjvzJgUeP0puqX0gByY2WjZzBKIRpASSKH/N5WN
         T33qW99+fQ+lmIF73OsDzL5qyhDHriEmD1aERih5pz4mwu0u3q8MfD1SbzCSsbFUZg6P
         chIzIpxnQ/bOSGN2NFTQSgjpOe/2g6EyfpabebXBQylJvjDa+rlEGRg16caXe9Nowek1
         wdTpByuE90m80ujZpB1tm5IjzQMkoXoiqFmRnnD9TFtpt0cq7loUwxstl/izO9/cr+UY
         xupXzY/ceG3ouvwNDHKNNmQGDf+u1goxYGpmBvD+lK+sVKhgB+JjzjbMRhNMfQiTk7qy
         R81A==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 150.101.137.131 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: AJcUukcGqIyEg/9fkDl32WKhqMUFw45W1P4veKONpTZUhkUzhhieV1Ck
	vJne6FkU9TGSK91FtPEzdjl63XERchDwVPnWQ4iFQmlP1RTQY44lWCYyTaO+iBXcDlSwbUmcPWP
	IOwZqTomRsoL6p9eTF/YSUsr53YnJdjN61Q+8YNFlXwYrqVYKRUEi7GKMkU8UOtg=
X-Received: by 2002:a62:9719:: with SMTP id n25mr29949561pfe.240.1548821837723;
        Tue, 29 Jan 2019 20:17:17 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4SYeVPBC4ApvaNiU9ueOHskJ95r3ov4Y8HutwDui2L5ww7KOoboSz/ESBD6k6a21pli1Yx
X-Received: by 2002:a62:9719:: with SMTP id n25mr29949530pfe.240.1548821836872;
        Tue, 29 Jan 2019 20:17:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548821836; cv=none;
        d=google.com; s=arc-20160816;
        b=LFsAixJt90A2etWqrrQysouHi6VM00vlDpEcQ5Qz92D6JTaJRV3H7FCvgAMq7EfBBZ
         BDGFFHZ9lWZ4hkYLHHeBzGBpg4UYyDrLxbEnr6bDhlQCUMm4lqr+xKq+GTH3KMS3m6N3
         emXW2juFmqJMUhCtffqNbxoc+fMDIEz/PE13t6bdoKVEbUNJdjewjfLiGe+rfGJJIce7
         A1vEuEvlBdxq0hGgZHBt0Wme/3q22kPiLBkYmJnXzWv5QebuRvKF9jke5dno9iEaw9ut
         BVQfqzptjOrcQzAL9t66IyXPHRcjoyVEW4Wm+e/3zOy5gUdAmZGw6Dd0mPK+gxJN3szp
         6f9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=W1FE2bpb5OpVzPkW6sAIQNI2BbpKiJHL6X2rHy29RYg=;
        b=bmiBFuNkePyL1tJOGqGLxPPSFae4PUoYGJr2QNh8n79yeZ/+yjAdz2HY2G1tAISKQu
         GlV3fHdW0XFur5pCpoenKYTasdgpLMGEI70Pyl4PJQnWNpkN1gcn9XHvfs7p7N+f+daL
         pK/X165ea04hBryOcdzkUCcq+eg0kQeRZKs/pQrob4qQnza/l24jYAXaXGLmny19PoCn
         yGyf4nuPeGBn1VVMoAmceO6lJyHqHaDWVcKomNX3p5NU88NYvqDcQBKXC3erLO90Mll3
         TEBMfhYCuqvBSKwx0xW/+8SmpmdKmPpYHLNpmBILPrWaJq3dLnfDoLPAfViRaIijJSxj
         NAGA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 150.101.137.131 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id m7si489222pfc.118.2019.01.29.20.17.15
        for <linux-mm@kvack.org>;
        Tue, 29 Jan 2019 20:17:16 -0800 (PST)
Received-SPF: neutral (google.com: 150.101.137.131 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=150.101.137.131;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 150.101.137.131 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail07.adl2.internode.on.net with ESMTP; 30 Jan 2019 14:47:14 +1030
Received: from discord.disaster.area ([192.168.1.111])
	by dastard with esmtp (Exim 4.80)
	(envelope-from <david@fromorbit.com>)
	id 1gohJJ-0000dT-MN; Wed, 30 Jan 2019 15:17:13 +1100
Received: from dave by discord.disaster.area with local (Exim 4.92-RC4)
	(envelope-from <david@fromorbit.com>)
	id 1gohJJ-0007eI-Kc; Wed, 30 Jan 2019 15:17:13 +1100
From: Dave Chinner <david@fromorbit.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-xfs@vger.kernel.org
Cc: guro@fb.com,
	akpm@linux-foundation.org,
	mhocko@kernel.org,
	vdavydov.dev@gmail.com
Subject: [PATCH 2/2] Revert "mm: slowly shrink slabs with a relatively small number of objects"
Date: Wed, 30 Jan 2019 15:17:07 +1100
Message-Id: <20190130041707.27750-3-david@fromorbit.com>
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

This reverts commit 172b06c32b949759fe6313abec514bc4f15014f4.

This change changes the agressiveness of shrinker reclaim, causing
small cache and low priority reclaim to greatly increase
scanning pressure on small caches. As a result, light memory
pressure has a disproportionate affect on small caches, and causes
large caches to be reclaimed much faster than previously.

As a result, it greatly perturbs the delicate balance of the VFS
caches (dentry/inode vs file page cache) such that the inode/dentry
caches are reclaimed much, much faster than the page cache and this
drives us into several other caching imbalance related problems.

As such, this is a bad change and needs to be reverted.

[ Needs some massaging to retain the later seekless shrinker
modifications. ]

cc: <stable@vger.kernel.org>
Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 mm/vmscan.c | 10 ----------
 1 file changed, 10 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index a714c4f800e9..e979705bbf32 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -491,16 +491,6 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 		delta = freeable / 2;
 	}
 
-	/*
-	 * Make sure we apply some minimal pressure on default priority
-	 * even on small cgroups. Stale objects are not only consuming memory
-	 * by themselves, but can also hold a reference to a dying cgroup,
-	 * preventing it from being reclaimed. A dying cgroup with all
-	 * corresponding structures like per-cpu stats and kmem caches
-	 * can be really big, so it may lead to a significant waste of memory.
-	 */
-	delta = max_t(unsigned long long, delta, min(freeable, batch_size));
-
 	total_scan += delta;
 	if (total_scan < 0) {
 		pr_err("shrink_slab: %pF negative objects to delete nr=%ld\n",
-- 
2.20.1


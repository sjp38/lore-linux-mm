Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F283C32751
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 02:33:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 447A920693
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 02:33:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 447A920693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9AF458E000A; Wed, 31 Jul 2019 22:33:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9376C8E0001; Wed, 31 Jul 2019 22:33:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 84FC18E000A; Wed, 31 Jul 2019 22:33:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5115C8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 22:33:31 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 191so44618182pfy.20
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 19:33:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=+HMegXJqs63r9fNYwwecy8WW9ooPRF/60fsoRvsrbR0=;
        b=eNVpX7dcbu1drx3ZX1QKhsiFWu6opIeRCiLclXeECs9S9pklxAneD3g0SavTw0V/0+
         803MDswwLYTiYePPTHa3azoDeBPDhS+yLq4xzxSEDniVjDF5mPkJ6/WDZad6rircJuyY
         vrRGOLQYxzsFxTZCEBHz0P36L9iwuskkK0SYrxDdS78izOm8jFcrlmh13ATkgckxHQNe
         F0Bz0uDBfj09r5ziC3lP/tDC/prgXn6Q/URm4Yml6y1VEmsvYnP+ymR//3olvzGlVYAu
         UDSfxtlVYmN5RN7fN32TG9EiYdLXjJJdy9zRplXdxnU3yfXXtblfk/BoFEhGmFGuA9IS
         C6bw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAXRzc6UZH4STgvRrlnUvTRPAf3UNvmggPrOI5xMBV+FKuR2qjw1
	gZNi623b1Xc0dxZL2acqbq2pdLNHUKSMgBMVECzvdXF44zy88IgTew8NCphuaMD9TJ5GFgyQnOP
	jvogha3MsXDUMH8cbKiBwhiLJhMS4EfM6WtOBMYEXyNo9ewbSIHpwuDk7sJXATBw=
X-Received: by 2002:a63:d210:: with SMTP id a16mr5696845pgg.77.1564626810804;
        Wed, 31 Jul 2019 19:33:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw0H4TwdSQoRwfOqR0L8hjehCYkxe4CVIMOyT9nVYNkwH1eNpJWcnY5ttNrqYCzeFS63A6z
X-Received: by 2002:a63:d210:: with SMTP id a16mr5696795pgg.77.1564626809918;
        Wed, 31 Jul 2019 19:33:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564626809; cv=none;
        d=google.com; s=arc-20160816;
        b=WxpZM6ChDs05znAeVXpdHNGQapihvhkQ1KfvUAPWfHxAZM8QCe0qRcSWDthNgtPRDX
         2P/YYZC4hUSmVvTNwBuDIXz4I7Yeufd/RlfpJfHY1keWv+BFrJQ/JWmmjSJKK3Z93S5z
         RwPN8SO1y3KmvIkX/s7v/7+i1itciyl1aD6Tn2h2ycnRA7LhFg19IFg7gCqaDsiYCaoz
         HIYfksmRaeJKzXuEmXz1J0nXnRN7tt76bFc4XX2P0B07Iqxut1KahWL1HTGe5vhFqpv6
         lLFmrrcX6PGOQk2kxi+4g7+OhfBYIv3LbqiqxcF8TX5mUKQrob7x6VGxzTKfv1jKR/Tv
         hKCQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=+HMegXJqs63r9fNYwwecy8WW9ooPRF/60fsoRvsrbR0=;
        b=udoFYPOZHcc435P7rP2RxFIHEwh6iSSKUDpbcWycJBFFNAs2HtLhaSfog4Lw9/4GLo
         /tJr6fFTzKK+VUpDhbSsWesAW/tANmhb2i+DMqMHKPjdHZcRK8+Qa4CQ/4rExTNw9OF9
         KFE7ygnmNjYaFVV28kmknaeZPEBXwgjmailJ3tlEGEn69l52XXeM4FXspsBzMlEk4EXY
         S1MLGmy4jGjEE9d0L/JdFaCtq0ncZOgeLj1Sv2Efeh0EX4MXwQLobTKj7R9NaZzSnSnK
         9Nx97lw6pnDzBQqcwUAtOckfAYvDfVNwVhtZWFqlYUulYhU/sZ+nrjyAIX8++JpGQEGJ
         9c7w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail105.syd.optusnet.com.au (mail105.syd.optusnet.com.au. [211.29.132.249])
        by mx.google.com with ESMTP id u21si36009225pgn.290.2019.07.31.19.33.29
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 19:33:29 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.249;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-195-139-63.pa.nsw.optusnet.com.au [49.195.139.63])
	by mail105.syd.optusnet.com.au (Postfix) with ESMTPS id 86C32362348
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 12:33:28 +1000 (AEST)
Received: from discord.disaster.area ([192.168.253.110])
	by dread.disaster.area with esmtp (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1ht0eA-0003aY-Se; Thu, 01 Aug 2019 12:16:50 +1000
Received: from dave by discord.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1ht0fG-0001ko-QX; Thu, 01 Aug 2019 12:17:58 +1000
From: Dave Chinner <david@fromorbit.com>
To: linux-xfs@vger.kernel.org
Cc: linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: [PATCH 06/24] mm: reclaim_state records pages reclaimed, not slabs
Date: Thu,  1 Aug 2019 12:17:34 +1000
Message-Id: <20190801021752.4986-7-david@fromorbit.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190801021752.4986-1-david@fromorbit.com>
References: <20190801021752.4986-1-david@fromorbit.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=FNpr/6gs c=1 sm=1 tr=0 cx=a_idp_d
	a=fNT+DnnR6FjB+3sUuX8HHA==:117 a=fNT+DnnR6FjB+3sUuX8HHA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=FmdZ9Uzk2mMA:10 a=20KFwNOVAAAA:8
	a=pP-XxJAliQGaY3BKeNcA:9
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Dave Chinner <dchinner@redhat.com>

Name change only, no logic changes.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/inode.c           | 2 +-
 include/linux/swap.h | 5 +++--
 mm/slab.c            | 2 +-
 mm/slob.c            | 2 +-
 mm/slub.c            | 2 +-
 mm/vmscan.c          | 4 ++--
 6 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index 0f1e3b563c47..8c70f0643218 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -762,7 +762,7 @@ static enum lru_status inode_lru_isolate(struct list_head *item,
 			else
 				__count_vm_events(PGINODESTEAL, reap);
 			if (current->reclaim_state)
-				current->reclaim_state->reclaimed_slab += reap;
+				current->reclaim_state->reclaimed_pages += reap;
 		}
 		iput(inode);
 		spin_lock(lru_lock);
diff --git a/include/linux/swap.h b/include/linux/swap.h
index de2c67a33b7e..978e6cd5c05a 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -126,10 +126,11 @@ union swap_header {
 
 /*
  * current->reclaim_state points to one of these when a task is running
- * memory reclaim
+ * memory reclaim. It is typically used by shrinkers to return reclaim
+ * information back to the main vmscan loop.
  */
 struct reclaim_state {
-	unsigned long reclaimed_slab;
+	unsigned long	reclaimed_pages;	/* pages freed by shrinkers */
 };
 
 #ifdef __KERNEL__
diff --git a/mm/slab.c b/mm/slab.c
index 9df370558e5d..abc97e340f6d 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1396,7 +1396,7 @@ static void kmem_freepages(struct kmem_cache *cachep, struct page *page)
 	page->mapping = NULL;
 
 	if (current->reclaim_state)
-		current->reclaim_state->reclaimed_slab += 1 << order;
+		current->reclaim_state->reclaimed_pages += 1 << order;
 	uncharge_slab_page(page, order, cachep);
 	__free_pages(page, order);
 }
diff --git a/mm/slob.c b/mm/slob.c
index 7f421d0ca9ab..c46ce297805e 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -208,7 +208,7 @@ static void *slob_new_pages(gfp_t gfp, int order, int node)
 static void slob_free_pages(void *b, int order)
 {
 	if (current->reclaim_state)
-		current->reclaim_state->reclaimed_slab += 1 << order;
+		current->reclaim_state->reclaimed_pages += 1 << order;
 	free_pages((unsigned long)b, order);
 }
 
diff --git a/mm/slub.c b/mm/slub.c
index e6c030e47364..a3e4bc62383b 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1743,7 +1743,7 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
 
 	page->mapping = NULL;
 	if (current->reclaim_state)
-		current->reclaim_state->reclaimed_slab += pages;
+		current->reclaim_state->reclaimed_pages += pages;
 	uncharge_slab_page(page, order, s);
 	__free_pages(page, order);
 }
diff --git a/mm/vmscan.c b/mm/vmscan.c
index d5ce26b4d49d..231ddcfcd046 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2765,8 +2765,8 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 		} while ((memcg = mem_cgroup_iter(root, memcg, &reclaim)));
 
 		if (reclaim_state) {
-			sc->nr_reclaimed += reclaim_state->reclaimed_slab;
-			reclaim_state->reclaimed_slab = 0;
+			sc->nr_reclaimed += reclaim_state->reclaimed_pages;
+			reclaim_state->reclaimed_pages = 0;
 		}
 
 		/* Record the subtree's reclaim efficiency */
-- 
2.22.0


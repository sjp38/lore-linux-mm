Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 40B31C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 15:07:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 925B92082E
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 15:07:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 925B92082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 401466B029D; Wed, 10 Apr 2019 11:07:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B08F6B029E; Wed, 10 Apr 2019 11:07:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2EE6A6B029F; Wed, 10 Apr 2019 11:07:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id BC6696B029D
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 11:07:11 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id v20so567594ljk.7
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 08:07:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=RbuphLDB+mN5EpFYMulzUBA0h0k4c65mv71IO28HzLA=;
        b=eTLoyUf47V0SdfE5BVZN//55wrEWMXG/AodNspHnCYL3NCb0JiUhhIj7tMvfcEJDVV
         wrui7he5XazbSwoSZMowG8vLyFUN95hKOkop/YO2BL1Nsh8bUW5Fj738GGxFZSc/eJPr
         l2sPIqFAd6w6C0nsIQ4Fj6XT9NHTktADSVHwn7WdtrZK9iqwXw+VnlTr2S9X3jefz/SQ
         o3LNftJRLwgku6bRCSge70jJ4ooboOwT/IJSv3iyAz/2+vmgUNWVKgKN6v6s7ztb1Kos
         ieEMsgFXqzgC2VDwTJrt2hxJYQe3EBUAm7iDP3qs7pGGLvARS05d8nxyHcoN57ygdQnD
         GxpQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAW3Gmfhz/SPQ6tDjT0A4wAjnJFlj5X88j1wEcRmhfJxWGUB+lPy
	hr7Y7BvEgaFWoLFXEFAdMxfAMghf/f76KJjZ2Odr31a/z1vUXJMr2Ih/6MlOC7bleS0mgzzgIK0
	+VrKWUmr1vGrpnFkzZCk8D6TRb5NEj48nCsHUJqRYEtKklnb/M2Qiisvd7t0imfWIIw==
X-Received: by 2002:ac2:4554:: with SMTP id j20mr24770003lfm.112.1554908830936;
        Wed, 10 Apr 2019 08:07:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzS8agfbfK47B2Xq4nrSO8w+r0GBQ3xmcyUOSPmUsopJD5LT+ah8cF0TO6wyYZYvAtC34mi
X-Received: by 2002:ac2:4554:: with SMTP id j20mr24769946lfm.112.1554908829888;
        Wed, 10 Apr 2019 08:07:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554908829; cv=none;
        d=google.com; s=arc-20160816;
        b=R1tyA+22+Nx9IpOXrDnOFs55M7pGLHZALmJolJ5egiNc6KCCY8wmtXNbFfGbQbBIz/
         Ov6gCLUf73NzmIlx5wAqFZSRp2UBeO0un9zLIoPJSCMI4nOFFrEIQOmMR3j2zoyvTOfs
         EmJi7fBj5pzk6JDjcvduFQwxc8fM74cuP24tR0WM/mrQ0kKsML8fGp1w39U6Van94r8Q
         fK9lsOmhzHH7rieZExv9Vn+Z8d736D9cvbmbWJBBHZivnzWvJzFdmHXn/HyOXKBQT87Y
         hnULbNfwZtV6i8J5jWqh025vhGtcCg//1fWjnqiS1hU1rbwN4iquxXyhfwnVJt+A5biq
         z1jw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :to:from:subject;
        bh=RbuphLDB+mN5EpFYMulzUBA0h0k4c65mv71IO28HzLA=;
        b=j8Fa8smca/4ZAe7mp8omRIITEDa+FSbHL2A85kyMpORFUVCswBOZtpmQgBYo7f1wdT
         Ucsvk/I1VszhE8JQm5ZlCeBm7h2yjlX/ivqL5Z72uCzEBFmYVXHKH2AvMz6RWhp+BnaH
         Ej639Yl3OCWg2dKjjNUMR64aZgsDfFxCIA3tPLflfK5i+CxZkNpP4oDObm09KfDHXhPE
         v3RFG7VcSmVzkfcbUBc9O4SJiqPoSSHculKt84IXD9RP3GI9BdiGkxE196FXKqAS9aRi
         yOY5ZN3eofvf08+JkXCH1epaMjNokaDLHElHyyJB14FwxSDp88NUGbDhR64uB4muLK28
         cwEA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id r15si29804954lji.60.2019.04.10.08.07.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 08:07:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169] (helo=localhost.localdomain)
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hEEoc-0006KG-0W; Wed, 10 Apr 2019 18:07:06 +0300
Subject: [PATCH] mm: Simplify shrink_inactive_list()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
To: akpm@linux-foundation.org, mhocko@suse.com, hannes@cmpxchg.org,
 dave@stgolabs.net, ktkhai@virtuozzo.com, linux-mm@kvack.org
Date: Wed, 10 Apr 2019 18:07:04 +0300
Message-ID: <155490878845.17489.11907324308110282086.stgit@localhost.localdomain>
User-Agent: StGit/0.18
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This merges together duplicating patterns of code.
Changes in enum vm_event_item is made to underline
that *_DIRECT and *_KSWAPD must differ by 1.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 include/linux/vm_event_item.h |    4 ++--
 mm/vmscan.c                   |   31 +++++++++----------------------
 2 files changed, 11 insertions(+), 24 deletions(-)

diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 47a3441cf4c4..8f1403e692a2 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -31,9 +31,9 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		PGLAZYFREED,
 		PGREFILL,
 		PGSTEAL_KSWAPD,
-		PGSTEAL_DIRECT,
+		PGSTEAL_DIRECT = PGSTEAL_KSWAPD + 1,
 		PGSCAN_KSWAPD,
-		PGSCAN_DIRECT,
+		PGSCAN_DIRECT = PGSCAN_KSWAPD + 1,
 		PGSCAN_DIRECT_THROTTLE,
 #ifdef CONFIG_NUMA
 		PGSCAN_ZONE_RECLAIM_FAILED,
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 836b28913bd7..f8ac0825d1c7 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1907,6 +1907,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	unsigned long nr_taken;
 	struct reclaim_stat stat;
 	int file = is_file_lru(lru);
+	int is_direct = !current_is_kswapd();
 	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
 	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
 	bool stalled = false;
@@ -1934,17 +1935,10 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, nr_taken);
 	reclaim_stat->recent_scanned[file] += nr_taken;
 
-	if (current_is_kswapd()) {
-		if (global_reclaim(sc))
-			__count_vm_events(PGSCAN_KSWAPD, nr_scanned);
-		count_memcg_events(lruvec_memcg(lruvec), PGSCAN_KSWAPD,
-				   nr_scanned);
-	} else {
-		if (global_reclaim(sc))
-			__count_vm_events(PGSCAN_DIRECT, nr_scanned);
-		count_memcg_events(lruvec_memcg(lruvec), PGSCAN_DIRECT,
-				   nr_scanned);
-	}
+	if (global_reclaim(sc))
+		__count_vm_events(PGSCAN_KSWAPD + is_direct, nr_scanned);
+	__count_memcg_events(lruvec_memcg(lruvec), PGSCAN_KSWAPD + is_direct,
+			     nr_scanned);
 	spin_unlock_irq(&pgdat->lru_lock);
 
 	if (nr_taken == 0)
@@ -1955,17 +1949,10 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 
 	spin_lock_irq(&pgdat->lru_lock);
 
-	if (current_is_kswapd()) {
-		if (global_reclaim(sc))
-			__count_vm_events(PGSTEAL_KSWAPD, nr_reclaimed);
-		count_memcg_events(lruvec_memcg(lruvec), PGSTEAL_KSWAPD,
-				   nr_reclaimed);
-	} else {
-		if (global_reclaim(sc))
-			__count_vm_events(PGSTEAL_DIRECT, nr_reclaimed);
-		count_memcg_events(lruvec_memcg(lruvec), PGSTEAL_DIRECT,
-				   nr_reclaimed);
-	}
+	if (global_reclaim(sc))
+		__count_vm_events(PGSTEAL_KSWAPD + is_direct, nr_reclaimed);
+	__count_memcg_events(lruvec_memcg(lruvec), PGSTEAL_KSWAPD + is_direct,
+			     nr_reclaimed);
 	reclaim_stat->recent_rotated[0] = stat.nr_activate[0];
 	reclaim_stat->recent_rotated[1] = stat.nr_activate[1];
 


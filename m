Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D306DC10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 10:56:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 900622084D
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 10:56:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 900622084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2DC096B000C; Fri, 12 Apr 2019 06:56:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 28C1C6B0010; Fri, 12 Apr 2019 06:56:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1C9336B026B; Fri, 12 Apr 2019 06:56:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id AF31E6B000C
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 06:56:01 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id v18so2123350lja.21
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 03:56:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=Ae6lZrPUyhDwHKxzw3edjlJ+RmrQHGqCjULBPBcGtGc=;
        b=H8O7HQJW4Ihe+ra2H7vYlWohqACWZVlHw4qsJ54kyjjkvGBkhoJ+/z2D4sTcqDSfbK
         ANWWUUTwbez7400nYMBIoRmrXND3ccidFO2EX9hpS0Y4gFxIo6PqRD0ioYAfx6X/NMQt
         mrPbcX2AmZuptHNly9NEBPAuDBIDF7wovuouuVBhx2EuGTc0xe8K8+rYQsxC5JFsnPgd
         sYV0QcRAE7gbaFAsu6aq4uN4UuXKU5sP7bEW8bYwaDUrp2qnIrLptbZE8pchdZ8qr2lj
         aJK5lQS1rU+DSw/wENPEzXFX0Ht0dUYN4qq2699X4/r6Win8FVGjI5B0wCfuZWzbE200
         9PWw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAVk4MbpZeGDnQausqks0fwCr6Wh1xEqD5q+rvDYWilx9qeDDGUx
	kiBpkexCJfHVtX9ElikaubFyIHogIped9YwW9eXH476ZXWKEViEPZvqp6/+orFIBQup5/68rRGw
	kh14yJQW9xMpQsEce23D42X8/fKGhLZI9tVwdKVDhQQi/ldLm0FuyPn8HHvQdPlZU3g==
X-Received: by 2002:a19:48c9:: with SMTP id v192mr11090985lfa.136.1555066561104;
        Fri, 12 Apr 2019 03:56:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxKoHz006+JTJamtw0F1wgv6n4L/9oz65S+XZCBpfct/R8/biwNIPx1XZIKoZ5tigD7ANpR
X-Received: by 2002:a19:48c9:: with SMTP id v192mr11090925lfa.136.1555066560279;
        Fri, 12 Apr 2019 03:56:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555066560; cv=none;
        d=google.com; s=arc-20160816;
        b=CO6ixSrttBO+41rmqJJc2HeWS9GIzQWaTDrA5sRxdLu+VBIFNrnhQzQ3n6saLzTLce
         KFOvDogV1WraUrEyPFjxhMGp8dtuzgPsyi0TX1JYu9tAdoCQicRKLYEB32qIkIp9YzM9
         iqC6RjhSA5V3zKU/eCgaVd740Eu0NIECtXTeoHXk6cvpNjAojfyfQkXQAbnBgB8SrKNy
         zYZUIbMU543oiCzH4O4Q5UdQKa3Np+ZHcYIKGs0+vT/lDpTHw9F7HJrmxSCiaC9U1zNi
         VZ1wNpHuGM5up7iTd/N+ADwUBL+oprA4Yx2yAr832UJeuODz8w+NfMcg5PmQXLKjCHPl
         Wnjg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=Ae6lZrPUyhDwHKxzw3edjlJ+RmrQHGqCjULBPBcGtGc=;
        b=WrEGvk4T2M207ooalNSM67ZOSsNg7ojEvnhQKHuakwaHJQYKglwzTCvOpJ84hZ9tOL
         1wxXrwl5YPOY4VJ+wOJgeQll+YQSvOC6J3JkYg1JPGcjfZpK5mczqkH9Db6YjRSpohNH
         7COcLbe4gLrdftqHh33iXFQ5xO1woH/R/JjFb906lKRwf5shX75O33v9iP3zFmycMdNm
         iGEzBzBh2dawqMr7l34XfSAJwVEfWkjPQXcJiE2cuLH3YXlvO4II5+7hwWOC0zk3b5AK
         hKy2T5hmlfqNkjQ6xsn9jWDDbJ2Ks8+3FZE4PZTvJ/0sRY5cjn3e4A19/yAf5Lvobwg7
         sX0g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id 12si31305022ljv.217.2019.04.12.03.56.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Apr 2019 03:56:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hEtqh-0007Ed-NC; Fri, 12 Apr 2019 13:55:59 +0300
Subject: [PATCH v2] mm: Simplify shrink_inactive_list()
To: Baoquan He <bhe@redhat.com>, Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, hannes@cmpxchg.org,
 dave@stgolabs.net, linux-mm@kvack.org
References: <155490878845.17489.11907324308110282086.stgit@localhost.localdomain>
 <20190411221310.sz5jtsb563wlaj3v@ca-dmjordan1.us.oracle.com>
 <20190412000547.GB3856@localhost.localdomain>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <26e570cd-dbee-575c-3a23-ff8798de77dc@virtuozzo.com>
Date: Fri, 12 Apr 2019 13:55:59 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190412000547.GB3856@localhost.localdomain>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This merges together duplicating patterns of code.
Also, replace count_memcg_events() with its
irq-careless namesake.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>

v2: Introduce local variable.
---
 mm/vmscan.c |   31 +++++++++----------------------
 1 file changed, 9 insertions(+), 22 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 836b28913bd7..d96efff59a11 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1907,6 +1907,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	unsigned long nr_taken;
 	struct reclaim_stat stat;
 	int file = is_file_lru(lru);
+	enum vm_event_item item;
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
+	item = current_is_kswapd() ? PGSCAN_KSWAPD : PGSCAN_DIRECT;
+	if (global_reclaim(sc))
+		__count_vm_events(item, nr_scanned);
+	__count_memcg_events(lruvec_memcg(lruvec), item, nr_scanned);
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
+	item = current_is_kswapd() ? PGSTEAL_KSWAPD : PGSTEAL_DIRECT;
+	if (global_reclaim(sc))
+		__count_vm_events(item, nr_reclaimed);
+	__count_memcg_events(lruvec_memcg(lruvec), item, nr_reclaimed);
 	reclaim_stat->recent_rotated[0] = stat.nr_activate[0];
 	reclaim_stat->recent_rotated[1] = stat.nr_activate[1];
 


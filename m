Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E675C10F04
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 10:35:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D7F2F2229F
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 10:35:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D7F2F2229F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7D03E8E0004; Thu, 14 Feb 2019 05:35:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 757EC8E0001; Thu, 14 Feb 2019 05:35:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6481C8E0004; Thu, 14 Feb 2019 05:35:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id ECE9A8E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 05:35:33 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id p86-v6so1493725lja.2
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 02:35:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:date:message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=mMg/AVqtFcnKMYwe/4ygFWWdKEl+mZxjuAXpdgR0ndU=;
        b=Y4M7aZFLX6GH+CQTWasrshtkDGXbcn+oDU2OWqnLCj+4LefyYhgLbKErDtxYWnLk4h
         K/a0Y/av59zDabMOLM8j6kwPN263S3deDqwWB2GmqM9mVguSUOV5Du7fYMFmpp2FwC3J
         YA6mIrrgLpyUNjNyBUv4NYD5Q4Y067fvfPYDmW+w5I22LJp/phwlfeyRnDoCrbIMQwUb
         vJBg6TntioE2BJc2/0sZgY2Kksycge2TB7xiWr3cDtYNtdnz/HWoREqKl7OgoH2fbLRx
         ikSieI0UMjlN1VUUWFw6idntb8jlcShYevoOUHbBlikoocRhETMz7rNEBY1tZkM3YZg1
         Xwjw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: AHQUAuZdjBnaSSvDhbXY1KL0qxt4HxluJA2pIUv5cpw0YOfQe4ny6qhL
	H5yDVcfa3yTAYtQ08+NhVsflEK1t4IT4YQabbiFJ5e2PXeQokLw56NO0V41Ec1dx4e5kryWwOYI
	yP5de9s55+d4qtd86Ut7cN0JPSETpFrV+fXaXPknZiAwRHEFBd9LqIlSj1Ko0rnbjIA==
X-Received: by 2002:a2e:81a:: with SMTP id 26-v6mr1940659lji.14.1550140533374;
        Thu, 14 Feb 2019 02:35:33 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYrdfmnto5tW1APtQL+l+SEwD7+xSc8IQe7dqZ7YAoNtLTq3lCgx7FVP+jzXta73FMygUBc
X-Received: by 2002:a2e:81a:: with SMTP id 26-v6mr1940618lji.14.1550140532439;
        Thu, 14 Feb 2019 02:35:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550140532; cv=none;
        d=google.com; s=arc-20160816;
        b=cWuStyvWoUn7JQtaj0DOLvdwXwolZq0TDT+OClIXtPuvBVjFegxVkyR9mu4Db2luXV
         8MNxJoYbTTDjphaj2Mw6VpWitGouWD7GjiR2KJaNAwIL1TADZAGlbcInswyr2dSo4tvh
         EYxOeScz8FwwkSpEpMttMMVNz24rJpsPDk/cNf2mczIdCScLA6lTupaYxPf3vwShtA7Q
         id9fKzFtpeDBTZRasbhf+0ES3Knr2jpVmPsdWbyrOiJiI7uBGc0rEf9j+W3FO8U/Ry8h
         ZQFtjaWRH+4fMDK1gNngyukjwHUHFyF3VrjJP20UoowxMILSGVeWSErMbGthaokPM3Tg
         hjyQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:to:from:subject;
        bh=mMg/AVqtFcnKMYwe/4ygFWWdKEl+mZxjuAXpdgR0ndU=;
        b=0NY7a7bROsJoFqG2YIqOXp88CAPeLxVNgenZVz3r2MSKXBrQh9iRrIkBDaxo7vL/L1
         sdxiY74X2a8Y7XlbPRSdo45dkBYDOBpKBf93dE5EDqszSjaDSXdeD7QpauXETxgdWN0M
         780LrnzkjO/C1pnLOL8Pkz4pyR0Ib7aqRso2w9ki/oEtgMThgTTzWDZiC/FP+xE50fZf
         /aCHuUuyj92gKjSKhhRodurLfoywqd8yPnvoik/FlZ45yb64O3jyCwj7LGsOIf6Wm5O4
         aOiGap0cRVXhlqhxMG+8fmhsq9hiiu/QGqyHAjQP8FSqVP1DBf63gQ4x9g6CuZ94ex4+
         WbMg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id 9-v6si1720603lji.166.2019.02.14.02.35.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 02:35:32 -0800 (PST)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169] (helo=localhost.localdomain)
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1guEMY-00053G-Sm; Thu, 14 Feb 2019 13:35:26 +0300
Subject: [PATCH v2 2/4] mm: Move nr_deactivate accounting to
 shrink_active_list()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
To: akpm@linux-foundation.org, daniel.m.jordan@oracle.com, mhocko@suse.com,
 ktkhai@virtuozzo.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Date: Thu, 14 Feb 2019 13:35:26 +0300
Message-ID: <155014052676.28944.12905432053578390912.stgit@localhost.localdomain>
In-Reply-To: <155014039859.28944.1726860521114076369.stgit@localhost.localdomain>
References: <155014039859.28944.1726860521114076369.stgit@localhost.localdomain>
User-Agent: StGit/0.18
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We know which LRU is not active.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 mm/vmscan.c |   10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 84542004a277..8d7d55e71511 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2040,12 +2040,6 @@ static unsigned move_active_pages_to_lru(struct lruvec *lruvec,
 		}
 	}
 
-	if (!is_active_lru(lru)) {
-		__count_vm_events(PGDEACTIVATE, nr_moved);
-		count_memcg_events(lruvec_memcg(lruvec), PGDEACTIVATE,
-				   nr_moved);
-	}
-
 	return nr_moved;
 }
 
@@ -2137,6 +2131,10 @@ static void shrink_active_list(unsigned long nr_to_scan,
 
 	nr_activate = move_active_pages_to_lru(lruvec, &l_active, &l_hold, lru);
 	nr_deactivate = move_active_pages_to_lru(lruvec, &l_inactive, &l_hold, lru - LRU_ACTIVE);
+
+	__count_vm_events(PGDEACTIVATE, nr_deactivate);
+	__count_memcg_events(lruvec_memcg(lruvec), PGDEACTIVATE, nr_deactivate);
+
 	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, -nr_taken);
 	spin_unlock_irq(&pgdat->lru_lock);
 


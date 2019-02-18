Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CF176C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 08:21:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 95A85218AD
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 08:21:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 95A85218AD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 428D88E0007; Mon, 18 Feb 2019 03:21:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3AEFA8E0001; Mon, 18 Feb 2019 03:21:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 251698E0007; Mon, 18 Feb 2019 03:21:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id A73E88E0001
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 03:21:13 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id p86-v6so3973614lja.2
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 00:21:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:date:message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=tdC0mzs80WGKatTqNZ8P/CEriCSP6hwO50kzHXGiqkM=;
        b=PQJrYAxpEyvaK+goALji35Kl3cexoWAtpLY054Rp2UWu0fFZ9aDHN0w2pCgVKTXEbv
         8rLP0YnPbDGjqBPK602vvLOVhi1TeC0bVcqmEyl3knBIgh+kC58D7T2NzTZberPyDinC
         sl+osh8bFJ97N9KzboDZXYONcfvrg4qkbS9aHmZNnPRPncVt9Hsiz48TYj+3+rBFo3Sd
         dB7EHbf74oRvIs9XxLnhPCPlw6YpgMzr8rZb1n0QMex3HEY4Mxq3S8W97UxcKO7c381n
         DQABcOwLJsz+ndT1CrOpCLit2Eo4QGJPQGIttTtLc3uSfNUYpEI5hUB/Ui9nMTgNdbfr
         WZ0g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: AHQUAuYnkQNv0cVS1K0OnedrI5/isWNLoia88FcigrdQX7fRv6N9XN4h
	kXQZ+XFT5qYqGd+pPnRGOQ2ty91uh/0s8xuwmJwe52ExwbouFF6A1IZRot/xMag/UlPGP0KqjjW
	ydBWc85YZsMYKtXWYXS1Hs4Z7sR7Ty83cxT45jhZjbu3+AX3v6edA3fbPQAKpDqD6ww==
X-Received: by 2002:a19:645e:: with SMTP id b30mr12965474lfj.15.1550478072978;
        Mon, 18 Feb 2019 00:21:12 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZe6hk6GLToPRmftmAI3ooFDbtsLLl6uxh+cVxaiyI9opoaN7WtuO0TtF5b5JhnDZ1B8ZlT
X-Received: by 2002:a19:645e:: with SMTP id b30mr12965433lfj.15.1550478071833;
        Mon, 18 Feb 2019 00:21:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550478071; cv=none;
        d=google.com; s=arc-20160816;
        b=gAVwhCDS766qyvmLHzh5X4Vchd9l1PGKi2k1B7N3OMJF8zlK+yMAShrhETsuNuWNVk
         Lr9tLiD1xri6fJgMLwfOH7TJ1jeD4159IUtC7wlHl5fsK72Dl56B2OT+1wTl8eZDsALc
         rrRGaleRP/pqML8YUWdSQekd09neT12U79EARgckTaiZZNN/tyVkavrPLzYVaWH4dDRO
         wX99MC+XuCVsTwRQ//oktaJCZXlnjPjCp6zCT34+WrJU2zrvklfTrQiXAB0NEKWoIFHT
         iQ4T8mpd+QldSOlNCugLLMIuR3xuGC7Wt5KnpsbpWvQUfAMDOz3VWN7Xzr1hrW7bBTiJ
         sAUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:to:from:subject;
        bh=tdC0mzs80WGKatTqNZ8P/CEriCSP6hwO50kzHXGiqkM=;
        b=w2Z5Zpu58TTfJ6IxOhScWijlHNqYTPq0jjYfPKk17iOtLPOaWYcRHz7C3ZMwOJmg1S
         0yL0PbybVQtjl+Kc0RTladTY8Ji07YnAnlvSvrSMKU9hUFmrFLY7d8WKL1KCym/W2pO3
         BNWLegauWvimQFduYBCKe/mUSEh+l70nJ+s/TrEyI4wA9sRMUrlIBEJP+n7alhn5azok
         tTb604MUw1JSiP1rVgHXtQkmkes2pYl9cDqAErnUAcK3qAauIippuJBmiTjh11c4x4m6
         8WG/0ug9M+0W3/thhKUhVJwJ1Zcj1HRC+K1z7mXZv8Yb9Gdxi4Mbc4c2Bx7Eex1mMrs2
         pCJg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id j18si2410743lji.101.2019.02.18.00.21.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 00:21:11 -0800 (PST)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169] (helo=localhost.localdomain)
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1gveAe-0007pn-M3; Mon, 18 Feb 2019 11:21:00 +0300
Subject: [PATCH v3 3/4] mm: Remove pages_to_free argument of
 move_active_pages_to_lru()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
To: akpm@linux-foundation.org, daniel.m.jordan@oracle.com, mhocko@suse.com,
 ktkhai@virtuozzo.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Date: Mon, 18 Feb 2019 11:21:00 +0300
Message-ID: <155047806056.13111.495183724111676749.stgit@localhost.localdomain>
In-Reply-To: <155047790692.13111.18025172438615659583.stgit@localhost.localdomain>
References: <155047790692.13111.18025172438615659583.stgit@localhost.localdomain>
User-Agent: StGit/0.18
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We may use input argument list as output argument too.
This makes the function more similar to putback_inactive_pages().

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>

v2: Fix comment spelling.
---
 mm/vmscan.c |   19 +++++++++++++------
 1 file changed, 13 insertions(+), 6 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 8d7d55e71511..656a9b5af2a4 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2004,10 +2004,10 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 
 static unsigned move_active_pages_to_lru(struct lruvec *lruvec,
 				     struct list_head *list,
-				     struct list_head *pages_to_free,
 				     enum lru_list lru)
 {
 	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
+	LIST_HEAD(pages_to_free);
 	struct page *page;
 	int nr_pages;
 	int nr_moved = 0;
@@ -2034,12 +2034,17 @@ static unsigned move_active_pages_to_lru(struct lruvec *lruvec,
 				(*get_compound_page_dtor(page))(page);
 				spin_lock_irq(&pgdat->lru_lock);
 			} else
-				list_add(&page->lru, pages_to_free);
+				list_add(&page->lru, &pages_to_free);
 		} else {
 			nr_moved += nr_pages;
 		}
 	}
 
+	/*
+	 * To save our caller's stack, now use input list for pages to free.
+	 */
+	list_splice(&pages_to_free, list);
+
 	return nr_moved;
 }
 
@@ -2129,8 +2134,10 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	 */
 	reclaim_stat->recent_rotated[file] += nr_rotated;
 
-	nr_activate = move_active_pages_to_lru(lruvec, &l_active, &l_hold, lru);
-	nr_deactivate = move_active_pages_to_lru(lruvec, &l_inactive, &l_hold, lru - LRU_ACTIVE);
+	nr_activate = move_active_pages_to_lru(lruvec, &l_active, lru);
+	nr_deactivate = move_active_pages_to_lru(lruvec, &l_inactive, lru - LRU_ACTIVE);
+	/* Keep all free pages in l_active list */
+	list_splice(&l_inactive, &l_active);
 
 	__count_vm_events(PGDEACTIVATE, nr_deactivate);
 	__count_memcg_events(lruvec_memcg(lruvec), PGDEACTIVATE, nr_deactivate);
@@ -2138,8 +2145,8 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, -nr_taken);
 	spin_unlock_irq(&pgdat->lru_lock);
 
-	mem_cgroup_uncharge_list(&l_hold);
-	free_unref_page_list(&l_hold);
+	mem_cgroup_uncharge_list(&l_active);
+	free_unref_page_list(&l_active);
 	trace_mm_vmscan_lru_shrink_active(pgdat->node_id, nr_taken, nr_activate,
 			nr_deactivate, nr_rotated, sc->priority, file);
 }


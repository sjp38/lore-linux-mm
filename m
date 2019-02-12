Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D255C282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 15:14:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EA7902075C
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 15:14:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EA7902075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8B6278E0008; Tue, 12 Feb 2019 10:14:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 867778E0001; Tue, 12 Feb 2019 10:14:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 70A738E0008; Tue, 12 Feb 2019 10:14:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 036A28E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 10:14:14 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id x18-v6so932396lji.0
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 07:14:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:date:message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=Oxgf0NT9kIH/X4lnwBoqmxmK+tOhc5fNpShonJM1CSU=;
        b=IJCdc1c5aeu4mHei1mdMJE1ASw16h0NGgEmhqd+QML6BidpLuPEPTYzWmHY2zfOb28
         iwK1iqtuCFc/evmrtdHCmHUR/b9xwAGKP0QmXigb3gyI9w3uN5z+bkvcw+I9fhJXVQPB
         ROT/g4bWVQyR/G/MBgx5iiHMwZgZg3L7eDKruszomDwkI1oDNNRcIJkq81RlEQL20QMs
         NMhQJNjUiifag534tXxkfUhUtRDDrhHD4IC5Pw5zLIsdd8/JVgsDYUcgDmK637ZnYf4l
         a+JXEThPZJCndgYOclsgxNF8N7CqiQvvJ1694nvn0w9C3XcGtjUgFgyLije1G6zRjjYp
         9sDQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: AHQUAuaHHz7MWZo9CEX0QBkVCSdh8BW8hp836+n0SjRh0+HevSL2v5Uf
	Ei1vp0VDZiotlqpBvGbg//ZMs3pItKVDiUZpIFGexv1GFwg/lOevVKyCeO67UmI39bmRH4METnQ
	lrKYu6zQOX2Ep9eIziAYlFO9sSGnxgj0YSa5Cn65o5Bl/qqECvNlhfzkwh/R/TN2yew==
X-Received: by 2002:a19:c48e:: with SMTP id u136mr2592437lff.167.1549984453401;
        Tue, 12 Feb 2019 07:14:13 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYBNy1kvFg9CutDtNlB+fxx1LSQRMN7FGVgpZBU3PSZ9zJyrmKllCCENUnDKXITIjYl6epk
X-Received: by 2002:a19:c48e:: with SMTP id u136mr2592381lff.167.1549984452246;
        Tue, 12 Feb 2019 07:14:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549984452; cv=none;
        d=google.com; s=arc-20160816;
        b=NlZr/IYA/0If0WNPliWOjxbPyqLDKnVv0WAOl2xC6BiT+/gKWA82ou85ibxjEFtG1D
         Ie+KI6JPbeD32ZiFC3KoIDYjUnYV0jGa9SobqDE2GP3dK/O0XFi5AnUQ/b4XZml/EP8s
         F70OE/FOC+6NIQRhV1mijr8uBHtFVY0+cSl8Xl+Ok3MnN7rbL6rD/lBL5gaai8uuYve+
         KspY0dQGUUedL+q+VnJoNJ7jDcrnduh90ywX2jdSagk0F6MZEErvtau3fLey3/+NzwIc
         Yf95eBIPMMPScAcSZO22IxgxKL95kBiKouikKxCLEpSo7dYXHpUoI2sZBUJzuTpx4BnK
         6ydA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:to:from:subject;
        bh=Oxgf0NT9kIH/X4lnwBoqmxmK+tOhc5fNpShonJM1CSU=;
        b=v4QxGLc3c4kIdlq5IRUpEFFdNGIqCGxNdXxYI2LPw43SGgk95WanarMS2al3RwxZ/W
         bAHuhrn1ofuTD18r5hmMVOX/g8A6Iefgj/fP5GYoAnE81FT6WOiAOMqcevtP3RxndGhP
         wBuVBzwjl+IBxHLXDC0cXjEPe6xAVLpCvN7aML935xqaJZeAqVW2IZcaGs6MP5ujt8PW
         Q+gldu+PmLf8W+lH06iIxgdsxVn84Z1L6eaagPDwqWX/m3n4WIKWuhBIlDrX/JAxUV9M
         RvOgBQSPt7+6x+nL7x8Ib7XJyPt0Q1sQdkhgKK9h0os8YtKRgzjKeH1fbd0bEFP/lEG4
         NcVg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id w3si11752667lfa.77.2019.02.12.07.14.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 07:14:12 -0800 (PST)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169] (helo=localhost.localdomain)
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1gtZlD-0001ZB-Od; Tue, 12 Feb 2019 18:14:11 +0300
Subject: [PATCH 3/4] mm: Remove pages_to_free argument of
 move_active_pages_to_lru()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
To: akpm@linux-foundation.org, mhocko@suse.com, ktkhai@virtuozzo.com,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
Date: Tue, 12 Feb 2019 18:14:11 +0300
Message-ID: <154998445148.18704.11244772245027520877.stgit@localhost.localdomain>
In-Reply-To: <154998432043.18704.10326447825287153712.stgit@localhost.localdomain>
References: <154998432043.18704.10326447825287153712.stgit@localhost.localdomain>
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
---
 mm/vmscan.c |   19 +++++++++++++------
 1 file changed, 13 insertions(+), 6 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 8d7d55e71511..88fa71e4c28f 100644
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
+	/* Keep all free pages are in l_active list */
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


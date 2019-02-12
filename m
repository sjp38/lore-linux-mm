Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 40F3BC282CE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 15:14:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EEC17217D9
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 15:14:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EEC17217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9EE478E0009; Tue, 12 Feb 2019 10:14:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 97A2D8E0001; Tue, 12 Feb 2019 10:14:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7F33A8E0009; Tue, 12 Feb 2019 10:14:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id 112DA8E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 10:14:20 -0500 (EST)
Received: by mail-lf1-f72.google.com with SMTP id d8so335773lfa.23
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 07:14:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:date:message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=7zMctRGZ05kE70Bz3WkYp7PAVWydIeKsuSWdzLddV9E=;
        b=dHBVVkYsVYe49rdnojMsEBQ9j34/nejMpqIZgjA6rwcOCK4yy765PydHmfFyu83wQY
         2tA1xLdUNDL6b+x+gbOFVzwaOo7xlMjkq5aK2B+D/NOiwpgwCBiXuXUs6yt1awCf0E9E
         dX41E7KZN9NNnb8tx4jKqSFYyQ2pllbMF3c6NT49G7SpwMGeUad2fY2XEnqkkJu6Qn2O
         qPaVRfiEhXhWJ/DvG4M+WBtTAfcPQRua0/OT/ldPenkOxSqARzjlLqxqiuyRoexyog9/
         0upCiEUExeFAqO4RIUrUIa1KeKWuJgNYNguvvGzbKXrXnqX5xjBuXJ4ognhpaqNkZc9c
         wv0A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: AHQUAuZzjV5qtUgeA18UacsY78FWjlp/OwzlWnGfuGhW2x9yQvcPXpQd
	8Oc0ZkXp9ojgbwTMuH4wwiuxA36XyNwSVO0i3CgNP6RlCLWDC8ID0QlTfzG0UrrKFIYPiqBjgNh
	aWCr0kfrF3cv6snD9mA9DAgAufgKzbmeOt8utcEvd8idTWAolAWZxkljMCcf1E+VfPw==
X-Received: by 2002:a2e:2f15:: with SMTP id v21-v6mr2657395ljv.56.1549984459399;
        Tue, 12 Feb 2019 07:14:19 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaOuUBkqHBtfc5hc2FvAaGmztyafYPtxngcTbeXnCDOtx1h3rx/SAQRs57TNu3TBlc6CLIe
X-Received: by 2002:a2e:2f15:: with SMTP id v21-v6mr2657325ljv.56.1549984457981;
        Tue, 12 Feb 2019 07:14:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549984457; cv=none;
        d=google.com; s=arc-20160816;
        b=DU5zYjnelJVrRj1cVoTslPV/9jW9LqUm/M0NvAnjDpzSPED0prRquRYAIS8g9D1Bws
         vSxLu1wIVXynXJ4Hgxq5DBSdvL1NZqNDRjptJ0hgQI6uV2AIf6Nbul751J5GIvwDxx87
         mFVO4rTvSbRum4qn8waMpYTA8we+2FS0OimEvGGW3cQYplo5Ed/JCr5aVoUYFGYmT4ae
         fWU9hosf5hOtPPfVFjka2sOFcO7JREjZb/1hA0/xjus8HyplrmrSV91RL2GFFzb+rAil
         r4cvEHvCHTbS0Ti7snRJ4SeXjhHafNpVow4s1RPkH4B5PHOmfbvfx+iSvj6FKxeE/XAQ
         K9wQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:to:from:subject;
        bh=7zMctRGZ05kE70Bz3WkYp7PAVWydIeKsuSWdzLddV9E=;
        b=zvmRndHBY+CmjWcpQfO7+NbkhumkSYlv9SVfPgVpppK4RpJYHUDKno0VOkPfKlHzWR
         dElfTVuhtHKz9XYhMO5JaTIWS8ZTk62BfoBV0Lb7CP3BEEsl3E7x0UN0Zhw72QxOVcNE
         jQnbZ+zlre4Y6jRPF23npq3I24qs60K4KVMsH5c5bIVQR6uH7RoxYugjqncf0QH8oOB+
         cjpqPqpyqiZz7HQp3/denA2k/GiGsvLXyKAMJph7dB6MUiSOBzbcwI+lD5GN/w9+lT4l
         dWjAGJT/0pPPsP6N8ft+YqAI2L+xACdhhlK40Uo9wAWdYshRzvmjF5mt0PKccNibgag4
         4APA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id n21si2211060lfa.98.2019.02.12.07.14.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 07:14:17 -0800 (PST)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169] (helo=localhost.localdomain)
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1gtZlJ-0001ZP-Gv; Tue, 12 Feb 2019 18:14:17 +0300
Subject: [PATCH 4/4] mm: Generalize putback scan functions
From: Kirill Tkhai <ktkhai@virtuozzo.com>
To: akpm@linux-foundation.org, mhocko@suse.com, ktkhai@virtuozzo.com,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
Date: Tue, 12 Feb 2019 18:14:16 +0300
Message-ID: <154998445694.18704.16751838197928455484.stgit@localhost.localdomain>
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

This combines two similar functions move_active_pages_to_lru()
and putback_inactive_pages() into single move_pages_to_lru().
This remove duplicate code and makes object file size smaller.

Before:
   text	   data	    bss	    dec	    hex	filename
  57082	   4732	    128	  61942	   f1f6	mm/vmscan.o
After:
   text	   data	    bss	    dec	    hex	filename
  55112	   4600	    128	  59840	   e9c0	mm/vmscan.o

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 mm/vmscan.c |  124 ++++++++++++++++++++---------------------------------------
 1 file changed, 41 insertions(+), 83 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 88fa71e4c28f..66e70cf1dd94 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1807,33 +1807,53 @@ static int too_many_isolated(struct pglist_data *pgdat, int file,
 	return isolated > inactive;
 }
 
-static noinline_for_stack void
-putback_inactive_pages(struct lruvec *lruvec, struct list_head *page_list)
+/*
+ * This moves pages from @list to corresponding LRU list.
+ *
+ * We move them the other way if the page is referenced by one or more
+ * processes, from rmap.
+ *
+ * If the pages are mostly unmapped, the processing is fast and it is
+ * appropriate to hold zone_lru_lock across the whole operation.  But if
+ * the pages are mapped, the processing is slow (page_referenced()) so we
+ * should drop zone_lru_lock around each page.  It's impossible to balance
+ * this, so instead we remove the pages from the LRU while processing them.
+ * It is safe to rely on PG_active against the non-LRU pages in here because
+ * nobody will play with that bit on a non-LRU page.
+ *
+ * The downside is that we have to touch page->_refcount against each page.
+ * But we had to alter page->flags anyway.
+ *
+ * Returns the number of pages moved to the given lruvec.
+ */
+
+static unsigned noinline_for_stack move_pages_to_lru(struct lruvec *lruvec,
+						     struct list_head *list)
 {
 	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
+	int nr_pages, nr_moved = 0;
 	LIST_HEAD(pages_to_free);
+	struct page *page;
+	enum lru_list lru;
 
-	/*
-	 * Put back any unfreeable pages.
-	 */
-	while (!list_empty(page_list)) {
-		struct page *page = lru_to_page(page_list);
-		int lru;
-
-		VM_BUG_ON_PAGE(PageLRU(page), page);
-		list_del(&page->lru);
+	while (!list_empty(list)) {
+		page = lru_to_page(list);
 		if (unlikely(!page_evictable(page))) {
+			list_del_init(&page->lru);
 			spin_unlock_irq(&pgdat->lru_lock);
 			putback_lru_page(page);
 			spin_lock_irq(&pgdat->lru_lock);
 			continue;
 		}
-
 		lruvec = mem_cgroup_page_lruvec(page, pgdat);
 
+		VM_BUG_ON_PAGE(PageLRU(page), page);
 		SetPageLRU(page);
 		lru = page_lru(page);
-		add_page_to_lru_list(page, lruvec, lru);
+
+		nr_pages = hpage_nr_pages(page);
+		update_lru_size(lruvec, lru, page_zonenum(page), nr_pages);
+		list_move(&page->lru, &lruvec->lists[lru]);
 
 		if (put_page_testzero(page)) {
 			__ClearPageLRU(page);
@@ -1847,13 +1867,17 @@ putback_inactive_pages(struct lruvec *lruvec, struct list_head *page_list)
 				spin_lock_irq(&pgdat->lru_lock);
 			} else
 				list_add(&page->lru, &pages_to_free);
+		} else {
+			nr_moved += nr_pages;
 		}
 	}
 
 	/*
 	 * To save our caller's stack, now use input list for pages to free.
 	 */
-	list_splice(&pages_to_free, page_list);
+	list_splice(&pages_to_free, list);
+
+	return nr_moved;
 }
 
 /*
@@ -1945,7 +1969,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	reclaim_stat->recent_rotated[0] = stat.nr_activate[0];
 	reclaim_stat->recent_rotated[1] = stat.nr_activate[1];
 
-	putback_inactive_pages(lruvec, &page_list);
+	move_pages_to_lru(lruvec, &page_list);
 
 	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, -nr_taken);
 
@@ -1982,72 +2006,6 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	return nr_reclaimed;
 }
 
-/*
- * This moves pages from the active list to the inactive list.
- *
- * We move them the other way if the page is referenced by one or more
- * processes, from rmap.
- *
- * If the pages are mostly unmapped, the processing is fast and it is
- * appropriate to hold zone_lru_lock across the whole operation.  But if
- * the pages are mapped, the processing is slow (page_referenced()) so we
- * should drop zone_lru_lock around each page.  It's impossible to balance
- * this, so instead we remove the pages from the LRU while processing them.
- * It is safe to rely on PG_active against the non-LRU pages in here because
- * nobody will play with that bit on a non-LRU page.
- *
- * The downside is that we have to touch page->_refcount against each page.
- * But we had to alter page->flags anyway.
- *
- * Returns the number of pages moved to the given lru.
- */
-
-static unsigned move_active_pages_to_lru(struct lruvec *lruvec,
-				     struct list_head *list,
-				     enum lru_list lru)
-{
-	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
-	LIST_HEAD(pages_to_free);
-	struct page *page;
-	int nr_pages;
-	int nr_moved = 0;
-
-	while (!list_empty(list)) {
-		page = lru_to_page(list);
-		lruvec = mem_cgroup_page_lruvec(page, pgdat);
-
-		VM_BUG_ON_PAGE(PageLRU(page), page);
-		SetPageLRU(page);
-
-		nr_pages = hpage_nr_pages(page);
-		update_lru_size(lruvec, lru, page_zonenum(page), nr_pages);
-		list_move(&page->lru, &lruvec->lists[lru]);
-
-		if (put_page_testzero(page)) {
-			__ClearPageLRU(page);
-			__ClearPageActive(page);
-			del_page_from_lru_list(page, lruvec, lru);
-
-			if (unlikely(PageCompound(page))) {
-				spin_unlock_irq(&pgdat->lru_lock);
-				mem_cgroup_uncharge(page);
-				(*get_compound_page_dtor(page))(page);
-				spin_lock_irq(&pgdat->lru_lock);
-			} else
-				list_add(&page->lru, &pages_to_free);
-		} else {
-			nr_moved += nr_pages;
-		}
-	}
-
-	/*
-	 * To save our caller's stack, now use input list for pages to free.
-	 */
-	list_splice(&pages_to_free, list);
-
-	return nr_moved;
-}
-
 static void shrink_active_list(unsigned long nr_to_scan,
 			       struct lruvec *lruvec,
 			       struct scan_control *sc,
@@ -2134,8 +2092,8 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	 */
 	reclaim_stat->recent_rotated[file] += nr_rotated;
 
-	nr_activate = move_active_pages_to_lru(lruvec, &l_active, lru);
-	nr_deactivate = move_active_pages_to_lru(lruvec, &l_inactive, lru - LRU_ACTIVE);
+	nr_activate = move_pages_to_lru(lruvec, &l_active);
+	nr_deactivate = move_pages_to_lru(lruvec, &l_inactive);
 	/* Keep all free pages are in l_active list */
 	list_splice(&l_inactive, &l_active);
 


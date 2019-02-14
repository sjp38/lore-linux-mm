Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E97CC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 10:35:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 58925222A4
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 10:35:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 58925222A4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F240E8E0006; Thu, 14 Feb 2019 05:35:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED3168E0001; Thu, 14 Feb 2019 05:35:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D9B068E0006; Thu, 14 Feb 2019 05:35:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6C1628E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 05:35:46 -0500 (EST)
Received: by mail-lf1-f72.google.com with SMTP id d6so561075lfk.1
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 02:35:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:date:message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=p1qhfuMaoIfxu/+MYQ1eQD2AAYZso25tEhR+PZU2LMA=;
        b=HCHL75QjJN22RENxgsYNW1OPOJJnINh+62iU9xmLx+/8Ubl8VOwMh19VgpPtGrAVMj
         BkPzw+9UYLSZsQiEzyB4yGUoqQjYCWOY9LOrHnYYY1MaahxSewbPk2afrrbgh4Mb0YfX
         zLjv5CTLkon1aXIopgF7LPC5VneqaZdGX8R8X78MSnlIUQN/iCddRnkHhp2nmMU+6PRu
         U3bEikI8a5jUd0eeDiQ87H6lLA0PhniEdCKVmrGfK1JvLAG6d4L8Qmx0nY0G9KozHeAt
         jRjAEQdpcQ1kZBEKrcpPtcuNN5gsIXJLVMAPfEtrTAGTnjomvyNX8QU5c7wt0EmET3pE
         DVEQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: AHQUAubmvKvf/mw0aSxNRixGL4062ruT4feKJVOYmT8UGYfoR6CfQLBe
	J5wHlEIW6FRggQQm239NgA+4coWVFQTFiPf6hjZVSUwFSpyCiu5O9lgFbjO/7p7fi8ELUjKgnHb
	AD5NyyzyITsujZoKz9O/K4X+ktMcUZ6Ev/A3zBPQh8y3bcTJTGikNouSnMCclberDfg==
X-Received: by 2002:a2e:7614:: with SMTP id r20-v6mr1910802ljc.175.1550140545799;
        Thu, 14 Feb 2019 02:35:45 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZwJUbsG2T+Jp+iz1sqKj2r5rf0gpn/R85Kz1mB+CZ6PocqxUPLwF9yjnJYOM+NYejSKdz1
X-Received: by 2002:a2e:7614:: with SMTP id r20-v6mr1910736ljc.175.1550140544470;
        Thu, 14 Feb 2019 02:35:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550140544; cv=none;
        d=google.com; s=arc-20160816;
        b=WZZj+u6eoROe4tICY2fofENvnemqQeHaQmAAtp4EK2Iqga/qMK+0hB0jPtkooz+Tbm
         rv3sTcMXyVe1DsnXRH7HQhemmyNNfCfu4m4YHIaHBh9W7ACZ1Iyak+yhXe5orbkHjgXf
         gV1d2/LbQvXAbHOB81sxM1HczyVSATIwb519g+8qOa+A8g6Nh6TMtoRYxdD2BV+oPvZ7
         MMKLI6qDk3knJludkrvqRhrlu0oCRVQQ6mc/Q3HG7dXB0wMurYTwn4kiTYxFlDiI9baz
         ZiOprto7BajCwg9XCdW1nqyQ9Yctw5j0IEv5SFV7BJRpdZlWAO5te1o7VFvVXcbfNX3t
         igtw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:to:from:subject;
        bh=p1qhfuMaoIfxu/+MYQ1eQD2AAYZso25tEhR+PZU2LMA=;
        b=Mt1iA3cGyeXWZtMXjSVDKOykPQlLaWIwa7F6yIjpzp+cVKXpuCyV/y7f+r+sHudTG1
         3JX7FpP3wC/Vwpbgly0EcP8iBK1h2syE9pm/w3kU/MIweXmaaYdhN32OApvB7TJSfPaF
         xIGB4VaxLHeYdl9HUIKEeCr3nad86/kw4UpNxTQHQp7ASknHv/Jd+IZeoHGG4OgN/zlK
         W9QcoluvVROGQiv8nZ2vf8+Io/J8S4AVY/5Tvd/ciUK2Piqww7oCpqed+gVkhFqwE6kn
         L/Y8tPrki700yEiYeUM5Hg2bBijMPUddqmk1OlugfIP3QJ4Wto/HfTAlChkU6wbp/2Do
         ypJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id s191si1914141lfs.9.2019.02.14.02.35.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 02:35:44 -0800 (PST)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169] (helo=localhost.localdomain)
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1guEMj-00053m-CT; Thu, 14 Feb 2019 13:35:37 +0300
Subject: [PATCH v2 4/4] mm: Generalize putback scan functions
From: Kirill Tkhai <ktkhai@virtuozzo.com>
To: akpm@linux-foundation.org, daniel.m.jordan@oracle.com, mhocko@suse.com,
 ktkhai@virtuozzo.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Date: Thu, 14 Feb 2019 13:35:37 +0300
Message-ID: <155014053725.28944.7960592286711533914.stgit@localhost.localdomain>
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

This combines two similar functions move_active_pages_to_lru()
and putback_inactive_pages() into single move_pages_to_lru().
This remove duplicate code and makes object file size smaller.

Before:
   text	   data	    bss	    dec	    hex	filename
  57082	   4732	    128	  61942	   f1f6	mm/vmscan.o
After:
   text	   data	    bss	    dec	    hex	filename
  55112	   4600	    128	  59840	   e9c0	mm/vmscan.o

Note, that now we are checking for !page_evictable() coming
from shrink_active_list(), which shouldn't change any behavior
since that path works with evictable pages only.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>

v2: Move VM_BUG_ON() up.
---
 mm/vmscan.c |  122 +++++++++++++++++++----------------------------------------
 1 file changed, 40 insertions(+), 82 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 656a9b5af2a4..fcec2385dda2 100644
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
+	while (!list_empty(list)) {
+		page = lru_to_page(list);
 		VM_BUG_ON_PAGE(PageLRU(page), page);
-		list_del(&page->lru);
 		if (unlikely(!page_evictable(page))) {
+			list_del_init(&page->lru);
 			spin_unlock_irq(&pgdat->lru_lock);
 			putback_lru_page(page);
 			spin_lock_irq(&pgdat->lru_lock);
 			continue;
 		}
-
 		lruvec = mem_cgroup_page_lruvec(page, pgdat);
 
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
 	/* Keep all free pages in l_active list */
 	list_splice(&l_inactive, &l_active);
 


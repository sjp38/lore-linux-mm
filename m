Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0679C4360F
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 08:21:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 796CD218AD
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 08:21:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 796CD218AD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 27D768E0008; Mon, 18 Feb 2019 03:21:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 18F498E0001; Mon, 18 Feb 2019 03:21:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F23BA8E0008; Mon, 18 Feb 2019 03:21:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7ED5D8E0001
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 03:21:15 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id w16-v6so3237269ljw.6
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 00:21:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:date:message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=AtemCwdeLG1Nam5mqgEFvhwIWzJZyCew+qz/C63f2pE=;
        b=QufwhPH+af5TzK4bOokPRdtODWuLujIMjdCfACe/yGoKq9HKyrRYMm/Z5xyDWZcZBj
         km74a29pjnnNBZzZxMWvqW4XVyLumXQmuHzmrL/XjKSNqM7FN6lXcr/Jlj3G83RzMoXa
         LqOS4JFbz+XZsjF6Fbm0isN0GL3YUzeWOugkjgL2rHmvKFRcttD+HKo8cxwzC0uSzMVN
         5A4GD5QPemMSjRwd42nggGocxE0mI8NQmPBfZFtxSshq+msz9YtihQZXdVMJrTMrDqDJ
         0lR08qXnkah7/7Db9M3jaqrO0PJNh79cBcwfsTeNb8xpLOZQ6C74rrVQzn3Q4XZP5tqb
         QxXA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: AHQUAuYdwSrg9IVL/QTR9X9dL61ArC+xwqOn9qQ/cmPjtOp/NyCltbls
	Wke0nPUFoNc2pwj7C+EMhg7aS5wdcUNQWxxQQpOlEhCyqhbpwDvrbmJPaAfI8dt79aqr518HsQa
	IhwVt9IT1QBKi4s+oN/Eb5UfOtstGvLSBrc0eL2FpdAf+f3JL/7GZl0XoBBcdD94SwQ==
X-Received: by 2002:a19:4847:: with SMTP id v68mr12781449lfa.136.1550478074825;
        Mon, 18 Feb 2019 00:21:14 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbTQk6jZgXArSAknBPzSKQB2HMqWfWb9Kaa0Z4d6zcOdbb2A4qg11Kn/bldbgR3Kgil+pyU
X-Received: by 2002:a19:4847:: with SMTP id v68mr12781389lfa.136.1550478073315;
        Mon, 18 Feb 2019 00:21:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550478073; cv=none;
        d=google.com; s=arc-20160816;
        b=ETO7GSi0BE9yG6c+/as7g/oQMMIffJ/s5pk3zszrtDrf3fSIkYRr+AFmlK3XJxXQLe
         Fw6U2tiDtpKyR2jMoF83Soh+zWgqF+aLbgE3m6+09nbD0z26mcJ2qw9CTwBiB2gP9VkM
         4OG+T15uCWoZMtWcbts/H28JhZrwGdyN5ILxMGH2RDV1PwGXAvcptRo+K4q+z1N6/0lV
         9S8p7bAExfp1vQEwdZxdUuHc2pbrgfAxLaZAPVTt4QEiduOvRz+4JxZAZotsIGATSq2A
         ehXHhk7wNtYgcmwRyd/bbzBU525Ti+s8eDSUSkdqj+GNey6TGsVyjFAzTp3N7zp0CEfN
         6ipQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:to:from:subject;
        bh=AtemCwdeLG1Nam5mqgEFvhwIWzJZyCew+qz/C63f2pE=;
        b=tiYw0Gyipt7tlSJEzMmPTidgBX9RGD7hdOBqyl0jbULG2T70DYmiN4JmZPcac+zjN0
         GzUsR2m5dprYf1/99pC4YHzzLPjM3r4Gch6cnn0ZR1mTQW4JDP+Zi9b5KnDI0zAC3h3W
         iLUAcwjzahWIK0+vAjQI0u2cEDB4JBpyGFgE3i7F0+MARXTfhfbGVG1wbm2UPI+2SslC
         1pdmOnjxxtN1+lP2nP3FTjwbHVwWSxJ/osI32IzYAv1SGE3c0Qc47mSG6yWFr3AI5Yrz
         2FVDb1ap9JKECbP+LINNwA7qgGuHOYACu6MXnhjzplLozoCMWvZiza32NwdL4gofTe6v
         89cQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id k76si10959931lfg.12.2019.02.18.00.21.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 00:21:13 -0800 (PST)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169] (helo=localhost.localdomain)
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1gveAj-0007pv-S6; Mon, 18 Feb 2019 11:21:05 +0300
Subject: [PATCH v3 4/4] mm: Generalize putback scan functions
From: Kirill Tkhai <ktkhai@virtuozzo.com>
To: akpm@linux-foundation.org, daniel.m.jordan@oracle.com, mhocko@suse.com,
 ktkhai@virtuozzo.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Date: Mon, 18 Feb 2019 11:21:05 +0300
Message-ID: <155047806576.13111.9663490902206172043.stgit@localhost.localdomain>
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
Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>

v3: Replace list_del_init() with list_del()
v2: Move VM_BUG_ON() up.
---
 mm/vmscan.c |  122 +++++++++++++++++++----------------------------------------
 1 file changed, 40 insertions(+), 82 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 656a9b5af2a4..5647727919bc 100644
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
+			list_del(&page->lru);
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
 


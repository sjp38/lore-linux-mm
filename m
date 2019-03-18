Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2AA36C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 09:28:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CB58A2087C
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 09:28:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CB58A2087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 79EE56B000A; Mon, 18 Mar 2019 05:28:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 74EF56B000C; Mon, 18 Mar 2019 05:28:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 664B26B000D; Mon, 18 Mar 2019 05:28:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id F30986B000A
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 05:28:24 -0400 (EDT)
Received: by mail-lf1-f72.google.com with SMTP id z187so1491695lfa.21
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 02:28:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:date:message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=JpABL/NJyXGgYckGkxEeeeHpNf9ZSEcd/+27GWn8BZM=;
        b=GtoPtMKYDkSwInvkUueAbo4kHq7qx8MBe/N/yRkz2/m2SNrc4nm+k83sgpIVqC+iiU
         MSTF5NymBixjFoQL8oPDZJJVUTSXz7piyECEhdyBWf1jcX5XfIYA48FRPlAzso+s7tWL
         Y/2Xl7WQ8V/f2GvPu2UTnCPtXTYVi2ed04yjj4QVZkhOgcv6ciSQD9VN4o22mUwVCY35
         7b5gUw4xTvsW3hjnpBWSDjuMzQc1nAN+ZJW7dJKbb0Izg9VjhT2u79Ut51EBQe15gFYS
         7jhnVxi9s10siXOcJhbBVdn9WUXP0TGlgDqfvYWuTpF1skJXakQYNfJ1uICXMrm1hoMC
         I4Kw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAXXQuhm2XxptLLM6EvTIb5PcXR4vnRnYi7HOJXFPlnY0GAUGs01
	9DYq495o/8S2btybjsy7dAUpH4rExA6QJJlyD2apwXkZ8AIOW0NwaEYB84+Bno2kX9WPdt0RfV7
	e5icbFz4kzH5VpLR7aeNkzMmU5OWSuxBlKb8yoYG1bmrgHx+P7zqMMxcoqL1XFXHqiA==
X-Received: by 2002:a2e:9154:: with SMTP id q20mr89012ljg.30.1552901304244;
        Mon, 18 Mar 2019 02:28:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyOWUpMAzWUOhaUe3hOrTjFCJ4GttHDK/UrfihDrI7vc5Aeg8xoUJ9YlhveQTN3PuOGxYps
X-Received: by 2002:a2e:9154:: with SMTP id q20mr88965ljg.30.1552901303006;
        Mon, 18 Mar 2019 02:28:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552901303; cv=none;
        d=google.com; s=arc-20160816;
        b=Y/+X5OsNAZ7Jzmiv8DnBxea8yTvuIoSTm5KjMCYYkJdLAXwottYHCQlbRpxziFoYiL
         r1sX4+rqd+L+BPQtE5CfPO7hj4nsRzQpBBVrn4kDGIqTUolbb9ZaLFfWSdUDq0xpjC9K
         8JdFGowHcQ9rCJIoxt9uztvG1kuzua6BiQ/9w8aTecnENv4v+8aWCsUxzuadiLwpgxRU
         SD5QdvOoIDE6Mz9Ql2mkf0vAqdI7pGmA1hzE0BRaFWxnVV046eQcFidjFCxn7r8xBDN1
         JarfQ/qZTBmCXbhcue9LN6+Wqaj59RlqIzrVdkx4iO+hxR77KS49qzzlSV4Bcc/ZjKU0
         z2oQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:to:from:subject;
        bh=JpABL/NJyXGgYckGkxEeeeHpNf9ZSEcd/+27GWn8BZM=;
        b=xlMC5/oNTwir+ymC8LT4dRU4CsL53cHejExKwqflRDO9WI0qTOCQPnS4GqoybSwNdh
         HLNkXzdbL72vh4ZkpKErVLBWIvCaQUI0gWr4noU/DZdVxW4xqiVWD2s0fLZZcezdXamF
         cxh21WRKvjaU+EIE4+VODhKHbePawab70we37mxiirb+j+u2mhofw/J38Uawq80J627K
         45nvItrMyO8MzePC4yWdY5PKy3r2cb4Vv4Au0PiipJogHpFNPT5YSxbksa5dYRB+ctPR
         8zNIIcaAFi96g6Xtq84zi9VL1PAj25LNAv6eJa/SDaKtsDiDwaIjOcjn9SiA8oHP0z2i
         g6hg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id y22si7039779lji.93.2019.03.18.02.28.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Mar 2019 02:28:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169] (helo=localhost.localdomain)
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1h5oZ7-00055e-3U; Mon, 18 Mar 2019 12:28:17 +0300
Subject: [PATCH REBASED 4/4] mm: Generalize putback scan functions
From: Kirill Tkhai <ktkhai@virtuozzo.com>
To: akpm@linux-foundation.org, daniel.m.jordan@oracle.com, mhocko@suse.com,
 ktkhai@virtuozzo.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Date: Mon, 18 Mar 2019 12:28:16 +0300
Message-ID: <155290129627.31489.8321971028677203248.stgit@localhost.localdomain>
In-Reply-To: <155290113594.31489.16711525148390601318.stgit@localhost.localdomain>
References: <155290113594.31489.16711525148390601318.stgit@localhost.localdomain>
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
index 1794ec7b21d8..f6b9b45f731d 100644
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
- * appropriate to hold pgdat->lru_lock across the whole operation.  But if
- * the pages are mapped, the processing is slow (page_referenced()) so we
- * should drop pgdat->lru_lock around each page.  It's impossible to balance
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
 


Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C50BFC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 07:39:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 51CA720838
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 07:38:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 51CA720838
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B96658E0002; Fri, 15 Feb 2019 02:38:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B1ED28E0001; Fri, 15 Feb 2019 02:38:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9C13E8E0002; Fri, 15 Feb 2019 02:38:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 296178E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 02:38:44 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id u73-v6so2295914lja.4
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 23:38:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=/urinTztm47SIAnHhlBC0il+PW7/0e3EsjlbomPExPo=;
        b=nUmZK8VtWweSVKfHXnhY3JOwqajdzS2X7B6VgXz3QIhH7rm1NZY2/THly2b10DYRxB
         j7btFrFJLH/ZiBt7ZGPkKHceIsikWBPmAN6an0NVXccefcTUNnjuGHUm24zfcjtyE0ma
         Osg3iLJBXHAO6+vutxesrUIUm8IHoK0hFCwOja46qWj9cYlmbQBw4Wd7HBcJSs09PJrV
         skdQfrzU8PaafhbBvGa5Qo44hrnmmVCo1H/78tW2DpGyACOM7dD8jooWxsy9yVmcsSdE
         E+bT+YKU4Qdf1IBrqkHX0Z1ZQzz8Ww9zxzV2V57KRMXDv4/iKRG7EA2tzTXm2YWf5wYR
         XF2w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: AHQUAua+Kl+ynL6X9akDNflOxo9vPehDJYW1mxEu7PjrJz6z6nehU6ie
	oRutDLHy8/l4blLNaqPyAImXdUxS0AYa4ofbZlMwPVShqYHlDQSZnA7iu0Ov+BHpzbqWScBPaqm
	YKzoJRn03CtdCjNzZv2zMX8yVA7KF8HDLXKI51So4d2PITShq0QRN5hvJjpBhDWlr5A==
X-Received: by 2002:a19:a706:: with SMTP id q6mr4856424lfe.150.1550216323416;
        Thu, 14 Feb 2019 23:38:43 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY8JD3QgjZTfoFnnXjUhNrRxLWPLOojabB7TNi+RPeNLaENIzO+zAVrtGe5QI3OgLczK4yV
X-Received: by 2002:a19:a706:: with SMTP id q6mr4856362lfe.150.1550216322047;
        Thu, 14 Feb 2019 23:38:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550216322; cv=none;
        d=google.com; s=arc-20160816;
        b=B57dFV1wUBUY9TNye/t103UL7U4W8uQY7EjQa0ycx8r51fLPt5y8ixwL8t6yglzbMx
         0BAhzl5w5m+t0a30bqis7EVGStqVY+SdAKXxQMG2qa/4CkDDWxstaCb0D/Cyx8c+RdKD
         vg7q4KhHJhB3P1IO9fUv/TcNx02JUSYrSsH8ZZZtdGRtqg6xacHAQW56dm6YqAr8wyX7
         HqxZ4yqGVXY/hrVLVDpgHw0y/+tI5UJ1ymwDK2ieyMmjqrwdMdJguH2THA3prcUxxydD
         FWqQO1caZq+WipCWK7uOiZdhNR/F640IstoDgbxeJ4EMj4MQkPR0+P0lJiTL/wgxTaKB
         6BDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=/urinTztm47SIAnHhlBC0il+PW7/0e3EsjlbomPExPo=;
        b=yOOF4dYe0ZZffnwOakp1tQsirN62fpsSHWjEFyh7hOEgnhEiNUteRKtR/Co4uSLxkg
         Y/y3/1n6qLrj+j9tOkgmYaPv6UvbQvl4y/oDiZFbXLrRToyS1mAuIYG24GQX3XCDHp5q
         2S6sx7Ut5Sq+zzLCDzzCZdV7pdtrP4i2U2UUic+pG7VZK9Odn//85HC0FVOWHe7K8z46
         vjjWS4vm6JnFTr0hJs4DfcZj6eelwl+Wvno2NUQK5GhEVYeq5NphCSrl94DkTW7BQ+Pv
         onN+x8uHlCIo/0DwCikYWkswzKpoijIN+wRv5PLuk9ZEELBg65+uyfLuQ05qxGlRwgNP
         GpOg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id u6-v6si556792ljj.44.2019.02.14.23.38.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 23:38:41 -0800 (PST)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1guY50-0002o1-1m; Fri, 15 Feb 2019 10:38:38 +0300
Subject: [PATCH v2.5 1/4] mm: Move recent_rotated pages calculation to
 shrink_inactive_list()
To: Andrew Morton <akpm@linux-foundation.org>
Cc: daniel.m.jordan@oracle.com, mhocko@suse.com, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <155014039859.28944.1726860521114076369.stgit@localhost.localdomain>
 <155014052145.28944.16497030123804725057.stgit@localhost.localdomain>
 <20190214125759.97558dd947057db0397eb95e@linux-foundation.org>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <eea82417-9cbe-b89c-385c-c2ae5d77de4d@virtuozzo.com>
Date: Fri, 15 Feb 2019 10:38:37 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190214125759.97558dd947057db0397eb95e@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

mm: Move recent_rotated pages calculation to shrink_inactive_list()

From: Kirill Tkhai <ktkhai@virtuozzo.com>

The patch moves the calculation from putback_inactive_pages()
to shrink_inactive_list(). This makes putback_inactive_pages()
looking more similar to move_active_pages_to_lru().

To do that, we account activated pages in reclaim_stat::nr_activate.
Since a page may change its LRU type from anon to file cache
inside shrink_page_list() (see ClearPageSwapBacked()), we have to
account pages for the both types. So, nr_activate becomes an array.

Previously we used nr_activate to account PGACTIVATE events, but now
we account them into pgactivate variable (since they are about
number of pages in general, not about sum of hpage_nr_pages).

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>

v2.5: Update comment.
v2:   Update trace events.
---
 .../trace/postprocess/trace-vmscan-postprocess.pl  |    7 ++++---
 include/linux/vmstat.h                             |    2 +-
 include/trace/events/vmscan.h                      |   13 ++++++++-----
 mm/vmscan.c                                        |   15 +++++++--------
 4 files changed, 20 insertions(+), 17 deletions(-)

diff --git a/Documentation/trace/postprocess/trace-vmscan-postprocess.pl b/Documentation/trace/postprocess/trace-vmscan-postprocess.pl
index 66bfd8396877..995da15b16ca 100644
--- a/Documentation/trace/postprocess/trace-vmscan-postprocess.pl
+++ b/Documentation/trace/postprocess/trace-vmscan-postprocess.pl
@@ -113,7 +113,7 @@ my $regex_kswapd_wake_default = 'nid=([0-9]*) order=([0-9]*)';
 my $regex_kswapd_sleep_default = 'nid=([0-9]*)';
 my $regex_wakeup_kswapd_default = 'nid=([0-9]*) zid=([0-9]*) order=([0-9]*) gfp_flags=([A-Z_|]*)';
 my $regex_lru_isolate_default = 'isolate_mode=([0-9]*) classzone_idx=([0-9]*) order=([0-9]*) nr_requested=([0-9]*) nr_scanned=([0-9]*) nr_skipped=([0-9]*) nr_taken=([0-9]*) lru=([a-z_]*)';
-my $regex_lru_shrink_inactive_default = 'nid=([0-9]*) nr_scanned=([0-9]*) nr_reclaimed=([0-9]*) nr_dirty=([0-9]*) nr_writeback=([0-9]*) nr_congested=([0-9]*) nr_immediate=([0-9]*) nr_activate=([0-9]*) nr_ref_keep=([0-9]*) nr_unmap_fail=([0-9]*) priority=([0-9]*) flags=([A-Z_|]*)';
+my $regex_lru_shrink_inactive_default = 'nid=([0-9]*) nr_scanned=([0-9]*) nr_reclaimed=([0-9]*) nr_dirty=([0-9]*) nr_writeback=([0-9]*) nr_congested=([0-9]*) nr_immediate=([0-9]*) nr_activate_anon=([0-9]*) nr_activate_file=([0-9]*) nr_ref_keep=([0-9]*) nr_unmap_fail=([0-9]*) priority=([0-9]*) flags=([A-Z_|]*)';
 my $regex_lru_shrink_active_default = 'lru=([A-Z_]*) nr_scanned=([0-9]*) nr_rotated=([0-9]*) priority=([0-9]*)';
 my $regex_writepage_default = 'page=([0-9a-f]*) pfn=([0-9]*) flags=([A-Z_|]*)';
 
@@ -212,7 +212,8 @@ $regex_lru_shrink_inactive = generate_traceevent_regex(
 			"vmscan/mm_vmscan_lru_shrink_inactive",
 			$regex_lru_shrink_inactive_default,
 			"nid", "nr_scanned", "nr_reclaimed", "nr_dirty", "nr_writeback",
-			"nr_congested", "nr_immediate", "nr_activate", "nr_ref_keep",
+			"nr_congested", "nr_immediate", "nr_activate_anon",
+			"nr_activate_file", "nr_ref_keep",
 			"nr_unmap_fail", "priority", "flags");
 $regex_lru_shrink_active = generate_traceevent_regex(
 			"vmscan/mm_vmscan_lru_shrink_active",
@@ -407,7 +408,7 @@ sub process_events {
 			}
 
 			my $nr_reclaimed = $3;
-			my $flags = $12;
+			my $flags = $13;
 			my $file = 0;
 			if ($flags =~ /RECLAIM_WB_FILE/) {
 				$file = 1;
diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 2db8d60981fe..bdeda4b079fe 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -26,7 +26,7 @@ struct reclaim_stat {
 	unsigned nr_congested;
 	unsigned nr_writeback;
 	unsigned nr_immediate;
-	unsigned nr_activate;
+	unsigned nr_activate[2];
 	unsigned nr_ref_keep;
 	unsigned nr_unmap_fail;
 };
diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index a1cb91342231..4f0e45e90cfc 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -358,7 +358,8 @@ TRACE_EVENT(mm_vmscan_lru_shrink_inactive,
 		__field(unsigned long, nr_writeback)
 		__field(unsigned long, nr_congested)
 		__field(unsigned long, nr_immediate)
-		__field(unsigned long, nr_activate)
+		__field(unsigned int, nr_activate0)
+		__field(unsigned int, nr_activate1)
 		__field(unsigned long, nr_ref_keep)
 		__field(unsigned long, nr_unmap_fail)
 		__field(int, priority)
@@ -373,20 +374,22 @@ TRACE_EVENT(mm_vmscan_lru_shrink_inactive,
 		__entry->nr_writeback = stat->nr_writeback;
 		__entry->nr_congested = stat->nr_congested;
 		__entry->nr_immediate = stat->nr_immediate;
-		__entry->nr_activate = stat->nr_activate;
+		__entry->nr_activate0 = stat->nr_activate[0];
+		__entry->nr_activate1 = stat->nr_activate[1];
 		__entry->nr_ref_keep = stat->nr_ref_keep;
 		__entry->nr_unmap_fail = stat->nr_unmap_fail;
 		__entry->priority = priority;
 		__entry->reclaim_flags = trace_shrink_flags(file);
 	),
 
-	TP_printk("nid=%d nr_scanned=%ld nr_reclaimed=%ld nr_dirty=%ld nr_writeback=%ld nr_congested=%ld nr_immediate=%ld nr_activate=%ld nr_ref_keep=%ld nr_unmap_fail=%ld priority=%d flags=%s",
+	TP_printk("nid=%d nr_scanned=%ld nr_reclaimed=%ld nr_dirty=%ld nr_writeback=%ld nr_congested=%ld nr_immediate=%ld nr_activate_anon=%d nr_activate_file=%d nr_ref_keep=%ld nr_unmap_fail=%ld priority=%d flags=%s",
 		__entry->nid,
 		__entry->nr_scanned, __entry->nr_reclaimed,
 		__entry->nr_dirty, __entry->nr_writeback,
 		__entry->nr_congested, __entry->nr_immediate,
-		__entry->nr_activate, __entry->nr_ref_keep,
-		__entry->nr_unmap_fail, __entry->priority,
+		__entry->nr_activate0, __entry->nr_activate1,
+		__entry->nr_ref_keep, __entry->nr_unmap_fail,
+		__entry->priority,
 		show_reclaim_flags(__entry->reclaim_flags))
 );
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index ac4806f0f332..84542004a277 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1107,6 +1107,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 	LIST_HEAD(ret_pages);
 	LIST_HEAD(free_pages);
 	unsigned nr_reclaimed = 0;
+	unsigned pgactivate = 0;
 
 	memset(stat, 0, sizeof(*stat));
 	cond_resched();
@@ -1466,8 +1467,10 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			try_to_free_swap(page);
 		VM_BUG_ON_PAGE(PageActive(page), page);
 		if (!PageMlocked(page)) {
+			int type = page_is_file_cache(page);
 			SetPageActive(page);
-			stat->nr_activate++;
+			pgactivate++;
+			stat->nr_activate[type] += hpage_nr_pages(page);
 			count_memcg_page_event(page, PGACTIVATE);
 		}
 keep_locked:
@@ -1482,7 +1485,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 	free_unref_page_list(&free_pages);
 
 	list_splice(&ret_pages, page_list);
-	count_vm_events(PGACTIVATE, stat->nr_activate);
+	count_vm_events(PGACTIVATE, pgactivate);
 
 	return nr_reclaimed;
 }
@@ -1807,7 +1810,6 @@ static int too_many_isolated(struct pglist_data *pgdat, int file,
 static noinline_for_stack void
 putback_inactive_pages(struct lruvec *lruvec, struct list_head *page_list)
 {
-	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
 	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
 	LIST_HEAD(pages_to_free);
 
@@ -1833,11 +1835,6 @@ putback_inactive_pages(struct lruvec *lruvec, struct list_head *page_list)
 		lru = page_lru(page);
 		add_page_to_lru_list(page, lruvec, lru);
 
-		if (is_active_lru(lru)) {
-			int file = is_file_lru(lru);
-			int numpages = hpage_nr_pages(page);
-			reclaim_stat->recent_rotated[file] += numpages;
-		}
 		if (put_page_testzero(page)) {
 			__ClearPageLRU(page);
 			__ClearPageActive(page);
@@ -1945,6 +1942,8 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 		count_memcg_events(lruvec_memcg(lruvec), PGSTEAL_DIRECT,
 				   nr_reclaimed);
 	}
+	reclaim_stat->recent_rotated[0] = stat.nr_activate[0];
+	reclaim_stat->recent_rotated[1] = stat.nr_activate[1];
 
 	putback_inactive_pages(lruvec, &page_list);
 


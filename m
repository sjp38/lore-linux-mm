Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DCCCEC10F02
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 08:21:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 87F92218AD
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 08:21:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 87F92218AD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 254298E0005; Mon, 18 Feb 2019 03:21:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 119F48E0001; Mon, 18 Feb 2019 03:21:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 006608E0005; Mon, 18 Feb 2019 03:21:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id 86CCF8E0001
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 03:21:00 -0500 (EST)
Received: by mail-lf1-f72.google.com with SMTP id i19so1293513lfi.4
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 00:21:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:date:message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=j6lf0s+rCUNA4g/UtrK/iEyQd+zeh9+HicFeiMIFdjA=;
        b=reTchkWKtir7BMd8QIDzimARplMMGVAGutoPpvHCzOnfTF6YFmVFSy7lEJ/V75riyV
         3ZUddlZn4QG0MOZgsuXJIRz6ZPLhlwtTpch1RVhR+6G8/fGHetfcMdltzDY9ogmTlyWa
         XqJuz+cP0oAuegbGr7QORUBvxOAIygAlP7Vja+vCfoqjM1ywqt07sC2jwO7k2cflTGCn
         wp625eJW9hCSBUWvh+oMMvN/0MzARUl1gENMZrrNoGJZkUqRW13esz+LnS0DzX3FPNtX
         dOPCiaJW/7TYfBqzs8ra9ATt9bXUtRshzjUwZ90verO6YSpmXfESgGvo0xqzwa/XHFKp
         vhvg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: AHQUAub6ZbljL9zQLg/G3rbYfKUMSjWB7aRBK21jcYmeTmEULApc5xI6
	Tkj9N0KnH8LjQ9R4EasfRlB24ngQbp/22Nfq5VLOLbKbQtHfmejQR4QDFPBCS0UHxWDGSMfk55O
	Xiu1S6OxISIi0lNEqfZhe8lUXhdyhvaZwkr9cpKce9Lgf1oGxcY+G8FdwtFK/lROHiQ==
X-Received: by 2002:a2e:9a09:: with SMTP id o9-v6mr13243356lji.132.1550478059768;
        Mon, 18 Feb 2019 00:20:59 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ibc0sGnkwUGcR6tsNljbZmgU8EwYql49FbFt9asu7W6EPhkcSjfd3em10iYwqMObF0zLdNX
X-Received: by 2002:a2e:9a09:: with SMTP id o9-v6mr13243294lji.132.1550478058294;
        Mon, 18 Feb 2019 00:20:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550478058; cv=none;
        d=google.com; s=arc-20160816;
        b=RpH4OeB86Fi5/yz7Z0NFjqrcQ7Jwz6TNeoYZNLbpwPtnTMQ9Gs2JUT84VfSXhsBdK2
         f2cdCq4caMl0CJbKk4Hm2LnPHGOSiel42RqBpTC1FNIarJg5g/7PZOW6nRaZaTjcPKXT
         CemqYm3D3o0jqLq8NnbSg/9LLVwoTyHrDeXdodM1ZgfvlzDJ8Bt4xLe39L2GiY3d3PFo
         IO3ZzAlRT/z8f+SO3/M5dHXGJccQHygsa5I2jBSQABQIn4ra1qG0qs/KLf4HaECTFA0f
         atCnsUQP6podu2Un8mBKfA8G52EYgPcXIZok1gTdfqlbmBjNNVaHhKZKM1BuKeZGjUYj
         7FrA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:to:from:subject;
        bh=j6lf0s+rCUNA4g/UtrK/iEyQd+zeh9+HicFeiMIFdjA=;
        b=j9er5V3TnSIYWc6300y7iaRQgjiMeJk44w29+Nku2D5MLo6AXU8yFhD/NyXHpX74HP
         OQ3xz4cA7cASGDXuvpO0+7aNvRtbbZdamSntcz8Nx4GPcB+B52x2adw3OGuVDVjfkwQ0
         PNDLdHAiVpqZX3DStcj6qH3l2qvJZazaHcOPUMh7rSxEeQHo6bQzqvemZPz0jfkJDrg4
         b6MZosZFTNlo1v9wrJ0+YI1XQqsqRycPLLLdR7JAP0jPms9dM1Dn6oWVDyTjauTbvJyK
         xkQ9SeONYCisVrH/kM9X9wWG4h2CzTncPriKUhspudBQpLt/ZJXRjkZXa5hecKis+7EB
         DBRw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id i13si11197753lfc.125.2019.02.18.00.20.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 00:20:57 -0800 (PST)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169] (helo=localhost.localdomain)
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1gveAU-0007pQ-2n; Mon, 18 Feb 2019 11:20:50 +0300
Subject: [PATCH v3 1/4] mm: Move recent_rotated pages calculation to
 shrink_inactive_list()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
To: akpm@linux-foundation.org, daniel.m.jordan@oracle.com, mhocko@suse.com,
 ktkhai@virtuozzo.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Date: Mon, 18 Feb 2019 11:20:49 +0300
Message-ID: <155047804982.13111.9002323194452834079.stgit@localhost.localdomain>
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
Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>

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
 


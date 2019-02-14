Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73FF7C10F05
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 10:35:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 329BF222D4
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 10:35:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 329BF222D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C66E18E0003; Thu, 14 Feb 2019 05:35:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BECA78E0001; Thu, 14 Feb 2019 05:35:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ADEA88E0003; Thu, 14 Feb 2019 05:35:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4108C8E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 05:35:30 -0500 (EST)
Received: by mail-lf1-f72.google.com with SMTP id i203so558733lfg.10
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 02:35:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:date:message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=CAV5JrJk5VzPBdBegT7Rv/NudD3qrGSx97JRxyoZycw=;
        b=Zd51afL3BwggL32W0ERQ/fJ7EYS9wejpY4l0apYY8KBCMFa703Vcp/gmOqYs3NuM8J
         jYYEbe6gRqD6l4KVS8IUqKcp6SkBujn99Jmh73T49psNEYr7VfcZBWsnWr1NxMklAgVW
         WFBSAwHa6FgCAMkIYmXDQsAzi2sc1sJdA3TwKFxavmMexneDq6McjAJ+0nRZjPhCTlx/
         jbic94V6J1NQbpcb96lmUnJajSILFiJOR1fYbCxEMOSIWNpafL41zHoI/zlq+J6ILz9Q
         8Z/ixYJ9mnsQS7lsLePw9jtLayll0EFN8HqtTVwy8p0B878mpdd5+3zJsuCsl7CPMOUu
         R0aA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: AHQUAuZuQ+OkK7ZCoT6iHDH5tGnuQXsPuvQPlUtWmkCXjx5kYuSJzR1J
	7DuMYEzjtWQhdIoewQz4suEzhZoIFLCCn2Gyu8JvhamHL6/A4YK7BZ9y+8iq0c4pwSRqm9hJH/I
	jYTQun4f/d8Ja9oB60aZrk64KuuXuWocKiQ+o+febu7AbxCnfnUkJdwI8ujZ3I7CFvQ==
X-Received: by 2002:a19:384c:: with SMTP id d12mr1808640lfj.105.1550140529562;
        Thu, 14 Feb 2019 02:35:29 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZDgYvH950Y+J50nJYp5TpqsUK8EiPLN3WtHeNlGpFuglTK/Brs14hRl+XhoZM0NerejXot
X-Received: by 2002:a19:384c:: with SMTP id d12mr1808591lfj.105.1550140528370;
        Thu, 14 Feb 2019 02:35:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550140528; cv=none;
        d=google.com; s=arc-20160816;
        b=Vnu7Xxy/+G1RjCQ5v2zJi7ItW3DAPS9IuOn/vMET/jo/CX+PY7weD4X9f6U9h5UBpk
         For4pMl+Q7krcAX78SKm5aN4g6V1g9RND8E6na8cNPMy8DYO7mwckvM3uoX1njZvPPq5
         +JJ7daIw0gtibEwd0jA1IzZQ+jfGeOF0RxIC9eKVKri4jWFCR51laoPrALc3uOaYqeg3
         R6DaGkxy8RtvOJQwC0ug8deMUWeWSWkWyuXJtKemn6TTgnWzO9rQ8os5Q2c/9cu5uaFr
         GT2EY+YpePPs1G4LVWW2EzGHycz0q89cgTG5gLygKIh8J8orqahuxFnjP6LOJp6Xjak2
         M4zQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:to:from:subject;
        bh=CAV5JrJk5VzPBdBegT7Rv/NudD3qrGSx97JRxyoZycw=;
        b=jihZ49HPHzAbikP3HssN/ub/pWPhRMHKnmsYtBX8ZR+6lAbA+AsOnEx3yuOhEXF3lI
         cxqrzEHPfPaB4JrNAnKVPXNxA1vQ8b8VatYj/R96yqlw+jE4XzDkvlkNq1K2JpTqcMwr
         S0es1HT0yeSodWKvxfM7RkYCytQJnI0GfcCP2YZO9+z9t4Rz6jXHZ+SzazhlrjQcptJk
         dW5jCmvJ7a+qXwxSM69/TG6uSsBFhs+PFijYuqk3qip140VUtkmvRBY7zPBHzBOKYWLM
         B0R3h7SDkVKlYsi6H5DdPSIU8T7f6+4m4OYv1VpeZnW4Wba44PzalDVJTej8+PJJuC+E
         awOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id v13si1823863lfd.11.2019.02.14.02.35.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 02:35:28 -0800 (PST)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169] (helo=localhost.localdomain)
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1guEMT-000532-Ia; Thu, 14 Feb 2019 13:35:21 +0300
Subject: [PATCH v2 1/4] mm: Move recent_rotated pages calculation to
 shrink_inactive_list()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
To: akpm@linux-foundation.org, daniel.m.jordan@oracle.com, mhocko@suse.com,
 ktkhai@virtuozzo.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Date: Thu, 14 Feb 2019 13:35:21 +0300
Message-ID: <155014052145.28944.16497030123804725057.stgit@localhost.localdomain>
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

Currently, struct reclaim_stat::nr_activate is a local variable,
used only in shrink_page_list(). This patch introduces another
local variable pgactivate to use instead of it, and reuses
nr_activate to account number of active pages.

Note, that we need nr_activate to be an array, since type of page
may change during shrink_page_list() (see ClearPageSwapBacked()).

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>

v2: Update trace events.
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
 


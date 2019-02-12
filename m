Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3AD8CC282CA
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 15:14:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 03711217D9
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 15:14:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 03711217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A8B018E0006; Tue, 12 Feb 2019 10:14:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A16778E0001; Tue, 12 Feb 2019 10:14:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 891058E0006; Tue, 12 Feb 2019 10:14:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 166828E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 10:14:03 -0500 (EST)
Received: by mail-lf1-f71.google.com with SMTP id y13so341438lfg.14
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 07:14:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:date:message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=+YnQWQrQxrmDkSR8GKuGkhxf0mUW96FaQ/F8qD8cZvs=;
        b=TsYt6fzzgWPMrArtAxKQzEhZoLZjMqasYh0bJuAumfVPTFwtTTsqD60uhNnjwneTGR
         0M6hDFSawo6FAKUrIm/dZIcxxkClr6aunaHLNeobamySfiLygbGXs52eUpnw2PBAzcr8
         eIDNMTbASF9hlsXlta4+NE7SQY/BvGzgK5HTKgYcLWXhDpe57E14lguZT1ElCGE4UfNR
         SYjvZwZ2p1k7cCjGU9CG4kj5gCHBO2G1yuR0gJie8MRlzSdxLveG8pucMT60lML8GG7h
         s7CDaz7QHcg5BjRx1MEqMZIFtBQtiNwowVZZmRxofi6635pwYm1MPxoB1RTwHFosUkiJ
         wNdw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: AHQUAuZ3Z0hBFTzU00b2yqNId9z87vRds2GZAr4BfR8wQ8LBbYOS3Ukq
	PrgueRsAQOidf2xpkDIev8nO5pVxTAjPEuX4aHSR4Ts+xGFmS0O38DAHOOiJu3e9lK+A+RR/YR5
	XzTxgOXKGuXRTgGbDspgp3WfJ7B2j58bv2WSoVIjQCppNjcMqct1GJURBTE9D4CgbpA==
X-Received: by 2002:ac2:5085:: with SMTP id f5mr2750227lfm.30.1549984442374;
        Tue, 12 Feb 2019 07:14:02 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbmKOyZe9tS/Topf/j96JpZzCxjZF8s7EDJsv5JGh9nlm+vYkpaV/kB4WtgWSmn5yirduQU
X-Received: by 2002:ac2:5085:: with SMTP id f5mr2750160lfm.30.1549984441215;
        Tue, 12 Feb 2019 07:14:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549984441; cv=none;
        d=google.com; s=arc-20160816;
        b=zzrPpml/+1RyxdYbTsYKe68uBAQPWNAniSnWREAR70uR3wRgDAnKhGGMwBrLLOF9X6
         0K2ZhMYEPoTQ3G6eKkm3NMyav2JZcPg8xtR8N/cIHiB3YSzMrv8d2tsiLbnQe0qyf8tx
         FlkN11j2m+E0cBjvXfBnedAOPfAjPbBrGfLnn14hGyq4UTkqo5hJxqGyu8PLRBp6BMPY
         qrrC5lqPxtpuxObANaGNeWeIgsWPD0Hfb50pC8+coTpGEWxYP+pjjf7rMgrD3V0lWegD
         JAdT8pdX3tOAnmbFTPEhrtHLpjyQI/ufprlRtPKF8eu0+BzBCKUxW23nGnT7vRnIQJd/
         Vx6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:to:from:subject;
        bh=+YnQWQrQxrmDkSR8GKuGkhxf0mUW96FaQ/F8qD8cZvs=;
        b=KcuOUNkrNu+4RjrDHe/sS8znEwQJKNcn99xlrdbXvFRvR4kCa/p4BvT13OaznOzJSr
         0hAp8MMI+juPp0ve6WKJ7dA8gBdUXxqvuPR88+IUybRQmHFfXgQSF5DUXfdx3PRp9JfF
         H365tMDroTebSP3bSpwKIHCSG8CbAhzQKs+fNOTf1lnqyaoewELvP78IsGWqlAJi6p/z
         teAozBveICNEALaRXK35dSl4cW5SF8kmjv8dT4YWGEya8sBu1kyZyJhV33ZvevH14qzF
         2gKBnBsXPUu2MkSzUU6Z8QfNj0TgR19ZZlDnSxBnMaG2cmMw23pczwtncP99NJzp1yYp
         mVtw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id n21si2210604lfa.98.2019.02.12.07.14.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 07:14:01 -0800 (PST)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169] (helo=localhost.localdomain)
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1gtZl2-0001Yn-Px; Tue, 12 Feb 2019 18:14:00 +0300
Subject: [PATCH 1/4] mm: Move recent_rotated pages calculation to
 shrink_inactive_list()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
To: akpm@linux-foundation.org, mhocko@suse.com, ktkhai@virtuozzo.com,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
Date: Tue, 12 Feb 2019 18:14:00 +0300
Message-ID: <154998444053.18704.14821278988281142015.stgit@localhost.localdomain>
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

Currently, struct reclaim_stat::nr_activate is a local variable,
used only in shrink_page_list(). This patch introduces another
local variable pgactivate to use instead of it, and reuses
nr_activate to account number of active pages.

Note, that we need nr_activate to be an array, since type of page
may change during shrink_page_list() (see ClearPageSwapBacked()).

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 include/linux/vmstat.h |    2 +-
 mm/vmscan.c            |   15 +++++++--------
 2 files changed, 8 insertions(+), 9 deletions(-)

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
 


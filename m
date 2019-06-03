Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E9606C04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 21:08:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9640D241B1
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 21:08:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="JQ5yhRf4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9640D241B1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F7836B027A; Mon,  3 Jun 2019 17:08:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 058526B027B; Mon,  3 Jun 2019 17:08:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D51B46B027C; Mon,  3 Jun 2019 17:08:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9A0136B027A
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 17:08:49 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id c17so2029130pfb.21
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 14:08:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=KSFw6UqIUAUxKrMDMZ5bH9ogt1Vx0fiDNTjI7FIJO1I=;
        b=ej8kgniT5ndTT6mc298nW99iSsUpJa5CbFYYaRjH6OtBlH5d4R0xjNdFMjEBp+nWD4
         jYkQZI7xRIQmwS2fmv2gDQMn9WsIAng0WC1iDVMdS/vT/Vev3aCmfJchAlEUW0vsri1K
         6sGZ00HfE/Ce2bOdLmIjfOnGvUYU7GTlsdHbm/0myOK4Vkn6nAjSMcbZ+QFf4lGCLJQU
         q76Ex2DrJum0J3BNhtxAoZCuGudQb20ajAxjKtAseukQxrQ/eEpif3qZ032WW3vZK8iF
         WzX3Kq2U9PKBN5h6ZFQvSBoDJVmyjmhEnBApfdJ1utaccM73TDRS31muIXWQPRub5A2t
         0JQg==
X-Gm-Message-State: APjAAAXfUqO9cBLzvzif9HCKrpobG6vnT4Pz9RzgGgqyEP7agIzXOTZT
	NxyNjyeSZpZHEMZ9r0aOxPxffbP91OrXFDwBPABL4MqUM1U582jvbT/mDscSESLNVBaRi6t/ykJ
	iacI3DHePl253Ar9RSFRm7yriIJuD2P2pUefgic6b0HMcJWYHKUpp1i5N3qDbV4/p5w==
X-Received: by 2002:aa7:9203:: with SMTP id 3mr34617227pfo.123.1559596129079;
        Mon, 03 Jun 2019 14:08:49 -0700 (PDT)
X-Received: by 2002:aa7:9203:: with SMTP id 3mr34617061pfo.123.1559596127640;
        Mon, 03 Jun 2019 14:08:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559596127; cv=none;
        d=google.com; s=arc-20160816;
        b=txZD844hHmyw3q/JK3wfXayWZtUCNOR4A89C6yKGR2qSRHIHJ2lfw3Rk8C5xqPq9Bx
         SWAdER5yA3kp4naHfcEqHud4Uu1cQtVNz3S/oJph41NxV9rHv9jPTjcJq7WWVPBlK04f
         FN1eQzRjduidxkGuAClRp8XbICFL6EsdFAFbO5pRYcT/D4mcZXHjtgJsIuTBrownFIY5
         s4S/lrvB4Ir9Z5i6TnYwAwhZI+ItyJlIrGuNN9/Y+meDJ2OTLb2ExVs5Vmr8qMY1X9nd
         N1N1aH9mm8EooqTyhTnhaRDg6DLcrheFRZqyFM4FRMeKO2/hNM5QbNZ+k7ByeotjLT2E
         +oJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=KSFw6UqIUAUxKrMDMZ5bH9ogt1Vx0fiDNTjI7FIJO1I=;
        b=AgdO72EZIcd6/EgN928CVM719VLLD4YuTA+IIuyDGdcRkba7ay5gKkHR8ITUOV6HBB
         zjTBZExizJkdn7GLO4Scs0TIretngJJQYlT7qQ9hN7b25lb256uO0llwuEuMWEH5ld19
         iF+xi5uPu74mFYx7eDM+RgQmWW4v/Fp1GQFhQYEAIvZJtKSLzu5YjvaiRfKdzY8USOt+
         nopFlZqJxWKF4ItMpJedV1ZunV/War12RVycmaKLVISp2GvGB8x7+ix9KvpfOmxFCG7p
         on8N+FA3hZGrksx2a23syFNIf+B1dDdPRm7u+NHAoEVyBCz8G+0jKddpJbhFm7SYEFQB
         cbtg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=JQ5yhRf4;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id ce5sor18229682plb.17.2019.06.03.14.08.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 14:08:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=JQ5yhRf4;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=KSFw6UqIUAUxKrMDMZ5bH9ogt1Vx0fiDNTjI7FIJO1I=;
        b=JQ5yhRf4xOamEI7RraqoEXJphDySauJdGOeiTVixaZFJSg7e45kJelp1MVAg2pWzl8
         2pSdMhIaHfjVUfb58hAQ0h42WNUytSIxCl+jHgwplFWjdF/ert2FjaLjMk4qr65RnfF9
         PeopQtt/DlL/qVNZgoRHtZDKi/tvZwRrTIDkoDol1umDJ08XDwiKMRSDJTEzKW1w3Y5k
         qmYr7UwqwPrP19G46F9cHLRDTOR1dB9+K9Nk7WIj0cG2UKQJ8ae4S7qwuLyVKDKNQ5Ez
         To8a9pSigqlGJfBnTnLbEuEU0vg1Zp6uscBSqJlVLsJH2aJKq2meu/IHN3qP9OJ27ksZ
         XUeQ==
X-Google-Smtp-Source: APXvYqxhekrAeS4MNWMZ11e88dncPTFMLk2ht4wkuPxZo4rVekMrpq/gu1c9FfM4OkjwntgkJLKc4g==
X-Received: by 2002:a17:902:7c03:: with SMTP id x3mr7501223pll.242.1559596126911;
        Mon, 03 Jun 2019 14:08:46 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::1:9fa4])
        by smtp.gmail.com with ESMTPSA id j23sm4643592pgb.63.2019.06.03.14.08.45
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Jun 2019 14:08:46 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Suren Baghdasaryan <surenb@google.com>,
	Michal Hocko <mhocko@suse.com>,
	linux-mm@kvack.org,
	cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: [PATCH 11/11] mm: vmscan: enforce inactive:active ratio at the reclaim root
Date: Mon,  3 Jun 2019 17:07:46 -0400
Message-Id: <20190603210746.15800-12-hannes@cmpxchg.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190603210746.15800-1-hannes@cmpxchg.org>
References: <20190603210746.15800-1-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We split the LRU lists into inactive and an active parts to maximize
workingset protection while allowing just enough inactive cache space
to faciltate readahead and writeback for one-off file accesses (e.g. a
linear scan through a file, or logging); or just enough inactive anon
to maintain recent reference information when reclaim needs to swap.

With cgroups and their nested LRU lists, we currently don't do this
correctly. While recursive cgroup reclaim establishes a relative LRU
order among the pages of all involved cgroups, inactive:active size
decisions are done on a per-cgroup level. As a result, we'll reclaim a
cgroup's workingset when it doesn't have cold pages, even when one of
its siblings has plenty of it that should be reclaimed first.

For example: workload A has 50M worth of hot cache but doesn't do any
one-off file accesses; meanwhile, parallel workload B scans files and
rarely accesses the same page twice.

If these workloads were to run in an uncgrouped system, A would be
protected from the high rate of cache faults from B. But if they were
put in parallel cgroups for memory accounting purposes, B's fast cache
fault rate would push out the hot cache pages of A. This is unexpected
and undesirable - the "scan resistance" of the page cache is broken.

This patch moves inactive:active size balancing decisions to the root
of reclaim - the same level where the LRU order is established.

It does this by looking at the recursize size of the inactive and the
active file sets of the cgroup subtree at the beginning of the reclaim
cycle, and then making a decision - scan or skip active pages - that
applies throughout the entire run and to every cgroup involved.

With that in place, in the test above, the VM will recognize that
there are plenty of inactive pages in the combined cache set of
workloads A and B and prefer the one-off cache in B over the hot pages
in A. The scan resistance of the cache is restored.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/mmzone.h |   4 +-
 mm/vmscan.c            | 183 +++++++++++++++++++++++++----------------
 2 files changed, 116 insertions(+), 71 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index b3ab64cf5619..8d100905c2ec 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -270,12 +270,12 @@ enum lru_list {
 
 #define for_each_evictable_lru(lru) for (lru = 0; lru <= LRU_ACTIVE_FILE; lru++)
 
-static inline int is_file_lru(enum lru_list lru)
+static inline bool is_file_lru(enum lru_list lru)
 {
 	return (lru == LRU_INACTIVE_FILE || lru == LRU_ACTIVE_FILE);
 }
 
-static inline int is_active_lru(enum lru_list lru)
+static inline bool is_active_lru(enum lru_list lru)
 {
 	return (lru == LRU_ACTIVE_ANON || lru == LRU_ACTIVE_FILE);
 }
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 6b7bd5708c73..6af35bb02da0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -79,6 +79,11 @@ struct scan_control {
 	 */
 	struct mem_cgroup *target_mem_cgroup;
 
+	/* Can active pages be deactivated as part of reclaim? anon=0 file=1 */
+	unsigned int may_deactivate:2;
+	unsigned int force_deactivate:1;
+	unsigned int skipped_deactivate:1;
+
 	/* Writepage batching in laptop mode; RECLAIM_WRITE */
 	unsigned int may_writepage:1;
 
@@ -104,6 +109,9 @@ struct scan_control {
 	/* One of the zones is ready for compaction */
 	unsigned int compaction_ready:1;
 
+	/* There is easily reclaimable cold cache in the current node */
+	unsigned int cache_trim_mode:1;
+
 	/* The file pages on the current node are dangerously low */
 	unsigned int file_is_tiny:1;
 
@@ -2084,6 +2092,20 @@ static void shrink_active_list(unsigned long nr_to_scan,
 			nr_deactivate, nr_rotated, sc->priority, file);
 }
 
+static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
+				 struct lruvec *lruvec, struct scan_control *sc)
+{
+	if (is_active_lru(lru)) {
+		if (sc->may_deactivate & (1 << is_file_lru(lru)))
+			shrink_active_list(nr_to_scan, lruvec, sc, lru);
+		else
+			sc->skipped_deactivate = 1;
+		return 0;
+	}
+
+	return shrink_inactive_list(nr_to_scan, lruvec, sc, lru);
+}
+
 /*
  * The inactive anon list should be small enough that the VM never has
  * to do too much work.
@@ -2112,59 +2134,25 @@ static void shrink_active_list(unsigned long nr_to_scan,
  *    1TB     101        10GB
  *   10TB     320        32GB
  */
-static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
-				 struct scan_control *sc, bool actual_reclaim)
+static bool inactive_is_low(struct lruvec *lruvec, enum lru_list inactive_lru)
 {
-	enum lru_list active_lru = file * LRU_FILE + LRU_ACTIVE;
-	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
-	enum lru_list inactive_lru = file * LRU_FILE;
+	enum lru_list active_lru = inactive_lru + LRU_ACTIVE;
 	unsigned long inactive, active;
 	unsigned long inactive_ratio;
-	struct lruvec *target_lruvec;
-	unsigned long refaults;
 	unsigned long gb;
 
-	inactive = lruvec_lru_size(lruvec, inactive_lru, sc->reclaim_idx);
-	active = lruvec_lru_size(lruvec, active_lru, sc->reclaim_idx);
+	inactive = lruvec_page_state(lruvec, inactive_lru);
+	active = lruvec_page_state(lruvec, active_lru);
 
-	/*
-	 * When refaults are being observed, it means a new workingset
-	 * is being established. Disable active list protection to get
-	 * rid of the stale workingset quickly.
-	 */
-	target_lruvec = mem_cgroup_lruvec(sc->target_mem_cgroup, pgdat);
-	refaults = lruvec_page_state(target_lruvec, WORKINGSET_ACTIVATE);
-	if (file && actual_reclaim && target_lruvec->refaults != refaults) {
-		inactive_ratio = 0;
-	} else {
-		gb = (inactive + active) >> (30 - PAGE_SHIFT);
-		if (gb)
-			inactive_ratio = int_sqrt(10 * gb);
-		else
-			inactive_ratio = 1;
-	}
-
-	if (actual_reclaim)
-		trace_mm_vmscan_inactive_list_is_low(pgdat->node_id, sc->reclaim_idx,
-			lruvec_lru_size(lruvec, inactive_lru, MAX_NR_ZONES), inactive,
-			lruvec_lru_size(lruvec, active_lru, MAX_NR_ZONES), active,
-			inactive_ratio, file);
+	gb = (inactive + active) >> (30 - PAGE_SHIFT);
+	if (gb)
+		inactive_ratio = int_sqrt(10 * gb);
+	else
+		inactive_ratio = 1;
 
 	return inactive * inactive_ratio < active;
 }
 
-static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
-				 struct lruvec *lruvec, struct scan_control *sc)
-{
-	if (is_active_lru(lru)) {
-		if (inactive_list_is_low(lruvec, is_file_lru(lru), sc, true))
-			shrink_active_list(nr_to_scan, lruvec, sc, lru);
-		return 0;
-	}
-
-	return shrink_inactive_list(nr_to_scan, lruvec, sc, lru);
-}
-
 enum scan_balance {
 	SCAN_EQUAL,
 	SCAN_FRACT,
@@ -2226,28 +2214,17 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
 
 	/*
 	 * If the system is almost out of file pages, force-scan anon.
-	 * But only if there are enough inactive anonymous pages on
-	 * the LRU. Otherwise, the small LRU gets thrashed.
 	 */
-	if (sc->file_is_tiny &&
-	    !inactive_list_is_low(lruvec, false, sc, false) &&
-	    lruvec_lru_size(lruvec, LRU_INACTIVE_ANON,
-			    sc->reclaim_idx) >> sc->priority) {
+	if (sc->file_is_tiny) {
 		scan_balance = SCAN_ANON;
 		goto out;
 	}
 
 	/*
-	 * If there is enough inactive page cache, i.e. if the size of the
-	 * inactive list is greater than that of the active list *and* the
-	 * inactive list actually has some pages to scan on this priority, we
-	 * do not reclaim anything from the anonymous working set right now.
-	 * Without the second condition we could end up never scanning an
-	 * lruvec even if it has plenty of old anonymous pages unless the
-	 * system is under heavy pressure.
+	 * If there is enough inactive page cache, we do not reclaim
+	 * anything from the anonymous working right now.
 	 */
-	if (!inactive_list_is_low(lruvec, true, sc, false) &&
-	    lruvec_lru_size(lruvec, LRU_INACTIVE_FILE, sc->reclaim_idx) >> sc->priority) {
+	if (sc->cache_trim_mode) {
 		scan_balance = SCAN_FILE;
 		goto out;
 	}
@@ -2512,7 +2489,7 @@ static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
 	 * Even if we did not try to evict anon pages at all, we want to
 	 * rebalance the anon lru active/inactive ratio.
 	 */
-	if (total_swap_pages && inactive_list_is_low(lruvec, false, sc, true))
+	if (total_swap_pages && inactive_is_low(lruvec, LRU_INACTIVE_ANON))
 		shrink_active_list(SWAP_CLUSTER_MAX, lruvec,
 				   sc, LRU_ACTIVE_ANON);
 }
@@ -2686,6 +2663,7 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 	unsigned long nr_reclaimed, nr_scanned;
 	struct lruvec *target_lruvec;
 	bool reclaimable = false;
+	unsigned long file;
 
 	target_lruvec = mem_cgroup_lruvec(sc->target_mem_cgroup, pgdat);
 
@@ -2695,6 +2673,44 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 	nr_reclaimed = sc->nr_reclaimed;
 	nr_scanned = sc->nr_scanned;
 
+	/*
+	 * Target desirable inactive:active list ratios for the anon
+	 * and file LRU lists.
+	 */
+	if (!sc->force_deactivate) {
+		unsigned long refaults;
+
+		if (inactive_is_low(target_lruvec, LRU_INACTIVE_ANON))
+			sc->may_deactivate |= 1;
+		else
+			sc->may_deactivate &= ~1;
+
+		/*
+		 * When refaults are being observed, it means a new
+		 * workingset is being established. Deactivate to get
+		 * rid of any stale active pages quickly.
+		 */
+		refaults = lruvec_page_state(target_lruvec,
+					     WORKINGSET_ACTIVATE);
+		if (refaults != target_lruvec->refaults ||
+		    inactive_is_low(target_lruvec, LRU_INACTIVE_FILE))
+			sc->may_deactivate |= 2;
+		else
+			sc->may_deactivate &= ~2;
+	} else
+		sc->may_deactivate = 3;
+
+	/*
+	 * If we have plenty of inactive file pages that aren't
+	 * thrashing, try to reclaim those first before touching
+	 * anonymous pages.
+	 */
+	file = lruvec_page_state(target_lruvec, LRU_INACTIVE_FILE);
+	if (file >> sc->priority && !(sc->may_deactivate & 2))
+		sc->cache_trim_mode = 1;
+	else
+		sc->cache_trim_mode = 0;
+
 	/*
 	 * Prevent the reclaimer from falling into the cache trap: as
 	 * cache pages start out inactive, every cache fault will tip
@@ -2705,10 +2721,9 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 	 * anon pages.  Try to detect this based on file LRU size.
 	 */
 	if (!cgroup_reclaim(sc)) {
-		unsigned long file;
-		unsigned long free;
-		int z;
 		unsigned long total_high_wmark = 0;
+		unsigned long free, anon;
+		int z;
 
 		free = sum_zone_node_page_state(pgdat->node_id, NR_FREE_PAGES);
 		file = node_page_state(pgdat, NR_ACTIVE_FILE) +
@@ -2722,7 +2737,17 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 			total_high_wmark += high_wmark_pages(zone);
 		}
 
-		sc->file_is_tiny = file + free <= total_high_wmark;
+		/*
+		 * If anon is low too, this isn't a runaway file
+		 * reclaim problem, but rather just extreme memory
+		 * pressure. Reclaim as per usual in that case.
+		 */
+		anon = node_page_state(pgdat, NR_INACTIVE_ANON);
+
+		sc->file_is_tiny =
+			file + free <= total_high_wmark &&
+			!(sc->may_deactivate & 1) &&
+			anon >> sc->priority;
 	}
 
 	shrink_node_memcgs(pgdat, sc);
@@ -3026,9 +3051,27 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 	if (sc->compaction_ready)
 		return 1;
 
+	/*
+	 * We make inactive:active ratio decisions based on the node's
+	 * composition of memory, but a restrictive reclaim_idx or a
+	 * memory.low cgroup setting can exempt large amounts of
+	 * memory from reclaim. Neither of which are very common, so
+	 * instead of doing costly eligibility calculations of the
+	 * entire cgroup subtree up front, we assume the estimates are
+	 * good, and retry with forcible deactivation if that fails.
+	 */
+	if (sc->skipped_deactivate) {
+		sc->priority = initial_priority;
+		sc->force_deactivate = 1;
+		sc->skipped_deactivate = 0;
+		goto retry;
+	}
+
 	/* Untapped cgroup reserves?  Don't OOM, retry. */
 	if (sc->memcg_low_skipped) {
 		sc->priority = initial_priority;
+		sc->force_deactivate = 0;
+		sc->skipped_deactivate = 0;
 		sc->memcg_low_reclaim = 1;
 		sc->memcg_low_skipped = 0;
 		goto retry;
@@ -3310,18 +3353,20 @@ static void age_active_anon(struct pglist_data *pgdat,
 				struct scan_control *sc)
 {
 	struct mem_cgroup *memcg;
+	struct lruvec *lruvec;
 
 	if (!total_swap_pages)
 		return;
 
+	lruvec = mem_cgroup_lruvec(NULL, pgdat);
+	if (!inactive_is_low(lruvec, LRU_INACTIVE_ANON))
+		return;
+
 	memcg = mem_cgroup_iter(NULL, NULL, NULL);
 	do {
-		struct lruvec *lruvec = mem_cgroup_lruvec(memcg, pgdat);
-
-		if (inactive_list_is_low(lruvec, false, sc, true))
-			shrink_active_list(SWAP_CLUSTER_MAX, lruvec,
-					   sc, LRU_ACTIVE_ANON);
-
+		lruvec = mem_cgroup_lruvec(memcg, pgdat);
+		shrink_active_list(SWAP_CLUSTER_MAX, lruvec,
+				   sc, LRU_ACTIVE_ANON);
 		memcg = mem_cgroup_iter(NULL, memcg, NULL);
 	} while (memcg);
 }
-- 
2.21.0


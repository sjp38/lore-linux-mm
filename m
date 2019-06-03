Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A11B7C04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 21:08:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4A0D9249C9
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 21:08:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="wc1IAI5z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4A0D9249C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0AAFE6B0272; Mon,  3 Jun 2019 17:08:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED94A6B0273; Mon,  3 Jun 2019 17:08:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BCABA6B0274; Mon,  3 Jun 2019 17:08:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 83B376B0272
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 17:08:33 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id c4so10757830pgm.21
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 14:08:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=/ECwKX3tAPVrwDHDKYOADHOjDCqITvrKBeA6eRqjWZs=;
        b=OeolZ0PFZIGfzdhA04/6V1hZBTKstaOBtd3jPBofhMJhW31q2NUMKqU9jfdFhEvgeZ
         EoxxV795m0cXC0e32xUOpDdLxVE0xK2/DNpGZrAG/Ln9x3Hlka1XKnMnGoenus0F5LJn
         7C7A5QcWuCcy/WaHmtAZVZIoArCY4SM3YipDJZtY47MAnx18xbcmiQhRiwTXR7mlhxVm
         yS4/daEnFHQa0uDxlsRlPfgejElBOjPkFWee/ClG+4XZ11UMbFUA58wpGwkelPQB1vvV
         05FSjI0qJCi0esuH7UoQWxyRT6IXMfGvDXa+uZXdWU9Rbxcw9+VTadbZjEB2E3u7NYdW
         WOFg==
X-Gm-Message-State: APjAAAXvHwCFa1fUrBq4z1LgESW+BQDC9qapXf04sqkne+fA3V5tdMBJ
	FpO4vAP5SWog+6racyq9ca5C7y/NP+vO9QvKs/UayjvjAAhytEaZo8dm2+KSYtd+iS3ulDQdUtF
	b0hiriy/sopygvnapuyJENCeYMMciDuBqId/zO9O/aIyVG3JkfrhS06f02KtsreBXtg==
X-Received: by 2002:aa7:8ece:: with SMTP id b14mr24584821pfr.244.1559596113048;
        Mon, 03 Jun 2019 14:08:33 -0700 (PDT)
X-Received: by 2002:aa7:8ece:: with SMTP id b14mr24584693pfr.244.1559596112005;
        Mon, 03 Jun 2019 14:08:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559596112; cv=none;
        d=google.com; s=arc-20160816;
        b=HXEWjXbgzRaw+/QKMqT33YFnNJ1mdXL01bU/p9zuxDxJpi/pIinItkDK2qsZBSO3Jv
         A3a6ci12tPx07q9dkirH1TRDYCyab1lXFUN6YmgQ/HPnEnmZiueXTVYMTRyg+n3JZkei
         Yv3hr5SL603F92xl5aktzEMfHQO0JhDy9ef5XRNlwbEOpHsb8G0t3gJE+waYSjG1cfpK
         YRP43CtvhpexeqsNFE2x5EIOQsoM8yLhiM2Q9f8Zxj2hUqfZsE4m/6vfFEK2t7g2WYZh
         6voqGmVM/wLCdamAVqNSbkkGp5H/0F8n0LiZIy4z/uYxSS9czdzL9RXecLBLgE6WzAoj
         pa1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=/ECwKX3tAPVrwDHDKYOADHOjDCqITvrKBeA6eRqjWZs=;
        b=vpfZtuytBQr3MLaNIv6ejWUSZlTHrLhxGn4g1uWZcLvslUcr8JzNh0jANQkhMT/6tE
         +8LLySwg83hz3kLgrC4yMsDGqNisuD9Oy+40LUj5ynd0JFkk4VLdR2V5c6w7mMZkLkdv
         Lw3ETU4FeiiQIq0btLJ+h5Bqy3ZqVZi7bKL9O+3h87E+0kEkueamKkblloquYa6Ei+Nq
         oxpRRSXfqzDvTaHuTiT03Wriq+TwVVPZH23K4EECDJqT5lR6bIoNncl6HryMdRB5AWi/
         lUmDIDIIwyD9G/cLCrgrphA05JaGWwnOWjkTeK+XfvSFaGJVXzIpqRMVLYtWPrNfjWfM
         4BEg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=wc1IAI5z;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m65sor18304424pfm.66.2019.06.03.14.08.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 14:08:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=wc1IAI5z;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=/ECwKX3tAPVrwDHDKYOADHOjDCqITvrKBeA6eRqjWZs=;
        b=wc1IAI5zkjEeNFD/HUHIIB2H4ZEiiwVM44Ba+r/EDaRF3+H7i/JdKOmLOc7GkpUaXZ
         nsmUhjtAzV6Xt8bZLVEcSDL1/ZUOBooQnG9O1/17mij+ggkqxQYuN5S6vLcYdIDVLQFd
         HheOIOvrDxa75BK5RdfurEfDBmnxdJSk7pB/Sr4G/PRfMm3jCCWh7pWJW+C3c8Ue7voh
         Bk09b4PFXAcp/azMkFm0cUu0GP9FagGP0M0WlvdSyz5/KYs0QJo2xMGEH9BHt+MEwAqK
         fFXTKl+Ep/ZRQl2YI8RuqcPatNZBQ540LUZXo2NCHuCOvic+kaKnJ8EiOvdAO80Fzg8A
         C+wg==
X-Google-Smtp-Source: APXvYqx/5Lrk+LdVqxZQme1ApdkTNrnq9skskkPna5IZ39YLgvkLp8SXhS67uQwguS5V8QjCLUPvmA==
X-Received: by 2002:aa7:8b49:: with SMTP id i9mr6357080pfd.74.1559596111356;
        Mon, 03 Jun 2019 14:08:31 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::1:9fa4])
        by smtp.gmail.com with ESMTPSA id m8sm23997383pff.137.2019.06.03.14.08.30
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Jun 2019 14:08:30 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Suren Baghdasaryan <surenb@google.com>,
	Michal Hocko <mhocko@suse.com>,
	linux-mm@kvack.org,
	cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: [PATCH 04/11] mm: vmscan: naming fixes: cgroup_reclaim() and writeback_working()
Date: Mon,  3 Jun 2019 17:07:39 -0400
Message-Id: <20190603210746.15800-5-hannes@cmpxchg.org>
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

Seven years after introducing the global_reclaim() function, I still
have to double take when reading a callsite. I don't know how others
do it. This is a terrible name.

Invert the meaning and rename it to cgroup_reclaim().

[ After all, "global reclaim" is just regular reclaim invoked from the
  page allocator. It's reclaim on behalf of a cgroup limit that is a
  special case of reclaim, and should be explicit - not the reverse. ]

sane_reclaim() isn't very descriptive either: it tests whether we can
use the regular writeback throttling - available during regular page
reclaim or cgroup2 limit reclaim - or need to use the broken
wait_on_page_writeback() method. Rename it to writeback_working().

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c | 38 ++++++++++++++++++--------------------
 1 file changed, 18 insertions(+), 20 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 69c4c82a9b5a..afd5e2432a8e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -239,13 +239,13 @@ static void unregister_memcg_shrinker(struct shrinker *shrinker)
 #endif /* CONFIG_MEMCG_KMEM */
 
 #ifdef CONFIG_MEMCG
-static bool global_reclaim(struct scan_control *sc)
+static bool cgroup_reclaim(struct scan_control *sc)
 {
-	return !sc->target_mem_cgroup;
+	return sc->target_mem_cgroup;
 }
 
 /**
- * sane_reclaim - is the usual dirty throttling mechanism operational?
+ * writeback_working - is the usual dirty throttling mechanism unavailable?
  * @sc: scan_control in question
  *
  * The normal page dirty throttling mechanism in balance_dirty_pages() is
@@ -257,11 +257,9 @@ static bool global_reclaim(struct scan_control *sc)
  * This function tests whether the vmscan currently in progress can assume
  * that the normal dirty throttling mechanism is operational.
  */
-static bool sane_reclaim(struct scan_control *sc)
+static bool writeback_working(struct scan_control *sc)
 {
-	struct mem_cgroup *memcg = sc->target_mem_cgroup;
-
-	if (!memcg)
+	if (!cgroup_reclaim(sc))
 		return true;
 #ifdef CONFIG_CGROUP_WRITEBACK
 	if (cgroup_subsys_on_dfl(memory_cgrp_subsys))
@@ -293,12 +291,12 @@ static bool memcg_congested(pg_data_t *pgdat,
 
 }
 #else
-static bool global_reclaim(struct scan_control *sc)
+static bool cgroup_reclaim(struct scan_control *sc)
 {
-	return true;
+	return false;
 }
 
-static bool sane_reclaim(struct scan_control *sc)
+static bool writeback_working(struct scan_control *sc)
 {
 	return true;
 }
@@ -1211,7 +1209,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				goto activate_locked;
 
 			/* Case 2 above */
-			} else if (sane_reclaim(sc) ||
+			} else if (writeback_working(sc) ||
 			    !PageReclaim(page) || !may_enter_fs) {
 				/*
 				 * This is slightly racy - end_page_writeback()
@@ -1806,7 +1804,7 @@ static int too_many_isolated(struct pglist_data *pgdat, int file,
 	if (current_is_kswapd())
 		return 0;
 
-	if (!sane_reclaim(sc))
+	if (!writeback_working(sc))
 		return 0;
 
 	if (file) {
@@ -1957,7 +1955,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	reclaim_stat->recent_scanned[file] += nr_taken;
 
 	item = current_is_kswapd() ? PGSCAN_KSWAPD : PGSCAN_DIRECT;
-	if (global_reclaim(sc))
+	if (!cgroup_reclaim(sc))
 		__count_vm_events(item, nr_scanned);
 	__count_memcg_events(lruvec_memcg(lruvec), item, nr_scanned);
 	spin_unlock_irq(&pgdat->lru_lock);
@@ -1971,7 +1969,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	spin_lock_irq(&pgdat->lru_lock);
 
 	item = current_is_kswapd() ? PGSTEAL_KSWAPD : PGSTEAL_DIRECT;
-	if (global_reclaim(sc))
+	if (!cgroup_reclaim(sc))
 		__count_vm_events(item, nr_reclaimed);
 	__count_memcg_events(lruvec_memcg(lruvec), item, nr_reclaimed);
 	reclaim_stat->recent_rotated[0] += stat.nr_activate[0];
@@ -2239,7 +2237,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	 * using the memory controller's swap limit feature would be
 	 * too expensive.
 	 */
-	if (!global_reclaim(sc) && !swappiness) {
+	if (cgroup_reclaim(sc) && !swappiness) {
 		scan_balance = SCAN_FILE;
 		goto out;
 	}
@@ -2263,7 +2261,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	 * thrashing file LRU becomes infinitely more attractive than
 	 * anon pages.  Try to detect this based on file LRU size.
 	 */
-	if (global_reclaim(sc)) {
+	if (!cgroup_reclaim(sc)) {
 		unsigned long pgdatfile;
 		unsigned long pgdatfree;
 		int z;
@@ -2494,7 +2492,7 @@ static void shrink_node_memcg(struct pglist_data *pgdat, struct mem_cgroup *memc
 	 * abort proportional reclaim if either the file or anon lru has already
 	 * dropped to zero at the first pass.
 	 */
-	scan_adjusted = (global_reclaim(sc) && !current_is_kswapd() &&
+	scan_adjusted = (!cgroup_reclaim(sc) && !current_is_kswapd() &&
 			 sc->priority == DEF_PRIORITY);
 
 	blk_start_plug(&plug);
@@ -2816,7 +2814,7 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 		 * Legacy memcg will stall in page writeback so avoid forcibly
 		 * stalling in wait_iff_congested().
 		 */
-		if (!global_reclaim(sc) && sane_reclaim(sc) &&
+		if (cgroup_reclaim(sc) && writeback_working(sc) &&
 		    sc->nr.dirty && sc->nr.dirty == sc->nr.congested)
 			set_memcg_congestion(pgdat, root, true);
 
@@ -2911,7 +2909,7 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 		 * Take care memory controller reclaiming has small influence
 		 * to global LRU.
 		 */
-		if (global_reclaim(sc)) {
+		if (!cgroup_reclaim(sc)) {
 			if (!cpuset_zone_allowed(zone,
 						 GFP_KERNEL | __GFP_HARDWALL))
 				continue;
@@ -3011,7 +3009,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 retry:
 	delayacct_freepages_start();
 
-	if (global_reclaim(sc))
+	if (!cgroup_reclaim(sc))
 		__count_zid_vm_events(ALLOCSTALL, sc->reclaim_idx, 1);
 
 	do {
-- 
2.21.0


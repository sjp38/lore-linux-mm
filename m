Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3309FC43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 20:03:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB41B2175B
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 20:03:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB41B2175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA9B36B000E; Thu, 21 Mar 2019 16:03:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9B9486B0010; Thu, 21 Mar 2019 16:03:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 410796B000C; Thu, 21 Mar 2019 16:03:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id CB73B6B000A
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 16:03:00 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 18so6444056pgx.11
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 13:03:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=awb2dSQuAJCZWSdScxKVVSAlrOniCFGJRyt4vv2Mf74=;
        b=iQX5x9DRzsQ/j+cKJMrMgfzteQSfDCFzVdwWPdQkWkVGrqM/reu+2ppXyW+4sZ4BF6
         Hjb6pktqrwCcSWYckYXsZ29UYYmHhaYSdsZSNFHARJGCnmC+E/Mo9R/XBMC7cxggL2nY
         C4hTXt2EKEGTSyxlyCaKd+XUu23gssy9PAdH0pYC87ksCAqKc+YrWh3bfYVj14lSrgpX
         2OrFSyMUsuhck0zPnjd32GT29ScCFg0RdgkzW5mwygelDqILeseT+MXVPUjDP5WcSYFP
         2mPGPAt/+p6FGmtGE+DyAEaIFEMh6QjxcsAYYDfk8JIHp01XEHsh6r4ok+segbb2fcbE
         VI9w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXE5UjlSmvGTp1qWlPrycxFwiKBWVOuSKs2I1BZePTMFEjAJGf5
	PqpLEqkQ9SaNVb5Ir4f7O/o/Yu5TFzxFcozpbvvL16xNN7O4UEzNjliq1WjxiUclc1HwW8xTqzi
	DARurMvuAUqQS+lTTmaMzRVntqzKnR4wZdXsm6rzVT3kzSIrrMVpirrPcc+wQWxjZ2Q==
X-Received: by 2002:a17:902:1c9:: with SMTP id b67mr5290944plb.176.1553198580441;
        Thu, 21 Mar 2019 13:03:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxsYeC/j3zS9Bdz2YboVHgjTSPjX0VAl1LdctPQXWT28PCmUcEECQwhwaKwqorc2h+3MFHG
X-Received: by 2002:a17:902:1c9:: with SMTP id b67mr5290836plb.176.1553198579028;
        Thu, 21 Mar 2019 13:02:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553198579; cv=none;
        d=google.com; s=arc-20160816;
        b=SMuo+dJpmWtmqZ1F/uuh/ngtJFwl3HPHKeOO3hda4aqdb1Xp1QNiU3siy9A7kUmudC
         vbZ34WNF77srq/aCMhV1y1EMhrgarNMrXOT8Nfve3gkuhIe+XkwdqyWyIuMOH4itmSvc
         R0IsD2zE2Z6co05F846RakPZCKqo+68NHIF/okWy4/yppB+MJmiEOSyML+UXkP3ge2pr
         A7VnBZ+4ePSHOVbVftjpFA+H5RcMQjbsF2DHAuaLlEadh25HkAsRhGPbXSNWvCOuPgS8
         d31oe9XK2J0AWCSH8pqttLe0UDQzkmJWmLb+8NCBOjMHyc+HtGldYpJdwRkv6OgoEiBk
         VP/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=awb2dSQuAJCZWSdScxKVVSAlrOniCFGJRyt4vv2Mf74=;
        b=ZSCEQW0yoYfzxrTtWeVLF81qEn7E0iGrTZjb54WR4RsDlAncTrSOqXmFX1o48SmtGw
         i1YfdsXYtvX1zBIeL18pqljtsVKphOGCYYfyn4puilmv7yQyAQOeNgq2kIFewshwNqx4
         9q36yGa16qg+PJmluTz1jG6KS207dlCAnnuXe1nDDa75yLc7FIP073Of5OOWdpZMtJPg
         NtxIztmCOebKaWxZzIse/sAf51mf/lNLyhH9KdD4gxMNsETXiCc8hGbwPqwX8zH+/Igq
         n/J06lTVqiqzpSbBs9KZbNXJraPbtjK4ZYoDL8EJuQEfjMUmkInccaxcQ7a16I6+zYtb
         TnvA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id r25si4703408pfd.91.2019.03.21.13.02.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 13:02:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 21 Mar 2019 13:02:58 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,254,1549958400"; 
   d="scan'208";a="309246245"
Received: from unknown (HELO localhost.lm.intel.com) ([10.232.112.69])
  by orsmga005.jf.intel.com with ESMTP; 21 Mar 2019 13:02:58 -0700
From: Keith Busch <keith.busch@intel.com>
To: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-nvdimm@lists.01.org
Cc: Dave Hansen <dave.hansen@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Keith Busch <keith.busch@intel.com>
Subject: [PATCH 4/5] mm: Consider anonymous pages without swap
Date: Thu, 21 Mar 2019 14:01:56 -0600
Message-Id: <20190321200157.29678-5-keith.busch@intel.com>
X-Mailer: git-send-email 2.13.6
In-Reply-To: <20190321200157.29678-1-keith.busch@intel.com>
References: <20190321200157.29678-1-keith.busch@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Age and reclaim anonymous pages from nodes that have an online migration node even
if swap is not enabled.

Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 include/linux/swap.h | 20 ++++++++++++++++++++
 mm/vmscan.c          | 10 +++++-----
 2 files changed, 25 insertions(+), 5 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 4bfb5c4ac108..91b405a3b44f 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -680,5 +680,25 @@ static inline bool mem_cgroup_swap_full(struct page *page)
 }
 #endif
 
+static inline bool reclaim_anon_pages(struct mem_cgroup *memcg,
+				      int node_id)
+{
+	/* Always age anon pages when we have swap */
+	if (memcg == NULL) {
+		if (get_nr_swap_pages() > 0)
+			return true;
+	} else {
+		if (mem_cgroup_get_nr_swap_pages(memcg) > 0)
+			return true;
+	}
+
+	/* Also age anon pages if we can auto-migrate them */
+	if (next_migration_node(node_id) >= 0)
+		return true;
+
+	/* No way to reclaim anon pages */
+	return false;
+}
+
 #endif /* __KERNEL__*/
 #endif /* _LINUX_SWAP_H */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 0a95804e946a..226c4c838947 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -327,7 +327,7 @@ unsigned long zone_reclaimable_pages(struct zone *zone)
 
 	nr = zone_page_state_snapshot(zone, NR_ZONE_INACTIVE_FILE) +
 		zone_page_state_snapshot(zone, NR_ZONE_ACTIVE_FILE);
-	if (get_nr_swap_pages() > 0)
+	if (reclaim_anon_pages(NULL, zone_to_nid(zone)))
 		nr += zone_page_state_snapshot(zone, NR_ZONE_INACTIVE_ANON) +
 			zone_page_state_snapshot(zone, NR_ZONE_ACTIVE_ANON);
 
@@ -2206,7 +2206,7 @@ static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
 	 * If we don't have swap space, anonymous page deactivation
 	 * is pointless.
 	 */
-	if (!file && !total_swap_pages)
+	if (!file && !reclaim_anon_pages(NULL, pgdat->node_id))
 		return false;
 
 	inactive = lruvec_lru_size(lruvec, inactive_lru, sc->reclaim_idx);
@@ -2287,7 +2287,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	enum lru_list lru;
 
 	/* If we have no swap space, do not bother scanning anon pages. */
-	if (!sc->may_swap || mem_cgroup_get_nr_swap_pages(memcg) <= 0) {
+	if (!sc->may_swap || !reclaim_anon_pages(memcg, pgdat->node_id)) {
 		scan_balance = SCAN_FILE;
 		goto out;
 	}
@@ -2650,7 +2650,7 @@ static inline bool should_continue_reclaim(struct pglist_data *pgdat,
 	 */
 	pages_for_compaction = compact_gap(sc->order);
 	inactive_lru_pages = node_page_state(pgdat, NR_INACTIVE_FILE);
-	if (get_nr_swap_pages() > 0)
+	if (!reclaim_anon_pages(NULL, pgdat->node_id))
 		inactive_lru_pages += node_page_state(pgdat, NR_INACTIVE_ANON);
 	if (sc->nr_reclaimed < pages_for_compaction &&
 			inactive_lru_pages > pages_for_compaction)
@@ -3347,7 +3347,7 @@ static void age_active_anon(struct pglist_data *pgdat,
 {
 	struct mem_cgroup *memcg;
 
-	if (!total_swap_pages)
+	if (!reclaim_anon_pages(NULL, pgdat->node_id))
 		return;
 
 	memcg = mem_cgroup_iter(NULL, NULL, NULL);
-- 
2.14.4


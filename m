Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58E6CC282CE
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 22:12:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EED8C21726
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 22:12:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WnKcALRd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EED8C21726
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 95C3B6B026B; Fri,  5 Apr 2019 18:12:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E3876B026C; Fri,  5 Apr 2019 18:12:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7845C6B026D; Fri,  5 Apr 2019 18:12:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 394DC6B026B
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 18:12:35 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id x5so5116107pll.2
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 15:12:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=uA3ehOa7Jw+A2AorvTLb7I9vCJ3fGJ8/5DDYOfi5sas=;
        b=fX3piJsN2IqWmvdKnfR6yM00hKNiJcU7gxSe8es83mtqBRfcr42Po4Mpw4jMsRzKZk
         ZgCLBdJsIM6DoZYN/eLwS+f4PHEomXe7yOYtQu/nUH2mRapK8eTrrhhiIGaYVURioOf9
         MnmymTr6j+ROgYCHWNgmngaYiY0NYfOYrNK9vvygbe3jhZYk6LRvOtxMqeStcmoIOh7n
         PdCeHNNX9WMCbgAhr8dC9ljQdWc3J5+y8NxvWeTu9tNvM262VQFtSRRe4/KpceNqBnC/
         d6opuN9ce0g3c0B5XkA3GqfmMGv/ga1DFrLe/Q2as5WGbLo+FjzNkLCRn13sqggLe05x
         hbmg==
X-Gm-Message-State: APjAAAWS/Sp09uFbGmmHaMKWu2lKyYB9oT4YyGzxjK+ln5Tqeom00x9p
	KsyKWU3klyqyBVqaqhSEpuo7olQWOFaavDwnRp7/RXoafqHDmfuOemVuplaPfgvMHdfp701U6O1
	4JbdmP/YlVdWKg+rsMYpZa1rEiM36rORXlWc7YI6bvB9YZ8o5Q8RTQb/OUsuOgOT+Rg==
X-Received: by 2002:a63:ce50:: with SMTP id r16mr11630278pgi.89.1554502354805;
        Fri, 05 Apr 2019 15:12:34 -0700 (PDT)
X-Received: by 2002:a63:ce50:: with SMTP id r16mr11630192pgi.89.1554502353620;
        Fri, 05 Apr 2019 15:12:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554502353; cv=none;
        d=google.com; s=arc-20160816;
        b=zeppFkovAdmt3p+tK5aGW0L/yGV71qyD+yhdWa1PVLvw8JgdFlnlZGf6BHHGi6SqnT
         aN1j+biFy10kodrwuVkdyRo1lotQIa195fcwkDPeYzJGzrPmMc624Je7IITxSrsopTCw
         ia98Vg2jyBg43CEbb2yFwgw+GIbIg3nJiNwS92AAOeLbJr8o2Y0+zd1MFwGuV9XTR9U9
         BUJw62Ie314JPU1A+1j6OGsSmaUH2FLN+uiC8dLsvk6s0LnFo1bzim9mROekvT6COZsQ
         Xgw11wmCDbWe1S8YHlqA9CSt6XhqqIVfy+hPZtelQ/NaKXzPksRSOXKbZ2iRhpPMpbFM
         TD4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=uA3ehOa7Jw+A2AorvTLb7I9vCJ3fGJ8/5DDYOfi5sas=;
        b=XvaoAODzuBB91ozNOpjWIi8lS2ERB0jdf4wWa0plWbEq0XYEsctosX5vZOyrj+eOSb
         1t1ey833rqHYCbjO6zJExhSQ5UQkr4TrP5SRT4bWzFaMvDft/2HmijutT4XhuLJ5QqI4
         M0RWMA1kxS6bUWfKDhBjmEXv2fsXY9Ppq+oe8xYsuqIFoXJbkTvviof8KhxQfrHKming
         snZYwSaPdYO4yp5DqKCEdAa2udUJ+ummXDp4mq+XiKQoHbx3xNYeCbvGOksoSl0ZBVGr
         TCRV9v2ozwhNCCrp63DU497Mjn6Ybggmw3dRaBrQE2XnOmQXQ3qvGNU5Ken3K1sOqpO9
         mQyw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WnKcALRd;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k4sor17299299pfa.53.2019.04.05.15.12.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 05 Apr 2019 15:12:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WnKcALRd;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=uA3ehOa7Jw+A2AorvTLb7I9vCJ3fGJ8/5DDYOfi5sas=;
        b=WnKcALRdTyp6pCXsE8JbLXwNSXmiTwrFsD86/ca15xC7u7WFUMr1dE7ApT0PWfBIj/
         fVBe++igQ81F0zOktIZCozX8rjRSnoaY/GpBr5fuTvNnGBXAU/EDVdcQ0j+YK8gSJeFp
         SozQ8JmKuk9ZMiwRigZonoRQ1Kju/DEIKDhTYiizw22qlnPVmsaxixL9bcZW32E+OvG7
         XHC2vZ1cNV5OSM9zq4yYXWIslODYdwvFMAYTmV7/VnGEQQYwI/TRwTOOL8ladUa+HnhF
         1iCWT8NRfzQ4w7IDGGxbRN7d6C/Zjv1zIzS70/GaGt3PS1S0zVGPPvA/WQa7F3kdFjsY
         gkUg==
X-Google-Smtp-Source: APXvYqyGZ2UBm/RKCejvVc5BO/RoTRbaNNjBjAA4639olLhxNtuws2N0qQgEDERakVOHFz2Xtsl69Q==
X-Received: by 2002:a65:5183:: with SMTP id h3mr14500620pgq.53.1554502353162;
        Fri, 05 Apr 2019 15:12:33 -0700 (PDT)
Received: from localhost.localdomain (50-126-100-225.drr01.csby.or.frontiernet.net. [50.126.100.225])
        by smtp.gmail.com with ESMTPSA id a3sm39604616pfn.182.2019.04.05.15.12.32
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Apr 2019 15:12:32 -0700 (PDT)
Subject: [mm PATCH v7 4/4] mm: Initialize MAX_ORDER_NR_PAGES at a time
 instead of doing larger sections
From: Alexander Duyck <alexander.duyck@gmail.com>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: pavel.tatashin@microsoft.com, mhocko@suse.com, dave.jiang@intel.com,
 linux-nvdimm@lists.01.org, alexander.h.duyck@linux.intel.com,
 linux-kernel@vger.kernel.org, willy@infradead.org, mingo@kernel.org,
 yi.z.zhang@linux.intel.com, khalid.aziz@oracle.com, rppt@linux.vnet.ibm.com,
 vbabka@suse.cz, sparclinux@vger.kernel.org, dan.j.williams@intel.com,
 ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, davem@davemloft.net,
 kirill.shutemov@linux.intel.com
Date: Fri, 05 Apr 2019 15:12:32 -0700
Message-ID: <20190405221231.12227.85836.stgit@localhost.localdomain>
In-Reply-To: <20190405221043.12227.19679.stgit@localhost.localdomain>
References: <20190405221043.12227.19679.stgit@localhost.localdomain>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alexander Duyck <alexander.h.duyck@linux.intel.com>

Add yet another iterator, for_each_free_mem_range_in_zone_from, and then
use it to support initializing and freeing pages in groups no larger than
MAX_ORDER_NR_PAGES. By doing this we can greatly improve the cache locality
of the pages while we do several loops over them in the init and freeing
process.

We are able to tighten the loops further as a result of the "from" iterator
as we can perform the initial checks for first_init_pfn in our first call
to the iterator, and continue without the need for those checks via the
"from" iterator. I have added this functionality in the function called
deferred_init_mem_pfn_range_in_zone that primes the iterator and causes us
to exit if we encounter any failure.

On my x86_64 test system with 384GB of memory per node I saw a reduction in
initialization time from 1.85s to 1.38s as a result of this patch.

Reviewed-by: Pavel Tatashin <pasha.tatashin@soleen.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 include/linux/memblock.h |   16 +++++
 mm/page_alloc.c          |  162 ++++++++++++++++++++++++++++++++++------------
 2 files changed, 137 insertions(+), 41 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index f8b78892b977..47e3c0612592 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -263,6 +263,22 @@ void __next_mem_pfn_range_in_zone(u64 *idx, struct zone *zone,
 	     __next_mem_pfn_range_in_zone(&i, zone, p_start, p_end);	\
 	     i != U64_MAX;					\
 	     __next_mem_pfn_range_in_zone(&i, zone, p_start, p_end))
+
+/**
+ * for_each_free_mem_range_in_zone_from - iterate through zone specific
+ * free memblock areas from a given point
+ * @i: u64 used as loop variable
+ * @zone: zone in which all of the memory blocks reside
+ * @p_start: ptr to phys_addr_t for start address of the range, can be %NULL
+ * @p_end: ptr to phys_addr_t for end address of the range, can be %NULL
+ *
+ * Walks over free (memory && !reserved) areas of memblock in a specific
+ * zone, continuing from current position. Available as soon as memblock is
+ * initialized.
+ */
+#define for_each_free_mem_pfn_range_in_zone_from(i, zone, p_start, p_end) \
+	for (; i != U64_MAX;					  \
+	     __next_mem_pfn_range_in_zone(&i, zone, p_start, p_end))
 #endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
 
 /**
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 61467e28c966..06fbec9edf84 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1609,16 +1609,100 @@ static unsigned long  __init deferred_init_pages(struct zone *zone,
 	return (nr_pages);
 }
 
+/*
+ * This function is meant to pre-load the iterator for the zone init.
+ * Specifically it walks through the ranges until we are caught up to the
+ * first_init_pfn value and exits there. If we never encounter the value we
+ * return false indicating there are no valid ranges left.
+ */
+static bool __init
+deferred_init_mem_pfn_range_in_zone(u64 *i, struct zone *zone,
+				    unsigned long *spfn, unsigned long *epfn,
+				    unsigned long first_init_pfn)
+{
+	u64 j;
+
+	/*
+	 * Start out by walking through the ranges in this zone that have
+	 * already been initialized. We don't need to do anything with them
+	 * so we just need to flush them out of the system.
+	 */
+	for_each_free_mem_pfn_range_in_zone(j, zone, spfn, epfn) {
+		if (*epfn <= first_init_pfn)
+			continue;
+		if (*spfn < first_init_pfn)
+			*spfn = first_init_pfn;
+		*i = j;
+		return true;
+	}
+
+	return false;
+}
+
+/*
+ * Initialize and free pages. We do it in two loops: first we initialize
+ * struct page, then free to buddy allocator, because while we are
+ * freeing pages we can access pages that are ahead (computing buddy
+ * page in __free_one_page()).
+ *
+ * In order to try and keep some memory in the cache we have the loop
+ * broken along max page order boundaries. This way we will not cause
+ * any issues with the buddy page computation.
+ */
+static unsigned long __init
+deferred_init_maxorder(u64 *i, struct zone *zone, unsigned long *start_pfn,
+		       unsigned long *end_pfn)
+{
+	unsigned long mo_pfn = ALIGN(*start_pfn + 1, MAX_ORDER_NR_PAGES);
+	unsigned long spfn = *start_pfn, epfn = *end_pfn;
+	unsigned long nr_pages = 0;
+	u64 j = *i;
+
+	/* First we loop through and initialize the page values */
+	for_each_free_mem_pfn_range_in_zone_from(j, zone, start_pfn, end_pfn) {
+		unsigned long t;
+
+		if (mo_pfn <= *start_pfn)
+			break;
+
+		t = min(mo_pfn, *end_pfn);
+		nr_pages += deferred_init_pages(zone, *start_pfn, t);
+
+		if (mo_pfn < *end_pfn) {
+			*start_pfn = mo_pfn;
+			break;
+		}
+	}
+
+	/* Reset values and now loop through freeing pages as needed */
+	swap(j, *i);
+
+	for_each_free_mem_pfn_range_in_zone_from(j, zone, &spfn, &epfn) {
+		unsigned long t;
+
+		if (mo_pfn <= spfn)
+			break;
+
+		t = min(mo_pfn, epfn);
+		deferred_free_pages(spfn, t);
+
+		if (mo_pfn <= epfn)
+			break;
+	}
+
+	return nr_pages;
+}
+
 /* Initialise remaining memory on a node */
 static int __init deferred_init_memmap(void *data)
 {
 	pg_data_t *pgdat = data;
+	const struct cpumask *cpumask = cpumask_of_node(pgdat->node_id);
+	unsigned long spfn = 0, epfn = 0, nr_pages = 0;
+	unsigned long first_init_pfn, flags;
 	unsigned long start = jiffies;
-	unsigned long nr_pages = 0;
-	unsigned long spfn, epfn, first_init_pfn, flags;
-	int zid;
 	struct zone *zone;
-	const struct cpumask *cpumask = cpumask_of_node(pgdat->node_id);
+	int zid;
 	u64 i;
 
 	/* Bind memory initialisation thread to a local node if possible */
@@ -1644,22 +1728,20 @@ static int __init deferred_init_memmap(void *data)
 		if (first_init_pfn < zone_end_pfn(zone))
 			break;
 	}
-	first_init_pfn = max(zone->zone_start_pfn, first_init_pfn);
+
+	/* If the zone is empty somebody else may have cleared out the zone */
+	if (!deferred_init_mem_pfn_range_in_zone(&i, zone, &spfn, &epfn,
+						 first_init_pfn))
+		goto zone_empty;
 
 	/*
-	 * Initialize and free pages. We do it in two loops: first we initialize
-	 * struct page, than free to buddy allocator, because while we are
-	 * freeing pages we can access pages that are ahead (computing buddy
-	 * page in __free_one_page()).
+	 * Initialize and free pages in MAX_ORDER sized increments so
+	 * that we can avoid introducing any issues with the buddy
+	 * allocator.
 	 */
-	for_each_free_mem_pfn_range_in_zone(i, zone, &spfn, &epfn) {
-		spfn = max_t(unsigned long, first_init_pfn, spfn);
-		nr_pages += deferred_init_pages(zone, spfn, epfn);
-	}
-	for_each_free_mem_pfn_range_in_zone(i, zone, &spfn, &epfn) {
-		spfn = max_t(unsigned long, first_init_pfn, spfn);
-		deferred_free_pages(spfn, epfn);
-	}
+	while (spfn < epfn)
+		nr_pages += deferred_init_maxorder(&i, zone, &spfn, &epfn);
+zone_empty:
 	pgdat_resize_unlock(pgdat, &flags);
 
 	/* Sanity check that the next zone really is unpopulated */
@@ -1692,9 +1774,9 @@ static int __init deferred_init_memmap(void *data)
 {
 	unsigned long nr_pages_needed = ALIGN(1 << order, PAGES_PER_SECTION);
 	pg_data_t *pgdat = zone->zone_pgdat;
-	unsigned long nr_pages = 0;
-	unsigned long first_init_pfn, spfn, epfn, t, flags;
 	unsigned long first_deferred_pfn = pgdat->first_deferred_pfn;
+	unsigned long spfn, epfn, flags;
+	unsigned long nr_pages = 0;
 	u64 i;
 
 	/* Only the last zone may have deferred pages */
@@ -1723,37 +1805,35 @@ static int __init deferred_init_memmap(void *data)
 		return true;
 	}
 
-	first_init_pfn = max(zone->zone_start_pfn, first_deferred_pfn);
-
-	if (first_init_pfn >= pgdat_end_pfn(pgdat)) {
+	/* If the zone is empty somebody else may have cleared out the zone */
+	if (!deferred_init_mem_pfn_range_in_zone(&i, zone, &spfn, &epfn,
+						 first_deferred_pfn)) {
+		pgdat->first_deferred_pfn = ULONG_MAX;
 		pgdat_resize_unlock(pgdat, &flags);
-		return false;
+		return true;
 	}
 
-	for_each_free_mem_pfn_range_in_zone(i, zone, &spfn, &epfn) {
-		spfn = max_t(unsigned long, first_init_pfn, spfn);
+	/*
+	 * Initialize and free pages in MAX_ORDER sized increments so
+	 * that we can avoid introducing any issues with the buddy
+	 * allocator.
+	 */
+	while (spfn < epfn) {
+		/* update our first deferred PFN for this section */
+		first_deferred_pfn = spfn;
+
+		nr_pages += deferred_init_maxorder(&i, zone, &spfn, &epfn);
 
-		while (spfn < epfn && nr_pages < nr_pages_needed) {
-			t = ALIGN(spfn + PAGES_PER_SECTION, PAGES_PER_SECTION);
-			first_deferred_pfn = min(t, epfn);
-			nr_pages += deferred_init_pages(zone, spfn,
-							first_deferred_pfn);
-			spfn = first_deferred_pfn;
-		}
+		/* We should only stop along section boundaries */
+		if ((first_deferred_pfn ^ spfn) < PAGES_PER_SECTION)
+			continue;
 
+		/* If our quota has been met we can stop here */
 		if (nr_pages >= nr_pages_needed)
 			break;
 	}
 
-	for_each_free_mem_pfn_range_in_zone(i, zone, &spfn, &epfn) {
-		spfn = max_t(unsigned long, first_init_pfn, spfn);
-		epfn = min_t(unsigned long, first_deferred_pfn, epfn);
-		deferred_free_pages(spfn, epfn);
-
-		if (first_deferred_pfn == epfn)
-			break;
-	}
-	pgdat->first_deferred_pfn = first_deferred_pfn;
+	pgdat->first_deferred_pfn = spfn;
 	pgdat_resize_unlock(pgdat, &flags);
 
 	return nr_pages > 0;


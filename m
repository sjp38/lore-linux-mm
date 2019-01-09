Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4CC648E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 05:25:50 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id c34so2713662edb.8
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 02:25:50 -0800 (PST)
Received: from outbound-smtp25.blacknight.com (outbound-smtp25.blacknight.com. [81.17.249.193])
        by mx.google.com with ESMTPS id u24si1131803edy.88.2019.01.09.02.25.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 02:25:48 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp25.blacknight.com (Postfix) with ESMTPS id 5A1DBB898B
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 10:25:48 +0000 (GMT)
Date: Wed, 9 Jan 2019 10:25:46 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [bug report] mm, compaction: round-robin the order while
 searching the free lists for a target
Message-ID: <20190109102546.GS31517@techsingularity.net>
References: <20190109082733.GA5424@kadam>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190109082733.GA5424@kadam>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: linux-mm@kvack.org

On Wed, Jan 09, 2019 at 11:27:33AM +0300, Dan Carpenter wrote:
> Hello Mel Gorman,
> 
> The patch 1688e2896de4: "mm, compaction: round-robin the order while
> searching the free lists for a target" from Jan 8, 2019, leads to the
> following static checker warning:
> 
> 	mm/compaction.c:1252 next_search_order()
> 	warn: impossible condition '(cc->search_order < 0) => (0-u16max < 0)'
> 

Thanks Dan!

Does the following combination of two patches address it? The two
patches address separate problems with two patches in the series.

diff --git a/mm/compaction.c b/mm/compaction.c
index cc17f0c01811..a3b665e15ab2 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1269,6 +1269,10 @@ fast_isolate_freepages(struct compact_control *cc)
 	bool scan_start = false;
 	int order;
 
+	/* Full compaction passes in a negative order */
+	if (order <= 0)
+		return cc->free_pfn;
+
 	/*
 	 * If starting the scan, use a deeper search and use the highest
 	 * PFN found if a suitable one is not found.
diff --git a/mm/internal.h b/mm/internal.h
index 6b1e5e313855..bebfb4b655dd 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -192,7 +192,7 @@ struct compact_control {
 	unsigned long total_migrate_scanned;
 	unsigned long total_free_scanned;
 	unsigned short fast_search_fail;/* failures to use free list searches */
-	unsigned short search_order;	/* order to start a fast search at */
+	short search_order;		/* order to start a fast search at */
 	const gfp_t gfp_mask;		/* gfp mask of a direct compactor */
 	int order;			/* order a direct compactor needs */
 	int migratetype;		/* migratetype of direct compactor */

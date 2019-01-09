Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9890B8E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 05:35:46 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id b3so2792904edi.0
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 02:35:46 -0800 (PST)
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id h13si719781edf.24.2019.01.09.02.35.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 02:35:45 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id DCAA21C2912
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 10:35:44 +0000 (GMT)
Date: Wed, 9 Jan 2019 10:35:43 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [bug report] mm, compaction: round-robin the order while
 searching the free lists for a target
Message-ID: <20190109103543.GT31517@techsingularity.net>
References: <20190109082733.GA5424@kadam>
 <20190109102546.GS31517@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190109102546.GS31517@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: linux-mm@kvack.org

On Wed, Jan 09, 2019 at 10:25:46AM +0000, Mel Gorman wrote:
> On Wed, Jan 09, 2019 at 11:27:33AM +0300, Dan Carpenter wrote:
> > Hello Mel Gorman,
> > 
> > The patch 1688e2896de4: "mm, compaction: round-robin the order while
> > searching the free lists for a target" from Jan 8, 2019, leads to the
> > following static checker warning:
> > 
> > 	mm/compaction.c:1252 next_search_order()
> > 	warn: impossible condition '(cc->search_order < 0) => (0-u16max < 0)'
> > 
> 
> Thanks Dan!
> 
> Does the following combination of two patches address it? The two
> patches address separate problems with two patches in the series.
> 

Sending a version that was actually committed might help.

diff --git a/mm/compaction.c b/mm/compaction.c
index 6720234dc701..399dea80d09b 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1269,6 +1269,10 @@ fast_isolate_freepages(struct compact_control *cc)
 	bool scan_start = false;
 	int order;
 
+	/* Full compaction passes in a negative order */
+	if (cc->order <= 0)
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

-- 
Mel Gorman
SUSE Labs

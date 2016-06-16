Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id B02A86B025E
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 05:16:57 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r5so23909688wmr.0
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 02:16:57 -0700 (PDT)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.16])
        by mx.google.com with ESMTPS id f5si4233545wjt.204.2016.06.16.02.16.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jun 2016 02:16:56 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id 2B3651C232E
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 10:16:56 +0100 (IST)
Date: Thu, 16 Jun 2016 10:16:54 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 08/27] mm, vmscan: Simplify the logic deciding whether
 kswapd sleeps
Message-ID: <20160616091654.GG1868@techsingularity.net>
References: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
 <1465495483-11855-9-git-send-email-mgorman@techsingularity.net>
 <6b6b9f95-869a-a9f2-c5cf-f0a3e4d6bd6a@suse.cz>
 <20160616083033.GF1868@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160616083033.GF1868@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jun 16, 2016 at 09:30:33AM +0100, Mel Gorman wrote:
> > >@@ -2727,7 +2727,7 @@ static bool pfmemalloc_watermark_ok(pg_data_t *pgdat)
> > >
> > > 	/* kswapd must be awake if processes are being throttled */
> > > 	if (!wmark_ok && waitqueue_active(&pgdat->kswapd_wait)) {
> > >-		pgdat->classzone_idx = min(pgdat->classzone_idx,
> > >+		pgdat->kswapd_classzone_idx = min(pgdat->kswapd_classzone_idx,
> > > 						(enum zone_type)ZONE_NORMAL);
> > > 		wake_up_interruptible(&pgdat->kswapd_wait);
> > > 	}
> > >@@ -3211,6 +3211,12 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order,
> > >
> > > 	prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
> > >
> > >+	/* If kswapd has not been woken recently, then full sleep */
> > >+	if (classzone_idx == -1) {
> > >+		classzone_idx = balanced_classzone_idx = MAX_NR_ZONES - 1;
> > >+		goto full_sleep;
> > 
> > This will skip the wakeup_kcompactd() part.
> > 
> 
> I wrestled with this one. I decided to leave it alone on the grounds
> that if kswapd has not been woken recently then compaction efforts also
> have not failed and kcompactd is not required.
> 

And I was wrong. There needs to be a call to wakeup_kcompactd there to
cover the case where there was a single high-order allocation request
that failed and woke kswapd.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

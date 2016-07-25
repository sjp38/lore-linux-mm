Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 148CF6B0005
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 05:52:55 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id p41so112452699lfi.0
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 02:52:55 -0700 (PDT)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.16])
        by mx.google.com with ESMTPS id 204si20655147wmk.76.2016.07.25.02.52.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jul 2016 02:52:53 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id 225431C18D1
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 10:52:53 +0100 (IST)
Date: Mon, 25 Jul 2016 10:52:51 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 5/5] mm, vmscan: Account for skipped pages as a partial
 scan
Message-ID: <20160725095251.GN10438@techsingularity.net>
References: <1469110261-7365-1-git-send-email-mgorman@techsingularity.net>
 <1469110261-7365-6-git-send-email-mgorman@techsingularity.net>
 <20160725083913.GE1660@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160725083913.GE1660@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jul 25, 2016 at 05:39:13PM +0900, Minchan Kim wrote:
> > @@ -1465,14 +1471,24 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
> >  	 */
> >  	if (!list_empty(&pages_skipped)) {
> >  		int zid;
> > +		unsigned long total_skipped = 0;
> >  
> > -		list_splice(&pages_skipped, src);
> >  		for (zid = 0; zid < MAX_NR_ZONES; zid++) {
> >  			if (!nr_skipped[zid])
> >  				continue;
> >  
> >  			__count_zid_vm_events(PGSCAN_SKIP, zid, nr_skipped[zid]);
> > +			total_skipped += nr_skipped[zid];
> >  		}
> > +
> > +		/*
> > +		 * Account skipped pages as a partial scan as the pgdat may be
> > +		 * close to unreclaimable. If the LRU list is empty, account
> > +		 * skipped pages as a full scan.
> > +		 */
> 
> node-lru made OOM detection lengthy because a freeing of any zone will
> reset NR_PAGES_SCANNED easily so that it's hard to meet a situation
> pgdat_reclaimable returns *false*.
> 

Your patch should go a long way to addressing that as it checks the zone
counters first before conducting the scan. Remember as well that the longer
detection of OOM only applies to zone-constrained allocations and there
is always the possibility that highmem shrinking of pages frees lowmem
memory if buffers are used.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

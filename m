Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 5EFCF6B0037
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 06:12:23 -0400 (EDT)
Date: Tue, 19 Mar 2013 10:12:19 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 03/10] mm: vmscan: Flatten kswapd priority loop
Message-ID: <20130319101219.GC2055@suse.de>
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
 <1363525456-10448-4-git-send-email-mgorman@suse.de>
 <5147AA3B.9080807@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <5147AA3B.9080807@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Tue, Mar 19, 2013 at 07:58:51AM +0800, Simon Jeons wrote:
> >@@ -2672,26 +2677,25 @@ static void kswapd_shrink_zone(struct zone *zone,
> >  static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
> >  							int *classzone_idx)
> >  {
> >-	bool pgdat_is_balanced = false;
> >  	int i;
> >  	int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
> >  	unsigned long nr_soft_reclaimed;
> >  	unsigned long nr_soft_scanned;
> >  	struct scan_control sc = {
> >  		.gfp_mask = GFP_KERNEL,
> >+		.priority = DEF_PRIORITY,
> >  		.may_unmap = 1,
> >  		.may_swap = 1,
> >+		.may_writepage = !laptop_mode,
> 
> What's the influence of this change? If there are large numbers of
> anonymous pages and very little file pages, anonymous pages will not
> be swapped out when priorty >= DEF_PRIORITY-2. Just no sense scan.

None. The initialisation just moves from where it was after the
loop_again label to here. See the next hunk.

> >  		.order = order,
> >  		.target_mem_cgroup = NULL,
> >  	};
> >-loop_again:
> >-	sc.priority = DEF_PRIORITY;
> >-	sc.nr_reclaimed = 0;
> >-	sc.may_writepage = !laptop_mode;
> >  	count_vm_event(PAGEOUTRUN);
> >  	do {
> >  		unsigned long lru_pages = 0;
> >+		unsigned long nr_reclaimed = sc.nr_reclaimed;
> >+		bool raise_priority = true;
> >  		/*
> >  		 * Scan in the highmem->dma direction for the highest

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

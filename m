Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 42C7E6B0006
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 09:29:14 -0400 (EDT)
Date: Wed, 10 Apr 2013 14:29:07 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 03/10] mm: vmscan: Flatten kswapd priority loop
Message-ID: <20130410132907.GA3710@suse.de>
References: <1365505625-9460-1-git-send-email-mgorman@suse.de>
 <1365505625-9460-4-git-send-email-mgorman@suse.de>
 <51651913.4040007@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <51651913.4040007@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Apr 10, 2013 at 04:47:31PM +0900, Kamezawa Hiroyuki wrote:
> > @@ -2811,8 +2814,16 @@ loop_again:
> >   
> >   			if ((buffer_heads_over_limit && is_highmem_idx(i)) ||
> >   			    !zone_balanced(zone, testorder,
> > -					   balance_gap, end_zone))
> > -				kswapd_shrink_zone(zone, &sc, lru_pages);
> > +					   balance_gap, end_zone)) {
> > +				/*
> > +				 * There should be no need to raise the
> > +				 * scanning priority if enough pages are
> > +				 * already being scanned that high
> > +				 * watermark would be met at 100% efficiency.
> > +				 */
> > +				if (kswapd_shrink_zone(zone, &sc, lru_pages))
> > +					raise_priority = false;
> 
> priority will be raised up enough to scan the amount of "high" watermark
> and will not get larger than that if some pages are reclaimed ?
> 

Yes.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

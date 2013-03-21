Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 1E8096B005A
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 12:47:41 -0400 (EDT)
Date: Thu, 21 Mar 2013 16:47:37 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 01/10] mm: vmscan: Limit the number of pages kswapd
 reclaims at each priority
Message-ID: <20130321164737.GL1878@suse.de>
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
 <1363525456-10448-2-git-send-email-mgorman@suse.de>
 <20130321155705.GA27848@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130321155705.GA27848@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Thu, Mar 21, 2013 at 11:57:05AM -0400, Johannes Weiner wrote:
> On Sun, Mar 17, 2013 at 01:04:07PM +0000, Mel Gorman wrote:
> > The number of pages kswapd can reclaim is bound by the number of pages it
> > scans which is related to the size of the zone and the scanning priority. In
> > many cases the priority remains low because it's reset every SWAP_CLUSTER_MAX
> > reclaimed pages but in the event kswapd scans a large number of pages it
> > cannot reclaim, it will raise the priority and potentially discard a large
> > percentage of the zone as sc->nr_to_reclaim is ULONG_MAX. The user-visible
> > effect is a reclaim "spike" where a large percentage of memory is suddenly
> > freed. It would be bad enough if this was just unused memory but because
> > of how anon/file pages are balanced it is possible that applications get
> > pushed to swap unnecessarily.
> > 
> > This patch limits the number of pages kswapd will reclaim to the high
> > watermark. Reclaim will will overshoot due to it not being a hard limit as
> 
> will -> still?
> 
> > shrink_lruvec() will ignore the sc.nr_to_reclaim at DEF_PRIORITY but it
> > prevents kswapd reclaiming the world at higher priorities. The number of
> > pages it reclaims is not adjusted for high-order allocations as kswapd will
> > reclaim excessively if it is to balance zones for high-order allocations.
> 
> I don't really understand this last sentence.  Is the excessive
> reclaim a result of the patch, a description of what's happening
> now...?
> 

It's a very basic description of what happens now and with the patch
applied. Until patch 5 is applied, kswapd can still reclaim the world if
it reaches priority 0.

> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> 
> Nice, thank you.  Using the high watermark for larger zones is more
> reasonable than my hack that just always went with SWAP_CLUSTER_MAX,
> what with inter-zone LRU cycle time balancing and all.
> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

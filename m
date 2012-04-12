Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 50E516B0044
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 10:24:59 -0400 (EDT)
Date: Thu, 12 Apr 2012 16:24:35 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH V2 5/5] memcg: change the target nr_to_reclaim for each
 memcg under kswapd
Message-ID: <20120412142435.GJ1787@cmpxchg.org>
References: <1334181627-26942-1-git-send-email-yinghan@google.com>
 <20120411235638.GA1787@cmpxchg.org>
 <CALWz4ixnQ=XWUmPEqjEnGYrO6p+pU=VEGjJSEr22gfnmNPjrmg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALWz4ixnQ=XWUmPEqjEnGYrO6p+pU=VEGjJSEr22gfnmNPjrmg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org

On Wed, Apr 11, 2012 at 09:06:27PM -0700, Ying Han wrote:
> On Wed, Apr 11, 2012 at 4:56 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > On Wed, Apr 11, 2012 at 03:00:27PM -0700, Ying Han wrote:
> >> Under global background reclaim, the sc->nr_to_reclaim is set to
> >> ULONG_MAX. Now we are iterating all memcgs under the zone and we
> >> shouldn't pass the pressure from kswapd for each memcg.
> >>
> >> After all, the balance_pgdat() breaks after reclaiming SWAP_CLUSTER_MAX
> >> pages to prevent building up reclaim priorities.
> >
> > shrink_mem_cgroup_zone() bails out of a zone, balance_pgdat() bails
> > out of a priority loop, there is quite a difference.
> >
> > After this patch, kswapd no longer puts equal pressure on all zones in
> > the zonelist, which was a key reason why we could justify bailing
> > early out of individual zones in direct reclaim: kswapd will restore
> > fairness.
> 
> Guess I see your point here.
> 
> My intention is to prevent over-reclaim memcgs per-zone by having
> nr_to_reclaim to ULONG_MAX. Now, we scan each memcg based on
> get_scan_count() without bailout, do you see a problem w/o this patch?

The fact that we iterate over each memcg does not make a difference,
because the target that get_scan_count() returns for each zone-memcg
is in sum what it would have returned for the whole zone, so the scan
aggressiveness did not increase.  It just distributes the zone's scan
target over the set of memcgs proportional to their share of pages in
that zone.

So I have trouble deciding what's right.

On the one hand, I don't see why you bother with this patch, because
you don't increase the risk of overreclaim.  Michal's concern for
overreclaim came from the fact that I had kswapd do soft limit reclaim
at priority 0 without ever bailing from individual zones.  But your
soft limit implementation is purely about selecting memcgs to reclaim,
you never increase the pressure put on a memcg anywhere.

On the other hand, I don't even agree with that aspect of your series;
that you no longer prioritize explicitely soft-limited groups in
excess over unconfigured groups, as I mentioned in the other mail.
But if you did, you would likely need a patch like this, I think.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

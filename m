Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D3B3290010C
	for <linux-mm@kvack.org>; Tue, 17 May 2011 04:11:17 -0400 (EDT)
Date: Tue, 17 May 2011 10:11:00 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [rfc patch 0/6] mm: memcg naturalization
Message-ID: <20110517081100.GZ16531@cmpxchg.org>
References: <1305212038-15445-1-git-send-email-hannes@cmpxchg.org>
 <BANLkTikHhK8S-fMpe=KOYCF0kmXotHKCOQ@mail.gmail.com>
 <20110513072043.GE18610@cmpxchg.org>
 <BANLkTiky6=xwqb_ML1wg=8Gg=BO0nmeUog@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BANLkTiky6=xwqb_ML1wg=8Gg=BO0nmeUog@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, May 16, 2011 at 05:53:04PM -0700, Ying Han wrote:
> On Fri, May 13, 2011 at 12:20 AM, Johannes Weiner <hannes@cmpxchg.org>wrote:
> 
> > On Thu, May 12, 2011 at 11:53:37AM -0700, Ying Han wrote:
> > > On Thu, May 12, 2011 at 7:53 AM, Johannes Weiner <hannes@cmpxchg.org>
> > wrote:
> > >
> > > > Hi!
> > > >
> > > > Here is a patch series that is a result of the memcg discussions on
> > > > LSF (memcg-aware global reclaim, global lru removal, struct
> > > > page_cgroup reduction, soft limit implementation) and the recent
> > > > feature discussions on linux-mm.
> > > >
> > > > The long-term idea is to have memcgs no longer bolted to the side of
> > > > the mm code, but integrate it as much as possible such that there is a
> > > > native understanding of containers, and that the traditional !memcg
> > > > setup is just a singular group.  This series is an approach in that
> > > > direction.
> >
> 
> This sounds like a good long term plan. Now I would wonder should we take it
> step by step by doing:
>
> 1. improving the existing soft_limit reclaim from RB-tree based to link-list
> based, also in a round_robin fashion.
> We can keep the existing APIs but only changing the underlying
> implementation of  mem_cgroup_soft_limit_reclaim()
> 
> 2. remove the global lru list after the first one being proved to be
> efficient.
> 
> 3. then have better integration of memcg reclaim to the mm code.

I chose to go the other because it did not seem more complex to me and
fixed many things we had planned anyway.  Deeper integration, better
soft limit implementation (including better pressure distribution,
enforcement also from direct reclaim, not just kswapd), global lru
removal etc.

That ground work was a bit unwieldy and I think quite some confusion
ensued, but I am currently reorganizing, cleaning up, and documenting.
I expect the next version to be much easier to understand.

The three steps are still this:

1. make traditional reclaim memcg-aware.

2. improve soft limit based on 1.

3. remove global lru based on 1.

But 1. already effectively disables the global LRU for memcg-enabled
kernels, so 3. can be deferred until we are comfortable with 1.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

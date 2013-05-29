Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 633A76B0099
	for <linux-mm@kvack.org>; Wed, 29 May 2013 16:02:14 -0400 (EDT)
Date: Wed, 29 May 2013 16:01:54 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch v3 -mm 1/3] memcg: integrate soft reclaim tighter with
 zone shrinking code
Message-ID: <20130529200154.GF15721@cmpxchg.org>
References: <20130517160247.GA10023@cmpxchg.org>
 <1369674791-13861-1-git-send-email-mhocko@suse.cz>
 <20130529130538.GD10224@dhcp22.suse.cz>
 <20130529155756.GH10224@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130529155756.GH10224@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Glauber Costa <glommer@parallels.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 29, 2013 at 05:57:56PM +0200, Michal Hocko wrote:
> On Wed 29-05-13 15:05:38, Michal Hocko wrote:
> > On Mon 27-05-13 19:13:08, Michal Hocko wrote:
> > [...]
> > > Nevertheless I have encountered an issue while testing the huge number
> > > of groups scenario. And the issue is not limitted to only to this
> > > scenario unfortunately. As memcg iterators use per node-zone-priority
> > > cache to prevent from over reclaim it might quite easily happen that
> > > the walk will not visit all groups and will terminate the loop either
> > > prematurely or skip some groups. An example could be the direct reclaim
> > > racing with kswapd. This might cause that the loop misses over limit
> > > groups so no pages are scanned and so we will fall back to all groups
> > > reclaim.
> > 
> > And after some more testing and head scratching it turned out that
> > fallbacks to pass#2 I was seeing are caused by something else. It is
> > not race between iterators but rather reclaiming from zone DMA which
> > has troubles to scan anything despite there are pages on LRU and so we
> > fall back. I have to look into that more but what-ever the issue is it
> > shouldn't be related to the patch series.
> 
> Think I know what is going on. get_scan_count sees relatively small
> amount of pages in the lists (around 2k). This means that get_scan_count
> will tell us to scan nothing for DEF_PRIORITY (as the DMA32 is usually
> ~16M) then the DEF_PRIORITY is basically no-op and we have to wait and
> fall down to a priority which actually let us scan something.
> 
> Hmm, maybe ignoring soft reclaim for DMA zone would help to reduce
> one pointless loop over groups.

If you have a small group in excess of its soft limit and bigger
groups that are not, you may reclaim something in the regular reclaim
cycle before reclaiming anything in the soft limit cycle with the way
the code is structured.

The soft limit cycle probably needs to sit outside of the priority
loop, not inside the loop, so that the soft limit reclaim cycle
descends priority levels until it makes progress BEFORE it exits to
the regular reclaim cycle.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id E29CC6B0008
	for <linux-mm@kvack.org>; Wed, 23 Jan 2013 18:46:52 -0500 (EST)
Date: Thu, 24 Jan 2013 10:46:49 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC, PATCH 00/19] Numa aware LRU lists and shrinkers
Message-ID: <20130123234649.GV2498@dastard>
References: <1354058086-27937-1-git-send-email-david@fromorbit.com>
 <50FD6815.90900@parallels.com>
 <20130121232121.GG2498@dastard>
 <50FFF571.8080506@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50FFF571.8080506@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com, Johannes Weiner <hannes@cmpxchg.org>

On Wed, Jan 23, 2013 at 06:36:33PM +0400, Glauber Costa wrote:
> On 01/22/2013 03:21 AM, Dave Chinner wrote:
> > On Mon, Jan 21, 2013 at 08:08:53PM +0400, Glauber Costa wrote:
> >> On 11/28/2012 03:14 AM, Dave Chinner wrote:
> >>> [PATCH 09/19] list_lru: per-node list infrastructure
> >>>
> >>> This makes the generic LRU list much more scalable by changing it to
> >>> a {list,lock,count} tuple per node. There are no external API
> >>> changes to this changeover, so is transparent to current users.
> >>>
> >>> [PATCH 10/19] shrinker: add node awareness
> >>> [PATCH 11/19] fs: convert inode and dentry shrinking to be node
> >>>
> >>> Adds a nodemask to the struct shrink_control for callers of
> >>> shrink_slab to set appropriately for their reclaim context. This
> >>> nodemask is then passed by the inode and dentry cache reclaim code
> >>> to the generic LRU list code to implement node aware shrinking.
> >>
> >> I have a follow up question that popped up from a discussion between me
> >> and my very American friend Johnny Wheeler, also known as Johannes
> >> Weiner (CC'd). I actually remember we discussing this, but don't fully
> >> remember the outcome. And since I can't find it anywhere, it must have
> >> been in a media other than e-mail. So I thought it would do no harm in
> >> at least documenting it...
> >>
> >> Why are we doing this per-node, instead of per-zone?
> >>
> >> It seems to me that the goal is to collapse all zones of a node into a
> >> single list, but since the number of zones is not terribly larger than
> >> the number of nodes, and zones is where the pressure comes from, what do
> >> we really gain from this?
> > 
> > The number is quite a bit higher - there are platforms with 5 zones
> > to a node. The reality is, though, for most platforms slab
> > allocations come from a single zone - they never come from ZONE_DMA,
> > ZONE_HIGHMEM or ZONE_MOVEABLE, so there is there is no good reason
> > for having cache LRUs for these zones. So, two zones at most.
> > 
> Yes, but one would expect that most of those special zones would be
> present only in the first node, no? (correct me if I am wrong here).

As I understand it, every node has an identical zone setup (i.e. a
flat array of MAX_NR_ZONES zones in the struct pglist_data), and
pages are simply places the in the appropriate zones on each node...

Also, IIUC, the behaviour of the zones one each node is architecture
dependent, we can't make assumptions that certain zones are only
ever used on the first node...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

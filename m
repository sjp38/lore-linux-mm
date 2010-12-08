Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id AF24F6B0087
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 07:20:13 -0500 (EST)
Date: Wed, 8 Dec 2010 12:19:51 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/4] Add kswapd descriptor.
Message-ID: <20101208121951.GK5422@csn.ul.ie>
References: <1291099785-5433-1-git-send-email-yinghan@google.com> <1291099785-5433-2-git-send-email-yinghan@google.com> <20101207123308.GD5422@csn.ul.ie> <AANLkTimzL_CwLruzPspgmOk4OJU8M7dXycUyHmhW2s9O@mail.gmail.com> <20101208093948.1b3b64c5.kamezawa.hiroyu@jp.fujitsu.com> <AANLkTin+p5WnLjMkr8Qntkt4fR1+fdY=t6hkvV6G8Mok@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTin+p5WnLjMkr8Qntkt4fR1+fdY=t6hkvV6G8Mok@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Dec 07, 2010 at 05:24:12PM -0800, Ying Han wrote:
> On Tue, Dec 7, 2010 at 4:39 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Tue, 7 Dec 2010 09:28:01 -0800
> > Ying Han <yinghan@google.com> wrote:
> >
> >> On Tue, Dec 7, 2010 at 4:33 AM, Mel Gorman <mel@csn.ul.ie> wrote:
> >
> >> Potentially there will
> >> > also be a very large number of new IO sources. I confess I haven't read the
> >> > thread yet so maybe this has already been thought of but it might make sense
> >> > to have a 1:N relationship between kswapd and memcgroups and cycle between
> >> > containers. The difficulty will be a latency between when kswapd wakes up
> >> > and when a particular container is scanned. The closer the ratio is to 1:1,
> >> > the less the latency will be but the higher the contenion on the LRU lock
> >> > and IO will be.
> >>
> >> No, we weren't talked about the mapping anywhere in the thread. Having
> >> many kswapd threads
> >> at the same time isn't a problem as long as no locking contention (
> >> ext, 1k kswapd threads on
> >> 1k fake numa node system). So breaking the zone->lru_lock should work.
> >>
> >
> > That's me who make zone->lru_lock be shared. And per-memcg lock will makes
> > the maintainance of memcg very bad. That will add many races.
> > Or we need to make memcg's LRU not synchronized with zone's LRU, IOW, we need
> > to have completely independent LRU.
> >
> > I'd like to limit the number of kswapd-for-memcg if zone->lru lock contention
> > is problematic. memcg _can_ work without background reclaim.
> 
> >
> > How about adding per-node kswapd-for-memcg it will reclaim pages by a memcg's
> > request ? as
> >
> >        memcg_wake_kswapd(struct mem_cgroup *mem)
> >        {
> >                do {
> >                        nid = select_victim_node(mem);
> >                        /* ask kswapd to reclaim memcg's memory */
> >                        ret = memcg_kswapd_queue_work(nid, mem); /* may return -EBUSY if very busy*/
> >                } while()
> >        }
> >
> > This will make lock contention minimum. Anyway, using too much cpu for this
> > unnecessary_but_good_for_performance_function is bad. Throttoling is required.
> 
> I don't see the problem of one-kswapd-per-cgroup here since there will
> be no performance cost if they are not running.
> 

*If* they are not running. There is potentially a massive cost here.

> I haven't measured the lock contention and cputime for each kswapd
> running. Theoretically it would be a problem
> if thousands of cgroups are configured on the the host and all of them
> are under memory pressure.
> 

It's not just the locking. If all of these kswapds are running and each
container has a small number of dirty pages, we potentially have tens or
hundreds of kswapd each queueing a small number of pages for IO.  Granted,
if we reach the point where these IO sources are delegated to flusher threads
it would be less of a problem but it's not how things currently behave.

> We can either optimize the locking or make each kswapd smarter (hold
> the lock less time).

Holding the lock less time might allow other kswapd instances to make small
amounts of progress but they'll still be wasting a lot of CPU spinning on
the lock. It's not a simple issue which is why I think we need either a)
a means of telling kswapd which containers it should be reclaiming from
or b) a 1:N mapping of kswapd instances to containers from the outset.
Otherwise users with large numbers of containers will see severe slowdowns
under memory pressure where as previously they would have experienced stalls
in individual containers.

> My current plan is to have the
> one-kswapd-per-cgroup on the V2 patch w/ select_victim_node, and the
> optimization for this comes as following patchset.
> 

Will read when they come out :)

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

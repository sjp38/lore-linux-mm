Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 0FAF36B00EE
	for <linux-mm@kvack.org>; Mon,  5 Sep 2011 14:25:23 -0400 (EDT)
Date: Mon, 5 Sep 2011 20:25:14 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [patch] memcg: skip scanning active lists based on individual
 size
Message-ID: <20110905182514.GA20793@redhat.com>
References: <20110831090850.GA27345@redhat.com>
 <CAEwNFnBSg71QoLZbOqZbXK3fGEGneituU3PmiYTAw1VM3KcwcQ@mail.gmail.com>
 <20110901090931.c0721216.kamezawa.hiroyu@jp.fujitsu.com>
 <20110901061540.GA22561@redhat.com>
 <20110901153148.70452287.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110901153148.70452287.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Sep 01, 2011 at 03:31:48PM +0900, KAMEZAWA Hiroyuki wrote:
> On Thu, 1 Sep 2011 08:15:40 +0200
> Johannes Weiner <jweiner@redhat.com> wrote:
> 
> > On Thu, Sep 01, 2011 at 09:09:31AM +0900, KAMEZAWA Hiroyuki wrote:
> > > On Wed, 31 Aug 2011 19:13:34 +0900
> > > Minchan Kim <minchan.kim@gmail.com> wrote:
> > > 
> > > > On Wed, Aug 31, 2011 at 6:08 PM, Johannes Weiner <jweiner@redhat.com> wrote:
> > > > > Reclaim decides to skip scanning an active list when the corresponding
> > > > > inactive list is above a certain size in comparison to leave the
> > > > > assumed working set alone while there are still enough reclaim
> > > > > candidates around.
> > > > >
> > > > > The memcg implementation of comparing those lists instead reports
> > > > > whether the whole memcg is low on the requested type of inactive
> > > > > pages, considering all nodes and zones.
> > > > >
> > > > > This can lead to an oversized active list not being scanned because of
> > > > > the state of the other lists in the memcg, as well as an active list
> > > > > being scanned while its corresponding inactive list has enough pages.
> > > > >
> > > > > Not only is this wrong, it's also a scalability hazard, because the
> > > > > global memory state over all nodes and zones has to be gathered for
> > > > > each memcg and zone scanned.
> > > > >
> > > > > Make these calculations purely based on the size of the two LRU lists
> > > > > that are actually affected by the outcome of the decision.
> > > > >
> > > > > Signed-off-by: Johannes Weiner <jweiner@redhat.com>
> > > > > Cc: Rik van Riel <riel@redhat.com>
> > > > > Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > > > > Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > > > Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > > > > Cc: Balbir Singh <bsingharora@gmail.com>
> > > > 
> > > > Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> > > > 
> > > > I can't understand why memcg is designed for considering all nodes and zones.
> > > > Is it a mistake or on purpose?
> > > 
> > > It's purpose. memcg just takes care of the amount of pages.
> > 
> > This mechanism isn't about memcg at all, it's an aging decision at a
> > much lower level.  Can you tell me how the old implementation is
> > supposed to work?
> > 
> Old implemenation was supporsed to make vmscan to see only memcg and
> ignore zones. memcg doesn't take care of any zones. Then, it uses
> global numbers rather than zones.
> 
> Assume a system with 2 nodes and the whole memcg's inactive/active ratio
> is unbalaned. 
> 
>    Node      0     1
>    Active   800M   30M
>    Inactive 100M   200M
> 
> If we judge 'unbalance' based on zones, Node1's Active will not rotate
> even if it's not accessed for a while.
> If we judge unbalance based on total stat, Both of Node0 and Node 1
> will be rotated.

But why should we deactivate on Node 1?  We have good reasons not to
on the global level, why should memcgs silently behave differently?

I mostly don't understand it on a semantic level.  vmscan needs to
know whether a certain inactive LRU list has enough reclaim candidates
to skip scanning its corresponding active list.  The global state is
not useful to find out if a single inactive list has enough pages.

> Hmm, old one doesn't work as I expexted ?
> 
> But okay, as time goes, I think Node1's inactive will decreased
> and then, rotate will happen even with zone based ones.

Yes, that's how the mechanism is intended to work: with a constant
influx of used-once pages, we don't want to touch the active list.
But when the workload changes and inactive pages get either activated
or all reclaimed, the ratio changes and eventually we fall back to
deactivating pages again.

That's reclaim behaviour that has been around for a while and it
shouldn't make a difference if your workload is running in
root_mem_cgroup or another memcg.

> > > But, hmm, this change may be good for softlimit and your work.
> > 
> > Yes, I noticed those paths showing up in a profile with my patches.
> > Lots of memcgs on a multi-node machine will trigger it too.  But it's
> > secondary, my primary reasoning was: this does not make sense at all.
> 
> your word sounds always too strong to me ;) please be soft.

Sorry, I'll try to be less harsh.  Please don't take it personally :)

What I meant was that the computational overhead was not the primary
reason for this patch.  Although a reduction there is very welcome,
it's that deciding to skip the list based on the list size seems more
correct than deciding based on the overall state of the memcg, which
can only by accident show the same proportion of inactive/active.

It's a correctness fix for existing code, not an optimization or
preparation for future changes.

> > > I'll ack when you add performance numbers in changelog.
> > 
> > It's not exactly a performance optimization but I'll happily run some
> > workloads.  Do you have suggestions what to test for?  I.e. where
> > would you expect regressions?
> > 
> Some comparison about amount of swap-out before/after change will be good.
> 
> Hm. If I do...
>   - set up x86-64 NUMA box. (fake numa is ok.)
>   - create memcg with 500M limit.
>   - running kernel make with make -j 6(or more)
> 
> see time of make and amount of swap-out.

4G ram, 500M swap on SSD, numa=fake=16, 10 runs of make -j11 in 500M
memcg, standard deviation in parens:

		seconds		pswpin			pswpout
vanilla:	175.359(0.106)	6906.900(1779.135)	8913.200(1917.369)
patched:	176.144(0.243)	8581.500(1833.432)	10872.400(2124.104)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 6DC926B00EE
	for <linux-mm@kvack.org>; Tue,  6 Sep 2011 06:43:55 -0400 (EDT)
Date: Tue, 6 Sep 2011 12:43:47 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [patch] memcg: skip scanning active lists based on individual
 size
Message-ID: <20110906104347.GB25053@redhat.com>
References: <20110831090850.GA27345@redhat.com>
 <CAEwNFnBSg71QoLZbOqZbXK3fGEGneituU3PmiYTAw1VM3KcwcQ@mail.gmail.com>
 <20110901090931.c0721216.kamezawa.hiroyu@jp.fujitsu.com>
 <20110901061540.GA22561@redhat.com>
 <20110901153148.70452287.kamezawa.hiroyu@jp.fujitsu.com>
 <20110905182514.GA20793@redhat.com>
 <20110906183358.0a305900.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110906183358.0a305900.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Sep 06, 2011 at 06:33:58PM +0900, KAMEZAWA Hiroyuki wrote:
> On Mon, 5 Sep 2011 20:25:14 +0200
> Johannes Weiner <jweiner@redhat.com> wrote:
> 
> > On Thu, Sep 01, 2011 at 03:31:48PM +0900, KAMEZAWA Hiroyuki wrote:
> > > On Thu, 1 Sep 2011 08:15:40 +0200
> > > Johannes Weiner <jweiner@redhat.com> wrote:
> > > Old implemenation was supporsed to make vmscan to see only memcg and
> > > ignore zones. memcg doesn't take care of any zones. Then, it uses
> > > global numbers rather than zones.
> > > 
> > > Assume a system with 2 nodes and the whole memcg's inactive/active ratio
> > > is unbalaned. 
> > > 
> > >    Node      0     1
> > >    Active   800M   30M
> > >    Inactive 100M   200M
> > > 
> > > If we judge 'unbalance' based on zones, Node1's Active will not rotate
> > > even if it's not accessed for a while.
> > > If we judge unbalance based on total stat, Both of Node0 and Node 1
> > > will be rotated.
> > 
> > But why should we deactivate on Node 1?  We have good reasons not to
> > on the global level, why should memcgs silently behave differently?
> 
> One reason was I thought that memcg should behave as to have one LRU list,
> which is not devided by zones and wanted to ignore zones as much
> as possible. Second reason was that I don't want to increase swap-out
> caused by memcg limit.

You can think of it like this: if every active list is only balanced
when its inactive counterpart is too small, then the memcg-wide
proportion of inactive vs. active pages is as desired, too.  So even
after my change, the 'one big LRU' has the right inactive/active ratio.

On the other hand, the old way could allow for the memcg-level to have
the right proportion and still thrash one workload that is bound to
another node even though its inactive > active, but is overshadowed by
inactive < active workloads on other nodes.

> > I mostly don't understand it on a semantic level.  vmscan needs to
> > know whether a certain inactive LRU list has enough reclaim candidates
> > to skip scanning its corresponding active list.  The global state is
> > not useful to find out if a single inactive list has enough pages.
> 
> Ok, I agree to this. I should add other logic to do what I want.
> In my series,
>   - passing nodemask
>   - avoid overscan
>   - calculating node weight
> These will allow me to see what I want.

What /do/ you want? :) I just don't see your concern.  I mean, yes, no
increased swapout, but in what concrete scenario could you suspect
swapping to increase because of this change?

> > > > > I'll ack when you add performance numbers in changelog.
> > > > 
> > > > It's not exactly a performance optimization but I'll happily run some
> > > > workloads.  Do you have suggestions what to test for?  I.e. where
> > > > would you expect regressions?
> > > > 
> > > Some comparison about amount of swap-out before/after change will be good.
> > > 
> > > Hm. If I do...
> > >   - set up x86-64 NUMA box. (fake numa is ok.)
> > >   - create memcg with 500M limit.
> > >   - running kernel make with make -j 6(or more)
> > > 
> > > see time of make and amount of swap-out.
> > 
> > 4G ram, 500M swap on SSD, numa=fake=16, 10 runs of make -j11 in 500M
> > memcg, standard deviation in parens:
> > 
> > 		seconds		pswpin			pswpout
> > vanilla:	175.359(0.106)	6906.900(1779.135)	8913.200(1917.369)
> > patched:	176.144(0.243)	8581.500(1833.432)	10872.400(2124.104)
> 
> Hmm. swapin/out seems increased. But hmm...stddev is large.
> Is this expected ? reason ?

It's kind of expected because there is only a small number of parallel
jobs that have bursty memory usage, so the slightest timing variations
can make the difference between an episode of heavy thrashing and the
tasks having their bursts at different times and getting along fine.

So we are basically looking at test results that are clustered around
not one, but several different mean values.  The arithmetic mean is
not really meaningful for these samples.

> Anyway, I don't want to disturb you more. Thanks.

I am happy to test if my changes introduce regressions, I don't want
that, obviously.  But do you have a theory behind your concern that
swapping could increase?  Just saying, this test request seemed a bit
random because I don't see where my change would affect this
particular workload.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 34942900137
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 07:32:32 -0400 (EDT)
Date: Tue, 30 Aug 2011 13:32:21 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [patch] Revert "memcg: add memory.vmscan_stat"
Message-ID: <20110830113221.GF13061@redhat.com>
References: <20110808124333.GA31739@redhat.com>
 <20110809083345.46cbc8de.kamezawa.hiroyu@jp.fujitsu.com>
 <20110829155113.GA21661@redhat.com>
 <20110830101233.ae416284.kamezawa.hiroyu@jp.fujitsu.com>
 <20110830070424.GA13061@redhat.com>
 <20110830162050.f6c13c0c.kamezawa.hiroyu@jp.fujitsu.com>
 <20110830084245.GC13061@redhat.com>
 <20110830175609.4977ef7a.kamezawa.hiroyu@jp.fujitsu.com>
 <20110830101726.GD13061@redhat.com>
 <20110830193839.cf0fc597.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110830193839.cf0fc597.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Andrew Brestic <abrestic@google.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Aug 30, 2011 at 07:38:39PM +0900, KAMEZAWA Hiroyuki wrote:
> On Tue, 30 Aug 2011 12:17:26 +0200
> Johannes Weiner <jweiner@redhat.com> wrote:
> 
> > On Tue, Aug 30, 2011 at 05:56:09PM +0900, KAMEZAWA Hiroyuki wrote:
> > > On Tue, 30 Aug 2011 10:42:45 +0200
> > > Johannes Weiner <jweiner@redhat.com> wrote:
>  
> > > > > Assume 3 cgroups in a hierarchy.
> > > > > 
> > > > > 	A
> > > > >        /
> > > > >       B
> > > > >      /
> > > > >     C
> > > > > 
> > > > > C's scan contains 3 causes.
> > > > > 	C's scan caused by limit of A.
> > > > > 	C's scan caused by limit of B.
> > > > > 	C's scan caused by limit of C.
> > > > >
> > > > > If we make hierarchy sum at read, we think
> > > > > 	B's scan_stat = B's scan_stat + C's scan_stat
> > > > > But in precice, this is
> > > > > 
> > > > > 	B's scan_stat = B's scan_stat caused by B +
> > > > > 			B's scan_stat caused by A +
> > > > > 			C's scan_stat caused by C +
> > > > > 			C's scan_stat caused by B +
> > > > > 			C's scan_stat caused by A.
> > > > > 
> > > > > In orignal version.
> > > > > 	B's scan_stat = B's scan_stat caused by B +
> > > > > 			C's scan_stat caused by B +
> > > > > 
> > > > > After this patch,
> > > > > 	B's scan_stat = B's scan_stat caused by B +
> > > > > 			B's scan_stat caused by A +
> > > > > 			C's scan_stat caused by C +
> > > > > 			C's scan_stat caused by B +
> > > > > 			C's scan_stat caused by A.
> > > > > 
> > > > > Hmm...removing hierarchy part completely seems fine to me.
> > > > 
> > > > I see.
> > > > 
> > > > You want to look at A and see whether its limit was responsible for
> > > > reclaim scans in any children.  IMO, that is asking the question
> > > > backwards.  Instead, there is a cgroup under reclaim and one wants to
> > > > find out the cause for that.  Not the other way round.
> > > > 
> > > > In my original proposal I suggested differentiating reclaim caused by
> > > > internal pressure (due to own limit) and reclaim caused by
> > > > external/hierarchical pressure (due to limits from parents).
> > > > 
> > > > If you want to find out why C is under reclaim, look at its reclaim
> > > > statistics.  If the _limit numbers are high, C's limit is the problem.
> > > > If the _hierarchical numbers are high, the problem is B, A, or
> > > > physical memory, so you check B for _limit and _hierarchical as well,
> > > > then move on to A.
> > > > 
> > > > Implementing this would be as easy as passing not only the memcg to
> > > > scan (victim) to the reclaim code, but also the memcg /causing/ the
> > > > reclaim (root_mem):
> > > > 
> > > > 	root_mem == victim -> account to victim as _limit
> > > > 	root_mem != victim -> account to victim as _hierarchical
> > > > 
> > > > This would make things much simpler and more natural, both the code
> > > > and the way of tracking down a problem, IMO.
> > > 
> > > hmm. I have no strong opinion.
> > 
> > I do :-)
> > 
> BTW,  how to calculate C's lru scan caused by A finally ?
> 
>             A
>            /
>           B
>          /
>         C
> 
> At scanning LRU of C because of A's limit, where stats are recorded ?
> 
> If we record it in C, we lose where the memory pressure comes from.

It's recorded in C as 'scanned due to parent'.

If you want to track down where pressure comes from, you check the
outer container, B.  If B is scanned due to internal pressure, you
know that C's external pressure comes from B.  If B is scanned due to
external pressure, you know that B's and C's pressure comes from A or
the physical memory limit (the outermost container, so to speak).

The containers are nested.  If C is scanned because of the limit in A,
then this concerns B as well and B must be scanned as well as B, as
C's usage is fully contained in B.

There is not really a direct connection between C and A that is
irrelevant to B, so I see no need to record in C which parent was the
cause of the pressure.  Just that it was /a/ parent and not itself.
Then you can follow the pressure up the hierarchy tree.

Answer to your original question:

	C_scan_due_to_A = C_scan_external - B_scan_internal - A_scan_external

But IMO, having this exact number is not necessary to find the reason
for why C is experiencing memory pressure in the first place, and I
assume that this is the goal.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

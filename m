Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A5C9D6B0011
	for <linux-mm@kvack.org>; Mon,  9 May 2011 06:18:27 -0400 (EDT)
Date: Mon, 9 May 2011 12:18:17 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/7] memcg: add high/low watermark to res_counter
Message-ID: <20110509101817.GB16531@cmpxchg.org>
References: <20110503064945.GA18927@tiehlicka.suse.cz>
 <BANLkTimmpHcSJuO_8+P=GjYf+wB=Nyq=4w@mail.gmail.com>
 <20110503082550.GD18927@tiehlicka.suse.cz>
 <BANLkTikZtOdzsnjH=43AegLCpYc6ecfKsg@mail.gmail.com>
 <20110504085851.GC1375@tiehlicka.suse.cz>
 <BANLkTinxuSaCEvN4_vB=uA1rdGUwCpovog@mail.gmail.com>
 <20110505065901.GC11529@tiehlicka.suse.cz>
 <20110506142834.90e0b363.kamezawa.hiroyu@jp.fujitsu.com>
 <BANLkTinEEzkpBeTdK9nP2DAxRZbH8Ve=xw@mail.gmail.com>
 <20110509161047.eb674346.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110509161047.eb674346.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>

On Mon, May 09, 2011 at 04:10:47PM +0900, KAMEZAWA Hiroyuki wrote:
> On Sun, 8 May 2011 22:40:47 -0700
> Ying Han <yinghan@google.com> wrote:
> > Using the
> > limit to calculate the wmarks is straight-forward since doing
> > background reclaim reduces the latency spikes under direct reclaim.
> > The direct reclaim is triggered while the usage is hitting the limit.
> > 
> > This is different from the "soft_limit" which is based on the usage
> > and we don't want to reinvent the soft_limit implementation.
> > 
> Yes, this is a different feature.
> 
> 
> The discussion here is how to make APIs for "shrink_to" and "shrink_over", ok ?
> 
> I think there are 3 candidates.
> 
>   1. using distance to limit.
>      memory.shrink_to_distance
>            - memory will be freed to 'limit - shrink_to_distance'.
>      memory.shrink_over_distance
>            - memory will be freed when usage > 'limit - shrink_over_distance'
> 
>      Pros.
>       - Both of shrink_over and shirnk_to can be determined by users.
>       - Can keep stable distance to limit even when limit is changed.
>      Cons.
>       - complicated and seems not natural.
>       - hierarchy support will be very difficult.
> 
>   2. using bare value
>      memory.shrink_to
>            - memory will be freed to this 'shirnk_to'
>      memory.shrink_from
>            - memory will be freed when usage over this value.
>      Pros.
>       - Both of shrink_over and shrink)to can be determined by users.
>       - easy to understand, straightforward.
>       - hierarchy support will be easy.
>      Cons.
>       - The user may need to change this value when he changes the limit.
> 
> 
>   3. using only 'shrink_to'
>      memory.shrink_to
>            - memory will be freed to this value when the usage goes over this vaue
>              to some extent (determined by the system.)
> 
>      Pros.
>       - easy interface.
>       - hierarchy support will be easy.
>       - bad configuration check is very easy. 
>      Cons.
>       - The user may beed to change this value when he changes the limit.
> 
> 
> Then, I now vote for 3 because hierarchy support is easiest and enough handy for
> real use.

3. looks best to me as well.

What I am wondering, though: we already have a limit to push back
memcgs when we need memory, the soft limit.  The 'need for memory' is
currently defined as global memory pressure, which we know may be too
late.  The problem is not having no limit, the problem is that we want
to control the time of when this limit is enforced.  So instead of
adding another limit, could we instead add a knob like

	memory.force_async_soft_reclaim

that asynchroneously pushes back to the soft limit instead of having
another, separate limit to configure?

Pros:
- easy interface
- limit already existing
- hierarchy support already existing
- bad configuration check already existing
Cons:
- ?

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

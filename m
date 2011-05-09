Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 149DA6B0024
	for <linux-mm@kvack.org>; Mon,  9 May 2011 03:17:41 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 5AC203EE0B6
	for <linux-mm@kvack.org>; Mon,  9 May 2011 16:17:37 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4224345DE61
	for <linux-mm@kvack.org>; Mon,  9 May 2011 16:17:37 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2918445DE5C
	for <linux-mm@kvack.org>; Mon,  9 May 2011 16:17:37 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 17EA21DB804B
	for <linux-mm@kvack.org>; Mon,  9 May 2011 16:17:37 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BFC8E1DB8049
	for <linux-mm@kvack.org>; Mon,  9 May 2011 16:17:36 +0900 (JST)
Date: Mon, 9 May 2011 16:10:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/7] memcg: add high/low watermark to res_counter
Message-Id: <20110509161047.eb674346.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTinEEzkpBeTdK9nP2DAxRZbH8Ve=xw@mail.gmail.com>
References: <20110425182849.ab708f12.kamezawa.hiroyu@jp.fujitsu.com>
	<20110429133313.GB306@tiehlicka.suse.cz>
	<20110501150410.75D2.A69D9226@jp.fujitsu.com>
	<20110503064945.GA18927@tiehlicka.suse.cz>
	<BANLkTimmpHcSJuO_8+P=GjYf+wB=Nyq=4w@mail.gmail.com>
	<20110503082550.GD18927@tiehlicka.suse.cz>
	<BANLkTikZtOdzsnjH=43AegLCpYc6ecfKsg@mail.gmail.com>
	<20110504085851.GC1375@tiehlicka.suse.cz>
	<BANLkTinxuSaCEvN4_vB=uA1rdGUwCpovog@mail.gmail.com>
	<20110505065901.GC11529@tiehlicka.suse.cz>
	<20110506142834.90e0b363.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTinEEzkpBeTdK9nP2DAxRZbH8Ve=xw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>

On Sun, 8 May 2011 22:40:47 -0700
Ying Han <yinghan@google.com> wrote:

> On Thu, May 5, 2011 at 10:28 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Thu, 5 May 2011 08:59:01 +0200
> > Michal Hocko <mhocko@suse.cz> wrote:
> >
> >> On Wed 04-05-11 10:16:39, Ying Han wrote:
> >> > On Wed, May 4, 2011 at 1:58 AM, Michal Hocko <mhocko@suse.cz> wrote:
> >> > > On Tue 03-05-11 10:01:27, Ying Han wrote:
> >> > >> On Tue, May 3, 2011 at 1:25 AM, Michal Hocko <mhocko@suse.cz> wrote:
> >> > >> > On Tue 03-05-11 16:45:23, KOSAKI Motohiro wrote:
> >> > >> >> 2011/5/3 Michal Hocko <mhocko@suse.cz>:
> >> > >> >> > On Sun 01-05-11 15:06:02, KOSAKI Motohiro wrote:
> >> > >> >> >> > On Mon 25-04-11 18:28:49, KAMEZAWA Hiroyuki wrote:
> >> > > [...]
> >> > >> >> >> Can you please clarify this? I feel it is not opposite semantics.
> >> > >> >> >
> >> > >> >> > In the global reclaim low watermark represents the point when we _start_
> >> > >> >> > background reclaim while high watermark is the _stopper_. Watermarks are
> >> > >> >> > based on the free memory while this proposal makes it based on the used
> >> > >> >> > memory.
> >> > >> >> > I understand that the result is same in the end but it is really
> >> > >> >> > confusing because you have to switch your mindset from free to used and
> >> > >> >> > from under the limit to above the limit.
> >> > >> >>
> >> > >> >> Ah, right. So, do you have an alternative idea?
> >> > >> >
> >> > >> > Why cannot we just keep the global reclaim semantic and make it free
> >> > >> > memory (hard_limit - usage_in_bytes) based with low limit as the trigger
> >> > >> > for reclaiming?
> >> > >>
> >> > > [...]
> >> > >> The current scheme
> >> > >
> >> > > What is the current scheme?
> >> >
> >> > using the "usage_in_bytes" instead of "free"
> >> >
> >> > >> is closer to the global bg reclaim which the low is triggering reclaim
> >> > >> and high is stopping reclaim. And we can only use the "usage" to keep
> >> > >> the same API.
> >>
> >
> > Sorry for long absence.
> >
> >> And how is this closer to the global reclaim semantic which is based on
> >> the available memory?
> >
> > It's never be the same feature and not a similar feature, I think.
> >
> >> What I am trying to say here is that this new watermark concept doesn't
> >> fit in with the global reclaim. Well, standard user might not be aware
> >> of the zone watermarks at all because they cannot be set. But still if
> >> you are analyzing your memory usage you still check and compare free
> >> memory to min/low/high watermarks to find out what is the current memory
> >> pressure.
> >> If we had another concept with cgroups you would need to switch your
> >> mindset to analyze things.
> >>
> >> I am sorry, but I still do not see any reason why those cgroup watermaks
> >> cannot be based on total-usage.
> >
> > Hmm, so, the interface should be
> >
> > A memory.watermark A --- the total usage which kernel's memory shrinker starts.
> >
> > ?
> 
> 
> >
> > I'm okay with this. And I think this parameter should be fully independent from
> > the limit.
> 
> We need two watermarks like high/low where one is used to trigger the
> background reclaim and the other one is for stopping it. 

For avoiding confusion, I use another word as "shrink_to" and "shrink_over".
When the usage over "shrink_over", the kernel reduce the usage to "shrink_to".


IMHO, determining shrink_over-shrink_to distance is difficult and easy. It's
difficult because it depends on workload and if distacnce is too large,
it will consume much cpu time than expected. It's easy because some small amount of
shrink_over-shrink_to distance works well for usual use, as I set 4MB in my series.
(shrink_over - shrink_to distance is meaningless for users, I think.)

I think shrink_over-shrink_to is an implementation detail just for avoiding
frequent switch on/off memory reclaim, IOW, do jobs in a batched manner.

So, my patch hides "shrink_over" and just shows "shrink_to".


> Using the
> limit to calculate the wmarks is straight-forward since doing
> background reclaim reduces the latency spikes under direct reclaim.
> The direct reclaim is triggered while the usage is hitting the limit.
> 
> This is different from the "soft_limit" which is based on the usage
> and we don't want to reinvent the soft_limit implementation.
> 
Yes, this is a different feature.


The discussion here is how to make APIs for "shrink_to" and "shrink_over", ok ?

I think there are 3 candidates.

  1. using distance to limit.
     memory.shrink_to_distance
           - memory will be freed to 'limit - shrink_to_distance'.
     memory.shrink_over_distance
           - memory will be freed when usage > 'limit - shrink_over_distance'

     Pros.
      - Both of shrink_over and shirnk_to can be determined by users.
      - Can keep stable distance to limit even when limit is changed.
     Cons.
      - complicated and seems not natural.
      - hierarchy support will be very difficult.

  2. using bare value
     memory.shrink_to
           - memory will be freed to this 'shirnk_to'
     memory.shrink_from
           - memory will be freed when usage over this value.
     Pros.
      - Both of shrink_over and shrink)to can be determined by users.
      - easy to understand, straightforward.
      - hierarchy support will be easy.
     Cons.
      - The user may need to change this value when he changes the limit.


  3. using only 'shrink_to'
     memory.shrink_to
           - memory will be freed to this value when the usage goes over this vaue
             to some extent (determined by the system.)

     Pros.
      - easy interface.
      - hierarchy support will be easy.
      - bad configuration check is very easy. 
     Cons.
      - The user may beed to change this value when he changes the limit.


Then, I now vote for 3 because hierarchy support is easiest and enough handy for
real use.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

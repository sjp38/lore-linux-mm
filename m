Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 65BAE6B0023
	for <linux-mm@kvack.org>; Fri,  6 May 2011 01:35:19 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id C76CC3EE0BC
	for <linux-mm@kvack.org>; Fri,  6 May 2011 14:35:15 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id ACC8245DE5B
	for <linux-mm@kvack.org>; Fri,  6 May 2011 14:35:15 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8322E45DE58
	for <linux-mm@kvack.org>; Fri,  6 May 2011 14:35:15 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 74E04E08007
	for <linux-mm@kvack.org>; Fri,  6 May 2011 14:35:15 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 33C6FE08002
	for <linux-mm@kvack.org>; Fri,  6 May 2011 14:35:15 +0900 (JST)
Date: Fri, 6 May 2011 14:28:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/7] memcg: add high/low watermark to res_counter
Message-Id: <20110506142834.90e0b363.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110505065901.GC11529@tiehlicka.suse.cz>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Ying Han <yinghan@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>

On Thu, 5 May 2011 08:59:01 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> On Wed 04-05-11 10:16:39, Ying Han wrote:
> > On Wed, May 4, 2011 at 1:58 AM, Michal Hocko <mhocko@suse.cz> wrote:
> > > On Tue 03-05-11 10:01:27, Ying Han wrote:
> > >> On Tue, May 3, 2011 at 1:25 AM, Michal Hocko <mhocko@suse.cz> wrote:
> > >> > On Tue 03-05-11 16:45:23, KOSAKI Motohiro wrote:
> > >> >> 2011/5/3 Michal Hocko <mhocko@suse.cz>:
> > >> >> > On Sun 01-05-11 15:06:02, KOSAKI Motohiro wrote:
> > >> >> >> > On Mon 25-04-11 18:28:49, KAMEZAWA Hiroyuki wrote:
> > > [...]
> > >> >> >> Can you please clarify this? I feel it is not opposite semantics.
> > >> >> >
> > >> >> > In the global reclaim low watermark represents the point when we _start_
> > >> >> > background reclaim while high watermark is the _stopper_. Watermarks are
> > >> >> > based on the free memory while this proposal makes it based on the used
> > >> >> > memory.
> > >> >> > I understand that the result is same in the end but it is really
> > >> >> > confusing because you have to switch your mindset from free to used and
> > >> >> > from under the limit to above the limit.
> > >> >>
> > >> >> Ah, right. So, do you have an alternative idea?
> > >> >
> > >> > Why cannot we just keep the global reclaim semantic and make it free
> > >> > memory (hard_limit - usage_in_bytes) based with low limit as the trigger
> > >> > for reclaiming?
> > >>
> > > [...]
> > >> The current scheme
> > >
> > > What is the current scheme?
> > 
> > using the "usage_in_bytes" instead of "free"
> > 
> > >> is closer to the global bg reclaim which the low is triggering reclaim
> > >> and high is stopping reclaim. And we can only use the "usage" to keep
> > >> the same API.
> 

Sorry for long absence.

> And how is this closer to the global reclaim semantic which is based on
> the available memory?

It's never be the same feature and not a similar feature, I think.

> What I am trying to say here is that this new watermark concept doesn't
> fit in with the global reclaim. Well, standard user might not be aware
> of the zone watermarks at all because they cannot be set. But still if
> you are analyzing your memory usage you still check and compare free
> memory to min/low/high watermarks to find out what is the current memory
> pressure.
> If we had another concept with cgroups you would need to switch your 
> mindset to analyze things.
> 
> I am sorry, but I still do not see any reason why those cgroup watermaks
> cannot be based on total-usage.

Hmm, so, the interface should be

  memory.watermark  --- the total usage which kernel's memory shrinker starts.

?

I'm okay with this. And I think this parameter should be fully independent from
the limit.

Memcg can work without watermark reclaim. I think my patch just adds a new
_limit_ which a user can shrink usage of memory on deamand with kernel's help.
Memory reclaim works in background but this is not a kswapd, at all.

I guess performance benefit of using watermark under a cgroup which has limit
is very small and I think this is not for a performance tuning parameter. 
This is just a new limit.

Comparing 2 cases,

 cgroup A)
   - has limit of 300M, no watermaks.
 cgroup B)
   - has limit of UNLIMITED, watermarks=300M

A) has hard limit and memory reclaim cost is paid by user threads, and have
risks of OOM under memcg.
B) has no hard limit and memory reclaim cost is paid by kernel threads, and
will not have risk of OOM under memcg, but can be CPU burning.

I think this should be called as soft-limit ;) But we have another soft-limit now.
Then, I call this as watermark. This will be useful to resize usage of memory
in online because application will not hit limit and get big latency even while
an admin makes watermark smaller. 

Hmm, maybe I should allow watermark > limit setting ;).

Thanks,
-Kame






Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

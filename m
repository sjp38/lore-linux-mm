Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9335E6B0092
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 20:02:59 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 3FB633EE0C5
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 10:02:57 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 23FB345DE55
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 10:02:57 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id F2BAC45DE4E
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 10:02:56 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A6747EF8006
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 10:02:56 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 55676EF8003
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 10:02:56 +0900 (JST)
Date: Wed, 19 Jan 2011 09:56:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/5] Add per cgroup reclaim watermarks.
Message-Id: <20110119095650.02db87e0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTi=oFTf9pLKdBU4wXm4tTsWjH+E2q9d5_nm_7gt9@mail.gmail.com>
References: <1294956035-12081-1-git-send-email-yinghan@google.com>
	<1294956035-12081-3-git-send-email-yinghan@google.com>
	<20110114091119.2f11b3b9.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTimo7c3pwFoQvE140o6uFDOaRvxdq6+r3tQnfuPe@mail.gmail.com>
	<alpine.DEB.2.00.1101181227220.18781@chino.kir.corp.google.com>
	<AANLkTi=oFTf9pLKdBU4wXm4tTsWjH+E2q9d5_nm_7gt9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: David Rientjes <rientjes@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 18 Jan 2011 13:10:39 -0800
Ying Han <yinghan@google.com> wrote:

> On Tue, Jan 18, 2011 at 12:36 PM, David Rientjes <rientjes@google.com> wrote:
> > On Tue, 18 Jan 2011, Ying Han wrote:
> >
> >> I agree that "min_free_kbytes" concept doesn't apply well since there
> >> is no notion of "reserved pool" in memcg. I borrowed it at the
> >> beginning is to add a tunable to the per-memcg watermarks besides the
> >> hard_limit.
> >
> > You may want to add a small amount of memory that a memcg may allocate
> > from in oom conditions, however: memory reserves are allocated per-zone
> > and if the entire system is oom and that includes several dozen memcgs,
> > for example, they could all be contending for the same memory reserves.
> > It would be much easier to deplete all reserves since you would have
> > several tasks allowed to allocate from this pool: that's not possible
> > without memcg since the oom killer is serialized on zones and does not
> > kill a task if another oom killed task is already detected in the
> > tasklist.
> 
> so something like per-memcg min_wmark which also needs to be reserved upfront?
> 

I think the variable name 'min_free_kbytes' is the source of confusion...
It's just a watermark to trigger background reclaim. It's not reservation.


> > I think it would be very trivial to DoS the entire machine in this way:
> > set up a thousand memcgs with tasks that have core_state, for example, and
> > trigger them to all allocate anonymous memory up to their hard limit so
> > they oom at the same time. A The machine should livelock with all zones
> > having 0 pages free.
> >
> >> I read the
> >> patch posted from Satoru Moriya "Tunable watermarks", and introducing
> >> the per-memcg-per-watermark tunable
> >> sounds good to me. Might consider adding it to the next post.
> >>
> >
> > Those tunable watermarks were nacked for a reason: they are internal to
> > the VM and should be set to sane values by the kernel with no intevention
> > needed by userspace. A You'd need to show why a memcg would need a user to
> > tune its watermarks to trigger background reclaim and why that's not
> > possible by the kernel and how this is a special case in comparsion to the
> > per-zone watermarks used by the VM.
> 
> KAMEZAWA gave an example on his early post, which some enterprise user
> like to keep fixed amount of free pages
> regardless of the hard_limit.
> 
> Since setting the wmarks has impact on the reclaim behavior of each
> memcg,  adding this flexibility helps the system where it like to
> treat memcg differently based on the priority.
> 

Please add some tricks to throttle the usage of cpu by kswapd-for-memcg
even when the user sets some bad value. And the total number of threads/workers
for all memcg should be throttled, too. (I think this parameter can be 
sysctl or root cgroup parameter.)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

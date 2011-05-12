Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0737B900001
	for <linux-mm@kvack.org>; Thu, 12 May 2011 00:29:23 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id BDE453EE0C1
	for <linux-mm@kvack.org>; Thu, 12 May 2011 13:29:20 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A237545DE5A
	for <linux-mm@kvack.org>; Thu, 12 May 2011 13:29:20 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7CF8345DE55
	for <linux-mm@kvack.org>; Thu, 12 May 2011 13:29:20 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6948B1DB8046
	for <linux-mm@kvack.org>; Thu, 12 May 2011 13:29:20 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 226B9E08004
	for <linux-mm@kvack.org>; Thu, 12 May 2011 13:29:20 +0900 (JST)
Date: Thu, 12 May 2011 13:22:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 0/7] memcg async reclaim
Message-Id: <20110512132237.813a7c7f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110511205110.354fa05e.akpm@linux-foundation.org>
References: <20110510190216.f4eefef7.kamezawa.hiroyu@jp.fujitsu.com>
	<20110511182844.d128c995.akpm@linux-foundation.org>
	<20110512103503.717f4a96.kamezawa.hiroyu@jp.fujitsu.com>
	<20110511205110.354fa05e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Ying Han <yinghan@google.com>, Johannes Weiner <jweiner@redhat.com>, Michal Hocko <mhocko@suse.cz>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>

On Wed, 11 May 2011 20:51:10 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Thu, 12 May 2011 10:35:03 +0900 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > > What (user-visible) problem is this patchset solving?
> > > 
> > > IOW, what is the current behaviour, what is wrong with that behaviour
> > > and what effects does the patchset have upon that behaviour?
> > > 
> > > The sole answer from the above is "latency spikes".  Anything else?
> > > 
> > 
> > I think this set has possibility to fix latency spike. 
> > 
> > For example, in previous set, (which has tuning knobs), do a file copy
> > of 400M file under 400M limit.
> > ==
> > 1) == hard limit = 400M ==
> > [root@rhel6-test hilow]# time cp ./tmpfile xxx                
> > real    0m7.353s
> > user    0m0.009s
> > sys     0m3.280s
> > 
> > 2) == hard limit 500M/ hi_watermark = 400M ==
> > [root@rhel6-test hilow]# time cp ./tmpfile xxx
> > 
> > real    0m6.421s
> > user    0m0.059s
> > sys     0m2.707s
> > ==
> > and in both case, memory usage after test was 400M.
> 
> I'm surprised that reclaim consumed so much CPU.  But I guess that's a
> 200,000 page/sec reclaim rate which sounds high(?) but it's - what -
> 15,000 CPU clocks per page?  I don't recall anyone spending much effort
> on instrumenting and reducing CPU consumption in reclaim.
> 
Maybe I need to count the number of congestion_wait() in direct reclaim path.
"prioriry" may goes very high too early.....
(I don't like 'priority' in vmscan.c very much ;)

> Presumably there will be no improvement in CPU consumption on
> uniprocessor kernels or in single-CPU containers.  More likely a
> deterioration.
> 
Yes, no improvements on CPU cunsumption. (As I've repeatedly written.)
Just moving when the cpu is consumed.
I wanted a switch to control that for scheduling freeing pages when the admin
knows the system is free. But this version drops the knob for simplification
and check the 'default' & 'automatic' way. I'll add a knob again and then,
add a knob of turn-off this feature in natural way.


This is a result in previous set, which had elapsed_time statistics.
==
 # cat /cgroup/memory/A/memory.stat
 ....
 direct_elapsed_ns 0
 soft_elapsed_ns 0
 wmark_elapsed_ns 103566424
 direct_scanned 0
 soft_scanned 0
 wmark_scanned 29303
 direct_freed 0
 soft_freed 0
 wmark_freed 29290
==

In this run (maybe not copy, just 'cat'), async reclaim scan 29000 pages and consumes 0.1ms


> 
> ahem.
> 
> Copying a 400MB file in a non-containered kernel on this 8GB machine
> with old, slow CPUs takes 0.64 seconds systime, 0.66 elapsed.  Five
> times less than your machine.  Where the heck did all that CPU time go?
> 

Ah, sorry. above was on KVM.  without container.
==
[root@rhel6-test hilow]# time cp ./tmpfile xxx

real    0m5.197s
user    0m0.006s
sys     0m2.599s
==
Hmm, still slow. I'll use real hardware in the next post.

Maybe it's good to do a test with complex workload which use file cache.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

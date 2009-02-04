Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id E531B6B003D
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 01:51:55 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n146pqU8025640
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 4 Feb 2009 15:51:53 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7A5F245DD75
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 15:51:52 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5B5F945DD74
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 15:51:52 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6947E1DB803A
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 15:51:52 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 15B331DB803F
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 15:51:52 +0900 (JST)
Date: Wed, 4 Feb 2009 15:50:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [-mm patch] Show memcg information during OOM (v3)
Message-Id: <20090204155041.76d0927c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090204064249.GC4456@balbir.in.ibm.com>
References: <20090203172135.GF918@balbir.in.ibm.com>
	<4988E727.8030807@cn.fujitsu.com>
	<20090204033750.GB4456@balbir.in.ibm.com>
	<20090204142455.83c38ad6.kamezawa.hiroyu@jp.fujitsu.com>
	<20090204064249.GC4456@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 4 Feb 2009 12:12:49 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-02-04 14:24:55]:
> 
> > On Wed, 4 Feb 2009 09:07:50 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> > > > > +}
> > > > > +
> > > > >  #endif /* CONFIG_CGROUP_MEM_CONT */
> > > > >  
> > > > 
> > > > > +void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
> > > > > +{
> > > > > +	struct cgroup *task_cgrp;
> > > > > +	struct cgroup *mem_cgrp;
> > > > > +	/*
> > > > > +	 * Need a buffer on stack, can't rely on allocations. The code relies
> > > > 
> > > > I think it's in .bss section, but not on stack, and it's better to explain why
> > > > the static buffer is safe in the comment.
> > > >
> > > 
> > > Yes, it is no longer on stack, in the original patch it was. I'll send
> > > an updated patch 
> > > 
> > In the newest mmotm, OOM kill message is following.
> > ==
> > Feb  4 13:16:28 localhost kernel: [  249.338911] malloc2 invoked oom-killer: gfp_mask=0xd0, order=0, oomkilladj=0
> > Feb  4 13:16:28 localhost kernel: [  249.339018] malloc2 cpuset=/ mems_allowed=0
> > Feb  4 13:16:28 localhost kernel: [  249.339023] Pid: 3459, comm: malloc2 Not tainted 2.6.29-rc3-mm1 #1
> > Feb  4 13:16:28 localhost kernel: [  249.339185] Call Trace:
> > Feb  4 13:16:28 localhost kernel: [  249.339202]  [<ffffffff8148dda6>] ? _spin_unlock+0x26/0x2a
> > Feb  4 13:16:28 localhost kernel: [  249.339210]  [<ffffffff8108d48d>] oom_kill_process+0x99/0x272
> > Feb  4 13:16:28 localhost kernel: [  249.339214]  [<ffffffff8108d918>] ? select_bad_process+0x9d/0xfa
> > Feb  4 13:16:28 localhost kernel: [  249.339219]  [<ffffffff8108dc8f>] mem_cgroup_out_of_memory+0x65/0x82
> > Feb  4 13:16:28 localhost kernel: [  249.339224]  [<ffffffff810bd457>] __mem_cgroup_try_charge+0x14c/0x196
> > Feb  4 13:16:28 localhost kernel: [  249.339229]  [<ffffffff810bdffa>] mem_cgroup_charge_common+0x47/0x72
> > Feb  4 13:16:28 localhost kernel: [  249.339234]  [<ffffffff810be063>] mem_cgroup_newpage_charge+0x3e/0x4f
> > Feb  4 13:16:28 localhost kernel: [  249.339239]  [<ffffffff810a05f9>] handle_mm_fault+0x214/0x761
> > Feb  4 13:16:28 localhost kernel: [  249.339244]  [<ffffffff8149062d>] do_page_fault+0x248/0x25f
> > Feb  4 13:16:28 localhost kernel: [  249.339249]  [<ffffffff8148e64f>] page_fault+0x1f/0x30
> > Feb  4 13:16:28 localhost kernel: [  249.339260] Task in /group_A/01 killed as a result of limit of /group_A
> > Feb  4 13:16:28 localhost kernel: [  249.339264] memory: usage 39168kB, limit 40960kB, failcnt 1
> > Feb  4 13:16:28 localhost kernel: [  249.339266] memory+swap: usage 40960kB, limit 40960kB, failcnt 15
> > ==
> > Task in /group_A/01 is killed by mem+swap limit of /group_A. 
> > 
> > Yeah, very nice look :) thank you.
> > 
> 
> Welcome! Thanks for the good suggestion earlier.
> 
> > BTW, I wonder can't we show the path of mount point ?
> > /group_A/01 is /cgroup/group_A/01 and /group_A/ is /cgroup/group_A/ on this system.
> > Very difficult ?
> >
> 
> No, it is not very difficult, we just need to append the mount point.
> The reason for not doing it is consistency with output of
> /proc/<pid>/cgroup and other places where cgroup_path prints the path
> relative to the mount point. Since we are talking about memory, the
> administrator should know where it is mounted. Do you strongly feel
> the need to add mount point? My concern is consistency with other
> cgroup output (look at /proc/sched_debug) for example.
> 
No. just curious :)

Thanks a lot. Consistency is more important.

-Kame



> -- 
> 	Balbir
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

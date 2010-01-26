Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4DB826B009A
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 18:12:44 -0500 (EST)
Date: Tue, 26 Jan 2010 15:12:02 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3] oom-kill: add lowmem usage aware oom kill handling
Message-Id: <20100126151202.75bd9347.akpm@linux-foundation.org>
In-Reply-To: <20100125151503.49060e74.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100121145905.84a362bb.kamezawa.hiroyu@jp.fujitsu.com>
	<20100122152332.750f50d9.kamezawa.hiroyu@jp.fujitsu.com>
	<20100125151503.49060e74.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, rientjes@google.com, minchan.kim@gmail.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, 25 Jan 2010 15:15:03 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> Did several tests on x86-32 and I felt that sysctl value should be
> printed on oom log... this is v3.
> 
> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Default oom-killer uses badness calculation based on process's vm_size
> and some amounts of heuristics. Some users see proc->oom_score and
> proc->oom_adj to control oom-killed tendency under their server.
> 
> Now, we know oom-killer don't work ideally in some situaion, in PCs. Some
> enhancements are demanded. But such enhancements for oom-killer makes
> incomaptibility to oom-controls in enterprise world. So, this patch
> adds sysctl for extensions for oom-killer. Main purpose is for
> making a chance for wider test for new scheme.
> 
> One cause of OOM-Killer is memory shortage in lower zones.
> (If memory is enough, lowmem_reserve_ratio works well. but..)
> I saw lowmem-oom frequently on x86-32 and sometimes on ia64 in
> my cusotmer support jobs. If we just see process's vm_size at oom,
> we can never kill a process which has lowmem.
> At last, there will be an oom-serial-killer.
> 
> Now, we have per-mm lowmem usage counter. We can make use of it
> to select a good victim.
> 
> This patch does
>   - add sysctl for new bahavior.
>   - add CONSTRAINT_LOWMEM to oom's constraint type.
>   - pass constraint to __badness()
>   - change calculation based on constraint. If CONSTRAINT_LOWMEM,
>     use low_rss instead of vmsize.
> 
> Changelog 2010/01/25
>  - showing extension_mask value in OOM kill main log header.
> Changelog 2010/01/22:
>  - added sysctl
>  - fixed !CONFIG_MMU
>  - fixed fs/proc/base.c breakacge.

It'd be nice to see some testing results for this.  Perhaps "here's a
test case and here's the before-and-after behaviour".

I don't like the sysctl knob much.  Hardly anyone will know to enable
it so the feature won't get much testing and this binary decision
fractures the testing effort.  It would be much better if we can get
everyone running the same code.  I mean, if there are certain workloads
on certain machines with which the oom-killer doesn't behave correctly
then fix it!

Why was the '#include <linux/sysctl.h>" removed from sysctl.c?

The patch adds a random newline to sysctl.c.

It was never a good idea to add extern declarations to sysctl.c.  It's
better to add them to a subsystem-specific header file (ie:
mm-sysctl.h) and then include that file from the mm files that define
or use sysctl_foo, and include it into sysctl.c.  Oh well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

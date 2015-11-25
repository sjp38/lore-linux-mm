Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id A12406B0038
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 09:44:00 -0500 (EST)
Received: by wmec201 with SMTP id c201so73081983wme.1
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 06:44:00 -0800 (PST)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id p3si35151742wjb.37.2015.11.25.06.43.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Nov 2015 06:43:59 -0800 (PST)
Date: Wed, 25 Nov 2015 15:43:54 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 1/2] memcg: flatten task_struct->memcg_oom
Message-ID: <20151125144354.GB17308@twins.programming.kicks-ass.net>
References: <20150913185940.GA25369@htj.duckdns.org>
 <55FEC685.5010404@oracle.com>
 <20150921200141.GH13263@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150921200141.GH13263@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Ingo Molnar <mingo@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, akpm@linux-foundation.org, hannes@cmpxchg.org, mhocko@kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, vdavydov@parallels.com, kernel-team@fb.com

On Mon, Sep 21, 2015 at 04:01:41PM -0400, Tejun Heo wrote:
> (cc'ing scheduler folks)
> 
> On Sun, Sep 20, 2015 at 10:45:25AM -0400, Sasha Levin wrote:
> > On 09/13/2015 02:59 PM, Tejun Heo wrote:
> > > task_struct->memcg_oom is a sub-struct containing fields which are
> > > used for async memcg oom handling.  Most task_struct fields aren't
> > > packaged this way and it can lead to unnecessary alignment paddings.
> > > This patch flattens it.
> > > 
> > > * task.memcg_oom.memcg          -> task.memcg_in_oom
> > > * task.memcg_oom.gfp_mask	-> task.memcg_oom_gfp_mask
> > > * task.memcg_oom.order          -> task.memcg_oom_order
> > > * task.memcg_oom.may_oom        -> task.memcg_may_oom
> ...
> > I've started seeing these warnings:
> > 
> > [1598889.250160] WARNING: CPU: 3 PID: 11648 at include/linux/memcontrol.h:414 handle_mm_fault+0x1020/0x3fa0()
> ...
> > [1598892.247256] dump_stack (lib/dump_stack.c:52)
> > [1598892.249105] warn_slowpath_common (kernel/panic.c:448)
> > [1598892.253202] warn_slowpath_null (kernel/panic.c:482)
> > [1598892.255148] handle_mm_fault (include/linux/memcontrol.h:414 mm/memory.c:3430)
> > [1598892.268151] __do_page_fault (arch/x86/mm/fault.c:1239)
> > [1598892.269022] trace_do_page_fault (arch/x86/mm/fault.c:1331 include/linux/jump_label.h:133 include/linux/context_tracking_state.h:30 include/linux/context_tracking.h:46 arch/x86/mm/fault.c:1332)
> > [1598892.269894] do_async_page_fault (arch/x86/kernel/kvm.c:280)
> > [1598892.270792] async_page_fault (arch/x86/entry/entry_64.S:989)
> > 
> > Not sure if it's because of this patch or not, but I haven't seen them before.
> 
> So, the only way the patch could have caused the above is if someone
> who isn't the task itself is writing to the bitfields while the task
> is running.  Looking through the fields, ->sched_reset_on_fork seems a
> bit suspicious.  __sched_setscheduler() looks like it can modify the
> bit while the target task is running.  Peter, am I misreading the
> code?

Nope, that's quite possible. Looks like we need to break up those
bitfields a bit. All the scheduler ones should be serialized by
scheduler locks, but the others are fair game.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

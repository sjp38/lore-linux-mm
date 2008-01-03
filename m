Date: Thu, 3 Jan 2008 10:54:04 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 11 of 11] not-wait-memdie
In-Reply-To: <20080103130656.GR30939@v2.random>
Message-ID: <alpine.DEB.0.9999.0801031051260.27032@chino.kir.corp.google.com>
References: <504e981185254a12282d.1199326157@v2.random> <alpine.DEB.0.9999.0801030152540.25018@chino.kir.corp.google.com> <20080103130656.GR30939@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@cpushare.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 3 Jan 2008, Andrea Arcangeli wrote:

> > So I think we're moving in a direction of requiring OOM killer timeouts 
> > and the only plausible way to do that is on a per-task level.  It would 
> > require another unsigned long addition to struct task_struct but would 
> > completely fix OOM killer deadlocks.
> 
> Yes. That can be added incrementally in a later patch, it's a new
> logic. In the meantime the deadlock is gone.
> 

In the "meantime" assumes that this patch is added before a jiffies 
count is added to struct task_struct to detect OOM killer timeouts.  
Since per-task OOM killer timeouts will obsolete this change, it doesn't 
seem beneficial to add.

> In practice there's a sort of timeout already, the oom-killing task
> will schedule_timeout(1) with the zone-oom-lock hold, and all other
> tasks trying to free memory (except the TIF_MEMDIE one) will also
> schedule_timeout(1) inside the VM code. That tends to prevent spurious
> kills already but it's far from a guarantee.
> 

I agree, it's not a guarantee because of tasks that can get stuck in D 
state and never exit after repeatedly being OOM killed.  OOM killer 
timeouts would solve that problem and would be able to scale the offending 
task back by removing access to memory reserves and reducing its 
timeslice.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

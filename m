Date: Tue, 26 Jun 2007 14:20:42 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] oom: serialize oom killer for cpusets
In-Reply-To: <20070626205533.GH7059@v2.random>
Message-ID: <alpine.DEB.0.99.0706261414440.6721@chino.kir.corp.google.com>
References: <alpine.DEB.0.99.0706260241460.26409@chino.kir.corp.google.com>
 <20070626205533.GH7059@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 26 Jun 2007, Andrea Arcangeli wrote:

> This will help reducing the spurious-oom-kill window but it won't
> close it completely because no memory is released until the sigkill is
> handled and do_exit is called by the current task. I suspect you could
> close the race window completely by using my same TIF_MEMDIE slow-path
> to clear the CS_OOM bitflag in the cpuset (where I clear the global
> VM_is_OOM) instead of doing it before returning from oom-kill which is
> too early on.

In that case, it would turn into a simple cpuset_exit_oom(tsk); in the 
test_tsk_thread_flag(tsk, TIF_MEMDIE) check in exit_notify().  That's 
clean, but what happens if tsk gets stuck in TASK_UNINTERRUPTIBLE, for 
whatever reason, and then we leave the cpuset locked out of the OOM 
killer?  I'm trying to avoid having a last_tif_memdie_jiffies for each 
struct cpuset.

> BTW, since you applied on top of my oom patchset, I hope somebody will
> help integrating it to mainline or at least -mm! ;)
> 

I was assuming that your patchset had already reached -mm so I simply 
applied it on top of current git which gives no conflicts.  I hope to see 
your patches included.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

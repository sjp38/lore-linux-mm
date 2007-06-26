Date: Tue, 26 Jun 2007 23:57:03 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] oom: serialize oom killer for cpusets
Message-ID: <20070626215702.GA22366@v2.random>
References: <alpine.DEB.0.99.0706260241460.26409@chino.kir.corp.google.com> <20070626205533.GH7059@v2.random> <alpine.DEB.0.99.0706261414440.6721@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.0.99.0706261414440.6721@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 26, 2007 at 02:20:42PM -0700, David Rientjes wrote:
> In that case, it would turn into a simple cpuset_exit_oom(tsk); in the 
> test_tsk_thread_flag(tsk, TIF_MEMDIE) check in exit_notify().  That's 
> clean, but what happens if tsk gets stuck in TASK_UNINTERRUPTIBLE, for 
> whatever reason, and then we leave the cpuset locked out of the OOM 
> killer?  I'm trying to avoid having a last_tif_memdie_jiffies for each 
> struct cpuset.

Right, to avoid risking deadlocks with infinite loops like the one
I've fixed in nfs (a R state deadlock in that case, not D state),
you'd need a last_tif_memdie_jiffies in the cpuset :(

I wish there was a cleaner way to detect if we run into a
deadlock... At least in your case since you kill "current" you avoid
some of the TASK_UNINTERRUPTIBLE deadlocks like the one where the
chosen one is blocked in the PG_locked bitflag. The chosen one for you
is alive and well running inside alloc_pages, so it's more likely
capable to notice that it received a sigkill, than the ones that are
already in D state.

> I was assuming that your patchset had already reached -mm so I simply 

I didn't receive any -mm automatic email about it yet, so I assumed
it's not yet in.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

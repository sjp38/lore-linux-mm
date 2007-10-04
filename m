Subject: Re: [PATCH 3/6] cpuset write throttle
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20071004005658.732b96cc.pj@sgi.com>
References: <469D3342.3080405@google.com> <46E741B1.4030100@google.com>
	 <46E7434F.9040506@google.com>
	 <20070914161517.5ea3847f.akpm@linux-foundation.org>
	 <4702E49D.2030206@google.com>
	 <Pine.LNX.4.64.0710031045290.3525@schroedinger.engr.sgi.com>
	 <4703FF89.4000601@google.com>
	 <Pine.LNX.4.64.0710032055120.4560@schroedinger.engr.sgi.com>
	 <1191483450.13204.96.camel@twins>  <20071004005658.732b96cc.pj@sgi.com>
Content-Type: text/plain
Date: Thu, 04 Oct 2007 10:15:05 +0200
Message-Id: <1191485705.5574.1.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: clameter@sgi.com, solo@google.com, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, 2007-10-04 at 00:56 -0700, Paul Jackson wrote:
> Peter wrote:
> > Perhaps you can keep a proportion in the cpu-set, and do a similar trick
> > that the process proportions do.
> 
> Beware -- the following comment is made by someone who has been
> basically zero attention to this thread, so could be --way-- off
> the mark.
> 
> Be that as it may, avoid putting anything in the cpuset that you need
> to get to frequently.  Access to all cpusets in the system is guarded
> by a single global mutex.  The current performance assumption is that
> about the only things that need to access the contents of a cpuset are:
>  1) explicit user file operations on the special files in the cpuset
>     file system, and
>  2) some exceptional situations from slow code paths, such as memory
>     shortage or cpu hotplug events.
> 
> Well ... almost.  If you don't mind the occassional access to the wrong
> cpuset, then just taking the task_lock on the current task will guarantee
> you that the cpuset pointer in the task struct points to --some-- cpuset,
> usually the right one.  This can be (and is) used for some statistic
> gathering purposes (look for 'fmeter' in kernel/cpuset.c), where exact
> counts are not required.  Perhaps that applies here as well.

Ugh, yeah. Its a statistical thing, but task_lock is quite a big lock to
take. Are cpusets RCU freed? In which case we could just rcu_deref the
cpuset pointer and do whatever needs done to whatever we find.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

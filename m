Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C9CBF8D0039
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 18:36:44 -0500 (EST)
Date: Thu, 27 Jan 2011 15:36:42 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC] mm: Make vm_acct_memory scalable for large memory
 allocations
Message-Id: <20110127153642.f022b51c.akpm@linux-foundation.org>
In-Reply-To: <1296082319.2712.100.camel@schen9-DESK>
References: <1296082319.2712.100.camel@schen9-DESK>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, 26 Jan 2011 14:51:59 -0800
Tim Chen <tim.c.chen@linux.intel.com> wrote:

> During testing of concurrent malloc/free by multiple processes on a 8
> socket NHM-EX machine (8cores/socket, 64 cores total), I noticed that
> malloc of large memory (e.g. 32MB) did not scale well.  A test patch
> included here increased 32MB mallocs/free with 64 concurrent processes
> from 69K operations/sec to 4066K operations/sec on 2.6.37 kernel, and
> eliminated the cpu cycles contending for spin_lock in the vm_commited_as
> percpu_counter.

This seems like a pretty dumb test case.  We have 64 cores sitting in a
loop "allocating" 32MB of memory, not actually using that memory and
then freeing it up again.

Any not-completely-insane application would actually _use_ the memory. 
Which involves pagefaults, page allocations and much memory traffic
modifying the page contents.

Do we actually care?

> Spin lock contention occurs when vm_acct_memory increments/decrements
> the percpu_counter vm_committed_as by the number of pages being
> used/freed. Theoretically vm_committed_as is a percpu_counter and should
> streamline the concurrent update by using the local counter in
> vm_commited_as.  However, if the update is greater than
> percpu_counter_batch limit, then it will overflow into the global count
> in vm_commited_as.  Currently percpu_counter_batch is non-configurable
> and hardcoded to 2*num_online_cpus.  So any update of vm_commited_as by
> more than 256 pages will cause overflow in my test scenario which has
> 128 logical cpus. 
> 
> In the patch, I have set an enlargement multiplication factor for
> vm_commited_as's batch limit. I limit the sum of all local counters up
> to 5% of the total pages before overflowing into the global counter.
> This will avoid the frequent contention of the spin_lock in
> vm_commited_as. Some additional work will need to be done to make
> setting of this multiplication factor cpu hotplug aware.  Advise on
> better approaches are welcomed.
> 
> ...
> 
> Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
> diff --git a/include/linux/percpu_counter.h b/include/linux/percpu_counter.h
> index 46f6ba5..5a892d8 100644
> --- a/include/linux/percpu_counter.h
> +++ b/include/linux/percpu_counter.h
> @@ -21,6 +21,7 @@ struct percpu_counter {
>  #ifdef CONFIG_HOTPLUG_CPU
>  	struct list_head list;	/* All percpu_counters are on a list */
>  #endif
> +	u32 multibatch;
>  	s32 __percpu *counters;
>  };

I dunno.  Wouldn't it be better to put a `batch' field into
percpu_counter and then make the global percpu_counter_batch just go
away?

That would require modifying each counter's `batch' at cpuhotplug time,
while somehow retaining the counter's user's intent.  So perhaps the
counter would need two fields - original_batch and operating_batch or
similar.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f171.google.com (mail-ve0-f171.google.com [209.85.128.171])
	by kanga.kvack.org (Postfix) with ESMTP id 76C6D6B0037
	for <linux-mm@kvack.org>; Wed, 28 May 2014 12:18:34 -0400 (EDT)
Received: by mail-ve0-f171.google.com with SMTP id oz11so12738114veb.16
        for <linux-mm@kvack.org>; Wed, 28 May 2014 09:18:34 -0700 (PDT)
Received: from cdptpa-oedge-vip.email.rr.com (cdptpa-outbound-snat.email.rr.com. [107.14.166.227])
        by mx.google.com with ESMTP id ph7si11001768veb.6.2014.05.28.09.18.33
        for <linux-mm@kvack.org>;
        Wed, 28 May 2014 09:18:33 -0700 (PDT)
Date: Wed, 28 May 2014 12:18:32 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 1/2] ftrace: print stack usage right before Oops
Message-ID: <20140528121832.747aaf75@gandalf.local.home>
In-Reply-To: <1401260039-18189-1-git-send-email-minchan@kernel.org>
References: <1401260039-18189-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, rusty@rustcorp.com.au, mst@redhat.com, Dave Hansen <dave.hansen@intel.com>

On Wed, 28 May 2014 15:53:58 +0900
Minchan Kim <minchan@kernel.org> wrote:

> While I played with my own feature(ex, something on the way to reclaim),
> kernel went to oops easily. I guessed reason would be stack overflow
> and wanted to prove it.
> 
> I found stack tracer which would be very useful for me but kernel went
> oops before my user program gather the information via
> "watch cat /sys/kernel/debug/tracing/stack_trace" so I couldn't get an
> stack usage of each functions.
> 
> What I want was that emit the kernel stack usage when kernel goes oops.
> 
> This patch records callstack of max stack usage into ftrace buffer
> right before Oops and print that information with ftrace_dump_on_oops.
> At last, I can find a culprit. :)
> 

This is not dependent on patch 2/2, nor is 2/2 dependent on this patch,
I'll review this as if 2/2 does not exist.


> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  kernel/trace/trace_stack.c | 32 ++++++++++++++++++++++++++++++--
>  1 file changed, 30 insertions(+), 2 deletions(-)
> 
> diff --git a/kernel/trace/trace_stack.c b/kernel/trace/trace_stack.c
> index 5aa9a5b9b6e2..5eb88e60bc5e 100644
> --- a/kernel/trace/trace_stack.c
> +++ b/kernel/trace/trace_stack.c
> @@ -51,6 +51,30 @@ static DEFINE_MUTEX(stack_sysctl_mutex);
>  int stack_tracer_enabled;
>  static int last_stack_tracer_enabled;
>  
> +static inline void print_max_stack(void)
> +{
> +	long i;
> +	int size;
> +
> +	trace_printk("        Depth    Size   Location"
> +			   "    (%d entries)\n"

Please do not break strings just to satisfy that silly 80 character
limit. Even Linus Torvalds said that's pretty stupid.

Also, do not use trace_printk(). It is not made to be included in a
production kernel. It reserves special buffers to make it as fast as
possible, and those buffers should not be created in production
systems. In fact, I will probably add for 3.16 a big warning message
when trace_printk() is used.

Since this is a bug, why not just use printk() instead?

BTW, wouldn't this this function crash as well if the stack is already
bad?

-- Steve

> +			   "        -----    ----   --------\n",
> +			   max_stack_trace.nr_entries - 1);
> +
> +	for (i = 0; i < max_stack_trace.nr_entries; i++) {
> +		if (stack_dump_trace[i] == ULONG_MAX)
> +			break;
> +		if (i+1 == max_stack_trace.nr_entries ||
> +				stack_dump_trace[i+1] == ULONG_MAX)
> +			size = stack_dump_index[i];
> +		else
> +			size = stack_dump_index[i] - stack_dump_index[i+1];
> +
> +		trace_printk("%3ld) %8d   %5d   %pS\n", i, stack_dump_index[i],
> +				size, (void *)stack_dump_trace[i]);
> +	}
> +}
> +
>  static inline void
>  check_stack(unsigned long ip, unsigned long *stack)
>  {
> @@ -149,8 +173,12 @@ check_stack(unsigned long ip, unsigned long *stack)
>  			i++;
>  	}
>  
> -	BUG_ON(current != &init_task &&
> -		*(end_of_stack(current)) != STACK_END_MAGIC);
> +	if ((current != &init_task &&
> +		*(end_of_stack(current)) != STACK_END_MAGIC)) {
> +		print_max_stack();
> +		BUG();
> +	}
> +
>   out:
>  	arch_spin_unlock(&max_stack_lock);
>  	local_irq_restore(flags);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 646AB6B0253
	for <linux-mm@kvack.org>; Thu, 20 Aug 2015 19:10:30 -0400 (EDT)
Received: by pacdd16 with SMTP id dd16so29545822pac.2
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 16:10:30 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id h11si9704820pdf.39.2015.08.20.16.10.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Aug 2015 16:10:29 -0700 (PDT)
Date: Thu, 20 Aug 2015 16:10:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch -mm] mm, oom: add global access to memory reserves on
 livelock
Message-Id: <20150820161028.07855b9076447c4a52fcff97@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.10.1508201358490.607@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1508201358490.607@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Oleg Nesterov <oleg@redhat.com>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 20 Aug 2015 14:00:36 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:

> On system oom, a process may fail to exit if its thread depends on a lock
> held by another allocating process.
> 
> In this case, we can detect an oom kill livelock that requires memory
> allocation to be successful to resolve.
> 
> This patch introduces an oom expiration, set to 5s, that defines how long
> a thread has to exit after being oom killed.
> 
> When this period elapses, it is assumed that the thread cannot make
> forward progress without help.  The only help the VM may provide is to
> allow pending allocations to succeed, so it grants all allocators access
> to memory reserves after reclaim and compaction have failed.
> 
> This patch does not allow global access to memory reserves on memcg oom
> kill, but the functionality is there if extended.

I'm struggling a bit to understand how this works.  afaict what happens
is that if some other (non-oom-killed) thread is spinning in the page
allocator and then __alloc_pages_may_oom() decides to oom-kill this
not-yet-oom-killed thread, out_of_memory() will then tell this process
"you can access page reserves", rather than oom-killing it.

I think.

If so, the "provide all threads" comment over the OOM_EXPIRE_MSECS
definition is a bit incomplete.

Also, there are a whole bunch of reasons why a caller to
out_of_memory() won't call into select_bad_process(), where all the
magic happens.  Such as task_will_free_mem(), !oom_unkillable_task(),
etc.  Can't those thing prevent those threads from getting permission
to use page reserves?

I suspect I'm just not understanding the implementation here.  A fuller
explanation (preferably in the .c files!) would help.


Also...  the hard-wired 5 second delay is of course problematic.  What
goes wrong if this is reduced to zero?  ie, let non-oom-killed threads
access page reserves immediately?

>
> ...
>
> @@ -254,8 +263,57 @@ static enum oom_constraint constrained_alloc(struct oom_control *oc,
>  }
>  #endif
>  
> +#ifdef CONFIG_STACKTRACE
> +#define MAX_STACK_TRACE_ENTRIES	(64)
> +static unsigned long stack_trace_entries[MAX_STACK_TRACE_ENTRIES *
> +					 sizeof(unsigned long)];
> +static DEFINE_MUTEX(stack_trace_mutex);
> +
> +static void print_stacks_expired(struct task_struct *task)
> +{
> +	/* One set of stack traces every OOM_EXPIRE_MS */
> +	static DEFINE_RATELIMIT_STATE(expire_rs, OOM_EXPIRE_MSECS / 1000 * HZ,
> +				      1);
> +	struct stack_trace trace = {
> +		.nr_entries = 0,
> +		.max_entries = ARRAY_SIZE(stack_trace_entries),
> +		.entries = stack_trace_entries,
> +		.skip = 2,
> +	};
> +
> +	if (!__ratelimit(&expire_rs))
> +		return;
> +
> +	WARN(true,
> +	     "%s (%d) has failed to exit -- global access to memory reserves started\n",
> +	     task->comm, task->pid);
> +
> +	/*
> +	 * If cred_guard_mutex can't be acquired, this may be a mutex that is
> +	 * being held causing the livelock.  Return without printing the stack.
> +	 */
> +	if (!mutex_trylock(&task->signal->cred_guard_mutex))
> +		return;
> +
> +	mutex_lock(&stack_trace_mutex);
> +	save_stack_trace_tsk(task, &trace);
> +
> +	pr_info("Call Trace of %s/%d:\n", task->comm, task->pid);
> +	print_stack_trace(&trace, 0);
> +
> +	mutex_unlock(&stack_trace_mutex);
> +	mutex_unlock(&task->signal->cred_guard_mutex);
> +}
> +#else
> +static inline void print_stacks_expired(struct task_struct *task)
> +{
> +}
> +#endif /* CONFIG_STACKTRACE */

That ""%s (%d) has failed to exit" warning is still useful if
CONFIG_STACKTRACE=n and I suggest it be moved into the caller.

Alternatively, make that message in exit_mm() dependent on
CONFIG_STACKTRACE as well - it's a bit odd to print the "ended" message
without having printed the "started" message.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

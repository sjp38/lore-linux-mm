Date: Tue, 31 Jul 2007 10:01:14 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [rfc] balance-on-fork NUMA placement
Message-ID: <20070731080114.GA12367@elte.hu>
References: <20070731054142.GB11306@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070731054142.GB11306@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <ak@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

* Nick Piggin <npiggin@suse.de> wrote:

> This patch uses memory policies to attempt to improve this. It 
> requires that we ask the scheduler to suggest the child's new CPU 
> earlier in the fork, but that is not a fundamental difference.

no fundamental objections, but i think we could simply move sched_fork() 
to the following place:

> @@ -989,10 +990,13 @@ static struct task_struct *copy_process(
>  	if (retval)
>  		goto fork_out;
>  
> +	cpu = sched_fork_suggest_cpu(clone_flags);
> +	mpol_arg = mpol_prefer_cpu_start(cpu);
> +
>  	retval = -ENOMEM;
>  	p = dup_task_struct(current);
>  	if (!p)
> -		goto fork_out;
> +		goto fork_mpol;
>  
>  	rt_mutex_init_task(p);


_after_ the dup_task_struct(). Then change sched_fork() to return a CPU 
number - hence we dont have a separate sched_fork_suggest_cpu() 
initialization function, only one, obvious sched_fork() function. 
Agreed?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

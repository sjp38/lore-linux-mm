Date: Fri, 9 Jun 2006 14:33:33 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Light weight counter 1/1 Framework
Message-Id: <20060609143333.39b29109.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0606091216320.1174@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0606091216320.1174@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, npiggin@suse.de, ak@suse.de, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Christoph Lameter <clameter@sgi.com> wrote:
>
> -/*
> - * Accumulate the page_state information across all CPUs.
> - * The result is unavoidably approximate - it can change
> - * during and after execution of this function.
> - */

sob.  How about updating the nice comment rather than removing it?

>  
> -void get_full_page_state(struct page_state *ret)
> +void all_vm_events(unsigned long *ret)
>  {
> -	cpumask_t mask = CPU_MASK_ALL;
> -
> -	__get_page_state(ret, sizeof(*ret) / sizeof(unsigned long), &mask);
> +	sum_vm_events(ret, &cpu_online_map);
>  }
> +EXPORT_SYMBOL(all_vm_events);
>  
> -unsigned long read_page_state_offset(unsigned long offset)
> +unsigned long get_global_vm_events(enum vm_event_item e)
>  {
>  	unsigned long ret = 0;
>  	int cpu;
>  
> -	for_each_online_cpu(cpu) {
> -		unsigned long in;
> +	for_each_possible_cpu(cpu)
> +		ret += per_cpu(vm_event_states, cpu).event[e];
>  
> -		in = (unsigned long)&per_cpu(page_states, cpu) + offset;
> -		ret += *((unsigned long *)in);
> -	}
>  	return ret;
>  }

Here.   Some description of the difference between these two, and why one
would call one and not the other.

I'd be rather interested in reading that comment because afaict,
get_global_vm_events() has no callers.

And nor should it, please.  It has potential to be seriously inefficient. 
Much, much better to kill this function and to implement a CPU hotplug
notifier to spill the going-away CPU's stats into another CPU's
accumulators.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

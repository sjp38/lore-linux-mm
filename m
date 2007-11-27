Date: Tue, 27 Nov 2007 15:21:22 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/1] mm: Prevent dereferencing non-allocated per_cpu
 variables
Message-Id: <20071127152122.1d5fbce3.akpm@linux-foundation.org>
In-Reply-To: <20071127151241.038c146d.akpm@linux-foundation.org>
References: <20071127215052.090968000@sgi.com>
	<20071127215054.660250000@sgi.com>
	<20071127221628.GG24223@one.firstfloor.org>
	<20071127151241.038c146d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: andi@firstfloor.org, travis@sgi.com, ak@suse.de, clameter@sgi.com, pageexec@freemail.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 27 Nov 2007 15:12:41 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Tue, 27 Nov 2007 23:16:28 +0100
> Andi Kleen <andi@firstfloor.org> wrote:
> 
> > On Tue, Nov 27, 2007 at 01:50:53PM -0800, travis@sgi.com wrote:
> > > Change loops controlled by 'for (i = 0; i < NR_CPUS; i++)' to use
> > > 'for_each_possible_cpu(i)' when there's a _remote possibility_ of
> > > dereferencing a non-allocated per_cpu variable involved.
> > > 
> > > All files except mm/vmstat.c are x86 arch.
> > > 
> > > Based on 2.6.24-rc3-mm1 .
> > > 
> > > Thanks to pageexec@freemail.hu for pointing this out.
> > 
> > Looks good to me. 2.6.24 candidate.
> 
> hm.  Has anyone any evidence that we're actually touching
> not-possible-cpu's memory here?
> 
> Also, the sum_vm_events() change looks buggy - it assumes that
> cpu_possible_map has no gaps in it.  But that change is unneeded because
> sum_vm_events() is only ever passed cpu_online_map and I'm hoping that we
> don't usually online not-possible CPUs.
> 
> --- a/mm/vmstat.c~mm-prevent-dereferencing-non-allocated-per_cpu-variables-fix
> +++ a/mm/vmstat.c
> @@ -27,12 +27,12 @@ static void sum_vm_events(unsigned long 
>  	memset(ret, 0, NR_VM_EVENT_ITEMS * sizeof(unsigned long));
>  
>  	cpu = first_cpu(*cpumask);
> -	while (cpu < NR_CPUS && cpu_possible(cpu)) {
> +	while (cpu < NR_CPUS) {
>  		struct vm_event_state *this = &per_cpu(vm_event_states, cpu);
>  
>  		cpu = next_cpu(cpu, *cpumask);
>  
> -		if (cpu < NR_CPUS && cpu_possible(cpu))
> +		if (cpu < NR_CPUS)
>  			prefetch(&per_cpu(vm_event_states, cpu));

The prefetch however might still need some work - we can indeed do
prefetch() against a not-possible CPU's memory here.  And I do recall that
4-5 years ago we did have a CPU (one of mine, iirc) which would oops when
prefetching from a bad address.  I forget what the conclusion was on that
matter.

If we do want to fix the prefetch-from-outer-space then we should be using
cpu_isset(cpu, *cpumask) here rather than cpu_possible().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 4/5] x86: Add config variables for SMP_MAX
Date: Fri, 18 Jan 2008 21:36:15 +0100
References: <20080118183011.354965000@sgi.com> <200801182104.22486.ioe-lkml@rameria.de> <479108C3.1010800@sgi.com>
In-Reply-To: <479108C3.1010800@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200801182136.15213.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Travis <travis@sgi.com>
Cc: Ingo Oeser <ioe-lkml@rameria.de>, Andrew Morton <akpm@linux-foundation.org>, mingo@elte.hu, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

First I think you have to get rid of the THREAD_ORDER stuff -- your
goal of the whole patchkit after all is to allow distributions to
support NR_CPUS==4096 in the standard kernels and I doubt any
distribution will over chose a THREAD_ORDER > 1 in their 
standard kernels because it would be too unreliable on smaller
systems.

> Here are the top stack consumers with NR_CPUS = 4k.
> 
>                          16392 isolated_cpu_setup
>                          10328 build_sched_domains
>                           8248 numa_initmem_init

These should run single threaded early at boot so you can probably just make
the cpumask_t variables static __initdata

>                           4664 cpu_attach_domain
>                           4104 show_shared_cpu_map

These above are the real pigs. Fortunately they are all clearly
slowpath (except perhaps show_shared_cpu_map) so just using heap
allocations or when needed bootmem for them should be fine.

>                           3656 centrino_target
>                           3608 powernowk8_cpu_init
>                           3192 sched_domain_node_span

x86-64 always has 8k stacks and separate interrupt stack. As long
as the calls are not in some stack intensive layered context (like block
IO processing path etc.) <3k shouldn't be too big an issue.

BTW there is a trick to get more stack space on x86-64 temporarily:
run it in a softirq. They got 16k stacks by default. Just leave
enough left over for the hard irqs that might happen if you don't
have interrupts disabled.

>                           3144 acpi_cpufreq_target
>                           2584 __svc_create_thread
>                           2568 cpu_idle_wait
>                           2136 netxen_nic_flash_print
>                           2104 powernowk8_target
>                           2088 _cpu_down
>                           2072 cache_add_dev
>                           2056 get_cur_freq
>                              0 acpi_processor_ffh_cstate_probe
>                           2056 microcode_write
>                              0 acpi_processor_get_throttling
>                           2048 check_supported_cpu
> 
> And I've yet to figure out how to accumulate stack sizes using
> call threads.

One way if you don't care about indirect/asm calls is to use cflow and do
some post processing that adds up the data from checkstack.pl

The other way is to use mcount, but only for situations you can reproduce
of course. I did have a 2.4 mcount based stack instrumentation patch
some time ago that I could probably dig out if it was useful.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

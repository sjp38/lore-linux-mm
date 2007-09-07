Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp05.au.ibm.com (8.13.1/8.13.1) with ESMTP id l87BITqb018777
	for <linux-mm@kvack.org>; Fri, 7 Sep 2007 21:18:29 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.250.242])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l87BM0Ic116210
	for <linux-mm@kvack.org>; Fri, 7 Sep 2007 21:22:00 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l87BIQnR008255
	for <linux-mm@kvack.org>; Fri, 7 Sep 2007 21:18:26 +1000
Message-ID: <46E1337D.3090005@linux.vnet.ibm.com>
Date: Fri, 07 Sep 2007 16:48:21 +0530
From: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] ppc64: Convert cpu_sibling_map to a per_cpu data
 array
References: <20070907040943.467530005@sgi.com> <20070907040944.380253345@sgi.com>
In-Reply-To: <20070907040944.380253345@sgi.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: travis@sgi.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

travis@sgi.com wrote:
> Convert cpu_sibling_map to a per_cpu cpumask_t array for the ppc64
> architecture.
>
> Note: these changes have not been built nor tested.
>
> Note: I also don't know if these changes are particularly
> relevant for the ppc64 architecture.
>
> Signed-off-by: Mike Travis <travis@sgi.com>
> ---
>  arch/powerpc/kernel/setup-common.c        |    4 ++--
>  arch/powerpc/kernel/smp.c                 |    4 ++--
>  arch/powerpc/platforms/cell/cbe_cpufreq.c |    2 +-
>  include/asm-powerpc/smp.h                 |    3 ++-
>  include/asm-powerpc/topology.h            |    2 +-
>  5 files changed, 8 insertions(+), 7 deletions(-)
>
> --- a/arch/powerpc/kernel/setup-common.c
> +++ b/arch/powerpc/kernel/setup-common.c
> @@ -415,9 +415,9 @@
>  	 * Do the sibling map; assume only two threads per processor.
>  	 */
>  	for_each_possible_cpu(cpu) {
> -		cpu_set(cpu, cpu_sibling_map[cpu]);
> +		cpu_set(cpu, cpu_sibling_map(cpu));
>  		if (cpu_has_feature(CPU_FTR_SMT))
> -			cpu_set(cpu ^ 0x1, cpu_sibling_map[cpu]);
> +			cpu_set(cpu ^ 0x1, cpu_sibling_map(cpu));
>  	}
>
>  	vdso_data->processorCount = num_present_cpus();
> --- a/arch/powerpc/kernel/smp.c
> +++ b/arch/powerpc/kernel/smp.c
> @@ -61,11 +61,11 @@
>
>  cpumask_t cpu_possible_map = CPU_MASK_NONE;
>  cpumask_t cpu_online_map = CPU_MASK_NONE;
> -cpumask_t cpu_sibling_map[NR_CPUS] = { [0 ... NR_CPUS-1] = CPU_MASK_NONE };
> +DEFINE_PER_CPU(cpumask_t, cpu_sibling_map) = CPU_MASK_NONE;
>
>  EXPORT_SYMBOL(cpu_online_map);
>  EXPORT_SYMBOL(cpu_possible_map);
> -EXPORT_SYMBOL(cpu_sibling_map);
> +EXPORT_PER_CPU_SYMBOL(cpu_sibling_map);
>
>  /* SMP operations for this machine */
>  struct smp_ops_t *smp_ops;
> --- a/arch/powerpc/platforms/cell/cbe_cpufreq.c
> +++ b/arch/powerpc/platforms/cell/cbe_cpufreq.c
> @@ -117,7 +117,7 @@
>  	policy->cur = cbe_freqs[cur_pmode].frequency;
>
>  #ifdef CONFIG_SMP
> -	policy->cpus = cpu_sibling_map[policy->cpu];
> +	policy->cpus = cpu_sibling_map(policy->cpu);
>  #endif
>
>  	cpufreq_frequency_table_get_attr(cbe_freqs, policy->cpu);
> --- a/include/asm-powerpc/smp.h
> +++ b/include/asm-powerpc/smp.h
> @@ -58,7 +58,8 @@
>  					(smp_hw_index[(cpu)] = (phys))
>  #endif
>
> -extern cpumask_t cpu_sibling_map[NR_CPUS];
> +DECLARE_PER_CPU(cpumask_t, cpu_sibling_map);
> +#define cpu_sibling_map(cpu) per_cpu(cpu_sibling_map, cpu)
>
>  /* Since OpenPIC has only 4 IPIs, we use slightly different message numbers.
>   *
> --- a/include/asm-powerpc/topology.h
> +++ b/include/asm-powerpc/topology.h
> @@ -108,7 +108,7 @@
>  #ifdef CONFIG_PPC64
>  #include <asm/smp.h>
>
> -#define topology_thread_siblings(cpu)	(cpu_sibling_map[cpu])
> +#define topology_thread_siblings(cpu)	(cpu_sibling_map(cpu))
>  #endif
>  #endif
>
>
>   
Hi Mike,

After applying the patch, the build fails with following error

CHK include/linux/version.h
CHK include/linux/utsrelease.h
CC arch/powerpc/kernel/asm-offsets.s
In file included from include/linux/smp.h:19,
from include/linux/topology.h:33,
from include/linux/mmzone.h:660,
from include/linux/gfp.h:4,
from include/linux/slab.h:14,
from include/linux/percpu.h:5,
from include/asm/time.h:18,
from include/asm/cputime.h:26,
from include/linux/sched.h:65,
from arch/powerpc/kernel/asm-offsets.c:17:
include/asm/smp.h:61: error: expected declaration specifiers or ?...? 
before ?cpu_sibling_map?
include/asm/smp.h:61: warning: data definition has no type or storage class
include/asm/smp.h:61: warning: type defaults to ?int? in declaration of 
?DECLARE_PER_CPU?
make[1]: *** [arch/powerpc/kernel/asm-offsets.s] Error 1
make: *** [prepare0] Error 2

Thanks & Regards,
Kamalesh Babulal.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

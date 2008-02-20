Message-ID: <47BC4D26.2080102@sgi.com>
Date: Wed, 20 Feb 2008 07:54:14 -0800
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] x86_64: Fold pda into per cpu area v3
References: <20080219203335.866324000@polaris-admin.engr.sgi.com>	<20080219203336.046039000@polaris-admin.engr.sgi.com>	<20080220120747.GA13695@elte.hu> <20080220141659.45ec31fa.dada1@cosmosbay.com>
In-Reply-To: <20080220141659.45ec31fa.dada1@cosmosbay.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andy Whitcroft <apw@shadowen.org>, Randy Dunlap <rdunlap@xenotime.net>, Joel Schopp <jschopp@austin.ibm.com>
List-ID: <linux-mm.kvack.org>

Eric Dumazet wrote:
> On Wed, 20 Feb 2008 13:07:47 +0100
> Ingo Molnar <mingo@elte.hu> wrote:
> 
>> * Mike Travis <travis@sgi.com> wrote:
>>
>>>   * Declare the pda as a per cpu variable. This will move the pda area
>>>     to an address accessible by the x86_64 per cpu macros.  
>>>     Subtraction of __per_cpu_start will make the offset based from the 
>>>     beginning of the per cpu area.  Since %gs is pointing to the pda, 
>>>     it will then also point to the per cpu variables and can be 
>>>     accessed thusly:
>>>
>>> 	%gs:[&per_cpu_xxxx - __per_cpu_start]
>> randconfig QA on x86.git found a crash on x86.git#testing with 
>> nmi_watchdog=2 (config attached) - and i bisected it down to this patch.
>>
>> config and crashlog attached. You can pick up x86.git#testing via:
>>
>>   http://people.redhat.com/mingo/x86.git/README
>>
>> (since i had to hand-merge the patch when integrating it, i've attached 
>> the merged version below.)
>>
>> 	Ingo
>>
>> -------------->
>> Subject: x86_64: Fold pda into per cpu area v3
>> From: Mike Travis <travis@sgi.com>
>> Date: Tue, 19 Feb 2008 12:33:36 -0800
>>
>>   * Declare the pda as a per cpu variable. This will move the pda area
>>     to an address accessible by the x86_64 per cpu macros.  Subtraction
>>     of __per_cpu_start will make the offset based from the beginning
>>     of the per cpu area.  Since %gs is pointing to the pda, it will
>>     then also point to the per cpu variables and can be accessed thusly:
>>
>> 	%gs:[&per_cpu_xxxx - __per_cpu_start]
>>
>>   * The boot_pdas are only needed in head64.c so move the declaration
>>     over there.  And since the boot_cpu_pda is only used during
>>     bootup and then copied to the per_cpu areas during init, it is
>>     then removable.  In addition, the initial cpu_pda pointer table
>>     is reallocated to be the correct size for the number of cpus.
>>
>>   * Remove the code that allocates special pda data structures.
>>     Since the percpu area is currently maintained for all possible
>>     cpus then the pda regions will stay intact in case cpus are
>>     hotplugged off and then back on.
>>
>>   * Relocate the x86_64 percpu variables to begin at zero. Then
>>     we can directly use the x86_32 percpu operations. x86_32
>>     offsets %fs by __per_cpu_start. x86_64 has %gs pointing
>>     directly to the pda and the per cpu area thereby allowing
>>     access to the pda with the x86_64 pda operations and access
>>     to the per cpu variables using x86_32 percpu operations.
>>
>>   * This also supports further integration of x86_32/64.
>>
>> Cc:	Andy Whitcroft <apw@shadowen.org>
>> Cc:	Randy Dunlap <rdunlap@xenotime.net>
>> Cc:	Joel Schopp <jschopp@austin.ibm.com>
>> Signed-off-by: Christoph Lameter <clameter@sgi.com>
>> Signed-off-by: Mike Travis <travis@sgi.com>
>> Signed-off-by: Ingo Molnar <mingo@elte.hu>
>> ---
>>  arch/x86/Kconfig                 |    3 +
>>  arch/x86/kernel/head64.c         |   41 ++++++++++++++++++++++++
>>  arch/x86/kernel/setup64.c        |   66 ++++++++++++++++++++++++---------------
>>  arch/x86/kernel/smpboot_64.c     |   16 ---------
>>  arch/x86/kernel/vmlinux_64.lds.S |    1 
>>  include/asm-x86/pda.h            |   13 +++++--
>>  include/asm-x86/percpu.h         |   33 +++++++++++--------
>>  7 files changed, 115 insertions(+), 58 deletions(-)
>>
>> Index: linux-x86.q/arch/x86/Kconfig
>> ===================================================================
>> --- linux-x86.q.orig/arch/x86/Kconfig
>> +++ linux-x86.q/arch/x86/Kconfig
>> @@ -122,6 +122,9 @@ config ARCH_HAS_CPU_RELAX
>>  config HAVE_SETUP_PER_CPU_AREA
>>  	def_bool X86_64
>>  
>> +config HAVE_ZERO_BASED_PER_CPU
>> +	def_bool X86_64
>> +
>>  config ARCH_HIBERNATION_POSSIBLE
>>  	def_bool y
>>  	depends on !SMP || !X86_VOYAGER
>> Index: linux-x86.q/arch/x86/kernel/head64.c
>> ===================================================================
>> --- linux-x86.q.orig/arch/x86/kernel/head64.c
>> +++ linux-x86.q/arch/x86/kernel/head64.c
>> @@ -11,6 +11,7 @@
>>  #include <linux/string.h>
>>  #include <linux/percpu.h>
>>  #include <linux/start_kernel.h>
>> +#include <linux/bootmem.h>
>>  
>>  #include <asm/processor.h>
>>  #include <asm/proto.h>
>> @@ -23,6 +24,12 @@
>>  #include <asm/kdebug.h>
>>  #include <asm/e820.h>
>>  
>> +#ifdef CONFIG_SMP
>> +/* Only used before the per cpu areas are setup. */
>> +static struct x8664_pda boot_cpu_pda[NR_CPUS] __initdata;
>> +static struct x8664_pda *_cpu_pda_init[NR_CPUS] __initdata;
>> +#endif
>> +
>>  static void __init zap_identity_mappings(void)
>>  {
>>  	pgd_t *pgd = pgd_offset_k(0UL);
>> @@ -102,8 +109,14 @@ void __init x86_64_start_kernel(char * r
>>  
>>  	early_printk("Kernel alive\n");
>>  
>> +#ifdef CONFIG_SMP
>> +	_cpu_pda = (void *)_cpu_pda_init;
>>   	for (i = 0; i < NR_CPUS; i++)
>>   		cpu_pda(i) = &boot_cpu_pda[i];
>> +#endif
>> +
>> +	/* setup percpu segment offset for cpu 0 */
>> +	cpu_pda(0)->data_offset = (unsigned long)__per_cpu_load;
>>  
>>  	pda_init(0);
>>  	copy_bootdata(__va(real_mode_data));
>> @@ -128,3 +141,31 @@ void __init x86_64_start_kernel(char * r
>>  
>>  	start_kernel();
>>  }
>> +
>> +#ifdef	CONFIG_SMP
>> +/*
>> + * Remove initial boot_cpu_pda array and cpu_pda pointer table.
>> + *
>> + * This depends on setup_per_cpu_areas relocating the pda to the beginning
>> + * of the per_cpu area so that (_cpu_pda[i] != &boot_cpu_pda[i]).  If it
>> + * is equal then the new pda has not been setup for this cpu, and the pda
>> + * table will have a NULL address for this cpu.
>> + */
>> +void __init x86_64_cleanup_pda(void)
>> +{
>> +	int i;
>> +
>> +	_cpu_pda = alloc_bootmem_low(nr_cpu_ids * sizeof(void *));
> 
> Here we allocate an array of [nr_cpu_ids] slots
> 
>> +
>> +	if (!_cpu_pda)
>> +		panic("Cannot allocate cpu pda table\n");
>> +
>> +	/* cpu_pda() now points to allocated cpu_pda_table */
>> +
>> +	for (i = 0; i < NR_CPUS; i++)
> 
> But in this loop we want to read/write on [NR_CPUS] slots of this array
> 
>> +		if (_cpu_pda_init[i] == &boot_cpu_pda[i])
>> +			cpu_pda(i) = NULL;
>> +		else
>> +			cpu_pda(i) = _cpu_pda_init[i];
>> +}
>> +#endif
> 
> You might want to apply this patch.
> 
> I also wonder if _cpu_pda should be set only at the very end of 
> x86_64_cleanup_pda(), after array initialization, or maybe other
> cpus are not yet running ? (Sorry I cannot boot test this patch at this momeent)
> 
> [PATCH] x86_64: x86_64_cleanup_pda() should use nr_cpu_ids instead of NR_CPUS
> 
> We allocate an array of nr_cpu_ids pointers, so we should respect its bonds.

> 
> Delay change of _cpu_pda after array initialization.
> 
> Also take into account that alloc_bootmem_low() :
> - calls panic() if not enough memory
> - already clears allocated memory
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> 
> diff --git a/arch/x86/kernel/head64.c b/arch/x86/kernel/head64.c
> index 3942e6a..21532eb 100644
> --- a/arch/x86/kernel/head64.c
> +++ b/arch/x86/kernel/head64.c
> @@ -154,18 +154,16 @@ void __init x86_64_start_kernel(char * real_mode_data)
>  void __init x86_64_cleanup_pda(void)
>  {
>  	int i;
> +	struct x8664_pda **new_cpu_pda;
>  
> -	_cpu_pda = alloc_bootmem_low(nr_cpu_ids * sizeof(void *));
> +	new_cpu_pda = alloc_bootmem_low(nr_cpu_ids * sizeof(void *));
>  
> -	if (!_cpu_pda)
> -		panic("Cannot allocate cpu pda table\n");
>  
> +	for (i = 0; i < nr_cpu_ids; i++)
> +		if (_cpu_pda_init[i] != &boot_cpu_pda[i])
> +			new_cpu_pda[i] = _cpu_pda_init[i];
> +	mb();
> +	_cpu_pda = new_cpu_pda;
>  	/* cpu_pda() now points to allocated cpu_pda_table */
> -
> -	for (i = 0; i < NR_CPUS; i++)
> -		if (_cpu_pda_init[i] == &boot_cpu_pda[i])
> -			cpu_pda(i) = NULL;
> -		else
> -			cpu_pda(i) = _cpu_pda_init[i];
>  }
>  #endif


Yes, thank you!  I had changed this in a later version ... I must have grabbed
an earlier version to do the patch split.  (But I did not have the memory barrier.)

At this point only the boot cpu is running and we're in the time slot between
allocating per cpu areas and sched_init().

I'm just building an x86.git#testing branch.  I will see if I can't replicate
the problem.

Thanks again,
Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

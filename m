Message-ID: <479286CA.3080705@sgi.com>
Date: Sat, 19 Jan 2008 15:24:58 -0800
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/5] x86: Add config variables for SMP_MAX
References: <20080118183011.354965000@sgi.com> <20080118183011.917801000@sgi.com> <20080119145243.GA27974@elte.hu> <20080119151522.GA7774@elte.hu> <20080119152357.GA11706@elte.hu>
In-Reply-To: <20080119152357.GA11706@elte.hu>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:
> * Ingo Molnar <mingo@elte.hu> wrote:
> 
>> and then it crashes with:
>>
>>  [    0.000000] Bootmem setup node 0 0000000000000000-000000003fff0000
>>  [    0.000000] KERN_NOTICE cpu_to_node(0): usage too early!
>>  PANIC: early exception 06 rip 10:ffffffff81f77f30 error 0 cr2 f06f53
>>  [    0.000000] Pid: 0, comm: swapper Not tainted 2.6.24-rc8 #422
>>  [    0.000000]
>>  [    0.000000] Call Trace:
>>  [    0.000000]  [<ffffffff81f76b4a>] ? setup_node_bootmem+0x1a0/0x1b8
>>  [    0.000000]  [<ffffffff81f77f30>] ? acpi_scan_nodes+0x204/0x255
>>  [    0.000000]  [<ffffffff81f77f30>] ? acpi_scan_nodes+0x204/0x255
>>  [    0.000000]  [<ffffffff81f77103>] ? numa_initmem_init+0x343/0x471
>>
>> moral: PLEASE do not use BUG() on in early init code, unless 
>> absolutely necessary.
> 
> the right fix is below.
> 
> 	Ingo
> 
> ---
>  include/asm-x86/topology.h |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> Index: linux/include/asm-x86/topology.h
> ===================================================================
> --- linux.orig/include/asm-x86/topology.h
> +++ linux/include/asm-x86/topology.h
> @@ -70,10 +70,10 @@ static inline int cpu_to_node(int cpu)
>  	if(x86_cpu_to_node_map_early_ptr) {
>  		printk("KERN_NOTICE cpu_to_node(%d): usage too early!\n",
>  			(int)cpu);
> -		BUG();
> +		dump_stack();
>  	}
>  #endif
> -	if(per_cpu_offset(cpu))
> +	if (per_cpu_offset(cpu))
>  		return per_cpu(x86_cpu_to_node_map, cpu);
>  	else
>  		return NUMA_NO_NODE;
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

Except the function needs to return a valid node id if it's to continue:

--- linux.orig/include/asm-x86/topology.h       2008-01-19 15:23:04.996551867 -0800
+++ linux/include/asm-x86/topology.h    2008-01-19 15:23:05.208564537 -0800
@@ -67,10 +67,11 @@ static inline int early_cpu_to_node(int
 static inline int cpu_to_node(int cpu)
 {
 #ifdef CONFIG_DEBUG_PER_CPU_MAPS
-       if(x86_cpu_to_node_map_early_ptr) {
+       if (x86_cpu_to_node_map_early_ptr) {
                printk("KERN_NOTICE cpu_to_node(%d): usage too early!\n",
                        (int)cpu);
                dump_stack();
+               return ((numanode_t *)x86_cpu_to_node_map_early_ptr)[cpu];
        }
 #endif
        if (per_cpu_offset(cpu))

??

Thannks,
Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

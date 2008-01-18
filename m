Message-ID: <479108C3.1010800@sgi.com>
Date: Fri, 18 Jan 2008 12:14:59 -0800
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/5] x86: Add config variables for SMP_MAX
References: <20080118183011.354965000@sgi.com> <20080118183011.917801000@sgi.com> <200801182104.22486.ioe-lkml@rameria.de>
In-Reply-To: <200801182104.22486.ioe-lkml@rameria.de>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Oeser <ioe-lkml@rameria.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Ingo Oeser wrote:
> Hi Mike,
> 
> On Friday 18 January 2008, travis@sgi.com wrote:
>> +config THREAD_ORDER
>> +	int "Kernel stack size (in page order)"
>> +	range 1 3
>> +	depends on X86_64_SMP
>> +	default "3" if X86_SMP_MAX
>> +	default "1"
>> +	help
>> +	  Increases kernel stack size.
>> +
> 
> Could you please elaborate, why this is needed and put more info about
> this requirement into this patch description?
> 
> People worked hard to push data allocation from stack to heap to make 
> THREAD_ORDER of 0 and 1 possible. So why increase it again and why does this
> help scalability?
> 
> Many thanks and Best Regards
> 
> Ingo Oeser, puzzled a bit :-)


The primary problem arises because of cpumask_t local variables.  Until I
can deal with these, increasing NR_CPUS to a really large value increases
stack size dramatically.

Here are the top stack consumers with NR_CPUS = 4k.

                         16392 isolated_cpu_setup
                         10328 build_sched_domains
                          8248 numa_initmem_init
                          4664 cpu_attach_domain
                          4104 show_shared_cpu_map
                          3656 centrino_target
                          3608 powernowk8_cpu_init
                          3192 sched_domain_node_span
                          3144 acpi_cpufreq_target
                          2584 __svc_create_thread
                          2568 cpu_idle_wait
                          2136 netxen_nic_flash_print
                          2104 powernowk8_target
                          2088 _cpu_down
                          2072 cache_add_dev
                          2056 get_cur_freq
                             0 acpi_processor_ffh_cstate_probe
                          2056 microcode_write
                             0 acpi_processor_get_throttling
                          2048 check_supported_cpu

And I've yet to figure out how to accumulate stack sizes using
call threads.

Thanks,
Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

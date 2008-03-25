Message-Id: <20080325021954.979158000@polaris-admin.engr.sgi.com>
Date: Mon, 24 Mar 2008 19:19:54 -0700
From: Mike Travis <travis@sgi.com>
Subject: [PATCH 00/10] NR_CPUS: third reduction of NR_CPUS memory usage
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Here's the third round of removing static allocations of arrays using
NR_CPUS to size the length.  The change is to use PER_CPU variables in
place of the static tables, or allocate the array based on nr_cpu_ids.

In addition, there's a cleanup of x86 non-smp code, the movement of
setting nr_cpu_ids to setup_per_cpu_areas() so it's available as soon
as possible, and a new function cpumask_scnprintf_len() to return the
number of characters needed to display "len" cpumask bits.

Affected files:

	arch/ia64/kernel/acpi.c
	arch/ia64/kernel/setup.c
	arch/powerpc/kernel/setup_64.c
	arch/sparc64/mm/init.c
	arch/x86/kernel/cpu/intel_cacheinfo.c
	arch/x86/kernel/genapic_64.c
	arch/x86/kernel/mpparse_64.c
	arch/x86/kernel/setup64.c
	arch/x86/kernel/smpboot_32.c
	arch/x86/mm/numa_64.c
	arch/x86/oprofile/nmi_int.c
	drivers/acpi/processor_core.c
	drivers/acpi/processor_idle.c
	drivers/acpi/processor_perflib.c
	drivers/acpi/processor_throttling.c
	drivers/base/cpu.c
	drivers/cpufreq/cpufreq.c
	drivers/cpufreq/cpufreq_stats.c
	drivers/cpufreq/freq_table.c
	include/acpi/processor.h
	include/asm-x86/smp_32.h
	include/asm-x86/smp_64.h
	include/asm-x86/topology.h
	include/linux/bitmap.h
	include/linux/cpumask.h
	init/main.c
	kernel/sched.c
	lib/bitmap.c
	net/core/dev.c

Based on linux-2.6.25-rc5-mm1

Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: Andi Kleen <ak@suse.de>
Cc: Anton Blanchard <anton@samba.org>
Cc: Christoph Lameter <clameter@sgi.com>
Cc: Dave Jones <davej@codemonkey.org.uk>
Cc: David S. Miller <davem@davemloft.net>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: James Morris <jmorris@namei.org>
Cc: Len Brown <len.brown@intel.com>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Paul Jackson <pj@sgi.com>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Philippe Elie <phil.el@wanadoo.fr>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Tony Luck <tony.luck@intel.com>
Cc: William L. Irwin <wli@holomorphy.com>

Signed-off-by: Mike Travis <travis@sgi.com>
---

I moved the x86_64 cleanup and move-set-nr_cpu_ids from the zero-based
percpu variables patchset to this one, as I was encountering a panic
from system_call_after_swapgs() after an unknown device interrupt during
module loading.  That problem will be dealt with in another patch.


Here's the various effects of the patches on memory usages using the
akpm2 config file with NR_CPUS=4096 and MAXNODES=512:

====== Data (-l 500)
    1 - initial
    2 - cleanup
    4 - nr_cpus-in-cpufreq-cpu_alloc
    5 - nr_cpus-in-acpi-driver-cpu_alloc
    7 - nr_cpus-in-intel_cacheinfo
    8 - nr_cpus-in-cpu_c
   11 - nr_cpus-in-kernel_sched

    .1.   .2.     .4.     .5.   .7.     .8.    .11.  
  32768     .  -32768       .     .       .       .   show_table(.bss)
  32768     .       .       .     .       .  -32768   sched_group_nodes_bycpu(.bss)
  32768     .       .  -32768     .       .       .   processors(.bss)
  32768     .       .  -32768     .       .       .   processor_device_array(.bss)
  32768     .       .       .     .       .  -32768   init_sched_entity_p(.bss)
  32768     .       .       .     .       .  -32768   init_cfs_rq_p(.bss)
  32768     .       .       .-32768       .       .   index_kobject(.bss)
  32768     .       .       .-32768       .       .   cpuid4_info(.bss)
  32768     .  -32768       .     .       .       .   cpufreq_cpu_governor(.bss)
  32768     .  -32768       .     .       .       .   cpufreq_cpu_data(.bss)
  32768     .       .       .     .  -32768       .   cpu_sys_devices(.bss)
  32768     .       .       .-32768       .       .   cache_kobject(.bss)

====== Text/Data ()
    1 - initial
    4 - nr_cpus-in-cpufreq-cpu_alloc
    5 - nr_cpus-in-acpi-driver-cpu_alloc
    7 - nr_cpus-in-intel_cacheinfo
    8 - nr_cpus-in-cpu_c
   11 - nr_cpus-in-kernel_sched

       .1.     .4.     .5.     .7.     .8.    .11.    ..final..
   3373056       .   +2048       .       .       . 3375104    <1%  TextSize
   1656832       .   +2048       .       .       . 1658880    <1%  DataSize
   1855488  -98304  -65536  -98304  -32768  -98304 1462272   -21%  BssSize
  10395648       .   +4096       .       .       . 10399744   <1%  OtherSize
  17281024  -98304  -57344  -98304  -32768  -98304 16896000   -2%  Totals

====== Stack (-l 500)
... files 11 vars 928 all 0 lim 500 unch 0

    1 - initial
    7 - nr_cpus-in-intel_cacheinfo
   11 - nr_cpus-in-kernel_sched

   .1.    .7.   .11.    ..final..
  4648      .  -4080  568   -87%  cpu_attach_domain
  4104  -4104      .    .  -100%  show_shared_cpu_map
  8752  -4104  -4080  568   -93%  Totals

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

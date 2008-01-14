Message-ID: <478BA170.10806@sgi.com>
Date: Mon, 14 Jan 2008 09:52:48 -0800
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00/10] x86: Reduce memory and intra-node effects with
 large count NR_CPUs
References: <20080113183453.973425000@sgi.com> <20080114081418.GB18296@elte.hu> <20080114090010.GA5404@elte.hu>
In-Reply-To: <20080114090010.GA5404@elte.hu>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:
> * Ingo Molnar <mingo@elte.hu> wrote:
> 
>>> 32cpus			  1kcpus-before		    1kcpus-after
>>>    7172678 Total	   +23314404 Total	       -147590 Total
>> 1kcpus-after means it's +23314404-147590, i.e. +23166814? (i.e. a 0.6% 
>> reduction of the bloat?)
> 
> or if it's relative to 32cpus then that's an excellent result :)
> 
> 	Ingo

Nope, it's a cumulative thing.


> allsizes -w 72 32cpus 1kcpus-after
32cpus                              1kcpus-after
       228 .altinstr_replacemen             +0 .altinstr_replacemen
      1219 .altinstructions                 +0 .altinstructions
    717512 .bss                       +1395328 .bss
     61374 .comment                         +0 .comment
        16 .con_initcall.init               +0 .con_initcall.init
    425256 .data                        +19200 .data
    178688 .data.cacheline_alig      +12898304 .data.cacheline_alig
      8192 .data.init_task                  +0 .data.init_task
      4096 .data.page_aligned               +0 .data.page_aligned
     27008 .data.percpu                +128896 .data.percpu
     43904 .data.read_mostly          +8703776 .data.read_mostly
         4 .data_nosave                     +0 .data_nosave
      5141 .exit.text                       +8 .exit.text
    138480 .init.data                    +4608 .init.data
       133 .init.ramfs                      +1 .init.ramfs
      3192 .init.setup                      +0 .init.setup
    159754 .init.text                     +904 .init.text
      2288 .initcall.init                   +0 .initcall.init
         8 .jiffies                         +0 .jiffies
      4512 .pci_fixup                       +0 .pci_fixup
   1314438 .rodata                        +760 .rodata
     36552 .smp_locks                     +256 .smp_locks
   3971848 .text                        +14773 .text
      3368 .vdso                            +0 .vdso
         4 .vgetcpu_mode                    +0 .vgetcpu_mode
       218 .vsyscall_0                      +0 .vsyscall_0
        52 .vsyscall_1                      +0 .vsyscall_1
        91 .vsyscall_2                      +0 .vsyscall_2
         8 .vsyscall_3                      +0 .vsyscall_3
        54 .vsyscall_fn                     +0 .vsyscall_fn
        80 .vsyscall_gtod_data              +0 .vsyscall_gtod_data
     39480 __bug_table                      +0 __bug_table
     16320 __ex_table                       +0 __ex_table
      9160 __param                          +0 __param
   7172678 Total                     +23166814 Total

My goal is to move 90+% of the wasted, unused memory to either
the percpu area or the initdata section.  The 4 fronts are:
NR_CPUS arrays, cpumask_t usages, more efficient cpu_alloc/percpu
area, and (relatively small) redesign of the irq system.  (The
node and apicid arrays are related to the NR_CPUS arrays.)

The irq structs are particularly bad because they use NR_CPUS**2
arrays and the irq vars use 22588416 bytes (74%) of the total
30339492 bytes of memory:

   7172678 Total                      30339492 Total

> datasizes -w 72 32cpus 1kcpus-before
32cpus                              1kcpus-before
      262144    BSS __log_buf           12681216 CALNDA irq_desc
      163840 CALNDA irq_desc             8718336 RMDATA irq_cfg
      131072    BSS entries               528384    BSS irq_lists
       76800 INITDA early_node_map        396288    BSS irq_2_pin
       30720 RMDATA irq_cfg               264192    BSS irq_timer_state
       29440    BSS ide_hwifs             262144    BSS __log_buf
       24576    BSS boot_exception_       132168 PERCPU per_cpu__kstat
       20480    BSS irq_lists             131072    BSS entries
       18840   DATA ioctl_start           131072    BSS boot_pageset
       16384    BSS boot_cpu_stack        131072 CALNDA boot_cpu_pda
       15360    BSS irq_2_pin              98304    BSS cpu_devices
       14677   DATA bnx2_CP_b06FwTe        76800 INITDA early_node_map

I'm still working on a tool to analyze runtime usage of kernel
memory.

And I'm very open to any and all suggestions... ;-)

Thanks,
Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

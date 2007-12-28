Message-ID: <47757311.5050503@sgi.com>
Date: Fri, 28 Dec 2007 14:05:05 -0800
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 05/10] x86_64: Use generic percpu
References: <20071228001046.854702000@sgi.com> <20071228001047.556634000@sgi.com> <200712281354.52453.ak@suse.de>
In-Reply-To: <200712281354.52453.ak@suse.de>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>, tglx@linutronix.de, mingo@redhat.com
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
> On Friday 28 December 2007 01:10:51 travis@sgi.com wrote:
>> x86_64 provides an optimized way to determine the local per cpu area
>> offset through the pda and determines the base by accessing a remote
>> pda.
>
> And? The rationale for this patch seems to be incomplete.
>
> As far as I can figure out you're replacing an optimized percpu
> implementation which a dumber generic one. Which needs
> at least some description why.

The specific intent for the next wave of changes coming are to reduce
the impact of having a large NR_CPUS count on smaller systems and to
minimize memory traffic between nodes.  This patchset addresses the
per_cpu data areas in preparation to cpu_alloc changes to compact the
PERCPU area, remove the various per_cpu data offset and pointer arrays,
and speed up calculating the per_cpu data offset.

Since those changes have a bigger impact it was felt that we should
prepare the groundwork before hand.  It also has the benefit of
merging one more of the i386 and x86_64 headers.

> If the generic one is now as good or better than the
> specific one that might be ok, but that should be somewhere
> in the description.

I could gather some performance data, though the effect will be
larger as later changes are made.

> Also for such changes .text size comparisons before/after
> are a good idea.

x86_64-defconfig:

pre-percpu                          post-percpu
         225 .altinstr_replacemen             +0 .altinstr_replacemen
        1195 .altinstructions                 +0 .altinstructions
      716104 .bss                             +0 .bss
       58300 .comment                         +0 .comment
          16 .con_initcall.init               +0 .con_initcall.init
      415816 .data                            +0 .data
      178688 .data.cacheline_alig             +0 .data.cacheline_alig
        8192 .data.init_task                  +0 .data.init_task
        4096 .data.page_aligned               +0 .data.page_aligned
       27008 .data.percpu                     +0 .data.percpu
       43904 .data.read_mostly                +0 .data.read_mostly
           4 .data_nosave                     +0 .data_nosave
        5097 .exit.text                       +0 .exit.text
      138384 .init.data                       +0 .init.data
         133 .init.ramfs                      +0 .init.ramfs
        3192 .init.setup                      +0 .init.setup
      159373 .init.text                       +3 .init.text
        2296 .initcall.init                   +0 .initcall.init
           8 .jiffies                         +0 .jiffies
        4512 .pci_fixup                       +0 .pci_fixup
     1411137 .rodata                          +8 .rodata
       35400 .smp_locks                       +0 .smp_locks
     3629056 .text                           +48 .text
        3368 .vdso                            +0 .vdso
           4 .vgetcpu_mode                    +0 .vgetcpu_mode
         218 .vsyscall_0                      +0 .vsyscall_0
          52 .vsyscall_1                      +0 .vsyscall_1
          91 .vsyscall_2                      +0 .vsyscall_2
           8 .vsyscall_3                      +0 .vsyscall_3
          54 .vsyscall_fn                     +0 .vsyscall_fn
          80 .vsyscall_gtod_data              +0 .vsyscall_gtod_data
       39144 __bug_table                      +0 __bug_table
       16320 __ex_table                       +0 __ex_table
       44592 __ksymtab                        +0 __ksymtab
       15200 __ksymtab_gpl                    +0 __ksymtab_gpl
          48 __ksymtab_gpl_future             +0 __ksymtab_gpl_future
       87756 __ksymtab_strings                +0 __ksymtab_strings
          32 __ksymtab_unused_gpl             +0 __ksymtab_unused_gpl
        8280 __param                          +0 __param
     7057383 Total                           +59 Total

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Received: from pneumatic-tube.sgi.com (pneumatic-tube.sgi.com [204.94.214.22])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA08025
	for <linux-mm@kvack.org>; Mon, 10 May 1999 13:34:12 -0400
From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199905101734.KAA43772@google.engr.sgi.com>
Subject: [RFT] [PATCH] kanoj-mm1-2.2.5 ia32 big memory patch
Date: Mon, 10 May 1999 10:33:59 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>
List-ID: <linux-mm.kvack.org>

Linux is currently limited on ia32 platforms by a 4Gb virtual
address space size, that it carves up between user address space
and kernel address space, leading to the limitation that it can
only support maximum 2Gb physical memory on an ia32 system.
This patch allows Linux to use approximately 3.8Gb of physical
memory on ia32 platforms, while preserving 3Gb user space. This
patch has not been extensively tested, and I am still looking
into some performance degradations of specific benchmarks. If
you are interested in downloading this patch, please click here
(approximately 40 Kb):

        http://www.linux.sgi.com/intel/bigmem/kanoj-mm1-2.2.5

Testers, I would like to hear from you regarding:
1. any dosemu regressions.
2. any wine regressions.
3. any CLONE_VM regressions.
4. any performance regressions.
5. any other problems.

To activate the patch code, turn on "Big memory support" in
"Processor type and features", then change PAGE_OFFSET in
include/asm-i386/page.h to 0x10000000, as well as in
arch/i386/vmlinux.lds.

A detailed discussion of the patch follows.

Kanoj
kanoj@engr.sgi.com

Implementation:
---------------

Almost all of the new code is under #ifdef CONFIG_BIGMEM.

This patch implements a single kernel address space and a per
process address space, by having one kernel page directory which
is used inside the kernel, while each process get its own page
directory in user mode that does not map any of kernel code or
data (except as mentioned below). Conversely, the kernel page
directory does not map any of user code or data. When the kernel
tries to access user space (uaccess functions), it uses a light
weight version of the algorithm used by a ptrace debugger on a
debugee (include/asm-i386/uaccess.h, arch/i386/lib/usercopy.c).

For this scheme to work, as soon as a user process drops into
the kernel due to intr/exception/fault, it switches to using
the kernel page directory (arch/i386/kernel/entry.S, arch/i386/
kernel/irq.h). Due to the way the processor works, the initial
part of the intr/exception/fault handling code is mapped into
the user's page directory, as is the GDT, IDT, LDT and TSS.
These table addresses are not the ones that the kernel uses, rather
predefined addresses that are mapped in each process to point to
these tables (arch/i386/mm/init.c, include/asm-i386/fixmap.h,
arch/i386/vmlinux.lds). Similarly, at intr/exception/fault iret
time, the code detects if it is going back into user space and
switches to using the user page directory (arch/i386/kernel/entry.S).

The initial exception code and iret code needs to use an alias
for the kernel stack and task structure. For this, the following
fields are used (include/asm-i386/pgtable.h, arch/i386/kernel/
process.c, arch/i386/kernel/entry.S):

tsk->tss.ecx = kernel mapped address of the task structure
tsk->tss.eax = user mapped address of the task structure
tsk->tss.ebx = user mapped address of the 2nd kernel stack frame

In a CLONE_VM environment, each thread's task/kstack is mapped
into the process address space (include/asm-i386/pgtable.h).

Discussion:
-----------

This patch is far from the optimal solution, but it does not require
any drivers to be changed, and allows a big user address space, as
well as big physical memory. The performance costs of this
implementation are:

1. Implicit tlb flushing every time a process drops inside the kernel
and goes back into user space.
2. Since the same virtual address might be a valid user address and a
valid kernel address, global page bit on i686 can not be used.
3. All uaccess interfaces have been changed into procedure calls, and
cross-address space accesses have to be done.
4. Incidental costs related to maintaining the high mapped memory values
in the tss per thread, as well as some extra cycles added to some
macros that can not assume that PAGE_OFFSET >= 0x80000000.

Fortunately, #1, 2 and 4 are not very big components, although #2
can be a big degradation source depending on the app.

Testing/Results:
----------------

First, some output while running AIM7:
[root@solomon /root]# cat /proc/meminfo
        total:    used:    free:  shared: buffers:  cached:
Mem:  3918684160 1059385344 2859298816 988303360 497721344 75644928
Swap:        0        0        0
MemTotal:   3826840 kB
MemFree:    2792284 kB
MemShared:   965140 kB
Buffers:     486056 kB
Cached:       73872 kB
SwapTotal:        0 kB
SwapFree:         0 kB
[root@solomon /root]# uptime
 11:23am  up  9:09,  2 users,  load average: 663.40, 766.81, 966.42

Testing has *not* been extensive. Part of the reason of advertising
the patch is to get help in testing. Specially with apps that do
modify_ldt, vm86 and CLONE_VM calls.

AIM7 benchmark is the only app that has been run extensively. A
couple of tests (signal_test, dir_rtns_1) show big degradations,
solely because they do a lot of short uaccess calls. (Note that
an uaccess call tht moves, say 256 bytes of data, is not too bad,
since the cross-address space overhead is amortized. On the other
hand, if the transfer is done 16 bytes at a time, the overhead
becomes quite noticeable). Even the exec_test shows about a 5%
degradation. Excluding signal_test/dir_rtns_1, all the other tests
were put in a random job mix, the following results show 1 - 2%
degradation on a 4 400Mhz, 1200M, 13 disk system (2.2.1 against
2.2.1 + bigmem patch):

2.2.1:
Tasks   Jobs/Min        JTI     Real    CPU     Jobs/sec/task
1000    2010.8          98      2745.2  10890.0 0.0335
1100    1959.2          98      3099.2  12305.7 0.0297
1200    1844.7          98      3590.9  14267.5 0.0256
1300    1737.7          98      4129.5  16418.1 0.0223
1400    1647.2          98      4691.6  18662.9 0.0196
1500    1617.1          98      5120.3  20372.5 0.0180

2.2.1 + bigmem patch:
Tasks   Jobs/Min        JTI     Real    CPU     Jobs/sec/task
1000    1984.7          98      2781.3  11027.8 0.0331
1100    1923.5          98      3156.8  12533.9 0.0291
1200    1821.3          98      3636.9  14450.2 0.0253
1300    1726.0          98      4157.6  16530.2 0.0221
1400    1638.2          98      4717.3  18763.9 0.0195
1500    1634.7          98      5065.1  20156.2 0.0182

Conclusion:
-----------

There are probably a lot of problems with the code as it stands
today. Reviewers, please let me know of any possible improvements.
Any ideas on how to improve the uaccess performance will also be
greatly appreciated. Testers, your input will be most valuable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

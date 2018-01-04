Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4C9F46B04C7
	for <linux-mm@kvack.org>; Thu,  4 Jan 2018 02:14:26 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id g13so415549wrh.19
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 23:14:26 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o202sor726156wmg.9.2018.01.03.23.14.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Jan 2018 23:14:24 -0800 (PST)
Date: Thu, 4 Jan 2018 08:14:21 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: "bad pmd" errors + oops with KPTI on 4.14.11 after loading X.509
 certs
Message-ID: <20180104071421.aaqikae3gh23ew4l@gmail.com>
References: <CAD3VwcrHs8W_kMXKyDjKnjNDkkK57-0qFS5ATJYCphJHU0V3ow@mail.gmail.com>
 <20180103084600.GA31648@trogon.sfo.coreos.systems>
 <20180103092016.GA23772@kroah.com>
 <20180104003303.GA1654@trogon.sfo.coreos.systems>
 <alpine.DEB.2.20.1801040136390.1957@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1801040136390.1957@nanos>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Benjamin Gilbert <benjamin.gilbert@coreos.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>


* Thomas Gleixner <tglx@linutronix.de> wrote:

> On Wed, 3 Jan 2018, Benjamin Gilbert wrote:
> 
> > On Wed, Jan 03, 2018 at 10:20:16AM +0100, Greg Kroah-Hartman wrote:
> > > Ick, not good, any chance you can test 4.15-rc6 to verify that the issue
> > > is also there (or not)?
> > 
> > I haven't been able to reproduce this on 4.15-rc6.
> 
> Hmm. So we need to scrutinize the subtle differences between 4.15-rc6 and 4.14.11....

So here's a list of candidate 'missing commits':

triton:~/tip> git log --oneline --no-merges WIP.x86/pti..linus arch/x86 | grep -viE 'apic|irq|vector|probe|kvm|timer|rdt|crypto|platform|tsc|insn|xen|mpx|umip|efi|build|parav|SEV|kmemch|power|stacktrace|unwind|kmmio|dma|boot|PCI|resource|init|virt|kexec|unused|perf|5-level'
10a7e9d84915: Do not hash userspace addresses in fault handlers
f5b5fab1780c: x86/decoder: Fix and update the opcodes map
88edb57d1e0b: x86/vdso: Change time() prototype to match __vdso_time()
d553d03f7057: x86: Fix Sparse warnings about non-static functions
f4e9b7af0cd5: x86/microcode/AMD: Add support for fam17h microcode loading
e3811a3f74bd: x86/cpufeatures: Make X86_BUG_FXSAVE_LEAK detectable in CPUID on AMD
328b4ed93b69: x86: don't hash faulting address in oops printout
b562c171cf01: locking/refcounts: Do not force refcount_t usage as GPL-only export
1501899a898d: mm: fix device-dax pud write-faults triggered by get_user_pages()
55d2d0ad2fb4: x86/idt: Load idt early in start_secondary
9d0b62328d34: x86/tlb: Disable interrupts when changing CR4
0c3292ca8025: x86/tlb: Refactor CR4 setting and shadow write
12a78d43de76: x86/decoder: Add new TEST instruction pattern
30bb9811856f: x86/topology: Avoid wasting 128k for package id array
252714155f04: x86/acpi: Handle SCI interrupts above legacy space gracefully
be62a3204406: x86/mm: Limit mmap() of /dev/mem to valid physical addresses
1e0f25dbf246: x86/mm: Prevent non-MAP_FIXED mapping across DEFAULT_MAP_WINDOW border
fcdaf842bd8f: mm, sparse: do not swamp log with huge vmemmap allocation failures
353b1e7b5859: x86/mm: set fields in deferred pages
7d5905dc14a8: x86 / CPU: Always show current CPU frequency in /proc/cpuinfo
4d2dc2cc766c: fcntl: don't cap l_start and l_end values for F_GETLK64 in compat syscall
b29c6ef7bb12: x86 / CPU: Avoid unnecessary IPIs in arch_freq_get_on_cpu()
450cbdd0125c: locking/x86: Use LOCK ADD for smp_mb() instead of MFENCE
9f08890ab906: x86/pvclock: add setter for pvclock_pvti_cpu0_va
c5e260890d5f: x86/mm: Remove unnecessary TLB flush for SME in-place encryption
4a75aeacda3c: ACPI / APEI: Remove arch_apei_flush_tlb_one()
e4dca7b7aa08: treewide: Fix function prototypes for module_param_call()
7ed4325a44ea: Drivers: hv: vmbus: Make panic reporting to be more useful
6aa7de059173: locking/atomics: COCCINELLE/treewide: Convert trivial ACCESS_ONCE() patterns to READ_ONCE()/WRITE_ONCE()
506458efaf15: locking/barriers: Convert users of lockless_dereference() to READ_ONCE()
0cfe5b5fc027: x86: Use ARRAY_SIZE
c1bd743e54cd: arch/x86: remove redundant null checks before kmem_cache_destroy
a4c1887d4c14: locking/arch: Remove dummy arch_{read,spin,write}_lock_flags() implementations
0160fb177d48: locking/arch: Remove dummy arch_{read,spin,write}_relax() implementations
19c60923010b: locking/arch, x86: Add __down_read_killable()
39208aa7ecb7: locking/refcounts, x86/asm: Enable CONFIG_ARCH_HAS_REFCOUNT
564c9cc84e2a: locking/refcounts, x86/asm: Use unique .text section for refcount exceptions
30c23f29d2d5: locking/x86: Use named operands in rwsem.h

Note the exclusion regex pattern which might be overly aggressive.

Taking out the commits that should have no real effect leads to this list:

f4e9b7af0cd5: x86/microcode/AMD: Add support for fam17h microcode loading
e3811a3f74bd: x86/cpufeatures: Make X86_BUG_FXSAVE_LEAK detectable in CPUID on AMD
1501899a898d: mm: fix device-dax pud write-faults triggered by get_user_pages()
55d2d0ad2fb4: x86/idt: Load idt early in start_secondary
9d0b62328d34: x86/tlb: Disable interrupts when changing CR4
0c3292ca8025: x86/tlb: Refactor CR4 setting and shadow write
252714155f04: x86/acpi: Handle SCI interrupts above legacy space gracefully
be62a3204406: x86/mm: Limit mmap() of /dev/mem to valid physical addresses
1e0f25dbf246: x86/mm: Prevent non-MAP_FIXED mapping across DEFAULT_MAP_WINDOW border
fcdaf842bd8f: mm, sparse: do not swamp log with huge vmemmap allocation failures
353b1e7b5859: x86/mm: set fields in deferred pages
7d5905dc14a8: x86 / CPU: Always show current CPU frequency in /proc/cpuinfo
4d2dc2cc766c: fcntl: don't cap l_start and l_end values for F_GETLK64 in compat syscall
b29c6ef7bb12: x86 / CPU: Avoid unnecessary IPIs in arch_freq_get_on_cpu()
450cbdd0125c: locking/x86: Use LOCK ADD for smp_mb() instead of MFENCE
6aa7de059173: locking/atomics: COCCINELLE/treewide: Convert trivial ACCESS_ONCE() patterns to READ_ONCE()/WRITE_ONCE()
506458efaf15: locking/barriers: Convert users of lockless_dereference() to READ_ONCE()
a4c1887d4c14: locking/arch: Remove dummy arch_{read,spin,write}_lock_flags() implementations
0160fb177d48: locking/arch: Remove dummy arch_{read,spin,write}_relax() implementations
19c60923010b: locking/arch, x86: Add __down_read_killable()
39208aa7ecb7: locking/refcounts, x86/asm: Enable CONFIG_ARCH_HAS_REFCOUNT
564c9cc84e2a: locking/refcounts, x86/asm: Use unique .text section for refcount exceptions
30c23f29d2d5: locking/x86: Use named operands in rwsem.h

And taking out the locking commits which should have no effect on x86 ordering 
gives this (possibly overly aggressively trimmed) list:

f4e9b7af0cd5: x86/microcode/AMD: Add support for fam17h microcode loading
e3811a3f74bd: x86/cpufeatures: Make X86_BUG_FXSAVE_LEAK detectable in CPUID on AMD
1501899a898d: mm: fix device-dax pud write-faults triggered by get_user_pages()
55d2d0ad2fb4: x86/idt: Load idt early in start_secondary
9d0b62328d34: x86/tlb: Disable interrupts when changing CR4
0c3292ca8025: x86/tlb: Refactor CR4 setting and shadow write
252714155f04: x86/acpi: Handle SCI interrupts above legacy space gracefully
be62a3204406: x86/mm: Limit mmap() of /dev/mem to valid physical addresses
1e0f25dbf246: x86/mm: Prevent non-MAP_FIXED mapping across DEFAULT_MAP_WINDOW border
fcdaf842bd8f: mm, sparse: do not swamp log with huge vmemmap allocation failures
353b1e7b5859: x86/mm: set fields in deferred pages
7d5905dc14a8: x86 / CPU: Always show current CPU frequency in /proc/cpuinfo
4d2dc2cc766c: fcntl: don't cap l_start and l_end values for F_GETLK64 in compat syscall
b29c6ef7bb12: x86 / CPU: Avoid unnecessary IPIs in arch_freq_get_on_cpu()
450cbdd0125c: locking/x86: Use LOCK ADD for smp_mb() instead of MFENCE

I think microcode and DAX changes are probably innocent, the IDT loading should 
only affect SMP bootstrap, and the ACPI irq, deferred-pages, cpufreq-info and 
sparsemem fixes are probably unrelated as well. This leaves:

9d0b62328d34: x86/tlb: Disable interrupts when changing CR4
0c3292ca8025: x86/tlb: Refactor CR4 setting and shadow write
be62a3204406: x86/mm: Limit mmap() of /dev/mem to valid physical addresses
1e0f25dbf246: x86/mm: Prevent non-MAP_FIXED mapping across DEFAULT_MAP_WINDOW border
4d2dc2cc766c: fcntl: don't cap l_start and l_end values for F_GETLK64 in compat syscall
450cbdd0125c: locking/x86: Use LOCK ADD for smp_mb() instead of MFENCE

These will cherry-pick cleanly, so it would be nice to test them on top of of the 
-stable kernel that fails:

  for N in 450cbdd0125c 4d2dc2cc766c 1e0f25dbf246 be62a3204406 0c3292ca8025 9d0b62328d34; do git cherry-pick $N; done

if this brute-force approach resolves the problem then we have a shorter list of 
fixes to look at.

If it doesn't fix the problem then the problem is either:

 - fixed by one of the other commits
 - or is fixed by one of the non-x86 upstream commits (of which there are over 10,000)
 - or the problem is non-deterministic,
 - or the problem is build layout dependent,
 - (or it's something I missed to consider)

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

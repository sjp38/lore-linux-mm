Date: Fri, 26 Jan 2007 12:23:35 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bugme-new] [Bug 7889] New: an oops inside kmem_get_pages
Message-Id: <20070126122335.02ef92cf.akpm@osdl.org>
In-Reply-To: <200701261951.l0QJpTlj014473@fire-2.osdl.org>
References: <200701261951.l0QJpTlj014473@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, pluto@pld-linux.org
Cc: "bugme-daemon@kernel-bugs.osdl.org" <bugme-daemon@bugzilla.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 26 Jan 2007 11:51:29 -0800
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=7889
> 
>            Summary: an oops inside kmem_get_pages
>     Kernel Version: 2.6.20rc5/smp
>             Status: NEW
>           Severity: blocking
>              Owner: akpm@osdl.org
>          Submitter: pluto@pld-linux.org
> 
> 
> Most recent kernel where this bug did *NOT* occur:
> 
> 2.6.20rc5 with smp config and disabled `amd k8 cool'n'quiet' bios option.
> 2.6.20rc5 with non-smp config and enabled cool'n'quiet.
> 2.6.18.x works fine with all configuratioins, 2.6.19.x not tested so far.
> 
> Hardware Environment:
> 
> M/B: http://www.epox.nl/products/view.php?product_id=421
> 
> processor _ _ _ : 0
> vendor_id _ _ _ : AuthenticAMD
> cpu family _ _ _: 15
> model _ _ _ _ _ : 55
> model name _ _ _: AMD Athlon(tm) 64 Processor 3700+
> stepping _ _ _ _: 2
> cpu MHz _ _ _ _ : 2200.000
> cache size _ _ _: 1024 KB
> fpu _ _ _ _ _ _ : yes
> fpu_exception _ : yes
> cpuid level _ _ : 1
> wp _ _ _ _ _ _ _: yes
> flags _ _ _ _ _ : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca 
> cmov pat pse36 clflush mmx fxsr sse sse2 syscall nx mmxext fxsr_opt lm 
> 3dnowext 3dnow pni lahf_lm
> bogomips _ _ _ _: 4423.06
> TLB size _ _ _ _: 1024 4K pages
> clflush size _ _: 64
> cache_alignment : 64
> address sizes _ : 40 bits physical, 48 bits virtual
> power management: ts fid vid ttp
> 
> RAM: 1GB DDR.
> 
> Software Environment:
> 
> gcc-4.1.2 with recent binutils.
> 
> Problem Description:
> 
> smp kernel oopses on uniprocessor hardware in early boot stage.
> disabling the amd/k8 cool'n'quiet feature in bios ( acpi/cpufreq related )
> helps, however this may be only a side effect of different flow control.
> disabling config_cpu_freq doesn't help when above metioned bios option
> is enabled.
> 
> Steps to reproduce:
> 
> just boot the bzImage.
> 

Gad.  A null pointer deref right in the main path of the page allocator.

Presumably something has gone wrong with the core MM initialisation on
that kernel.  Could you please work out the exact file-n-line of the
oops?  Build the kernel with CONFIG_DEBUG_INFO and do

gdb vmlinux

(gdb) l *<EIP where it oopsed>

You'll find this points at list_del(), so you'll need to offset the hex
address by a little bit to identify the list_del() caller.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

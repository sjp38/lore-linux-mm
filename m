Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id C3C176B0253
	for <linux-mm@kvack.org>; Tue, 12 Sep 2017 15:45:13 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id j16so12798583pga.6
        for <linux-mm@kvack.org>; Tue, 12 Sep 2017 12:45:13 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n13sor5247523pfg.8.2017.09.12.12.45.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Sep 2017 12:45:11 -0700 (PDT)
Content-Type: multipart/alternative;
	boundary=Apple-Mail-C3A58DA3-A473-4E2E-9E6C-3329C7E27313
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH v4 00/10] PCID and improved laziness
From: Andy Lutomirski <luto@amacapital.net>
In-Reply-To: <1505244724.4482.78.camel@intel.com>
Date: Tue, 12 Sep 2017 12:45:09 -0700
Content-Transfer-Encoding: 7bit
Message-Id: <428E07CE-6F76-4137-B568-B9794735A51F@amacapital.net>
References: <cover.1498751203.git.luto@kernel.org> <CALBSrqDW6pGjHxOmzfnkY_KoNeH6F=pTb8-tJ8r-zbu4prw9HQ@mail.gmail.com> <1505244724.4482.78.camel@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sai Praneeth Prakhya <sai.praneeth.prakhya@intel.com>
Cc: x86@kernel.org, linux-kernel <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, torvalds@linux-foundation.org, akpm@linux-foundation.org, mgorman@suse.de, linux-mm@kvack.org, nadav.amit@gmail.com, riel@redhat.com, "Hansen, Dave" <dave.hansen@intel.com>, arjan@linux.intel.com, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>, "Luck, Tony" <tony.luck@intel.com>, "Shankar, Ravi V" <ravi.v.shankar@intel.com>, Matt Fleming <matt@codeblueprint.co.uk>, "Yu, Fenghua" <fenghua.yu@intel.com>, mingo@kernel.org


--Apple-Mail-C3A58DA3-A473-4E2E-9E6C-3329C7E27313
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: quoted-printable



On Sep 12, 2017, at 12:32 PM, Sai Praneeth Prakhya <sai.praneeth.prakhya@int=
el.com> wrote:

>> From: Andy Lutomirski <luto@kernel.org>
>> Date: Thu, Jun 29, 2017 at 8:53 AM
>> Subject: [PATCH v4 00/10] PCID and improved laziness
>> To: x86@kernel.org
>> Cc: linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>,
>> Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton
>> <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>,
>> "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit
>> <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen
>> <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>,
>> Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski
>> <luto@kernel.org>
>>=20
>>=20
>> *** Ingo, even if this misses 4.13, please apply the first patch
>> before
>> *** the merge window.
>>=20
>> There are three performance benefits here:
>>=20
>> 1. TLB flushing is slow.  (I.e. the flush itself takes a while.)
>>   This avoids many of them when switching tasks by using PCID.  In
>>   a stupid little benchmark I did, it saves about 100ns on my laptop
>>   per context switch.  I'll try to improve that benchmark.
>>=20
>> 2. Mms that have been used recently on a given CPU might get to keep
>>   their TLB entries alive across process switches with this patch
>>   set.  TLB fills are pretty fast on modern CPUs, but they're even
>>   faster when they don't happen.
>>=20
>> 3. Lazy TLB is way better.  We used to do two stupid things when we
>>   ran kernel threads: we'd send IPIs to flush user contexts on their
>>   CPUs and then we'd write to CR3 for no particular reason as an
>> excuse
>>   to stop further IPIs.  With this patch, we do neither.
>>=20
>> This will, in general, perform suboptimally if paravirt TLB flushing
>> is in use (currently just Xen, I think, but Hyper-V is in the works).
>> The code is structured so we could fix it in one of two ways: we
>> could take a spinlock when touching the percpu state so we can update
>> it remotely after a paravirt flush, or we could be more careful about
>> our exactly how we access the state and use cmpxchg16b to do atomic
>> remote updates.  (On SMP systems without cmpxchg16b, we'd just skip
>> the optimization entirely.)
>>=20
>> This is still missing a final comment-only patch to add overall
>> documentation for the whole thing, but I didn't want to block sending
>> the maybe-hopefully-final code on that.
>>=20
>> This is based on tip:x86/mm.  The branch is here if you want to play:
>> https://git.kernel.org/pub/scm/linux/kernel/git/luto/linux.git/log/?h=3Dx=
86/pcid
>>=20
>> In general, performance seems to exceed my expectations.  Here are
>> some performance numbers copy-and-pasted from the changelogs for
>> "Rework lazy TLB mode and TLB freshness" and "Try to preserve old
>> TLB entries using PCID":
>>=20
>>=20
>=20
> Hi Andy,
>=20
> I have booted Linus's tree (8fac2f96ab86b0e14ec4e42851e21e9b518bdc55) on
> Skylake server and noticed that it reboots automatically.
>=20
> When I booted the same kernel with command line arg "nopcid" it works
> fine. Please find below a snippet of dmesg. Please let me know if you
> need more info to debug.
>=20
> [    0.000000] Kernel command line: BOOT_IMAGE=3D/boot/vmlinuz-4.13.0+
> root=3DUUID=3D3b8e9636-6e23-4785-a4e2-5954bfe86fd9 ro console=3Dtty0
> console=3DttyS0,115200n8
> [    0.000000] log_buf_len individual max cpu contribution: 4096 bytes
> [    0.000000] log_buf_len total cpu_extra contributions: 258048 bytes
> [    0.000000] log_buf_len min size: 262144 bytes
> [    0.000000] log_buf_len: 524288 bytes
> [    0.000000] early log buf free: 212560(81%)
> [    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
> [    0.000000] ------------[ cut here ]------------
> [    0.000000] WARNING: CPU: 0 PID: 0 at arch/x86/mm/tlb.c:245
> initialize_tlbstate_and_flush+0x6c/0xf0
> [    0.000000] Modules linked in:
> [    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 4.13.0+ #5
> [    0.000000] task: ffffffff8960f480 task.stack: ffffffff89600000
> [    0.000000] RIP: 0010:initialize_tlbstate_and_flush+0x6c/0xf0
> [    0.000000] RSP: 0000:ffffffff89603e60 EFLAGS: 00010046
> [    0.000000] RAX: 00000000000406b0 RBX: ffff9f1700a17880 RCX:
> ffffffff8965de60
> [    0.000000] RDX: 0000008383a0a000 RSI: 000000000960a000 RDI:
> 0000008383a0a000
> [    0.000000] RBP: ffffffff89603e60 R08: 0000000000000000 R09:
> 0000ffffffffffff
> [    0.000000] R10: ffffffff89603ee8 R11: ffffffff0000ffff R12:
> 0000000000000000
> [    0.000000] R13: ffff9f1700a0c3e0 R14: ffffffff8960f480 R15:
> 0000000000000000
> [    0.000000] FS:  0000000000000000(0000) GS:ffff9f1700a00000(0000)
> knlGS:0000000000000000
> [    0.000000] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [    0.000000] CR2: ffff9fa7bffff000 CR3: 0000008383a0a000 CR4:
> 00000000000406b0
> [    0.000000] Call Trace:
> [    0.000000]  cpu_init+0x206/0x4f0
> [    0.000000]  ? __set_pte_vaddr+0x1d/0x30
> [    0.000000]  trap_init+0x3e/0x50
> [    0.000000]  ? trap_init+0x3e/0x50
> [    0.000000]  start_kernel+0x1e2/0x3f2
> [    0.000000]  x86_64_start_reservations+0x24/0x26
> [    0.000000]  x86_64_start_kernel+0x6f/0x72
> [    0.000000]  secondary_startup_64+0xa5/0xa5
> [    0.000000] Code: de 00 48 01 f0 48 39 c7 0f 85 92 00 00 00 48 8b 05
> ee e2 ee 00 a9 00 00 02 00 74 11 65 48 8b 05 8b 9d 7c 77 a9 00 00 02 00
> 75 02 <0f> ff 48 81 e2 00 f0 ff ff 0f 22 da 65 66 c7 05 66 9d 7c 77 00=20
> [    0.000000] ---[ end trace c258f2d278fe031f ]---
> [    0.000000] Memory: 791050356K/803934656K available (9585K kernel
> code, 1313K rwdata, 3000K rodata, 1176K init, 680K bss, 12884300K
> reserved, 0K cma-reserved)
> [    0.000000] SLUB: HWalign=3D64, Order=3D0-3, MinObjects=3D0, CPUs=3D64,=

> Nodes=3D4
> [    0.000000] Hierarchical RCU implementation.
> [    0.000000]    RCU event tracing is enabled.
> [    0.000000] NR_IRQS: 4352, nr_irqs: 3928, preallocated irqs: 16
> [    0.000000] Console: colour dummy device 80x25
> [    0.000000] console [tty0] enabled
> [    0.000000] console [ttyS0] enabled
> [    0.000000] clocksource: hpet: mask: 0xffffffff max_cycles:
> 0xffffffff, max_idle_ns: 79635855245 ns
> [    0.001000] tsc: Detected 2000.000 MHz processor
> [    0.002000] Calibrating delay loop (skipped), value calculated using
> timer frequency.. 4000.00 BogoMIPS (lpj=3D2000000)
> [    0.003003] pid_max: default: 65536 minimum: 512
> [    0.004030] ACPI: Core revision 20170728
> [    0.091853] ACPI: 6 ACPI AML tables successfully acquired and loaded
> [    0.094143] Security Framework initialized
> [    0.095004] SELinux:  Initializing.
> [    0.145612] Dentry cache hash table entries: 33554432 (order: 16,
> 268435456 bytes)
> [    0.170544] Inode-cache hash table entries: 16777216 (order: 15,
> 134217728 bytes)
> [    0.172699] Mount-cache hash table entries: 524288 (order: 10,
> 4194304 bytes)
> [    0.174441] Mountpoint-cache hash table entries: 524288 (order: 10,
> 4194304 bytes)
> [    0.176351] CPU: Physical Processor ID: 0
> [    0.177003] CPU: Processor Core ID: 0
> [    0.178007] ENERGY_PERF_BIAS: Set to 'normal', was 'performance'
> [    0.179003] ENERGY_PERF_BIAS: View and update with
> x86_energy_perf_policy(8)
> [    0.180013] mce: CPU supports 20 MCE banks
> [    0.181018] CPU0: Thermal monitoring enabled (TM1)
> [    0.182057] process: using mwait in idle threads
> [    0.183005] Last level iTLB entries: 4KB 64, 2MB 8, 4MB 8
> [    0.184003] Last level dTLB entries: 4KB 64, 2MB 0, 4MB 0, 1GB 4
> [    0.185223] Freeing SMP alternatives memory: 36K
> [    0.193912] smpboot: Max logical packages: 8
> [    0.194017] Switched APIC routing to physical flat.
> [    0.196496] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
> [    0.206252] smpboot: CPU0: Intel(R) Xeon(R) Platinum 8164 CPU @
> 2.00GHz (family: 0x6, model: 0x55, stepping: 0x4)
> [    0.207131] Performance Events: PEBS fmt3+, Skylake events, 32-deep
> LBR, full-width counters, Intel PMU driver.
> [    0.208003] ... version:                4
> [    0.209001] ... bit width:              48
> [    0.210001] ... generic registers:      4
> [    0.211001] ... value mask:             0000ffffffffffff
> [    0.212001] ... max period:             00007fffffffffff
> [    0.213001] ... fixed-purpose events:   3
> [    0.214001] ... event mask:             000000070000000f
> [    0.215078] Hierarchical SRCU implementation.
> [    0.216867] smp: Bringing up secondary CPUs ...
> [    0.217085] x86: Booting SMP configuration:
> [    0.218001] .... node  #0, CPUs:        #1
> [    0.001000] ------------[ cut here ]------------
> [    0.001000] WARNING: CPU: 1 PID: 0 at arch/x86/mm/tlb.c:245
> initialize_tlbstate_and_flush+0x6c/0xf0
> [    0.001000] Modules linked in:
> [    0.001000] CPU: 1 PID: 0 Comm: swapper/1 Tainted: G        W
> 4.13.0+ #5
> [    0.001000] task: ffff9f16fa393e40 task.stack: ffffaf0e98afc000
> [    0.001000] RIP: 0010:initialize_tlbstate_and_flush+0x6c/0xf0
> [    0.001000] RSP: 0000:ffffaf0e98affeb0 EFLAGS: 00010046
> [    0.001000] RAX: 00000000000000a0 RBX: ffff9f1700a57880 RCX:
> ffffffff8965de60
> [    0.001000] RDX: 0000008383a0a000 RSI: 000000000960a000 RDI:
> 0000008383a0a000
> [    0.001000] RBP: ffffaf0e98affeb0 R08: 0000000000000000 R09:
> 0000000000000000
> [    0.001000] R10: ffffaf0e98affe78 R11: ffffaf0e98affdb6 R12:
> 0000000000000001
> [    0.001000] R13: ffff9f1700a4c3e0 R14: ffff9f16fa393e40 R15:
> 0000000000000001
> [    0.001000] FS:  0000000000000000(0000) GS:ffff9f1700a40000(0000)
> knlGS:0000000000000000
> [    0.001000] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [    0.001000] CR2: 0000000000000000 CR3: 0000008383a0a000 CR4:
> 00000000000000a0
> [    0.001000] invalid opcode: 0000 [#1] SMP
> [    0.001000] Modules linked in:
> [    0.001000] CPU: 1 PID: 0 Comm: swapper/1 Tainted: G        W
> 4.13.0+ #5
> [    0.001000] task: ffff9f16fa393e40 task.stack: ffffaf0e98afc000
> [    0.001000] RIP: 0010:__show_regs+0x255/0x290
> [    0.001000] RSP: 0000:ffffaf0e98affbc0 EFLAGS: 00010002
> [    0.001000] RAX: 0000000000000018 RBX: 0000000000000000 RCX:
> 0000000000000000
> [    0.001000] RDX: 0000000000000000 RSI: 0000000000000000 RDI:
> ffffffff898a978c
> [    0.001000] RBP: ffffaf0e98affc10 R08: 0000000000000001 R09:
> 0000000000000373
> [    0.001000] R10: ffffffff8884fb8c R11: ffffffff898ab7cd R12:
> 00000000ffff0ff0
> [    0.001000] R13: 0000000000000400 R14: ffff9f1700a40000 R15:
> 0000000000000000
> [    0.001000] FS:  0000000000000000(0000) GS:ffff9f1700a40000(0000)
> knlGS:0000000000000000
> [    0.001000] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [    0.001000] CR2: 0000000000000000 CR3: 0000008383a0a000 CR4:
> 00000000000000a0
> --------------------<snip>--------------------------------------
> [    0.001000] invalid opcode: 0000 [#20] SMP
> [    0.001000] Modules linked in:
> [    0.001000] CPU: 1 PID: 0 Comm: swapper/1 Tainted: G        W
> 4.13.0+ #5
> [    0.001000] task: ffff9f16fa393e40 task.stack: ffffaf0e98afc000
> [    0.001000] RIP: 0010:__show_regs+0x255/0x290
> [    0.001000] RSP: 0000:ffffaf0e98afc788 EFLAGS: 00010002
> [    0.001000] RAX: 0000000000000018 RBX: 0000000000000000 RCX:
> 0000000000000000
> [    0.001000] RDX: 0000000000000000 RSI: 0000000000000000 RDI:
> ffffffff898a978c
> [    0.001000] RBP: ffffaf0e98afc7d8 R08: 0000000000000001 R09:
> 0000000000000490
> [    0.001000] R10: ffffffff88818785 R11: ffffffff898ab7cd R12:
> 00000000ffff0ff0
> [    0.001000] R13: 0000000000000400 R14: ffff9f1700a40000 R15:
> 0000000000000000
> [    0.001000] FS:  0000000000000000(0000) GS:ffff9f1700a40000(0000)
> knlGS:0000000000000000
> [    0.001000] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [    0.001000] CR2: 0000000000000000 CR3: 0000008383a0a000 CR4:
> 00000000000000a0
> Force an S5 exit path.

I'm on my way to LPC, so I can't  easily work on this right this instant.

Can you try this branch, though?

https://git.kernel.org/pub/scm/linux/kernel/git/luto/linux.git/commit/?h=3Dx=
86/fixes&id=3Dcb88ae619b4c3d832d224f2c641849dc02aed864

>=20
> Regards,
> Sai
>=20
>=20

--Apple-Mail-C3A58DA3-A473-4E2E-9E6C-3329C7E27313
Content-Type: text/html;
	charset=utf-8
Content-Transfer-Encoding: quoted-printable

<html><head><meta http-equiv=3D"content-type" content=3D"text/html; charset=3D=
utf-8"></head><body dir=3D"auto"><div><br></div><div><br>On Sep 12, 2017, at=
 12:32 PM, Sai Praneeth Prakhya &lt;<a href=3D"mailto:sai.praneeth.prakhya@i=
ntel.com">sai.praneeth.prakhya@intel.com</a>&gt; wrote:<br><br></div><blockq=
uote type=3D"cite"><div><blockquote type=3D"cite"><span>From: Andy Lutomirsk=
i &lt;<a href=3D"mailto:luto@kernel.org">luto@kernel.org</a>&gt;</span><br><=
/blockquote><blockquote type=3D"cite"><span>Date: Thu, Jun 29, 2017 at 8:53 A=
M</span><br></blockquote><blockquote type=3D"cite"><span>Subject: [PATCH v4 0=
0/10] PCID and improved laziness</span><br></blockquote><blockquote type=3D"=
cite"><span>To: <a href=3D"mailto:x86@kernel.org">x86@kernel.org</a></span><=
br></blockquote><blockquote type=3D"cite"><span>Cc: <a href=3D"mailto:linux-=
kernel@vger.kernel.org">linux-kernel@vger.kernel.org</a>, Borislav Petkov &l=
t;<a href=3D"mailto:bp@alien8.de">bp@alien8.de</a>&gt;,</span><br></blockquo=
te><blockquote type=3D"cite"><span>Linus Torvalds &lt;<a href=3D"mailto:torv=
alds@linux-foundation.org">torvalds@linux-foundation.org</a>&gt;, Andrew Mor=
ton</span><br></blockquote><blockquote type=3D"cite"><span>&lt;<a href=3D"ma=
ilto:akpm@linux-foundation.org">akpm@linux-foundation.org</a>&gt;, Mel Gorma=
n &lt;<a href=3D"mailto:mgorman@suse.de">mgorman@suse.de</a>&gt;,</span><br>=
</blockquote><blockquote type=3D"cite"><span>"<a href=3D"mailto:linux-mm@kva=
ck.org">linux-mm@kvack.org</a>" &lt;<a href=3D"mailto:linux-mm@kvack.org">li=
nux-mm@kvack.org</a>&gt;, Nadav Amit</span><br></blockquote><blockquote type=
=3D"cite"><span>&lt;<a href=3D"mailto:nadav.amit@gmail.com">nadav.amit@gmail=
.com</a>&gt;, Rik van Riel &lt;<a href=3D"mailto:riel@redhat.com">riel@redha=
t.com</a>&gt;, Dave Hansen</span><br></blockquote><blockquote type=3D"cite">=
<span>&lt;<a href=3D"mailto:dave.hansen@intel.com">dave.hansen@intel.com</a>=
&gt;, Arjan van de Ven &lt;<a href=3D"mailto:arjan@linux.intel.com">arjan@li=
nux.intel.com</a>&gt;,</span><br></blockquote><blockquote type=3D"cite"><spa=
n>Peter Zijlstra &lt;<a href=3D"mailto:peterz@infradead.org">peterz@infradea=
d.org</a>&gt;, Andy Lutomirski</span><br></blockquote><blockquote type=3D"ci=
te"><span>&lt;<a href=3D"mailto:luto@kernel.org">luto@kernel.org</a>&gt;</sp=
an><br></blockquote><blockquote type=3D"cite"><span></span><br></blockquote>=
<blockquote type=3D"cite"><span></span><br></blockquote><blockquote type=3D"=
cite"><span>*** Ingo, even if this misses 4.13, please apply the first patch=
</span><br></blockquote><blockquote type=3D"cite"><span>before</span><br></b=
lockquote><blockquote type=3D"cite"><span>*** the merge window.</span><br></=
blockquote><blockquote type=3D"cite"><span></span><br></blockquote><blockquo=
te type=3D"cite"><span>There are three performance benefits here:</span><br>=
</blockquote><blockquote type=3D"cite"><span></span><br></blockquote><blockq=
uote type=3D"cite"><span>1. TLB flushing is slow. &nbsp;(I.e. the flush itse=
lf takes a while.)</span><br></blockquote><blockquote type=3D"cite"><span> &=
nbsp;&nbsp;This avoids many of them when switching tasks by using PCID. &nbs=
p;In</span><br></blockquote><blockquote type=3D"cite"><span> &nbsp;&nbsp;a s=
tupid little benchmark I did, it saves about 100ns on my laptop</span><br></=
blockquote><blockquote type=3D"cite"><span> &nbsp;&nbsp;per context switch. &=
nbsp;I'll try to improve that benchmark.</span><br></blockquote><blockquote t=
ype=3D"cite"><span></span><br></blockquote><blockquote type=3D"cite"><span>2=
. Mms that have been used recently on a given CPU might get to keep</span><b=
r></blockquote><blockquote type=3D"cite"><span> &nbsp;&nbsp;their TLB entrie=
s alive across process switches with this patch</span><br></blockquote><bloc=
kquote type=3D"cite"><span> &nbsp;&nbsp;set. &nbsp;TLB fills are pretty fast=
 on modern CPUs, but they're even</span><br></blockquote><blockquote type=3D=
"cite"><span> &nbsp;&nbsp;faster when they don't happen.</span><br></blockqu=
ote><blockquote type=3D"cite"><span></span><br></blockquote><blockquote type=
=3D"cite"><span>3. Lazy TLB is way better. &nbsp;We used to do two stupid th=
ings when we</span><br></blockquote><blockquote type=3D"cite"><span> &nbsp;&=
nbsp;ran kernel threads: we'd send IPIs to flush user contexts on their</spa=
n><br></blockquote><blockquote type=3D"cite"><span> &nbsp;&nbsp;CPUs and the=
n we'd write to CR3 for no particular reason as an</span><br></blockquote><b=
lockquote type=3D"cite"><span>excuse</span><br></blockquote><blockquote type=
=3D"cite"><span> &nbsp;&nbsp;to stop further IPIs. &nbsp;With this patch, we=
 do neither.</span><br></blockquote><blockquote type=3D"cite"><span></span><=
br></blockquote><blockquote type=3D"cite"><span>This will, in general, perfo=
rm suboptimally if paravirt TLB flushing</span><br></blockquote><blockquote t=
ype=3D"cite"><span>is in use (currently just Xen, I think, but Hyper-V is in=
 the works).</span><br></blockquote><blockquote type=3D"cite"><span>The code=
 is structured so we could fix it in one of two ways: we</span><br></blockqu=
ote><blockquote type=3D"cite"><span>could take a spinlock when touching the p=
ercpu state so we can update</span><br></blockquote><blockquote type=3D"cite=
"><span>it remotely after a paravirt flush, or we could be more careful abou=
t</span><br></blockquote><blockquote type=3D"cite"><span>our exactly how we a=
ccess the state and use cmpxchg16b to do atomic</span><br></blockquote><bloc=
kquote type=3D"cite"><span>remote updates. &nbsp;(On SMP systems without cmp=
xchg16b, we'd just skip</span><br></blockquote><blockquote type=3D"cite"><sp=
an>the optimization entirely.)</span><br></blockquote><blockquote type=3D"ci=
te"><span></span><br></blockquote><blockquote type=3D"cite"><span>This is st=
ill missing a final comment-only patch to add overall</span><br></blockquote=
><blockquote type=3D"cite"><span>documentation for the whole thing, but I di=
dn't want to block sending</span><br></blockquote><blockquote type=3D"cite">=
<span>the maybe-hopefully-final code on that.</span><br></blockquote><blockq=
uote type=3D"cite"><span></span><br></blockquote><blockquote type=3D"cite"><=
span>This is based on tip:x86/mm. &nbsp;The branch is here if you want to pl=
ay:</span><br></blockquote><blockquote type=3D"cite"><span><a href=3D"https:=
//git.kernel.org/pub/scm/linux/kernel/git/luto/linux.git/log/?h=3Dx86/pcid">=
https://git.kernel.org/pub/scm/linux/kernel/git/luto/linux.git/log/?h=3Dx86/=
pcid</a></span><br></blockquote><blockquote type=3D"cite"><span></span><br><=
/blockquote><blockquote type=3D"cite"><span>In general, performance seems to=
 exceed my expectations. &nbsp;Here are</span><br></blockquote><blockquote t=
ype=3D"cite"><span>some performance numbers copy-and-pasted from the changel=
ogs for</span><br></blockquote><blockquote type=3D"cite"><span>"Rework lazy T=
LB mode and TLB freshness" and "Try to preserve old</span><br></blockquote><=
blockquote type=3D"cite"><span>TLB entries using PCID":</span><br></blockquo=
te><blockquote type=3D"cite"><span></span><br></blockquote><blockquote type=3D=
"cite"><span></span><br></blockquote><span></span><br><span>Hi Andy,</span><=
br><span></span><br><span>I have booted Linus's tree (8fac2f96ab86b0e14ec4e4=
2851e21e9b518bdc55) on</span><br><span>Skylake server and noticed that it re=
boots automatically.</span><br><span></span><br><span>When I booted the same=
 kernel with command line arg "nopcid" it works</span><br><span>fine. Please=
 find below a snippet of dmesg. Please let me know if you</span><br><span>ne=
ed more info to debug.</span><br><span></span><br><span>[ &nbsp;&nbsp;&nbsp;=
0.000000] Kernel command line: BOOT_IMAGE=3D/boot/vmlinuz-4.13.0+</span><br>=
<span>root=3DUUID=3D3b8e9636-6e23-4785-a4e2-5954bfe86fd9 ro console=3Dtty0</=
span><br><span>console=3DttyS0,115200n8</span><br><span>[ &nbsp;&nbsp;&nbsp;=
0.000000] log_buf_len individual max cpu contribution: 4096 bytes</span><br>=
<span>[ &nbsp;&nbsp;&nbsp;0.000000] log_buf_len total cpu_extra contribution=
s: 258048 bytes</span><br><span>[ &nbsp;&nbsp;&nbsp;0.000000] log_buf_len mi=
n size: 262144 bytes</span><br><span>[ &nbsp;&nbsp;&nbsp;0.000000] log_buf_l=
en: 524288 bytes</span><br><span>[ &nbsp;&nbsp;&nbsp;0.000000] early log buf=
 free: 212560(81%)</span><br><span>[ &nbsp;&nbsp;&nbsp;0.000000] PID hash ta=
ble entries: 4096 (order: 3, 32768 bytes)</span><br><span>[ &nbsp;&nbsp;&nbs=
p;0.000000] ------------[ cut here ]------------</span><br><span>[ &nbsp;&nb=
sp;&nbsp;0.000000] WARNING: CPU: 0 PID: 0 at arch/x86/mm/tlb.c:245</span><br=
><span>initialize_tlbstate_and_flush+0x6c/0xf0</span><br><span>[ &nbsp;&nbsp=
;&nbsp;0.000000] Modules linked in:</span><br><span>[ &nbsp;&nbsp;&nbsp;0.00=
0000] CPU: 0 PID: 0 Comm: swapper Not tainted 4.13.0+ #5</span><br><span>[ &=
nbsp;&nbsp;&nbsp;0.000000] task: ffffffff8960f480 task.stack: ffffffff896000=
00</span><br><span>[ &nbsp;&nbsp;&nbsp;0.000000] RIP: 0010:initialize_tlbsta=
te_and_flush+0x6c/0xf0</span><br><span>[ &nbsp;&nbsp;&nbsp;0.000000] RSP: 00=
00:ffffffff89603e60 EFLAGS: 00010046</span><br><span>[ &nbsp;&nbsp;&nbsp;0.0=
00000] RAX: 00000000000406b0 RBX: ffff9f1700a17880 RCX:</span><br><span>ffff=
ffff8965de60</span><br><span>[ &nbsp;&nbsp;&nbsp;0.000000] RDX: 0000008383a0=
a000 RSI: 000000000960a000 RDI:</span><br><span>0000008383a0a000</span><br><=
span>[ &nbsp;&nbsp;&nbsp;0.000000] RBP: ffffffff89603e60 R08: 00000000000000=
00 R09:</span><br><span>0000ffffffffffff</span><br><span>[ &nbsp;&nbsp;&nbsp=
;0.000000] R10: ffffffff89603ee8 R11: ffffffff0000ffff R12:</span><br><span>=
0000000000000000</span><br><span>[ &nbsp;&nbsp;&nbsp;0.000000] R13: ffff9f17=
00a0c3e0 R14: ffffffff8960f480 R15:</span><br><span>0000000000000000</span><=
br><span>[ &nbsp;&nbsp;&nbsp;0.000000] FS: &nbsp;0000000000000000(0000) GS:f=
fff9f1700a00000(0000)</span><br><span>knlGS:0000000000000000</span><br><span=
>[ &nbsp;&nbsp;&nbsp;0.000000] CS: &nbsp;0010 DS: 0000 ES: 0000 CR0: 0000000=
080050033</span><br><span>[ &nbsp;&nbsp;&nbsp;0.000000] CR2: ffff9fa7bffff00=
0 CR3: 0000008383a0a000 CR4:</span><br><span>00000000000406b0</span><br><spa=
n>[ &nbsp;&nbsp;&nbsp;0.000000] Call Trace:</span><br><span>[ &nbsp;&nbsp;&n=
bsp;0.000000] &nbsp;cpu_init+0x206/0x4f0</span><br><span>[ &nbsp;&nbsp;&nbsp=
;0.000000] &nbsp;? __set_pte_vaddr+0x1d/0x30</span><br><span>[ &nbsp;&nbsp;&=
nbsp;0.000000] &nbsp;trap_init+0x3e/0x50</span><br><span>[ &nbsp;&nbsp;&nbsp=
;0.000000] &nbsp;? trap_init+0x3e/0x50</span><br><span>[ &nbsp;&nbsp;&nbsp;0=
.000000] &nbsp;start_kernel+0x1e2/0x3f2</span><br><span>[ &nbsp;&nbsp;&nbsp;=
0.000000] &nbsp;x86_64_start_reservations+0x24/0x26</span><br><span>[ &nbsp;=
&nbsp;&nbsp;0.000000] &nbsp;x86_64_start_kernel+0x6f/0x72</span><br><span>[ &=
nbsp;&nbsp;&nbsp;0.000000] &nbsp;secondary_startup_64+0xa5/0xa5</span><br><s=
pan>[ &nbsp;&nbsp;&nbsp;0.000000] Code: de 00 48 01 f0 48 39 c7 0f 85 92 00 0=
0 00 48 8b 05</span><br><span>ee e2 ee 00 a9 00 00 02 00 74 11 65 48 8b 05 8=
b 9d 7c 77 a9 00 00 02 00</span><br><span>75 02 &lt;0f&gt; ff 48 81 e2 00 f0=
 ff ff 0f 22 da 65 66 c7 05 66 9d 7c 77 00 </span><br><span>[ &nbsp;&nbsp;&n=
bsp;0.000000] ---[ end trace c258f2d278fe031f ]---</span><br><span>[ &nbsp;&=
nbsp;&nbsp;0.000000] Memory: 791050356K/803934656K available (9585K kernel</=
span><br><span>code, 1313K rwdata, 3000K rodata, 1176K init, 680K bss, 12884=
300K</span><br><span>reserved, 0K cma-reserved)</span><br><span>[ &nbsp;&nbs=
p;&nbsp;0.000000] SLUB: HWalign=3D64, Order=3D0-3, MinObjects=3D0, CPUs=3D64=
,</span><br><span>Nodes=3D4</span><br><span>[ &nbsp;&nbsp;&nbsp;0.000000] Hi=
erarchical RCU implementation.</span><br><span>[ &nbsp;&nbsp;&nbsp;0.000000]=
  &nbsp; &nbsp;RCU event tracing is enabled.</span><br><span>[ &nbsp;&nbsp;&=
nbsp;0.000000] NR_IRQS: 4352, nr_irqs: 3928, preallocated irqs: 16</span><br=
><span>[ &nbsp;&nbsp;&nbsp;0.000000] Console: colour dummy device 80x25</spa=
n><br><span>[ &nbsp;&nbsp;&nbsp;0.000000] console [tty0] enabled</span><br><=
span>[ &nbsp;&nbsp;&nbsp;0.000000] console [ttyS0] enabled</span><br><span>[=
 &nbsp;&nbsp;&nbsp;0.000000] clocksource: hpet: mask: 0xffffffff max_cycles:=
</span><br><span>0xffffffff, max_idle_ns: 79635855245 ns</span><br><span>[ &=
nbsp;&nbsp;&nbsp;0.001000] tsc: Detected 2000.000 MHz processor</span><br><s=
pan>[ &nbsp;&nbsp;&nbsp;0.002000] Calibrating delay loop (skipped), value ca=
lculated using</span><br><span>timer frequency.. 4000.00 BogoMIPS (lpj=3D200=
0000)</span><br><span>[ &nbsp;&nbsp;&nbsp;0.003003] pid_max: default: 65536 m=
inimum: 512</span><br><span>[ &nbsp;&nbsp;&nbsp;0.004030] ACPI: Core revisio=
n 20170728</span><br><span>[ &nbsp;&nbsp;&nbsp;0.091853] ACPI: 6 ACPI AML ta=
bles successfully acquired and loaded</span><br><span>[ &nbsp;&nbsp;&nbsp;0.=
094143] Security Framework initialized</span><br><span>[ &nbsp;&nbsp;&nbsp;0=
.095004] SELinux: &nbsp;Initializing.</span><br><span>[ &nbsp;&nbsp;&nbsp;0.=
145612] Dentry cache hash table entries: 33554432 (order: 16,</span><br><spa=
n>268435456 bytes)</span><br><span>[ &nbsp;&nbsp;&nbsp;0.170544] Inode-cache=
 hash table entries: 16777216 (order: 15,</span><br><span>134217728 bytes)</=
span><br><span>[ &nbsp;&nbsp;&nbsp;0.172699] Mount-cache hash table entries:=
 524288 (order: 10,</span><br><span>4194304 bytes)</span><br><span>[ &nbsp;&=
nbsp;&nbsp;0.174441] Mountpoint-cache hash table entries: 524288 (order: 10,=
</span><br><span>4194304 bytes)</span><br><span>[ &nbsp;&nbsp;&nbsp;0.176351=
] CPU: Physical Processor ID: 0</span><br><span>[ &nbsp;&nbsp;&nbsp;0.177003=
] CPU: Processor Core ID: 0</span><br><span>[ &nbsp;&nbsp;&nbsp;0.178007] EN=
ERGY_PERF_BIAS: Set to 'normal', was 'performance'</span><br><span>[ &nbsp;&=
nbsp;&nbsp;0.179003] ENERGY_PERF_BIAS: View and update with</span><br><span>=
x86_energy_perf_policy(8)</span><br><span>[ &nbsp;&nbsp;&nbsp;0.180013] mce:=
 CPU supports 20 MCE banks</span><br><span>[ &nbsp;&nbsp;&nbsp;0.181018] CPU=
0: Thermal monitoring enabled (TM1)</span><br><span>[ &nbsp;&nbsp;&nbsp;0.18=
2057] process: using mwait in idle threads</span><br><span>[ &nbsp;&nbsp;&nb=
sp;0.183005] Last level iTLB entries: 4KB 64, 2MB 8, 4MB 8</span><br><span>[=
 &nbsp;&nbsp;&nbsp;0.184003] Last level dTLB entries: 4KB 64, 2MB 0, 4MB 0, 1=
GB 4</span><br><span>[ &nbsp;&nbsp;&nbsp;0.185223] Freeing SMP alternatives m=
emory: 36K</span><br><span>[ &nbsp;&nbsp;&nbsp;0.193912] smpboot: Max logica=
l packages: 8</span><br><span>[ &nbsp;&nbsp;&nbsp;0.194017] Switched APIC ro=
uting to physical flat.</span><br><span>[ &nbsp;&nbsp;&nbsp;0.196496] ..TIME=
R: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D-1</span><br><span>[ &=
nbsp;&nbsp;&nbsp;0.206252] smpboot: CPU0: Intel(R) Xeon(R) Platinum 8164 CPU=
 @</span><br><span>2.00GHz (family: 0x6, model: 0x55, stepping: 0x4)</span><=
br><span>[ &nbsp;&nbsp;&nbsp;0.207131] Performance Events: PEBS fmt3+, Skyla=
ke events, 32-deep</span><br><span>LBR, full-width counters, Intel PMU drive=
r.</span><br><span>[ &nbsp;&nbsp;&nbsp;0.208003] ... version: &nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
4</span><br><span>[ &nbsp;&nbsp;&nbsp;0.209001] ... bit width: &nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;48</span><b=
r><span>[ &nbsp;&nbsp;&nbsp;0.210001] ... generic registers: &nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;4</span><br><span>[ &nbsp;&nbsp;&nbsp;0.211001] ... value mas=
k: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0=
000ffffffffffff</span><br><span>[ &nbsp;&nbsp;&nbsp;0.212001] ... max period=
: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;00=
007fffffffffff</span><br><span>[ &nbsp;&nbsp;&nbsp;0.213001] ... fixed-purpo=
se events: &nbsp;&nbsp;3</span><br><span>[ &nbsp;&nbsp;&nbsp;0.214001] ... e=
vent mask: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;000000070000000f</span><br><span>[ &nbsp;&nbsp;&nbsp;0.215078] Hierar=
chical SRCU implementation.</span><br><span>[ &nbsp;&nbsp;&nbsp;0.216867] sm=
p: Bringing up secondary CPUs ...</span><br><span>[ &nbsp;&nbsp;&nbsp;0.2170=
85] x86: Booting SMP configuration:</span><br><span>[ &nbsp;&nbsp;&nbsp;0.21=
8001] .... node &nbsp;#0, CPUs: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#1=
</span><br><span>[ &nbsp;&nbsp;&nbsp;0.001000] ------------[ cut here ]-----=
-------</span><br><span>[ &nbsp;&nbsp;&nbsp;0.001000] WARNING: CPU: 1 PID: 0=
 at arch/x86/mm/tlb.c:245</span><br><span>initialize_tlbstate_and_flush+0x6c=
/0xf0</span><br><span>[ &nbsp;&nbsp;&nbsp;0.001000] Modules linked in:</span=
><br><span>[ &nbsp;&nbsp;&nbsp;0.001000] CPU: 1 PID: 0 Comm: swapper/1 Taint=
ed: G &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;W</span><br><span>4.13.0+ #5=
</span><br><span>[ &nbsp;&nbsp;&nbsp;0.001000] task: ffff9f16fa393e40 task.s=
tack: ffffaf0e98afc000</span><br><span>[ &nbsp;&nbsp;&nbsp;0.001000] RIP: 00=
10:initialize_tlbstate_and_flush+0x6c/0xf0</span><br><span>[ &nbsp;&nbsp;&nb=
sp;0.001000] RSP: 0000:ffffaf0e98affeb0 EFLAGS: 00010046</span><br><span>[ &=
nbsp;&nbsp;&nbsp;0.001000] RAX: 00000000000000a0 RBX: ffff9f1700a57880 RCX:<=
/span><br><span>ffffffff8965de60</span><br><span>[ &nbsp;&nbsp;&nbsp;0.00100=
0] RDX: 0000008383a0a000 RSI: 000000000960a000 RDI:</span><br><span>00000083=
83a0a000</span><br><span>[ &nbsp;&nbsp;&nbsp;0.001000] RBP: ffffaf0e98affeb0=
 R08: 0000000000000000 R09:</span><br><span>0000000000000000</span><br><span=
>[ &nbsp;&nbsp;&nbsp;0.001000] R10: ffffaf0e98affe78 R11: ffffaf0e98affdb6 R=
12:</span><br><span>0000000000000001</span><br><span>[ &nbsp;&nbsp;&nbsp;0.0=
01000] R13: ffff9f1700a4c3e0 R14: ffff9f16fa393e40 R15:</span><br><span>0000=
000000000001</span><br><span>[ &nbsp;&nbsp;&nbsp;0.001000] FS: &nbsp;0000000=
000000000(0000) GS:ffff9f1700a40000(0000)</span><br><span>knlGS:000000000000=
0000</span><br><span>[ &nbsp;&nbsp;&nbsp;0.001000] CS: &nbsp;0010 DS: 0000 E=
S: 0000 CR0: 0000000080050033</span><br><span>[ &nbsp;&nbsp;&nbsp;0.001000] C=
R2: 0000000000000000 CR3: 0000008383a0a000 CR4:</span><br><span>000000000000=
00a0</span><br><span>[ &nbsp;&nbsp;&nbsp;0.001000] invalid opcode: 0000 [#1]=
 SMP</span><br><span>[ &nbsp;&nbsp;&nbsp;0.001000] Modules linked in:</span>=
<br><span>[ &nbsp;&nbsp;&nbsp;0.001000] CPU: 1 PID: 0 Comm: swapper/1 Tainte=
d: G &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;W</span><br><span>4.13.0+ #5<=
/span><br><span>[ &nbsp;&nbsp;&nbsp;0.001000] task: ffff9f16fa393e40 task.st=
ack: ffffaf0e98afc000</span><br><span>[ &nbsp;&nbsp;&nbsp;0.001000] RIP: 001=
0:__show_regs+0x255/0x290</span><br><span>[ &nbsp;&nbsp;&nbsp;0.001000] RSP:=
 0000:ffffaf0e98affbc0 EFLAGS: 00010002</span><br><span>[ &nbsp;&nbsp;&nbsp;=
0.001000] RAX: 0000000000000018 RBX: 0000000000000000 RCX:</span><br><span>0=
000000000000000</span><br><span>[ &nbsp;&nbsp;&nbsp;0.001000] RDX: 000000000=
0000000 RSI: 0000000000000000 RDI:</span><br><span>ffffffff898a978c</span><b=
r><span>[ &nbsp;&nbsp;&nbsp;0.001000] RBP: ffffaf0e98affc10 R08: 00000000000=
00001 R09:</span><br><span>0000000000000373</span><br><span>[ &nbsp;&nbsp;&n=
bsp;0.001000] R10: ffffffff8884fb8c R11: ffffffff898ab7cd R12:</span><br><sp=
an>00000000ffff0ff0</span><br><span>[ &nbsp;&nbsp;&nbsp;0.001000] R13: 00000=
00000000400 R14: ffff9f1700a40000 R15:</span><br><span>0000000000000000</spa=
n><br><span>[ &nbsp;&nbsp;&nbsp;0.001000] FS: &nbsp;0000000000000000(0000) G=
S:ffff9f1700a40000(0000)</span><br><span>knlGS:0000000000000000</span><br><s=
pan>[ &nbsp;&nbsp;&nbsp;0.001000] CS: &nbsp;0010 DS: 0000 ES: 0000 CR0: 0000=
000080050033</span><br><span>[ &nbsp;&nbsp;&nbsp;0.001000] CR2: 000000000000=
0000 CR3: 0000008383a0a000 CR4:</span><br><span>00000000000000a0</span><br><=
span>--------------------&lt;snip&gt;--------------------------------------<=
/span><br><span>[ &nbsp;&nbsp;&nbsp;0.001000] invalid opcode: 0000 [#20] SMP=
</span><br><span>[ &nbsp;&nbsp;&nbsp;0.001000] Modules linked in:</span><br>=
<span>[ &nbsp;&nbsp;&nbsp;0.001000] CPU: 1 PID: 0 Comm: swapper/1 Tainted: G=
 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;W</span><br><span>4.13.0+ #5</spa=
n><br><span>[ &nbsp;&nbsp;&nbsp;0.001000] task: ffff9f16fa393e40 task.stack:=
 ffffaf0e98afc000</span><br><span>[ &nbsp;&nbsp;&nbsp;0.001000] RIP: 0010:__=
show_regs+0x255/0x290</span><br><span>[ &nbsp;&nbsp;&nbsp;0.001000] RSP: 000=
0:ffffaf0e98afc788 EFLAGS: 00010002</span><br><span>[ &nbsp;&nbsp;&nbsp;0.00=
1000] RAX: 0000000000000018 RBX: 0000000000000000 RCX:</span><br><span>00000=
00000000000</span><br><span>[ &nbsp;&nbsp;&nbsp;0.001000] RDX: 0000000000000=
000 RSI: 0000000000000000 RDI:</span><br><span>ffffffff898a978c</span><br><s=
pan>[ &nbsp;&nbsp;&nbsp;0.001000] RBP: ffffaf0e98afc7d8 R08: 000000000000000=
1 R09:</span><br><span>0000000000000490</span><br><span>[ &nbsp;&nbsp;&nbsp;=
0.001000] R10: ffffffff88818785 R11: ffffffff898ab7cd R12:</span><br><span>0=
0000000ffff0ff0</span><br><span>[ &nbsp;&nbsp;&nbsp;0.001000] R13: 000000000=
0000400 R14: ffff9f1700a40000 R15:</span><br><span>0000000000000000</span><b=
r><span>[ &nbsp;&nbsp;&nbsp;0.001000] FS: &nbsp;0000000000000000(0000) GS:ff=
ff9f1700a40000(0000)</span><br><span>knlGS:0000000000000000</span><br><span>=
[ &nbsp;&nbsp;&nbsp;0.001000] CS: &nbsp;0010 DS: 0000 ES: 0000 CR0: 00000000=
80050033</span><br><span>[ &nbsp;&nbsp;&nbsp;0.001000] CR2: 0000000000000000=
 CR3: 0000008383a0a000 CR4:</span><br><span>00000000000000a0</span><br><span=
>Force an S5 exit path.</span><br></div></blockquote><div><br></div><div>I'm=
 on my way to LPC, so I can't &nbsp;easily work on this right this instant.<=
/div><div><br></div><div>Can you try this branch, though?</div><div><br></di=
v><div><a href=3D"https://git.kernel.org/pub/scm/linux/kernel/git/luto/linux=
.git/commit/?h=3Dx86/fixes&amp;id=3Dcb88ae619b4c3d832d224f2c641849dc02aed864=
">https://git.kernel.org/pub/scm/linux/kernel/git/luto/linux.git/commit/?h=3D=
x86/fixes&amp;id=3Dcb88ae619b4c3d832d224f2c641849dc02aed864</a></div><br><bl=
ockquote type=3D"cite"><div><span></span><br><span>Regards,</span><br><span>=
Sai</span><br><span></span><br><span></span><br></div></blockquote></body></=
html>=

--Apple-Mail-C3A58DA3-A473-4E2E-9E6C-3329C7E27313--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

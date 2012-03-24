Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id A774E6B0044
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 21:41:08 -0400 (EDT)
Received: by werj55 with SMTP id j55so4115954wer.14
        for <linux-mm@kvack.org>; Fri, 23 Mar 2012 18:41:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1332409539.18960.508.camel@twins>
References: <20120316144028.036474157@chello.nl>
	<CAOhV88NafiU7hseTzQfApthMk3X=_GT09gEM2Zzx5OJ=8z6vvw@mail.gmail.com>
	<1332409539.18960.508.camel@twins>
Date: Fri, 23 Mar 2012 18:41:06 -0700
Message-ID: <CAOhV88O+1=e9+Jrv3cx1j=wbbypzkXL=B6wToOPYRArgYVF9cQ@mail.gmail.com>
Subject: Re: [RFC][PATCH 00/26] sched/numa
From: Nish Aravamudan <nish.aravamudan@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Peter,

On Thu, Mar 22, 2012 at 2:45 AM, Peter Zijlstra <a.p.zijlstra@chello.nl> wr=
ote:
>
>> I was going to try and test this on power, but it fails to build:
>>
>> =A0 mm/filemap_xip.c: In function =91__xip_unmap=92:
>> =A0 mm/filemap_xip.c:199: error: implicit declaration of function
>> =91numa_add_vma_counter=92
>
> Add:
>
> #include <linux/mempolicy.h>
>
> to that file and it should build.

Thanks, I was able to get it to build, but it panic'd on one of my
machines. Full dmesg is below...

[2012-03-20 00:46:24]	boot: autotest
[2012-03-20 00:46:24]	Please wait, loading kernel...
[2012-03-20 00:46:28]	   Elf64 kernel loaded...
[2012-03-20 00:46:28]	Loading ramdisk...
[2012-03-20 00:46:32]	ramdisk loaded at 03180000, size: 11950 Kbytes
[2012-03-20 00:46:32]	OF stdout device is: /vdevice/vty@30000000
[2012-03-20 00:46:32]	Preparing to boot Linux version 3.3.0-rc7
(root@fbird-lp8.austin.ibm.com) (gcc version 4.6.2 20111027 (Red Hat
4.6.2-1) (GCC) ) #1 SMP Fri Mar 23 20:15:37 EDT 2012
[2012-03-20 00:46:32]	Detected machine type: 0000000000000101
[2012-03-20 00:46:32]	Max number of cores passed to firmware: 8 (NR_CPUS =
=3D 32)
[2012-03-20 00:46:32]	Calling ibm,client-architecture-support... done
[2012-03-20 00:46:32]	command line:
root=3D/dev/mapper/vg_fbirdlp8-lv_root console=3Dhvc0 IDENT=3D1332548257
[2012-03-20 00:46:32]	memory layout at init:
[2012-03-20 00:46:32]	  memory_limit : 0000000000000000 (16 MB aligned)
[2012-03-20 00:46:32]	  alloc_bottom : 0000000003d2c000
[2012-03-20 00:46:32]	  alloc_top    : 0000000010000000
[2012-03-20 00:46:32]	  alloc_top_hi : 0000000010000000
[2012-03-20 00:46:32]	  rmo_top      : 0000000010000000
[2012-03-20 00:46:32]	  ram_top      : 0000000010000000
[2012-03-20 00:46:32]	instantiating rtas at 0x000000000ed90000... done
[2012-03-20 00:46:32]	Querying for OPAL presence... not there.
[2012-03-20 00:46:32]	boot cpu hw idx 0
[2012-03-20 00:46:32]	starting cpu hw idx 4... done
[2012-03-20 00:46:32]	starting cpu hw idx 8... done
[2012-03-20 00:46:33]	starting cpu hw idx 12... done
[2012-03-20 00:46:33]	copying OF device tree...
[2012-03-20 00:46:33]	Building dt strings...
[2012-03-20 00:46:33]	Building dt structure...
[2012-03-20 00:46:33]	Device tree strings 0x0000000003e2d000 ->
0x0000000003e2e5af
[2012-03-20 00:46:33]	Device tree struct  0x0000000003e2f000 ->
0x0000000003e44000
[2012-03-20 00:46:33]	Calling quiesce...
[2012-03-20 00:46:33]	returning from prom_init
[2012-03-20 00:46:33]	Using pSeries machine description
[2012-03-20 00:46:33]	Using 1TB segments
[2012-03-20 00:46:33]	Found initrd at 0xc000000003180000:0xc000000003d2b800
[2012-03-20 00:46:33]	bootconsole [udbg0] enabled
[2012-03-20 00:46:33]	Partition configured for 16 cpus.
[2012-03-20 00:46:33]	CPU maps initialized for 4 threads per core
[2012-03-20 00:46:33]	Starting Linux PPC64 #1 SMP Fri Mar 23 20:15:37 EDT 2=
012
[2012-03-20 00:46:33]	-----------------------------------------------------
[2012-03-20 00:46:33]	ppc64_pft_size                =3D 0x1c
[2012-03-20 00:46:33]	physicalMemorySize            =3D 0x500000000
[2012-03-20 00:46:33]	htab_hash_mask                =3D 0x1fffff
[2012-03-20 00:46:33]	-----------------------------------------------------
[2012-03-20 00:46:33]	Initializing cgroup subsys cpuset
[2012-03-20 00:46:33]	Linux version 3.3.0-rc7
(root@fbird-lp8.austin.ibm.com) (gcc version 4.6.2 20111027 (Red Hat
4.6.2-1) (GCC) ) #1 SMP Fri Mar 23 20:15:37 EDT 2012
[2012-03-20 00:46:33]	[boot]0012 Setup Arch
[2012-03-20 00:46:33]	EEH: No capable adapters found
[2012-03-20 00:46:33]	PPC64 nvram contains 15360 bytes
[2012-03-20 00:46:33]	Zone PFN ranges:
[2012-03-20 00:46:33]	  DMA      0x00000000 -> 0x00500000
[2012-03-20 00:46:33]	  Normal   empty
[2012-03-20 00:46:33]	Movable zone start PFN for each node
[2012-03-20 00:46:33]	Early memory PFN ranges
[2012-03-20 00:46:33]	    1: 0x00000000 -> 0x00140000
[2012-03-20 00:46:33]	    3: 0x00140000 -> 0x00500000
[2012-03-20 00:46:33]	Could not find start_pfn for node 0
[2012-03-20 00:46:33]	[boot]0015 Setup Done
[2012-03-20 00:46:33]	PERCPU: Embedded 13 pages/cpu @c000000000f00000
s20864 r0 d32384 u262144
[2012-03-20 00:46:33]	Built 3 zonelists in Node order, mobility
grouping on.  Total pages: 5171200
[2012-03-20 00:46:33]	Policy zone: DMA
[2012-03-20 00:46:33]	Kernel command line:
root=3D/dev/mapper/vg_fbirdlp8-lv_root console=3Dhvc0 IDENT=3D1332548257
[2012-03-20 00:46:33]	PID hash table entries: 4096 (order: 3, 32768 bytes)
[2012-03-20 00:46:33]	freeing bootmem node 1
[2012-03-20 00:46:33]	freeing bootmem node 3
[2012-03-20 00:46:33]	Memory: 20628296k/20971520k available (12100k
kernel code, 343224k reserved, 1324k data, 948k bss, 468k init)
[2012-03-20 00:46:33]	SLUB: Genslabs=3D15, HWalign=3D128, Order=3D0-3,
MinObjects=3D0, CPUs=3D16, Nodes=3D256
[2012-03-20 00:46:33]	Hierarchical RCU implementation.
[2012-03-20 00:46:33]	NR_IRQS:512
[2012-03-20 00:46:33]	clocksource: timebase mult[1f40000] shift[24] registe=
red
[2012-03-20 00:46:33]	Console: colour dummy device 80x25
[2012-03-20 00:46:33]	console [hvc0] enabled, bootconsole disabled
[2012-03-20 00:46:33]	console [hvc0] enabled, bootconsole disabled
[2012-03-20 00:46:33]	pid_max: default: 32768 minimum: 301
[2012-03-20 00:46:33]	Dentry cache hash table entries: 4194304 (order:
13, 33554432 bytes)
[2012-03-20 00:46:33]	Inode-cache hash table entries: 2097152 (order:
12, 16777216 bytes)
[2012-03-20 00:46:33]	Mount-cache hash table entries: 256
[2012-03-20 00:46:33]	POWER7 performance monitor hardware support registere=
d
[2012-03-20 00:46:33]	Unable to handle kernel paging request for data
at address 0x00001688
[2012-03-20 00:46:33]	Faulting instruction address: 0xc000000000168338
[2012-03-20 00:46:33]	Oops: Kernel access of bad area, sig: 11 [#1]
[2012-03-20 00:46:33]	SMP NR_CPUS=3D32 NUMA pSeries
[2012-03-20 00:46:33]	Modules linked in:
[2012-03-20 00:46:33]	NIP: c000000000168338 LR: c0000000001b523c CTR:
0000000000000000
[2012-03-20 00:46:33]	REGS: c00000013d887700 TRAP: 0300   Not tainted
(3.3.0-rc7)
[2012-03-20 00:46:33]	MSR: 8000000000009032 <SF,EE,ME,IR,DR,RI>  CR:
24004022  XER: 00000008
[2012-03-20 00:46:33]	CFAR: 0000000000005374
[2012-03-20 00:46:33]	DAR: 0000000000001688, DSISR: 40000000
[2012-03-20 00:46:33]	TASK =3D c00000013d888000[1] 'swapper/0' THREAD:
c00000013d884000 CPU: 0
[2012-03-20 00:46:33]	GPR00: 0000000000000000 c00000013d887980
c000000000ce7990 00000000000012d0
[2012-03-20 00:46:33]	GPR04: 0000000000000000 0000000000001680
0000000000000000 0003005500000001
[2012-03-20 00:46:33]	GPR08: 0000000000000001 0000000000000000
c000000000d25000 0000000000000010
[2012-03-20 00:46:33]	GPR12: 0000000044004024 c00000000fffa000
0000000000000000 0000000000000060
[2012-03-20 00:46:33]	GPR16: c000000000a69040 c000000000a66828
0000000002e317f0 0000000001a3f930
[2012-03-20 00:46:33]	GPR20: 0000000000000000 0000000000001680
0000000000000001 0000000000210d00
[2012-03-20 00:46:33]	GPR24: c000000000d193a0 0000000000000000
0000000000001680 00000000000012d0
[2012-03-20 00:46:33]	GPR28: 0000000000000000 0000000000000000
c000000000c5d6e8 c00000013e009200
[2012-03-20 00:46:33]	NIP [c000000000168338] .__alloc_pages_nodemask+0xb8/0=
x860
[2012-03-20 00:46:33]	LR [c0000000001b523c] .new_slab+0xcc/0x3d0
[2012-03-20 00:46:33]	Call Trace:
[2012-03-20 00:46:33]	[c00000013d887980] [c0000000001683dc]
.__alloc_pages_nodemask+0x15c/0x860 (unreliable)
[2012-03-20 00:46:33]	[c00000013d887b00] [c0000000001b523c] .new_slab+0xcc/=
0x3d0
[2012-03-20 00:46:33]	[c00000013d887bb0] [c0000000007fc780]
.__slab_alloc+0x388/0x4e0
[2012-03-20 00:46:33]	[c00000013d887cd0] [c0000000001b5af8]
.kmem_cache_alloc_node_trace+0x98/0x230
[2012-03-20 00:46:33]	[c00000013d887d90] [c000000000b83ed0]
.numa_init+0x90/0x1d0
[2012-03-20 00:46:33]	[c00000013d887e20] [c00000000000ab60]
.do_one_initcall+0x60/0x1e0
[2012-03-20 00:46:33]	[c00000013d887ee0] [c000000000b5cad4]
.kernel_init+0xf0/0x1e0
[2012-03-20 00:46:33]	[c00000013d887f90] [c000000000021e14]
.kernel_thread+0x54/0x70
[2012-03-20 00:46:33]	Instruction dump:
[2012-03-20 00:46:33]	0b000000 eb1e8000 3ba00000 801800a8 2f800000
409e001c 7860efe3 38000000
[2012-03-20 00:46:33]	41820008 38000002 7b7d6fe2 7fbd0378 <e81a0008>
827800a4 3be00000 2fa00000
[2012-03-20 00:46:33]	---[ end trace 31fd0ba7d8756001 ]---
[2012-03-20 00:46:33]=09
[2012-03-20 00:46:35]	swapper/0 used greatest stack depth: 10832 bytes left
[2012-03-20 00:46:35]	Kernel panic - not syncing: Attempted to kill init!
[2012-03-20 00:46:48]	Rebooting in 10 seconds..

I can debug more next week, let me know if there is something specific
you want me to look at.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

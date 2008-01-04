Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m040XfN2026241
	for <linux-mm@kvack.org>; Thu, 3 Jan 2008 19:33:41 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m040XcBo119972
	for <linux-mm@kvack.org>; Thu, 3 Jan 2008 17:33:41 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m040XcCu004309
	for <linux-mm@kvack.org>; Thu, 3 Jan 2008 17:33:38 -0700
Date: Thu, 3 Jan 2008 16:33:36 -0800
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [BUG]  at mm/slab.c:3320
Message-ID: <20080104003336.GA2594@us.ibm.com>
References: <20071220100541.GA6953@skywalker> <20071225140519.ef8457ff.akpm@linux-foundation.org> <20071227153235.GA6443@skywalker> <Pine.LNX.4.64.0712271130200.30555@schroedinger.engr.sgi.com> <20071228051959.GA6385@skywalker> <Pine.LNX.4.64.0801021227580.20331@schroedinger.engr.sgi.com> <20080103155046.GA7092@skywalker>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080103155046.GA7092@skywalker>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, lee.schermerhorn@hp.com, bob.picco@hp.com, kamezawa.hiroyu@jp.fujitsu.com, mel@skynet.ie
List-ID: <linux-mm.kvack.org>

On 03.01.2008 [21:20:46 +0530], Aneesh Kumar K.V wrote:
> On Wed, Jan 02, 2008 at 12:32:42PM -0800, Christoph Lameter wrote:
> > 
> > This occurred on a 32 bit NUMA platform? Guess NUMAQ? 

Not NUMA-Q afaict, but 32-bit, yes. It's unclear what's going on with
this box, actually. Clearly the kernel detected NUMA; however the
listing in our testing grid does not indicate any NUMA nodes per sysfs,
I don't think. And in fact what the kernel detected doesn't necessarily
mesh with a normal NUMA system.

Does reverting this patch actually make the box boot? What was the last
kernel that worked on this box?

> > The dmesg that I saw was partial. Could you repost a full problem 
> > description to linux-mm@kvack.org and cc the authors of memoryless node 
> > support?
> > 
> > Nishanth Aravamudan <nacc@us.ibm.com>
> > Lee Schermerhorn <lee.schermerhorn@hp.com>
> > Bob Picco <bob.picco@hp.com>
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Mel Gorman <mel@skynet.ie>
> > Christoph Lameter <clameter@sgi.com>
> > 
> Full dmesg:
> ----------
> Booting 'autobench'
> 
> root (hd0,0)
>  Filesystem type is ext2fs, partition type 0x83
> kernel /boot/vmlinuz-autobench ro console=tty0 console=ttyS0,115200 autobench_a
> rgs: root=/dev/sda3 ABAT:1198144312
>    [Linux-bzImage, setup=0x2800, size=0x1a08e8]
> initrd /boot/initrd-autobench.img
>    [Linux-initrd @ 0x37ed8000, 0x117985 bytes]
> 
> Linux version 2.6.24-rc5-autokern1 (root@elm3a23) (gcc version 3.4.6 20060404 (Red Hat 3.4.6-9)) #1 SMP PREEMPT Thu Dec 20 04:16:18 EST 2007

<snip>

> Node: 0, start_pfn: 0, end_pfn: 156
> Node: 0, start_pfn: 256, end_pfn: 917393
> Node: 0, start_pfn: 1048576, end_pfn: 2752512

Hrm, this indicates 1 node with holes?

> get_memcfg_from_srat: assigning address to rsdp
> RSD PTR  v0 [IBM   ]
> Begin SRAT table scan....
> CPU 0x00 in proximity domain 0x00
> CPU 0x02 in proximity domain 0x00
> CPU 0x10 in proximity domain 0x00
> CPU 0x12 in proximity domain 0x00
> Memory range 0x0 to 0xE0000 (type 0x0) in proximity domain 0x00 enabled
> Memory range 0x100000 to 0x120000 (type 0x0) in proximity domain 0x00 enabled
> CPU 0x20 in proximity domain 0x01
> CPU 0x22 in proximity domain 0x01
> CPU 0x30 in proximity domain 0x01
> CPU 0x32 in proximity domain 0x01
> Memory range 0x120000 to 0x2A0000 (type 0x0) in proximity domain 0x01 enabled
> acpi20_parse_srat: Entry length value is zero; can't parse any further!

But two proximity domains (NUMA nodes?) according to SRAT? And then we
get a parse error?

> pxm bitmap: 03 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
> Number of logical nodes in system = 2

So we had 1 physical node above, but now we have 2 logical nodes?

> Number of memory chunks in system = 3
> chunk 0 nid 0 start_pfn 00000000 end_pfn 000e0000
> chunk 1 nid 0 start_pfn 00100000 end_pfn 00120000
> chunk 2 nid 1 start_pfn 00120000 end_pfn 002a0000
> Node: 0, start_pfn: 0, end_pfn: 1179648
> Node: 1, start_pfn: 1179648, end_pfn: 2752512

(side nit: why don't we always print in hex here?)

> Reserving 16384 pages of KVA for lmem_map of node 0
> Shrinking node 0 from 1179648 pages to 1163264 pages
> Reserving 22016 pages of KVA for lmem_map of node 1
> Shrinking node 1 from 2752512 pages to 2730496 pages
> Reserving total of 38400 pages for numa KVA remap
> kva_start_pfn ~ 190464 find_max_low_pfn() ~ 229376
> max_pfn = 2752512
> 9856MB HIGHMEM available.
> 896MB LOWMEM available.
> min_low_pfn = 1945, max_low_pfn = 229376, highstart_pfn = 229376
> Low memory ends at vaddr f8000000
> node 0 will remap to vaddr ee800000 - fc000000
> node 1 will remap to vaddr f2800000 - 01600000

And we have two nodes from here on out...

> High memory starts at vaddr f8000000
> found SMP MP-table at 0009c540
> Zone PFN ranges:
>   DMA             0 ->     4096
>   Normal       4096 ->   229376
>   HighMem    229376 ->  2752512
> Movable zone start PFN for each node
> early_node_map[3] active PFN ranges
>     0:        0 ->   917504
>     0:  1048576 ->  1163264
>     1:  1179648 ->  2730496

with holes as before.

<snip>

> Calibrating delay using timer specific routine.. 4002.61 BogoMIPS (lpj=8005239)
> ------------[ cut here ]------------
> kernel BUG at mm/slab.c:3320!
> invalid opcode: 0000 [#1] PREEMPT SMP 
> Modules linked in:
> 
> Pid: 0, comm: swapper Not tainted (2.6.24-rc5-autokern1 #1)
> EIP: 0060:[<c0181707>] EFLAGS: 00010046 CPU: 0
> EIP is at ____cache_alloc_node+0x1c/0x130
> EAX: ee4005c0 EBX: 00000000 ECX: 00000001 EDX: 000000d0
> ESI: 00000000 EDI: ee4005c0 EBP: c0408f74 ESP: c0408f54
>  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
> Process swapper (pid: 0, ti=c0408000 task=c03d5d80 task.ti=c0408000)
> Stack: c03d5d80 c0408f6c c017ac36 00000001 000000d0 00000000 000000d0 ee4005c0 
>        c0408f88 c0181577 0001080c 00000246 ee4005c0 c0408fa8 c0181a97 c0408fb0 
>        c01395b9 000000d0 0001080c 00099800 c03dccec c0408fd0 c01395b9 c0408fd0 
> Call Trace:
>  [<c0105e23>] show_trace_log_lvl+0x19/0x2e
>  [<c0105ee5>] show_stack_log_lvl+0x99/0xa1
>  [<c010603f>] show_registers+0xb3/0x1e9
>  [<c0106301>] die+0x11b/0x1fe
>  [<c02fb654>] do_trap+0x8e/0xa8
>  [<c01065cd>] do_invalid_op+0x88/0x92
>  [<c02fb422>] error_code+0x72/0x78
>  [<c0181577>] alternate_node_alloc+0x5b/0x60
>  [<c0181a97>] kmem_cache_alloc+0x50/0x120
>  [<c01395b9>] create_pid_cachep+0x4c/0xec
>  [<c041ae65>] pidmap_init+0x2f/0x6e
>  [<c040c715>] start_kernel+0x1ca/0x23e
>  [<00000000>] 0x0
>  =======================
> Code: ff eb 02 31 ff 89 f8 83 c4 10 5b 5e 5f 5d c3 55 89 e5 57 89 c7 56 53 83 ec 14 89 55 f0 89 4d ec 8b b4 88 88 02 00 00 85 f6 75 04 <0f> 0b eb fe e8 f3 ee ff ff 8d 46 24 89 45 e4 e8 23 97 17 00 8b 
> EIP: [<c0181707>] ____cache_alloc_node+0x1c/0x130 SS:ESP 0068:c0408f54
> Kernel panic - not syncing: Attempted to kill the idle task!
> -- 0:conmux-control -- time-stamp -- Dec/20/07  2:00:36 --
> (bot:conmon-payload) disconnected
> 
> 
> dmidecode output for machine details
> ----------------------------------

<snip>

The DMI information seems to indicate also that there is only one node
(Node 1)?

I'll try and reproduce on the box and investigate further.

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 86C546B004D
	for <linux-mm@kvack.org>; Fri,  5 Mar 2010 00:01:35 -0500 (EST)
Message-ID: <4B908FF3.5000303@kernel.org>
Date: Thu, 04 Mar 2010 21:00:35 -0800
From: Yinghai Lu <yinghai@kernel.org>
MIME-Version: 1.0
Subject: Re: mmotm boot panic bootmem-avoid-dma32-zone-by-default.patch
References: <49b004811003041321g2567bac8yb73235be32a27e7c@mail.gmail.com> <20100305032106.GA12065@cmpxchg.org>
In-Reply-To: <20100305032106.GA12065@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Greg Thelen <gthelen@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 03/04/2010 07:21 PM, Johannes Weiner wrote:
> Hello Greg,
> 
> On Thu, Mar 04, 2010 at 01:21:41PM -0800, Greg Thelen wrote:
>> On several systems I am seeing a boot panic if I use mmotm
>> (stamp-2010-03-02-18-38).  If I remove
>> bootmem-avoid-dma32-zone-by-default.patch then no panic is seen.  I
>> find that:
>> * 2.6.33 boots fine.
>> * 2.6.33 + mmotm w/o bootmem-avoid-dma32-zone-by-default.patch: boots fine.
>> * 2.6.33 + mmotm (including
>> bootmem-avoid-dma32-zone-by-default.patch): panics.
>> Note: I had to enable earlyprintk to see the panic.  Without
>> earlyprintk no console output was seen.  The system appeared to hang
>> after the loader.
> 
> Thanks for your report.  A few notes below.
> 
>> Here's the panic seen with earlyprintk using 2.6.33 + mmotm:
>>
>> Starting up ...
>> [    0.000000] Initializing cgroup subsys cpuset
>> [    0.000000] Initializing cgroup subsys cpu
>> [    0.000000] Linux version 2.6.33-mm1+
>> (gthelen@ninji.mtv.corp.google.com) (gcc version 4.2.4 (Ubuntu
>> 4.2.4-1ubuntu4)) #1 SMP Thu Mar 4 12:03:29 PST 2010
>> [    0.000000] Command line:
>> root=UUID=a77f406a-7cc7-4f49-9cc2-818b2b4159ae ro console=tty0
>> console=ttyS0,115200n8 earlyprintk=serial,ttyS0,9600
>> [    0.000000] BIOS-provided physical RAM map:
>> [    0.000000]  BIOS-e820: 0000000000000000 - 000000000009fc00 (usable)
>> [    0.000000]  BIOS-e820: 000000000009fc00 - 00000000000a0000 (reserved)
>> [    0.000000]  BIOS-e820: 00000000000e8000 - 0000000000100000 (reserved)
>> [    0.000000]  BIOS-e820: 0000000000100000 - 000000000fff0000 (usable)
>> [    0.000000]  BIOS-e820: 000000000fff0000 - 0000000010000000 (ACPI data)
>> [    0.000000]  BIOS-e820: 00000000fffbd000 - 0000000100000000 (reserved)
>> [    0.000000] bootconsole [earlyser0] enabled
>> [    0.000000] NX (Execute Disable) protection: active
>> [    0.000000] DMI 2.4 present.
>> [    0.000000] No AGP bridge found
>> [    0.000000] last_pfn = 0xfff0 max_arch_pfn = 0x400000000
>> [    0.000000] PAT not supported by CPU.
>> [    0.000000] CPU MTRRs all blank - virtualized system.
>> [    0.000000] Scanning 1 areas for low memory corruption
>> [    0.000000] modified physical RAM map:
>> [    0.000000]  modified: 0000000000000000 - 0000000000010000 (reserved)
>> [    0.000000]  modified: 0000000000010000 - 000000000009fc00 (usable)
>> [    0.000000]  modified: 000000000009fc00 - 00000000000a0000 (reserved)
>> [    0.000000]  modified: 00000000000e8000 - 0000000000100000 (reserved)
>> [    0.000000]  modified: 0000000000100000 - 000000000fff0000 (usable)
>> [    0.000000]  modified: 000000000fff0000 - 0000000010000000 (ACPI data)
>> [    0.000000]  modified: 00000000fffbd000 - 0000000100000000 (reserved)
>> [    0.000000] init_memory_mapping: 0000000000000000-000000000fff0000
> 
> 256MB of memory, right?
> 
>> [    0.000000] RAMDISK: 0fd9d000 - 0ffdf539
>> [    0.000000] ACPI: RSDP 00000000000fb450 00014 (v00 QEMU  )
>> [    0.000000] ACPI: RSDT 000000000fff0000 00030 (v01 QEMU   QEMURSDT
>> 00000001 QEMU 00000001)
>> [    0.000000] ACPI: FACP 000000000fff0030 00074 (v01 QEMU   QEMUFACP
>> 00000001 QEMU 00000001)
>> [    0.000000] ACPI: DSDT 000000000fff0100 0089D (v01   BXPC   BXDSDT
>> 00000001 INTL 20061109)
>> [    0.000000] ACPI: FACS 000000000fff00c0 00040
>> [    0.000000] ACPI: APIC 000000000fff09d8 00068 (v01 QEMU   QEMUAPIC
>> 00000001 QEMU 00000001)
>> [    0.000000] ACPI: SSDT 000000000fff099d 00037 (v01 QEMU   QEMUSSDT
>> 00000001 QEMU 00000001)
>> [    0.000000] No NUMA configuration found
>> [    0.000000] Faking a node at 0000000000000000-000000000fff0000
>> [    0.000000] Initmem setup node 0 0000000000000000-000000000fff0000
>> [    0.000000]   NODE_DATA [0000000001c4e040 - 0000000001c5303f]
>> [    0.000000] BUG: unable to handle kernel NULL pointer dereference at (null)
>> [    0.000000] IP: [<ffffffff81b0f5f7>] memory_present+0x9a/0xbf
>> [    0.000000] PGD 0
>> [    0.000000] Oops: 0000 [#1] SMP
>> [    0.000000] last sysfs file:
>> [    0.000000] CPU 0
>> [    0.000000] Modules linked in:
>> [    0.000000]
>> [    0.000000] Pid: 0, comm: swapper Not tainted 2.6.33-mm1+ #1 /
>> [    0.000000] RIP: 0010:[<ffffffff81b0f5f7>]  [<ffffffff81b0f5f7>]
>> memory_present+0x9a/0xbf
>> [    0.000000] RSP: 0000:ffffffff81a01e18  EFLAGS: 00010046
>> [    0.000000] RAX: 0000000000000000 RBX: 0000000000000000 RCX: 0000000000000002
>> [    0.000000] RDX: 0000000000000000 RSI: 0000000000000040 RDI: 0000000000000000
>> [    0.000000] RBP: ffffffff81a01e58 R08: ffffffffffffffff R09: 0000000000000040
>> [    0.000000] R10: ffff880001c4e040 R11: 0000000000004100 R12: 0000000000000000
>> [    0.000000] R13: 0000000000000000 R14: 0000000000000001 R15: 0000000000000000
>> [    0.000000] FS:  0000000000000000(0000) GS:ffffffff81adf000(0000)
>> knlGS:0000000000000000
>> [    0.000000] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> [    0.000000] CR2: 0000000000000000 CR3: 0000000001a08000 CR4: 00000000000000b0
>> [    0.000000] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>> [    0.000000] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
>> [    0.000000] Process swapper (pid: 0, threadinfo ffffffff81a00000,
>> task ffffffff81a10020)
>> [    0.000000] Stack:
>> [    0.000000]  000000000fff0000 000000000000009f 0000000000000000
>> 0000000000000000
>> [    0.000000] <0> 0000000000000040 ffffffff81a01ef8 0000000000000000
>> 0000000000000000
>> [    0.000000] <0> ffffffff81a01e78 ffffffff81b0dd0e ffffffff81a01e88
>> 000000000fff0000
>> [    0.000000] Call Trace:
>> [    0.000000]  [<ffffffff81b0dd0e>]
>> sparse_memory_present_with_active_regions+0x31/0x47
>> [    0.000000]  [<ffffffff81b0688a>] paging_init+0x3f/0x5b
>> [    0.000000]  [<ffffffff81af81a7>] setup_arch+0x964/0xa03
>> [    0.000000]  [<ffffffff8103014a>] ? need_resched+0x1e/0x28
>> [    0.000000]  [<ffffffff8103015d>] ? should_resched+0x9/0x2a
>> [    0.000000]  [<ffffffff8152de24>] ? _cond_resched+0x9/0x1d
>> [    0.000000]  [<ffffffff81af4a34>] start_kernel+0x9f/0x382
>> [    0.000000]  [<ffffffff81af4299>] x86_64_start_reservations+0xa9/0xad
>> [    0.000000]  [<ffffffff81af4383>] x86_64_start_kernel+0xe6/0xed
>> [    0.000000] Code: c7 00 56 c2 81 e8 a0 f9 a1 ff 48 83 3c dd 00 16
>> c2 81 00 75 08 4c 89 2c dd 00 16 c2 81 fe 05 11 60 11 00 4c 89 ff e8
>> 85 3b 5c ff <48> 83 38 00 75 03 4c 89 30 49 81 c4 00 80 00 00 4c 3b 65
>> c8 72
>> [    0.000000] RIP  [<ffffffff81b0f5f7>] memory_present+0x9a/0xbf
>> [    0.000000]  RSP <ffffffff81a01e18>
>> [    0.000000] CR2: 0000000000000000
>> [    0.000000] ---[ end trace 4eaa2a86a8e2da22 ]---
>> [    0.000000] Kernel panic - not syncing: Attempted to kill the idle task!
>> [    0.000000] Pid: 0, comm: swapper Tainted: G      D    2.6.33-mm1+ #1
>> [    0.000000] Call Trace:
>> [    0.000000]  [<ffffffff8103c78c>] panic+0x9e/0x113
>> [    0.000000]  [<ffffffff8103d3d6>] ? printk+0x67/0x69
>> [    0.000000]  [<ffffffff8105914e>] ? blocking_notifier_call_chain+0xf/0x11
>> [    0.000000]  [<ffffffff8103f8b4>] do_exit+0x78/0x70f
>> [    0.000000]  [<ffffffff8103ca2f>] ? spin_unlock_irqrestore+0x9/0xb
>> [    0.000000]  [<ffffffff8103dcde>] ? kmsg_dump+0x112/0x138
>> [    0.000000]  [<ffffffff81530061>] oops_end+0xb2/0xba
>> [    0.000000]  [<ffffffff810258d3>] no_context+0x1f5/0x204
>> [    0.000000]  [<ffffffff81025b1b>] __bad_area_nosemaphore+0x17f/0x1a2
>> [    0.000000]  [<ffffffff81025bb4>] bad_area_nosemaphore+0xe/0x10
>> [    0.000000]  [<ffffffff81531e36>] do_page_fault+0x122/0x24c
>> [    0.000000]  [<ffffffff8152f59f>] page_fault+0x1f/0x30
>> [    0.000000]  [<ffffffff81b0f5f7>] ? memory_present+0x9a/0xbf
>> [    0.000000]  [<ffffffff81b0f5f7>] ? memory_present+0x9a/0xbf
>> [    0.000000]  [<ffffffff81b0dd0e>]
>> sparse_memory_present_with_active_regions+0x31/0x47
>> [    0.000000]  [<ffffffff81b0688a>] paging_init+0x3f/0x5b
>> [    0.000000]  [<ffffffff81af81a7>] setup_arch+0x964/0xa03
>> [    0.000000]  [<ffffffff8103014a>] ? need_resched+0x1e/0x28
>> [    0.000000]  [<ffffffff8103015d>] ? should_resched+0x9/0x2a
>> [    0.000000]  [<ffffffff8152de24>] ? _cond_resched+0x9/0x1d
>> [    0.000000]  [<ffffffff81af4a34>] start_kernel+0x9f/0x382
>> [    0.000000]  [<ffffffff81af4299>] x86_64_start_reservations+0xa9/0xad
>> [    0.000000]  [<ffffffff81af4383>] x86_64_start_kernel+0xe6/0xed
>>
>> The kernel was built with 'make mrproper && make defconfig && make
>> ARCH=x86_64 CONFIG=smp -j 6'.  This panic is seen on every attempt, so
>> I can provide more diagnostics.
> 
> Okay, if you did defconfig and just hit enter to all questions, you
> should have SPARSEMEM_EXTREME and NO_BOOTMEM enabled.  This means that
> the 'mem_section' is an array of pointers and the following happens in
> memory_present():
> 
> 	for_one_pfn_in_each_section() {
> 		sparse_index_init(); /* no return value check */
> 		ms = __nr_to_section();
> 		if (!ms->section_mem_map) /* bang */
> 			...;
> 	}
> 
> where sparse_index_init(), in the SPARSEMEM_EXTREME case, will allocate
> the mem_section descriptor with bootmem.  If this would fail, the box
> would panic immediately earlier, but NO_BOOTMEM does not seem to get it
> right.
> 
> Greg, could you retry _with_ my bootmem patch applied, but with setting
> CONFIG_NO_BOOTMEM=n up front?
> 
> I think NO_BOOTMEM has several problems.  Yinghai, can you verify them?
> 
> 1. It does not seem to handle goal appropriately: bootmem would try
> without the goal if it does not make sense.  And in this case, the
> goal is 4G (above DMA32) and the amount of memory is 256M.
> 
> And if I did not miss something, this is the difference with my patch:
> without it, the default goal is 16M, which is no problem as it is well
> within your available memory.  But the change of the default goal moved
> it outside it which the bootmem replacement can not handle.
> 
> 2. The early reservation stuff seems to return NULL but callsites assume
> that the bootmem interface never does that.  Okay, the result is the same,
> we crash.  But it still moves error reporting to a possibly much later
> point where somebody actually dereferences the returned pointer.

related change could be: __alloc_bootmem_node_high...

void * __init __alloc_bootmem_node_high(pg_data_t *pgdat, unsigned long size,
                                   unsigned long align, unsigned long goal)
{
#ifdef MAX_DMA32_PFN
        unsigned long end_pfn;

        if (WARN_ON_ONCE(slab_is_available()))
                return kzalloc_node(size, GFP_NOWAIT, pgdat->node_id);

        /* update goal according ...MAX_DMA32_PFN */
        end_pfn = pgdat->node_start_pfn + pgdat->node_spanned_pages;

        if (end_pfn > MAX_DMA32_PFN + (128 >> (20 - PAGE_SHIFT)) &&
            (goal >> PAGE_SHIFT) < MAX_DMA32_PFN) {
                void *ptr; 
                unsigned long new_goal;
                                
                new_goal = MAX_DMA32_PFN << PAGE_SHIFT;
#ifdef CONFIG_NO_BOOTMEM
                ptr =  __alloc_memory_core_early(pgdat->node_id, size, align,
                                                 new_goal, -1ULL);
#else
                ptr = alloc_bootmem_core(pgdat->bdata, size, align,
                                                 new_goal, 0);
#endif
                if (ptr)
                        return ptr;
        }
#endif

        return __alloc_bootmem_node(pgdat, size, align, goal);

}

also __alloc_bootmem_node will not fallback...if you specify one big goal.

static void * __init_refok __earlyonly_bootmem_alloc(int node,
                                unsigned long size,
                                unsigned long align,
                                unsigned long goal)
{       
        return __alloc_bootmem_node_high(NODE_DATA(node), size, align, goal);
}
        
static void *vmemmap_buf;
static void *vmemmap_buf_end;
                
void * __meminit vmemmap_alloc_block(unsigned long size, int node)
{               
        /* If the main allocator is up use that, fallback to bootmem. */
        if (slab_is_available()) {
                struct page *page;               

                if (node_state(node, N_HIGH_MEMORY))
                        page = alloc_pages_node(node,
                                GFP_KERNEL | __GFP_ZERO, get_order(size));
                else
                        page = alloc_pages(GFP_KERNEL | __GFP_ZERO,
                                get_order(size));
                if (page)
                        return page_address(page);
                return NULL;
        } else
                return __earlyonly_bootmem_alloc(node, size, size,
                                __pa(MAX_DMA_ADDRESS));
}

so you patch change the goal in vmemmap_alloc_block ?

YH

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

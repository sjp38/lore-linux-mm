Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 0B20D6B0253
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 12:25:36 -0500 (EST)
Received: by pabur14 with SMTP id ur14so15097773pab.0
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 09:25:35 -0800 (PST)
Received: from mail1.bemta12.messagelabs.com (mail1.bemta12.messagelabs.com. [216.82.251.11])
        by mx.google.com with ESMTPS id o90si6390394pfi.73.2015.12.08.09.25.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 09:25:35 -0800 (PST)
Message-ID: <5667128B.3080704@sigmadesigns.com>
Date: Tue, 8 Dec 2015 18:25:31 +0100
From: Sebastian Frias <sebastian_frias@sigmadesigns.com>
MIME-Version: 1.0
Subject: m(un)map kmalloc buffers to userspace
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>, linux-kernel@vger.kernel.org

Hi,

We are porting a driver from Linux 3.4.39+ to 4.1.13+, CPU is Cortex-A9.

The driver maps kmalloc'ed memory to user space.
The usermode sees a contiguous space, although in reality it could span 
several chunks of memory allocated with separate calls to kmalloc.
For simplicity, the below example supposes a single chunk of kmalloc is 
mmaped (the problem does not seems to lie on the partition, but on the 
handling of page faults and/or mapping)

[driver]   : kmalloc(size) some buffer: "kaddr"
[usermode] : umvaddr = mmap(NULL, size, PROT_READ|PROT_WRITE, 
MAP_SHARED, fd, some_offset);
NOTE: "some_offset" is used to encode some flags for the driver
[driver]   : the driver's mmap would do:
              - vma->vm_page_prot = pgprot_noncached(*prot)
              - setup vma->vm_ops with a .fault handler
              - vma->vm_flags |= VM_RESERVED
              - store 'start' (which will equal "umvaddr")
              the .fault handler is setup to:
              - determine if the fault is on a virtual address that's 
supposed to map to "kaddr", if yes:
                - page = virt_to_page((kaddr + (vmf->virtual_address - 
vma->vm_start)) & PAGE_MASK)
                - get_page(page); (for whatever reason, there are 
actually two successive calls to "get_page()")
                - vmf->page = page and return VM_FAULT_MINOR;
[usermode]  : will use "umvaddr"

That worked just fine on 3.4 and earlier, but it is causing crashes on 
4.1.13+.
The crash happens as soon as the usermode tries to write (reading from a 
file) into "umvaddr" buffer (see further below for the log).
However, it does not happens 100% of the time, sometimes we don't get a 
crash, like if we were missing some initialisation?

Since VM_RESERVED was removed, we redefined it to VM_IO | VM_DONTEXPAND 
| VM_DONTDUMP (see 
http://thread.gmane.org/gmane.linux.kernel/1335615/focus=1335625)

Questions:
1) Do you guys see something wrong in the above scenario?
2) Now that VM_RESERVED was removed, is there another recommended flag 
to replace it for the purposes above?
3) Since it was working before, we suppose that something that was 
previously done by default on the kernel it is not done anymore, could 
that be a remap_pfn_range during mmap or kmalloc?
4) We tried using remap_pfn_range inside mmap and while it seems to 
work, we still get occasional crashes due to corrupted memory (in this 
case the behaviour is the same between 4.1 and 3.4 when using the same 
modified driver), are we missing something?

Thanks in advance,


Crash log:
[  194.330390] page fault for umvaddr=0xb597a000, kvaddr=0xe6580000
[  194.335389] page 0xe7fc4000
[  194.350169] Unable to handle kernel paging request at virtual address 
90ed1d49
[  194.357445] pgd = e777c000
[  194.360162] [90ed1d49] *pgd=00000000
[  194.363773] Internal error: Oops: 5 [#1] PREEMPT SMP ARM
[  194.369109] Modules linked in: em8xxx(PO) llad(PO) [last unloaded: llad]
[  194.375862] CPU: 1 PID: 1161 Comm: test_rmfp Tainted: P           O 
4.1.13+ #2
[  194.383382] Hardware name: Sigma Tango DT
[  194.387409] task: e6c97180 ti: e6e84000 task.ti: e6e84000
[  194.392846] PC is at inode_to_bdi+0x14/0x4c
[  194.397055] LR is at balance_dirty_pages_ratelimited+0x1c/0x7f4
[  194.403004] pc : [<c00efda4>]    lr : [<c00a1864>]    psr: a00e0013
[  194.403004] sp : e6e85ba8  ip : e6e85bc0  fp : e6e85bbc
[  194.414543] r10: 00000000  r9 : e6e2d5e8  r8 : 0000017a
[  194.419791] r7 : e6580000  r6 : e762bce8  r5 : 90ed1d35  r4 : e6580000
[  194.426349] r3 : e7fc4000  r2 : 00000000  r1 : e7fc4000  r0 : 90ed1d35
[  194.432908] Flags: NzCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM 
Segment user
[  194.440078] Control: 10c5387d  Table: a777c04a  DAC: 00000015
[  194.445850] Process test_rmfp (pid: 1161, stack limit = 0xe6e84218)
[  194.452147] Stack: (0xe6e85ba8 to 0xe6e86000)
[  194.456525] 5ba0:                   e6580000 e6e2d000 e6e85c34 
e6e85bc0 c00a1864 c00efd9c
[  194.464748] 5bc0: bf0227b8 bf021ad0 e7fc4000 e7fc4010 00000000 
c0444084 e6e85c44
...(snipped)...
[  194.744251] Backtrace:
[  194.746718] [<c00efd90>] (inode_to_bdi) from [<c00a1864>] 
(balance_dirty_pages_ratelimited+0x1c/0x7f4)
[  194.756071]  r5:e6e2d000 r4:e6580000
[  194.759671] [<c00a1848>] (balance_dirty_pages_ratelimited) from 
[<c00b79bc>] (handle_mm_fault+0x230/0x104c)
[  194.769461]  r10:00000000 r9:e6e2d5e8 r8:0000017a r7:b597a000 
r6:e762bce8 r5:e6e2d000
[  194.777346]  r4:e6580000
[  194.779894] [<c00b778c>] (handle_mm_fault) from [<c00221a4>] 
(do_page_fault+0x1cc/0x370)
[  194.788024]  r10:00000015 r9:e6d1d078 r8:b597a000 r7:e6c97180 
r6:00000817 r5:e6d1d040
[  194.795908]  r4:e6e85dc8
[  194.798455] [<c0021fd8>] (do_page_fault) from [<c000928c>] 
(do_DataAbort+0x40/0xc0)
[  194.806148]  r10:b597a000 r9:00001000 r8:e6e85dc8 r7:c0447334 
r6:b597a000 r5:c0021fd8
[  194.814030]  r4:00000817
[  194.816579] [<c000924c>] (do_DataAbort) from [<c00193d8>] 
(__dabt_svc+0x38/0x60)
[  194.824010] Exception stack(0xe6e85dc8 to 0xe6e85e10)
[  194.829086] 5dc0:                   00008000 00000000 00000000 
e7f7b020 e6e85efc 00001000
[  194.837307] 5de0: 00000000 e6e85ef4 00000000 00001000 b597a000 
e6e85e44 00000000 e6e85e10
[  194.845525] 5e00: c009970c c019e0f4 200f0013 ffffffff
[  194.850597]  r8:00000000 r7:e6e85dfc r6:ffffffff r5:200f0013 r4:c019e0f4
[  194.857353] [<c019e090>] (copy_page_to_iter) from [<c009970c>] 
(generic_file_read_iter+0x324/0x66c)
[  194.866442]  r10:e7f7b020 r9:e6daf940 r8:00000000 r7:00000000 
r6:e71d2e90 r5:e71d2f5c
[  194.874323]  r4:00001000
[  194.876874] [<c00993e8>] (generic_file_read_iter) from [<c01365a8>] 
(nfs_file_read+0x48/0x8c)
[  194.885440]  r10:00000000 r9:b597a000 r8:00008000 r7:e6e85f78 
r6:e6e85efc r5:e71d2e90
[  194.893322]  r4:e6e85f10
[  194.895872] [<c0136560>] (nfs_file_read) from [<c00cae90>] 
(__vfs_read+0xb0/0xd8)
[  194.903390]  r6:e6daf940 r5:00000000 r4:00000000 r3:c0136560
[  194.909089] [<c00cade0>] (__vfs_read) from [<c00cb548>] 
(vfs_read+0x7c/0xa0)
[  194.916170]  r8:00008000 r7:e6daf940 r6:e6e85f78 r5:b597a000 r4:e6daf940
[  194.922920] [<c00cb4cc>] (vfs_read) from [<c00cbb9c>] 
(SyS_read+0x44/0x98)
[  194.929826]  r6:e6daf943 r5:00000000 r4:00000000 r3:e6e85f78
[  194.935530] [<c00cbb58>] (SyS_read) from [<c0014ca0>] 
(ret_fast_syscall+0x0/0x3c)
[  194.943049]  r9:e6e84000 r8:c0014e68 r7:00000003 r6:b6a85000 
r5:be9e5a69 r4:be9dad40
[  194.950849] Code: e92dd830 e24cb004 e2505000 0a000006 (e5954014)
[  194.957132] ---[ end trace 34014c1bf96caa57 ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

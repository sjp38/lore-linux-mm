Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 357BF6B0005
	for <linux-mm@kvack.org>; Thu,  8 Mar 2018 15:35:11 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id p11so5202258qtg.19
        for <linux-mm@kvack.org>; Thu, 08 Mar 2018 12:35:11 -0800 (PST)
Received: from mx0b-00010702.pphosted.com (mx0b-00010702.pphosted.com. [148.163.158.57])
        by mx.google.com with ESMTPS id p13si2096268qtg.378.2018.03.08.12.35.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Mar 2018 12:35:09 -0800 (PST)
From: Gratian Crisan <gratian.crisan@ni.com>
Subject: Kernel page fault in vmalloc_fault() after a preempted ioremap
Date: Thu, 08 Mar 2018 14:34:26 -0600
Message-ID: <87a7vi1f3h.fsf@kerf.amer.corp.natinst.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Toshi Kani <toshi.kani@hpe.com>, Borislav Petkov <bp@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@intel.com>, Brian Gerst <brgerst@gmail.com>, Julia Cartwright <julia.cartwright@ni.com>, gratian@gmail.com

Hi all,

We are seeing kernel page faults happening on module loads with certain
drivers like the i915 video driver[1]. This was initially discovered on
a 4.9 PREEMPT_RT kernel. It takes 5 days on average to reproduce using a
simple reboot loop test. Looking at the code paths involved I believe
the issue is still present in the latest vanilla kernel.

Some relevant points are:

  * x86_64 CPU: Intel Atom E3940

  * CONFIG_HUGETLBFS is not set (which also gates CONFIG_HUGETLB_PAGE)

Based on function traces I was able to gather the sequence of events is:

  1. Driver starts a ioremap operation for a region that is PMD_SIZE in
  size (or PUD_SIZE).

  2. The ioremap() operation is preempted while it's in the middle of
  setting up the page mappings:
  ioremap_page_range->...->ioremap_pmd_range->pmd_set_huge <<preempted>>

  3. Unrelated tasks run. Traces also include some cross core scheduling
  IPI calls.

  4. Driver resumes execution finishes the ioremap operation and tries to
  access the newly mapped IO region. This triggers a vmalloc fault.

  5. The vmalloc_fault() function hits a kernel page fault when trying to
  dereference a non-existent *pte_ref.

The reason this happens is the code paths called from ioremap_page_range()
make different assumptions about when a large page (pud/pmd) mapping can be
used versus the code paths in vmalloc_fault().

Using the PMD sized ioremap case as an example (the PUD case is similar):
ioremap_pmd_range() calls ioremap_pmd_enabled() which is gated by
CONFIG_HAVE_ARCH_HUGE_VMAP. On x86_64 this will return true unless the
"nohugeiomap" kernel boot parameter is passed in.

On the other hand, in the rare case when a page fault happens in the
ioremap'ed region, vmalloc_fault() calls the pmd_huge() function to check
if a PMD page is marked huge or if it should go on and get a reference to
the PTE. However pmd_huge() is conditionally compiled based on the user
configured CONFIG_HUGETLB_PAGE selected by CONFIG_HUGETLBFS. If the
CONFIG_HUGETLBFS option is not enabled pmd_huge() is always defined to be
0.

The end result is an OOPS in vmalloc_fault() when the non-existent pte_ref
is dereferenced because the test for pmd_huge() failed.

Commit f4eafd8bcd52 ("x86/mm: Fix vmalloc_fault() to handle large pages
properly") attempted to fix the mismatch between ioremap() and
vmalloc_fault() with regards to huge page handling but it missed this use
case.

I am working on a simpler reproducing case however so far I've been
unsuccessful in re-creating the conditions that trigger the vmalloc fault
in the first place. Adding explicit scheduling points in
ioremap_pmd_range/pmd_set_huge doesn't seem to be sufficient. Ideas
appreciated.

Any thoughts on what a correct fix would look like? Should the ioremap
code paths respect the HUGETLBFS config or would it be better for the
vmalloc fault code paths to match the tests used in ioremap and not rely
on the HUGETLBFS option being enabled?

Thanks,
    Gratian


[1]

[    3.837847] BUG: unable to handle kernel paging request at ffff8800900003c0
[    3.837855] IP: [<ffffffff81054330>] vmalloc_fault+0x1e5/0x21d
[    3.837857] PGD 1f20067
[    3.837857] PUD 0
[    3.837858]
[    3.837860] Oops: 0000 [#1] PREEMPT SMP
[    3.837880] Modules linked in: i915(+) dwc3 udc_core nichenumk(PO) nifslk(PO) nimdbgk(PO) niorbk(PO) nipalk(PO) intel_gtt drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops drm igb atomicchinchk(PO) coretemp i2c_i801 nibds(PO) i2c_smbus nikal(PO) i2c_algo_bit dwc3_pci agpgart video tpm_tis backlight tpm_tis_core tpm button fuse
[    3.837885] CPU: 1 PID: 238 Comm: udevd Tainted: P           O    4.9.33-rt23-5.6.0d60 #1
[    3.837886] Hardware name: National Instruments NI cRIO-9042/NI cRIO-9042, BIOS 5.12 09/04/2017
[    3.837887] task: ffff880179137080 task.stack: ffffc90001154000
[    3.837891] RIP: 0010:[<ffffffff81054330>]  [<ffffffff81054330>] vmalloc_fault+0x1e5/0x21d
[    3.837892] RSP: 0018:ffffc900011578e8  EFLAGS: 00010006
[    3.837893] RAX: 00003ffffffff000 RBX: ffff8800000003c0 RCX: 80000000900001f3
[    3.837894] RDX: 80000000900001f3 RSI: ffff880000000000 RDI: 00003fffffe00000
[    3.837895] RBP: ffffc900011578f8 R08: 0000000090000000 R09: 0000000090000000
[    3.837896] R10: 0000000000000080 R11: 0000000000000080 R12: ffffc90001278000
[    3.837897] R13: ffffc900011579a8 R14: ffff880179b3a400 R15: 0000000000000048
[    3.837899] FS:  00007f7b7942f880(0000) GS:ffff88017fc80000(0000) knlGS:0000000000000000
[    3.837900] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[    3.837901] CR2: ffff8800900003c0 CR3: 0000000179207000 CR4: 00000000003406e0
[    3.837902] Stack:
[    3.837906]  0000000000000000 0000000000000000 ffffc90001157968 ffffffff810449f3
[    3.837909]  ffffc90001200000 ffffc90001400000 8000000000000173 0000000000000246
[    3.837911]  ffff880179b3a498 ffff880179137080 ffffc90001157958 0000000000000000
[    3.837912] Call Trace:
[    3.837919]  [<ffffffff810449f3>] __do_page_fault+0x313/0x420
[    3.837922]  [<ffffffff81044b55>] do_page_fault+0x25/0x70
[    3.837925]  [<ffffffff8105fb03>] ? iomem_map_sanity_check+0x93/0xd0
[    3.837930]  [<ffffffff815e1632>] page_fault+0x22/0x30
[    3.837994]  [<ffffffffa082350c>] ? i915_check_vgpu+0xc/0x80 [i915]
[    3.838048]  [<ffffffffa07c0dfa>] ? intel_uncore_init+0x1a/0x5c0 [i915]
[    3.838092]  [<ffffffffa075f28d>] i915_driver_load+0x73d/0x14d0 [i915]
[    3.838096]  [<ffffffff811ff596>] ? kernfs_add_one+0xf6/0x150
[    3.838141]  [<ffffffffa076aa0d>] i915_pci_probe+0x2d/0x50 [i915]
[    3.838145]  [<ffffffff8133fded>] local_pci_probe+0x2d/0x70
[    3.838147]  [<ffffffff813406a0>] pci_device_probe+0xd0/0x100
[    3.838152]  [<ffffffff81406518>] driver_probe_device+0xd8/0x280
[    3.838154]  [<ffffffff81406765>] __driver_attach+0xa5/0xb0
[    3.838157]  [<ffffffff814066c0>] ? driver_probe_device+0x280/0x280
[    3.838159]  [<ffffffff8140471a>] bus_for_each_dev+0x5a/0x90
[    3.838161]  [<ffffffff81405e5e>] driver_attach+0x1e/0x20
[    3.838163]  [<ffffffff81405ba0>] bus_add_driver+0x120/0x230
[    3.838166]  [<ffffffff81406e10>] driver_register+0x60/0xe0
[    3.838169]  [<ffffffff8134008e>] __pci_register_driver+0x7e/0x90
[    3.838171]  [<ffffffffa0895000>] ? 0xffffffffa0895000
[    3.838216]  [<ffffffffa089505a>] i915_init+0x5a/0x5e [i915]
[    3.838221]  [<ffffffff81000406>] do_one_initcall+0x46/0x160
[    3.838226]  [<ffffffff8112dea2>] ? do_init_module+0x29/0x1dd
[    3.838230]  [<ffffffff8112dedb>] do_init_module+0x62/0x1dd
[    3.838233]  [<ffffffff810caa34>] load_module+0x1db4/0x2510
[    3.838236]  [<ffffffff810c71f0>] ? show_initstate+0x50/0x50
[    3.838242]  [<ffffffff810cb241>] SYSC_finit_module+0xb1/0xc0
[    3.838246]  [<ffffffff810cb38e>] SyS_finit_module+0xe/0x10
[    3.838249]  [<ffffffff815e0660>] entry_SYSCALL_64_fastpath+0x13/0x94
[    3.838284] Code: 00 00 00 4c 0f 44 c8 49 21 d1 4d 39 c1 74 02 0f 0b 48 c1 eb 09 49 89 f8 81 e3 f8 0f 00 00 4d 85 d2 4c 0f 44 c0 48 01 f3 49 21 d0 <49> 8b 14 18 f7 c2 01 01 00 00 74 25 4d 85 db 48 0f 44 f8 48 21
[    3.838287] RIP  [<ffffffff81054330>] vmalloc_fault+0x1e5/0x21d
[    3.838288]  RSP <ffffc900011578e8>
[    3.838289] CR2: ffff8800900003c0
[    4.209883] ---[ end trace 0000000000000002 ]---

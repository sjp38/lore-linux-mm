Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 572436B0253
	for <linux-mm@kvack.org>; Sun, 15 Nov 2015 20:44:41 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so157450083pac.3
        for <linux-mm@kvack.org>; Sun, 15 Nov 2015 17:44:41 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTPS id fm8si46531221pad.29.2015.11.15.17.44.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 15 Nov 2015 17:44:40 -0800 (PST)
Date: Mon, 16 Nov 2015 10:45:21 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: kernel oops on mmotm-2015-10-15-15-20
Message-ID: <20151116014521.GA7973@bbox>
References: <20151030070350.GB16099@bbox>
 <20151102125749.GB7473@node.shutemov.name>
 <20151103030258.GJ17906@bbox>
 <20151103071650.GA21553@node.shutemov.name>
 <20151103073329.GL17906@bbox>
 <20151103152019.GM17906@bbox>
 <20151104142135.GA13303@node.shutemov.name>
 <20151105001922.GD7357@bbox>
 <20151108225522.GA29600@node.shutemov.name>
 <20151112003614.GA5235@bbox>
MIME-Version: 1.0
In-Reply-To: <20151112003614.GA5235@bbox>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Hugh Dickins <hughd@google.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>

On Thu, Nov 12, 2015 at 09:36:14AM +0900, Minchan Kim wrote:

<snip>

> > > mmotm-2015-10-15-15-20-no-madvise_free, IOW it means git head for
> > > 54bad5da4834 arm64: add pmd_[dirty|mkclean] for THP so there is no
> > > MADV_FREE code in there
> > >  + pte_mkdirty patch
> > >  + freeze/unfreeze patch
> > >  + do_page_add_anon_rmap patch
> > >  + above split_huge_pmd
> > > 
> > > 
> > > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
> > > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
> > > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
> > > BUG: Bad rss-counter state mm:ffff88007fa3bb80 idx:1 val:512
> > 
> > With the patch below my test setup run for 2+ days without triggering the
> > bug. split_huge_pmd patch should be dropped.
> > 
> > Please test.
> > 
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > index 14cbbad54a3e..7aa0a3fef2aa 100644
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -2841,9 +2841,6 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
> >  	write = pmd_write(*pmd);
> >  	young = pmd_young(*pmd);
> >  
> > -	/* leave pmd empty until pte is filled */
> > -	pmdp_huge_clear_flush_notify(vma, haddr, pmd);
> > -
> >  	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
> >  	pmd_populate(mm, &_pmd, pgtable);
> >  
> > @@ -2893,6 +2890,28 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
> >  	}
> >  
> >  	smp_wmb(); /* make pte visible before pmd */
> > +	/*
> > +	 * Up to this point the pmd is present and huge and userland has the
> > +	 * whole access to the hugepage during the split (which happens in
> > +	 * place). If we overwrite the pmd with the not-huge version pointing
> > +	 * to the pte here (which of course we could if all CPUs were bug
> > +	 * free), userland could trigger a small page size TLB miss on the
> > +	 * small sized TLB while the hugepage TLB entry is still established in
> > +	 * the huge TLB. Some CPU doesn't like that.
> > +	 * See http://support.amd.com/us/Processor_TechDocs/41322.pdf, Erratum
> > +	 * 383 on page 93. Intel should be safe but is also warns that it's
> > +	 * only safe if the permission and cache attributes of the two entries
> > +	 * loaded in the two TLB is identical (which should be the case here).
> > +	 * But it is generally safer to never allow small and huge TLB entries
> > +	 * for the same virtual address to be loaded simultaneously. So instead
> > +	 * of doing "pmd_populate(); flush_pmd_tlb_range();" we first mark the
> > +	 * current pmd notpresent (atomically because here the pmd_trans_huge
> > +	 * and pmd_trans_splitting must remain set at all times on the pmd
> > +	 * until the split is complete for this pmd), then we flush the SMP TLB
> > +	 * and finally we write the non-huge version of the pmd entry with
> > +	 * pmd_populate.
> > +	 */
> > +	pmdp_invalidate(vma, haddr, pmd);
> >  	pmd_populate(mm, pmd, pgtable);
> >  
> >  	if (freeze) {
> 
> I have been tested this patch with MADV_DONTNEED for a few days and
> I couldn't see the problem any more. And I will continue to test it
> with MADV_FREE.

During the test with MADV_FREE on kernel I applied your patches,
I couldn't see any problem.

However, in this round, I did another test which is same one
I attached but a liitle bit different because it doesn't do
(memcg things/kill/swapoff) for testing program long-live test.

With that, I encountered this problem.

page:ffffea0000f60080 count:1 mapcount:0 mapping:ffff88007f584691 index:0x600002a02
flags: 0x400000000006a028(uptodate|lru|writeback|swapcache|reclaim|swapbacked)
page dumped because: VM_BUG_ON_PAGE(!PageLocked(page))
page->mem_cgroup:ffff880077cf0c00
------------[ cut here ]------------
kernel BUG at mm/huge_memory.c:3340!
invalid opcode: 0000 [#1] SMP 
Dumping ftrace buffer:
   (ftrace buffer empty)
Modules linked in:
CPU: 7 PID: 1657 Comm: memhog Not tainted 4.3.0-rc5-mm1-madv-free+ #4
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
task: ffff88006b0f1a40 ti: ffff88004ced4000 task.ti: ffff88004ced4000
RIP: 0010:[<ffffffff8114bf67>]  [<ffffffff8114bf67>] split_huge_page_to_list+0x907/0x920
RSP: 0018:ffff88004ced7a38  EFLAGS: 00010296
RAX: 0000000000000021 RBX: ffffea0000f60080 RCX: ffffffff81830db8
RDX: 0000000000000001 RSI: 0000000000000246 RDI: ffffffff821df4d8
RBP: ffff88004ced7ab8 R08: 0000000000000000 R09: ffff8800000bc560
R10: ffffffff8163d880 R11: 0000000000014f25 R12: ffffea0000f60080
R13: ffffea0000f60088 R14: ffffea0000f60080 R15: 0000000000000000
FS:  00007f43d3ced740(0000) GS:ffff8800782e0000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007ff1f6fcdb98 CR3: 000000004cf56000 CR4: 00000000000006a0
Stack:
 cccccccccccccccd ffffea0000f60080 ffff88004ced7ad0 ffffea0000f60088
 ffff88004ced7ad0 0000000000000000 ffff88004ced7ab8 ffffffff810ef9d0
 ffffea0000f60000 0000000000000000 0000000000000000 ffffea0000f60080
Call Trace:
 [<ffffffff810ef9d0>] ? __lock_page+0xa0/0xb0
 [<ffffffff8114c09c>] deferred_split_scan+0x11c/0x260
 [<ffffffff81117bfc>] ? list_lru_count_one+0x1c/0x30
 [<ffffffff81101333>] shrink_slab.part.42+0x1e3/0x350
 [<ffffffff81105daa>] shrink_zone+0x26a/0x280
 [<ffffffff81105eed>] do_try_to_free_pages+0x12d/0x3b0
 [<ffffffff81106224>] try_to_free_pages+0xb4/0x140
 [<ffffffff810f8a59>] __alloc_pages_nodemask+0x459/0x920
 [<ffffffff8111e667>] handle_mm_fault+0xc77/0x1000
 [<ffffffff8142718d>] ? retint_kernel+0x10/0x10
 [<ffffffff81033629>] __do_page_fault+0x189/0x400
 [<ffffffff810338ac>] do_page_fault+0xc/0x10
 [<ffffffff81428142>] page_fault+0x22/0x30
Code: ff ff 48 c7 c6 f0 b2 77 81 4c 89 f7 e8 13 c3 fc ff 0f 0b 48 83 e8 01 e9 88 f7 ff ff 48 c7 c6 70 a1 77 81 4c 89 f7 e8 f9 c2 fc ff <0f> 0b 48 c7 c6 38 af 77 81 4c 89 e7 e8 e8 c2 fc ff 0f 0b 66 0f 
RIP  [<ffffffff8114bf67>] split_huge_page_to_list+0x907/0x920
 RSP <ffff88004ced7a38>
---[ end trace c9a60522e3a296e4 ]---


So, I reverted all MADV_FREE patches and chaged it with MADV_DONTNEED.
In this time, I saw below oops in this time.
If I miss somethings, please let me know it.

------------[ cut here ]------------
kernel BUG at include/linux/swapops.h:129!
invalid opcode: 0000 [#1] SMP 
Dumping ftrace buffer:
   (ftrace buffer empty)
Modules linked in:
CPU: 5 PID: 1563 Comm: madvise_test Not tainted 4.3.0-rc5-mm1-no-madv-free+ #5
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
task: ffff88007e8d3480 ti: ffff88007f524000 task.ti: ffff88007f524000
RIP: 0010:[<ffffffff811504be>]  [<ffffffff811504be>] migration_entry_to_page.part.61+0x4/0x6
RSP: 0018:ffff88007f527cd0  EFLAGS: 00010246
RAX: ffffea0000896b00 RBX: 00006000013ac000 RCX: ffffea0000000000
RDX: 0000000000000000 RSI: ffffea0001f93e80 RDI: 3e000000000225ac
RBP: ffff88007f527cd0 R08: 0000000000000101 R09: ffff88007e4fa000
R10: ffffea0001fda740 R11: 0000000000000000 R12: 00000000044b583e
R13: 00006000013ad000 R14: ffff88007f527e00 R15: ffff88007e4fad60
FS:  00007fe2f099a740(0000) GS:ffff8800782a0000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 000000000166c0d0 CR3: 000000007e57b000 CR4: 00000000000006a0
Stack:
 ffff88007f527db8 ffffffff81118030 00006000017fffff ffff88007f527e00
 00006000017fffff ffff88007ed71000 ffff88007e57b600 0000600001800000
 0000600001800000 00006000017fffff 0000600001800000 ffff88007efb6b78
Call Trace:
 [<ffffffff81118030>] unmap_single_vma+0x840/0x880
 [<ffffffff811188a1>] unmap_vmas+0x41/0x60
 [<ffffffff8111dfad>] unmap_region+0x9d/0x100
 [<ffffffff81120007>] do_munmap+0x217/0x380
 [<ffffffff811201b1>] vm_munmap+0x41/0x60
 [<ffffffff811210d2>] SyS_munmap+0x22/0x30
 [<ffffffff81420357>] entry_SYSCALL_64_fastpath+0x12/0x6a
Code: df 48 c1 ff 06 49 01 fc 4c 89 e7 e8 9c ff ff ff 85 c0 74 0c 4c 89 e0 48 c1 e0 06 48 29 d8 eb 02 31 c0 5b 41 5c 5d c3 55 48 89 e5 <0f> 0b 55 48 c7 c6 30 80 77 81 48 89 e5 e8 f0 45 fc ff 0f 0b 55 
RIP  [<ffffffff811504be>] migration_entry_to_page.part.61+0x4/0x6
 RSP <ffff88007f527cd0>
---[ end trace 01097fb7f9cf1b6c ]---

Another hit:

page:ffffea0000520080 count:2 mapcount:0 mapping:ffff880072b38a51 index:0x600002602
flags: 0x4000000000048028(uptodate|lru|swapcache|swapbacked)
page dumped because: VM_BUG_ON_PAGE(!PageLocked(page))
page->mem_cgroup:ffff880077cf0c00
------------[ cut here ]------------
kernel BUG at mm/huge_memory.c:3306!
invalid opcode: 0000 [#1] SMP 
Dumping ftrace buffer:
   (ftrace buffer empty)
Modules linked in:
CPU: 6 PID: 1419 Comm: madvise_test Not tainted 4.3.0-rc5-mm1-no-madv-free+ #5
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
task: ffff88006f108000 ti: ffff88006f054000 task.ti: ffff88006f054000
RIP: 0010:[<ffffffff811473bf>]  [<ffffffff811473bf>] split_huge_page_to_list+0x81f/0x890
RSP: 0000:ffff88006f057a40  EFLAGS: 00010282
RAX: 0000000000000021 RBX: ffffea0000520080 RCX: 0000000000000000
RDX: 0000000000000001 RSI: 0000000000000246 RDI: ffffffff821dd418
RBP: ffff88006f057ab8 R08: 0000000000000000 R09: ffff8800000bfb20
R10: ffffffff8163d1c0 R11: 0000000000005c5f R12: ffff88006f057ad0
R13: ffffea0000520080 R14: ffffea0000520080 R15: 0000000000000000
FS:  00007f09963a2740(0000) GS:ffff8800782c0000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000600003d92000 CR3: 000000007372e000 CR4: 00000000000006a0
Stack:
 ffffea0000520080 ffff88006f057ad0 ffffea0000520088 ffff88006f057ad0
 0000000000000000 ffff88006f057ab8 ffffffff810ec700 ffffea0000520000
 0000000000000000 0000000000000000 ffffea0000520080 ffff88006f057ad0
Call Trace:
 [<ffffffff810ec700>] ? __lock_page+0xa0/0xb0
 [<ffffffff81147545>] deferred_split_scan+0x115/0x240
 [<ffffffff8111445c>] ? list_lru_count_one+0x1c/0x30
 [<ffffffff810fdd63>] shrink_slab.part.43+0x1e3/0x350
 [<ffffffff81102788>] shrink_zone+0x238/0x250
 [<ffffffff811028cd>] do_try_to_free_pages+0x12d/0x3b0
 [<ffffffff81102c04>] try_to_free_pages+0xb4/0x140
 [<ffffffff810f57b9>] __alloc_pages_nodemask+0x459/0x920
 [<ffffffff8111aa2a>] handle_mm_fault+0xbca/0xf90
 [<ffffffff8105b8bc>] ? enqueue_task+0x3c/0x60
 [<ffffffff810602eb>] ? __set_cpus_allowed_ptr+0x9b/0x1a0
 [<ffffffff81032b49>] __do_page_fault+0x189/0x400
 [<ffffffff81032dcc>] do_page_fault+0xc/0x10
 [<ffffffff81421e02>] page_fault+0x22/0x30
Code: ff ff 48 c7 c6 d0 91 77 81 4c 89 f7 e8 1b d7 fc ff 0f 0b 48 83 e8 01 e9 70 f8 ff ff 48 c7 c6 50 80 77 81 4c 89 f7 e8 01 d7 fc ff <0f> 0b 48 c7 c6 d8 be 77 81 4c 89 ef e8 f0 d6 fc ff 0f 0b 48 83 
RIP  [<ffffffff811473bf>] split_huge_page_to_list+0x81f/0x890
 RSP <ffff88006f057a40>
---[ end trace 0ce8751b8410cd8e ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

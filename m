Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 73B9B6B0035
	for <linux-mm@kvack.org>; Fri, 25 Jul 2014 15:45:19 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id ey11so6662699pad.10
        for <linux-mm@kvack.org>; Fri, 25 Jul 2014 12:45:19 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id ip4si10134618pbd.223.2014.07.25.12.45.17
        for <linux-mm@kvack.org>;
        Fri, 25 Jul 2014 12:45:18 -0700 (PDT)
Date: Fri, 25 Jul 2014 15:44:50 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v8 05/22] Add vm_replace_mixed()
Message-ID: <20140725194450.GJ6754@linux.intel.com>
References: <cover.1406058387.git.matthew.r.wilcox@intel.com>
 <b1052af08b49965fd0e6b87b6733b89294c8cc1e.1406058387.git.matthew.r.wilcox@intel.com>
 <20140723114540.GD10317@node.dhcp.inet.fi>
 <20140723135221.GA6754@linux.intel.com>
 <20140723142048.GA11963@node.dhcp.inet.fi>
 <20140723142745.GD6754@linux.intel.com>
 <20140723155500.GA12790@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="NU0Ex4SbNnrxsi6C"
Content-Disposition: inline
In-Reply-To: <20140723155500.GA12790@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--NU0Ex4SbNnrxsi6C
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Jul 23, 2014 at 06:55:00PM +0300, Kirill A. Shutemov wrote:
> >         update_hiwater_rss(mm);
> 
> No: you cannot end up with lower rss after replace, iiuc.

Actually, you can ... when we replace a real page with a PFN, our rss
decreases.

> Do you mean you pointed to new file all the time? O_CREAT doesn't truncate
> file if it exists, iirc.

It was pointing to a new file.  Still not sure why that one failed to trigger
the problem.  The slightly modified version attached triggered the problem
*just fine* :-)

I've attached all the patches in my tree so far.  For the v9 patch kit,
I'll keep patch 3 as a separate patch, but roll patches 1, 2 and 4 into
other patches.

I am seeing something odd though.  When I run double-map with debugging
printks inserted in strategic spots in the kernel, I see four calls to
do_dax_fault().  The first two, as expected, are the loads from the two
mapped addresses.  The third is via mkwrite, but then the fourth time
I get a regular page fault for write, and I don't understand why I get it.

Any ideas?


[  880.966632] do_dax_fault: fault a8 page =           (null) bh state 0 written
 0 addr 7ff598835000
[  880.966637] dax_load_hole: page = ffffea0002784730
[  882.114387] do_dax_fault: fault a8 page = ffffea0002784730 bh state 0 written 0 addr 7ff598834000
[  882.114389] dax_load_hole: page = ffffea0002784730
[  882.780013] do_dax_fault: fault 5 page = ffffea0002784730 bh state 0 written 0 addr 7ff598835000
[  882.780095] insert_pfn: pte = 8000000108200225
[  882.780096] do_dax_fault: page = ffffea0002784730 pfn = 108200 error = 0
[  882.780098] CPU: 1 PID: 1511 Comm: double-map Not tainted 3.16.0-rc6+ #89
[  882.780099] Hardware name: Gigabyte Technology Co., Ltd. To be filled by O.E.M./Q87M-D2H, BIOS F6 08/03/2013
[  882.780100]  0000000000000000 ffff8800b41e3ba0 ffffffff815c6e73 ffffea0002784730
[  882.780102]  ffff8800b41e3c88 ffffffff8124c319 00007ff598835000 ffff8800b2436ac0
[  882.780104]  0000000000000005 ffffffffa01e3020 0000000000000004 ffff880000000005
[  882.780106] Call Trace:
[  882.780110]  [<ffffffff815c6e73>] dump_stack+0x4d/0x66
[  882.780114]  [<ffffffff8124c319>] do_dax_fault+0x569/0x6f0
[  882.780133]  [<ffffffff8124c4df>] dax_fault+0x3f/0x90
[  882.780136]  [<ffffffff81023b2e>] ? native_sched_clock+0x2e/0xb0
[  882.780137]  [<ffffffff8124c53e>] dax_mkwrite+0xe/0x10
[  882.780143]  [<ffffffffa01db955>] ext4_dax_mkwrite+0x15/0x20 [ext4]
[  882.780146]  [<ffffffff811ab627>] do_page_mkwrite+0x47/0xb0
[  882.780148]  [<ffffffff811ad7f2>] do_wp_page+0x6e2/0x990
[  882.780150]  [<ffffffff811aff1b>] handle_mm_fault+0x6ab/0xf70
[  882.780154]  [<ffffffff81062d2c>] __do_page_fault+0x1ec/0x5b0
[  882.780163]  [<ffffffff81063112>] do_page_fault+0x22/0x30
[  882.780165]  [<ffffffff815d1b78>] page_fault+0x28/0x30
[  882.780204] do_dax_fault: fault a9 page =           (null) bh state 20 written 1 addr 7ff598835000
[  882.780206] insert_pfn: pte = 8000000108200225
[  882.780207] do_dax_fault: page =           (null) pfn = 108200 error = 0
[  882.780208] CPU: 1 PID: 1511 Comm: double-map Not tainted 3.16.0-rc6+ #89
[  882.780208] Hardware name: Gigabyte Technology Co., Ltd. To be filled by O.E.M./Q87M-D2H, BIOS F6 08/03/2013
[  882.780209]  0000000000000000 ffff8800b41e3bc0 ffffffff815c6e73 0000000000000000
[  882.780211]  ffff8800b41e3ca8 ffffffff8124c319 00007ff598835000 ffff8800b41e3c08
[  882.780213]  ffff8800a2a60608 ffffffffa01e3020 0000000000000000 ffff8800000000a9
[  882.780214] Call Trace:
[  882.780216]  [<ffffffff815c6e73>] dump_stack+0x4d/0x66
[  882.780218]  [<ffffffff8124c319>] do_dax_fault+0x569/0x6f0
[  882.780232]  [<ffffffff8124c4df>] dax_fault+0x3f/0x90
[  882.780238]  [<ffffffffa01db975>] ext4_dax_fault+0x15/0x20 [ext4]
[  882.780240]  [<ffffffff811ab6d1>] __do_fault+0x41/0xd0
[  882.780241]  [<ffffffff811ae8a5>] do_shared_fault.isra.56+0x35/0x220
[  882.780243]  [<ffffffff811afb73>] handle_mm_fault+0x303/0xf70
[  882.780246]  [<ffffffff81062d2c>] __do_page_fault+0x1ec/0x5b0
[  882.780254]  [<ffffffff81063112>] do_page_fault+0x22/0x30
[  882.780255]  [<ffffffff815d1b78>] page_fault+0x28/0x30


diff --git a/fs/dax.c b/fs/dax.c
index b4fdfd9..4b0f928 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -257,6 +257,7 @@ static int dax_load_hole(struct address_space *mapping, struct page *page,
 	if (!page)
 		page = find_or_create_page(mapping, vmf->pgoff,
 						GFP_KERNEL | __GFP_ZERO);
+printk("%s: page = %p\n", __func__, page);
 	if (!page)
 		return VM_FAULT_OOM;
 	/* Recheck i_size under page lock to avoid truncate race */
@@ -332,6 +333,7 @@ static int do_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	if (error || bh.b_size < PAGE_SIZE)
 		goto sigbus;
 
+printk("%s: fault %x page = %p bh state %lx written %d addr %lx\n", __func__, vmf->flags, page, bh.b_state, buffer_written(&bh), vaddr);
 	if (!buffer_written(&bh) && !vmf->cow_page) {
 		if (vmf->flags & FAULT_FLAG_WRITE) {
 			error = get_block(inode, block, &bh, 1);
@@ -372,6 +374,8 @@ static int do_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	error = dax_get_pfn(&bh, &pfn, blkbits);
 	if (error > 0)
 		error = vm_replace_mixed(vma, vaddr, pfn);
+printk("%s: page = %p pfn = %lx error = %d\n", __func__, page, pfn, error);
+if ((vmf->flags & FAULT_FLAG_WRITE) || !(vmf->flags & FAULT_FLAG_USER)) dump_stack();
 
 	if (!page) {
 		mutex_unlock(&mapping->i_mmap_mutex);
diff --git a/mm/memory.c b/mm/memory.c
index a8e17ce..189716c 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1614,6 +1614,7 @@ static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 	/* Ok, finally just insert the thing.. */
 	entry = pte_mkspecial(pfn_pte(pfn, prot));
 	set_pte_at(mm, addr, pte, entry);
+printk("%s: pte = %llx\n", __func__, pte_val(entry));
 	update_mmu_cache(vma, addr, pte); /* XXX: why not for insert_page? */
 
 	retval = 0;

--NU0Ex4SbNnrxsi6C
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-dax-Only-unlock-the-i_mmap_mutex-if-we-locked-it.patch"


--NU0Ex4SbNnrxsi6C--

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f181.google.com (mail-vc0-f181.google.com [209.85.220.181])
	by kanga.kvack.org (Postfix) with ESMTP id 230076B0036
	for <linux-mm@kvack.org>; Thu, 10 Jul 2014 12:36:11 -0400 (EDT)
Received: by mail-vc0-f181.google.com with SMTP id il7so11141300vcb.12
        for <linux-mm@kvack.org>; Thu, 10 Jul 2014 09:36:10 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id dx8si23151864vdb.24.2014.07.10.09.36.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jul 2014 09:36:10 -0700 (PDT)
Date: Thu, 10 Jul 2014 12:35:55 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v4 13/13] mincore: apply page table walker on do_mincore()
Message-ID: <20140710163555.GB12391@nhori>
References: <1404234451-21695-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1404234451-21695-14-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20140709133436.GA18391@node.dhcp.inet.fi>
 <20140709213624.GC24698@nhori>
 <20140710100600.GA30360@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140710100600.GA30360@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Thu, Jul 10, 2014 at 01:06:00PM +0300, Kirill A. Shutemov wrote:
> On Wed, Jul 09, 2014 at 05:36:24PM -0400, Naoya Horiguchi wrote:
> > On Wed, Jul 09, 2014 at 04:34:36PM +0300, Kirill A. Shutemov wrote:
> > > On Tue, Jul 01, 2014 at 01:07:31PM -0400, Naoya Horiguchi wrote:
> > > > This patch makes do_mincore() use walk_page_vma(), which reduces many lines
> > > > of code by using common page table walk code.
> > > > 
> > > > ChangeLog v4:
> > > > - remove redundant vma
> > > > 
> > > > ChangeLog v3:
> > > > - add NULL vma check in mincore_unmapped_range()
> > > > - don't use pte_entry()
> > > > 
> > > > ChangeLog v2:
> > > > - change type of args of callbacks to void *
> > > > - move definition of mincore_walk to the start of the function to fix compiler
> > > >   warning
> > > > 
> > > > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > > 
> > > Trinity crases this implementation of mincore pretty easily:
> > > 
> > > [   42.775369] BUG: unable to handle kernel paging request at ffff88007bb61000
> > > [   42.776656] IP: [<ffffffff81126f8f>] mincore_unmapped_range+0xdf/0x100
> > 
> > Thanks for your testing/reporting.
> > 
> > ...
> > > 
> > > Looks like 'vec' overflow. I don't see what could prevent do_mincore() to
> > > write more than PAGE_SIZE to 'vec'.
> > 
> > I found the miscalculation of walk->private (vec) on thp and hugetlbfs.
> > I confirmed that the reported problem is fixed (I checked that trinity
> > never triggers the reported BUG) with the following changes on this patch.
> 
> With the changes:
> 
> [   26.850945] BUG: unable to handle kernel paging request at ffff880852d8c000
> [   26.852718] IP: [<ffffffff81126de7>] mincore_hugetlb+0x27/0x50
> [   26.853527] PGD 2ef6067 PUD 2ef9067 PMD 87fd4a067 PTE 8000000852d8c060
> [   26.854462] Oops: 0002 [#1] SMP DEBUG_PAGEALLOC
> [   26.854752] Modules linked in:
> [   26.854752] CPU: 5 PID: 170 Comm: trinity-c5 Not tainted 3.16.0-rc4-next-20140709-00013-g28e4629f71a8-dirty #1453
> [   26.854752] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> [   26.854752] task: ffff880852d22890 ti: ffff880852d24000 task.ti: ffff880852d24000
> [   26.854752] RIP: 0010:[<ffffffff81126de7>]  [<ffffffff81126de7>] mincore_hugetlb+0x27/0x50
> [   26.854752] RSP: 0018:ffff880852d27e28  EFLAGS: 00010206
> [   26.854752] RAX: ffff880852d8c000 RBX: 00007f9fb2200000 RCX: 00007f9fb2200000
> [   26.854752] RDX: 00007f9fb2001000 RSI: ffffffffffe00000 RDI: ffff88084f3edc80
> [   26.854752] RBP: ffff880852d27e28 R08: ffff880852d27f10 R09: ffffffff81126dc0
> [   26.854752] R10: 0000000000000000 R11: 0000000000000001 R12: 00007f9fde000000
> [   26.854752] R13: ffffffff82e32580 R14: 00007f9fb2000000 R15: ffff880852d27f10
> [   26.854752] FS:  00007f9fe1bde700(0000) GS:ffff88085a000000(0000) knlGS:0000000000000000
> [   26.854752] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [   26.854752] CR2: ffff880852d8c000 CR3: 0000000852d12000 CR4: 00000000000006e0
> [   26.854752] Stack:
> [   26.854752]  ffff880852d27eb8 ffffffff81135e24 ffff880852ce01d8 0000000000000282
> [   26.854752]  ffff880852ce01d8 ffff880852d22890 00007f9fde000000 ffff880852d27eb0
> [   26.854752]  0000000000000282 0000000000000000 ffffffff81127399 0000000000000282
> [   26.854752] Call Trace:
> [   26.854752]  [<ffffffff81135e24>] __walk_page_range+0x3f4/0x450
> [   26.854752]  [<ffffffff81127399>] ? SyS_mincore+0x179/0x270
> [   26.854752]  [<ffffffff81136031>] walk_page_vma+0x71/0x90
> [   26.854752]  [<ffffffff811273fe>] SyS_mincore+0x1de/0x270
> [   26.854752]  [<ffffffff81126fb0>] ? mincore_unmapped_range+0x100/0x100
> [   26.854752]  [<ffffffff81126eb0>] ? mincore_page+0xa0/0xa0
> [   26.854752]  [<ffffffff81126dc0>] ? handle_mm_fault+0xd30/0xd30
> [   26.854752]  [<ffffffff81746b12>] system_call_fastpath+0x16/0x1b
> [   26.854752] Code: 0f 1f 40 00 55 48 85 ff 49 8b 40 38 48 89 e5 74 33 48 83 3f 00 40 0f 95 c6 48 39 ca 74 19 66 0f 1f 44 00 00 48 81 c2 00 10 00 00 <40> 88 30 48 83 c0 01 48 39 d1 75 ed 49 89 40 38 31 c0 5d c3 0f 
> [   26.854752] RIP  [<ffffffff81126de7>] mincore_hugetlb+0x27/0x50
> [   26.854752]  RSP <ffff880852d27e28>
> [   26.854752] CR2: ffff880852d8c000
> [   26.854752] ---[ end trace 536bbdef8c6d5b03 ]---
> 
> Could you explain to me how you protect 'vec' from being overflowed? I don't
> any code for that.

I don't do it explicitly, so adding it is one solution.
But I think the problem comes from using walk_page_range() instead of
walk_page_vma() which forcibly sets the walk range from vm->vm_start to
vm->vm_end.
As the original code does, limiting the range to [addr, addr + pages <<
PAGE_SHIFT) is fine because it implicitly prevents buffer overflow.

Here is the revised fix for this patch. Please remove the one I replied
yesterday because it was wrong.

Thanks,
Naoya Horiguchi
---
diff --git a/mm/mincore.c b/mm/mincore.c
index 3c64dcbcb3e2..0e548fbce19e 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -34,7 +34,7 @@ static int mincore_hugetlb(pte_t *pte, unsigned long hmask, unsigned long addr,
 	present = pte && !huge_pte_none(huge_ptep_get(pte));
 	for (; addr != end; vec++, addr += PAGE_SIZE)
 		*vec = present;
-	walk->private += (end - addr) >> PAGE_SHIFT;
+	walk->private = vec;
 #else
 	BUG();
 #endif
@@ -118,8 +118,10 @@ static int mincore_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 		return 0;
 	}
 
-	if (pmd_trans_unstable(pmd))
+	if (pmd_trans_unstable(pmd)) {
+		mincore_unmapped_range(addr, end, walk);
 		return 0;
+	}
 
 	ptep = pte_offset_map_lock(walk->mm, pmd, addr, &ptl);
 	for (; addr != end; ptep++, addr += PAGE_SIZE) {
@@ -168,6 +170,7 @@ static int mincore_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 static long do_mincore(unsigned long addr, unsigned long pages, unsigned char *vec)
 {
 	struct vm_area_struct *vma;
+	unsigned long end;
 	int err;
 	struct mm_walk mincore_walk = {
 		.pmd_entry = mincore_pte_range,
@@ -180,16 +183,11 @@ static long do_mincore(unsigned long addr, unsigned long pages, unsigned char *v
 	if (!vma || addr < vma->vm_start)
 		return -ENOMEM;
 	mincore_walk.mm = vma->vm_mm;
-
-	err = walk_page_vma(vma, &mincore_walk);
+	end = min(vma->vm_end, addr + (pages << PAGE_SHIFT));
+	err = walk_page_range(addr, end, &mincore_walk);
 	if (err < 0)
 		return err;
-	else {
-		unsigned long end;
-
-		end = min(vma->vm_end, addr + (pages << PAGE_SHIFT));
-		return (end - addr) >> PAGE_SHIFT;
-	}
+	return (end - addr) >> PAGE_SHIFT;
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

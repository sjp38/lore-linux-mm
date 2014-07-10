Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id D6B666B0031
	for <linux-mm@kvack.org>; Thu, 10 Jul 2014 06:06:15 -0400 (EDT)
Received: by mail-wi0-f179.google.com with SMTP id cc10so4175107wib.12
        for <linux-mm@kvack.org>; Thu, 10 Jul 2014 03:06:15 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.199])
        by mx.google.com with ESMTP id j4si61584956wja.141.2014.07.10.03.06.14
        for <linux-mm@kvack.org>;
        Thu, 10 Jul 2014 03:06:14 -0700 (PDT)
Date: Thu, 10 Jul 2014 13:06:00 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v4 13/13] mincore: apply page table walker on do_mincore()
Message-ID: <20140710100600.GA30360@node.dhcp.inet.fi>
References: <1404234451-21695-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1404234451-21695-14-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20140709133436.GA18391@node.dhcp.inet.fi>
 <20140709213624.GC24698@nhori>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140709213624.GC24698@nhori>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Wed, Jul 09, 2014 at 05:36:24PM -0400, Naoya Horiguchi wrote:
> On Wed, Jul 09, 2014 at 04:34:36PM +0300, Kirill A. Shutemov wrote:
> > On Tue, Jul 01, 2014 at 01:07:31PM -0400, Naoya Horiguchi wrote:
> > > This patch makes do_mincore() use walk_page_vma(), which reduces many lines
> > > of code by using common page table walk code.
> > > 
> > > ChangeLog v4:
> > > - remove redundant vma
> > > 
> > > ChangeLog v3:
> > > - add NULL vma check in mincore_unmapped_range()
> > > - don't use pte_entry()
> > > 
> > > ChangeLog v2:
> > > - change type of args of callbacks to void *
> > > - move definition of mincore_walk to the start of the function to fix compiler
> > >   warning
> > > 
> > > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > 
> > Trinity crases this implementation of mincore pretty easily:
> > 
> > [   42.775369] BUG: unable to handle kernel paging request at ffff88007bb61000
> > [   42.776656] IP: [<ffffffff81126f8f>] mincore_unmapped_range+0xdf/0x100
> 
> Thanks for your testing/reporting.
> 
> ...
> > 
> > Looks like 'vec' overflow. I don't see what could prevent do_mincore() to
> > write more than PAGE_SIZE to 'vec'.
> 
> I found the miscalculation of walk->private (vec) on thp and hugetlbfs.
> I confirmed that the reported problem is fixed (I checked that trinity
> never triggers the reported BUG) with the following changes on this patch.

With the changes:

[   26.850945] BUG: unable to handle kernel paging request at ffff880852d8c000
[   26.852718] IP: [<ffffffff81126de7>] mincore_hugetlb+0x27/0x50
[   26.853527] PGD 2ef6067 PUD 2ef9067 PMD 87fd4a067 PTE 8000000852d8c060
[   26.854462] Oops: 0002 [#1] SMP DEBUG_PAGEALLOC
[   26.854752] Modules linked in:
[   26.854752] CPU: 5 PID: 170 Comm: trinity-c5 Not tainted 3.16.0-rc4-next-20140709-00013-g28e4629f71a8-dirty #1453
[   26.854752] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   26.854752] task: ffff880852d22890 ti: ffff880852d24000 task.ti: ffff880852d24000
[   26.854752] RIP: 0010:[<ffffffff81126de7>]  [<ffffffff81126de7>] mincore_hugetlb+0x27/0x50
[   26.854752] RSP: 0018:ffff880852d27e28  EFLAGS: 00010206
[   26.854752] RAX: ffff880852d8c000 RBX: 00007f9fb2200000 RCX: 00007f9fb2200000
[   26.854752] RDX: 00007f9fb2001000 RSI: ffffffffffe00000 RDI: ffff88084f3edc80
[   26.854752] RBP: ffff880852d27e28 R08: ffff880852d27f10 R09: ffffffff81126dc0
[   26.854752] R10: 0000000000000000 R11: 0000000000000001 R12: 00007f9fde000000
[   26.854752] R13: ffffffff82e32580 R14: 00007f9fb2000000 R15: ffff880852d27f10
[   26.854752] FS:  00007f9fe1bde700(0000) GS:ffff88085a000000(0000) knlGS:0000000000000000
[   26.854752] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   26.854752] CR2: ffff880852d8c000 CR3: 0000000852d12000 CR4: 00000000000006e0
[   26.854752] Stack:
[   26.854752]  ffff880852d27eb8 ffffffff81135e24 ffff880852ce01d8 0000000000000282
[   26.854752]  ffff880852ce01d8 ffff880852d22890 00007f9fde000000 ffff880852d27eb0
[   26.854752]  0000000000000282 0000000000000000 ffffffff81127399 0000000000000282
[   26.854752] Call Trace:
[   26.854752]  [<ffffffff81135e24>] __walk_page_range+0x3f4/0x450
[   26.854752]  [<ffffffff81127399>] ? SyS_mincore+0x179/0x270
[   26.854752]  [<ffffffff81136031>] walk_page_vma+0x71/0x90
[   26.854752]  [<ffffffff811273fe>] SyS_mincore+0x1de/0x270
[   26.854752]  [<ffffffff81126fb0>] ? mincore_unmapped_range+0x100/0x100
[   26.854752]  [<ffffffff81126eb0>] ? mincore_page+0xa0/0xa0
[   26.854752]  [<ffffffff81126dc0>] ? handle_mm_fault+0xd30/0xd30
[   26.854752]  [<ffffffff81746b12>] system_call_fastpath+0x16/0x1b
[   26.854752] Code: 0f 1f 40 00 55 48 85 ff 49 8b 40 38 48 89 e5 74 33 48 83 3f 00 40 0f 95 c6 48 39 ca 74 19 66 0f 1f 44 00 00 48 81 c2 00 10 00 00 <40> 88 30 48 83 c0 01 48 39 d1 75 ed 49 89 40 38 31 c0 5d c3 0f 
[   26.854752] RIP  [<ffffffff81126de7>] mincore_hugetlb+0x27/0x50
[   26.854752]  RSP <ffff880852d27e28>
[   26.854752] CR2: ffff880852d8c000
[   26.854752] ---[ end trace 536bbdef8c6d5b03 ]---

Could you explain to me how you protect 'vec' from being overflowed? I don't
any code for that.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

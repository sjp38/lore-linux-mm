Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 970C36B0002
	for <linux-mm@kvack.org>; Sun, 14 Apr 2013 03:13:16 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id lb1so2068280pab.33
        for <linux-mm@kvack.org>; Sun, 14 Apr 2013 00:13:15 -0700 (PDT)
Date: Sun, 14 Apr 2013 16:13:08 +0900
From: Minchan Kim <minchan.kernel.2@gmail.com>
Subject: Re: mm: BUG in do_huge_pmd_wp_page
Message-ID: <20130414071146.GB8241@blaptop>
References: <51559150.3040407@oracle.com>
 <20130410080202.GB21292@blaptop>
 <20130411131813.17FD7E0085@blue.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130411131813.17FD7E0085@blue.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Mel Gorman <mgorman@suse.de>, Dave Jones <davej@redhat.com>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dave Hansen <dave@sr71.net>

On Thu, Apr 11, 2013 at 04:18:13PM +0300, Kirill A. Shutemov wrote:
> Minchan Kim wrote:
> > On Fri, Mar 29, 2013 at 09:04:16AM -0400, Sasha Levin wrote:
> > > Hi all,
> > > 
> > > While fuzzing with trinity inside a KVM tools guest running latest -next kernel,
> > > I've stumbled on the following.
> > > 
> > > It seems that the code in do_huge_pmd_wp_page() was recently modified in
> > > "thp: do_huge_pmd_wp_page(): handle huge zero page".
> > > 
> > > Here's the trace:
> > > 
> > > [  246.244708] BUG: unable to handle kernel paging request at ffff88009c422000
> > > [  246.245743] IP: [<ffffffff81a0a795>] copy_page_rep+0x5/0x10
> > > [  246.250569] PGD 7232067 PUD 7235067 PMD bfefe067 PTE 800000009c422060
> > > [  246.251529] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> > > [  246.252325] Dumping ftrace buffer:
> > > [  246.252791]    (ftrace buffer empty)
> > > [  246.252869] Modules linked in:
> > > [  246.252869] CPU 3
> > > [  246.252869] Pid: 11985, comm: trinity-child12 Tainted: G        W    3.9.0-rc4-next-20130328-sasha-00014-g91a3267 #319
> > > [  246.252869] RIP: 0010:[<ffffffff81a0a795>]  [<ffffffff81a0a795>] copy_page_rep+0x5/0x10
> > > [  246.252869] RSP: 0018:ffff88000015bc40  EFLAGS: 00010286
> > > [  246.252869] RAX: ffff88000015bfd8 RBX: 0000000002710880 RCX: 0000000000000200
> > > [  246.252869] RDX: 0000000000000000 RSI: ffff88009c422000 RDI: ffff88009a422000
> > > [  246.252869] RBP: ffff88000015bc98 R08: 0000000002718000 R09: 0000000000000001
> > > [  246.252869] R10: 0000000000000001 R11: 0000000000000000 R12: ffff880000000000
> > > [  246.252869] R13: ffff88000015bfd8 R14: ffff88000015bfd8 R15: fffffffffff80000
> > > [  246.252869] FS:  00007f53db93f700(0000) GS:ffff8800bba00000(0000) knlGS:0000000000000000
> > > [  246.252869] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [  246.252869] CR2: ffff88009c422000 CR3: 0000000000159000 CR4: 00000000000406e0
> > > [  246.252869] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > > [  246.252869] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> > > [  246.252869] Process trinity-child12 (pid: 11985, threadinfo ffff88000015a000, task ffff88009c60b000)
> > > [  246.252869] Stack:
> > > [  246.252869]  ffffffff81234aae ffff88000015bc88 ffffffff81273639 0000000000a00000
> > > [  246.252869]  0000000002718000 ffff8800ab36d050 ffff880000153800 ffffea0002690000
> > > [  246.252869]  0000000000a00000 ffff8800ab36d000 ffffea0002710000 ffff88000015bd48
> > > [  246.252869] Call Trace:
> > > [  246.252869]  [<ffffffff81234aae>] ? copy_user_huge_page+0x1de/0x240
> > > [  246.252869]  [<ffffffff81273639>] ? mem_cgroup_charge_common+0xa9/0xc0
> > > [  246.252869]  [<ffffffff8126b4d7>] do_huge_pmd_wp_page+0x9f7/0xc60
> > > [  246.252869]  [<ffffffff81a0acd9>] ? __const_udelay+0x29/0x30
> > > [  246.252869]  [<ffffffff8123364e>] handle_mm_fault+0x26e/0x650
> > > [  246.252869]  [<ffffffff8117dc1a>] ? __lock_is_held+0x5a/0x80
> > > [  246.252869]  [<ffffffff83db3814>] ? __do_page_fault+0x514/0x5e0
> > > [  246.252869]  [<ffffffff83db3870>] __do_page_fault+0x570/0x5e0
> > > [  246.252869]  [<ffffffff811c6500>] ? rcu_eqs_exit_common+0x60/0x260
> > > [  246.252869]  [<ffffffff811c740e>] ? rcu_eqs_enter_common+0x33e/0x3b0
> > > [  246.252869]  [<ffffffff811c679c>] ? rcu_eqs_exit+0x9c/0xb0
> > > [  246.252869]  [<ffffffff83db3912>] do_page_fault+0x32/0x50
> > > [  246.252869]  [<ffffffff83db2ef0>] do_async_page_fault+0x30/0xc0
> > > [  246.252869]  [<ffffffff83db01e8>] async_page_fault+0x28/0x30
> > > [  246.252869] Code: 90 90 90 90 90 90 9c fa 65 48 3b 06 75 14 65 48 3b 56 08 75 0d 65 48 89 1e 65 48 89 4e 08 9d b0 01 c3 9d 30
> > > c0 c3 b9 00 02 00 00 <f3> 48 a5 c3 0f 1f 80 00 00 00 00 eb ee 66 66 66 90 66 66 66 90
> > > [  246.252869] RIP  [<ffffffff81a0a795>] copy_page_rep+0x5/0x10
> > > [  246.252869]  RSP <ffff88000015bc40>
> > > [  246.252869] CR2: ffff88009c422000
> > > [  246.252869] ---[ end trace 09fbe37b108d5766 ]---
> > > 
> > > And this is the code:
> > > 
> > >         if (is_huge_zero_pmd(orig_pmd))
> > >                 clear_huge_page(new_page, haddr, HPAGE_PMD_NR);
> > >         else
> > >                 copy_user_huge_page(new_page, page, haddr, vma, HPAGE_PMD_NR); <--- this
> > > 
> > > 
> > > Thanks,
> > > Sasha
> > 
> > I don't know this issue was already resolved. If so, my reply become a just
> > question to Kirill regardless of this BUG.
> > 
> > When I am looking at the code, I was wonder about the logic of GHZP(aka,
> > get_huge_zero_page) reference handling. The logic depends on that page
> > allocator never alocate PFN 0.
> > 
> > Who makes sure it? What happens if allocator allocates PFN 0?
> > I don't know all of architecture makes sure it.
> > You investigated it for all arches?
> > 
> > If not, 
> > CPU 1                   CPU 2                                   CPU 3
> > 
> > shrink_huge_zero_page
> > huge_zero_refcount = 0;
> >                         GHZP
> >                         pfn_0_zero_page = alloc_pages 
> >                                                          GHZP
> >                                                          pfn_some_zero_page = alloc_page
> > huge_zero_pfn = 0
> >                         huge_zero_pfn = pfn_0
> >                         huge_zero_refcount = 2
> >                                                         huge_zero_pfn = pfn_some
> >                                                         huge_zero_refcount = 2
> > 
> > So, if you want to stick this logic, at least, don't we need BUG_ON to check
> > pfn 0 allocation in get_huge_zero_page?
> 
> I don't think it's related to oops in the thread (I was not able to
> reproduce it), but nice catch anyway.
> 
> What about the patch below?
> 
> =====
> 
> >From 4579aefd606b2dd82797af163ce6d08912894b3a Mon Sep 17 00:00:00 2001
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Date: Thu, 11 Apr 2013 15:47:50 +0300
> Subject: [PATCH] thp: fix huge zero page logic for page with pfn == 0
> 
> Current implementation of huge zero page uses pfn value 0 to indicate
> that the page hasn't allocated yet. It assumes that buddy page allocator
> can't return page with pfn == 0.
> 
> Let's rework the code to store 'struct page *' of huge zero page, not
> its pfn. This way we can avoid the weak assumption.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Reported-by: Minchan Kim <minchan@kernel.org>

Looks nice to me.

Acked-by: Minchan Kim <minchan@kernel.org>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id F216D6B0253
	for <linux-mm@kvack.org>; Fri, 29 Jul 2016 04:00:54 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id e139so106359723oib.3
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 01:00:54 -0700 (PDT)
Received: from out4433.biz.mail.alibaba.com (out4433.biz.mail.alibaba.com. [47.88.44.33])
        by mx.google.com with ESMTP id p7si17885186iod.35.2016.07.29.01.00.52
        for <linux-mm@kvack.org>;
        Fri, 29 Jul 2016 01:00:53 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <01fa01d1e94c$4be09210$e3a1b630$@alibaba-inc.com>
In-Reply-To: <01fa01d1e94c$4be09210$e3a1b630$@alibaba-inc.com>
Subject: Re: [PATCH] mm: fail prefaulting if page table allocation fails
Date: Fri, 29 Jul 2016 16:00:37 +0800
Message-ID: <021901d1e96f$4b271830$e1754890$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Vegard Nossum' <vegard.nossum@oracle.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

> 
> I ran into this:
> 
>     BUG: sleeping function called from invalid context at mm/page_alloc.c:3784
>     in_atomic(): 0, irqs_disabled(): 0, pid: 1434, name: trinity-c1
>     2 locks held by trinity-c1/1434:
>      #0:  (&mm->mmap_sem){......}, at: [<ffffffff810ce31e>] __do_page_fault+0x1ce/0x8f0
>      #1:  (rcu_read_lock){......}, at: [<ffffffff81378f86>] filemap_map_pages+0xd6/0xdd0
> 
>     CPU: 0 PID: 1434 Comm: trinity-c1 Not tainted 4.7.0+ #58
>     Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Ubuntu-1.8.2-1ubuntu1 04/01/2014
>      ffff8800b662f698 ffff8800b662f548 ffffffff81d6d001 ffffffff83a61100
>      ffff8800b662f620 ffff8800b662f610 ffffffff81373fd1 0000000041b58ab3
>      ffffffff8406ca21 ffffffff81373e4c 0000000041b58ab3 ffffffff00000008
>     Call Trace:
>      [<ffffffff81d6d001>] dump_stack+0x65/0x84
>      [<ffffffff81373fd1>] panic+0x185/0x2dd
>      [<ffffffff8118e38c>] ___might_sleep+0x51c/0x600
>      [<ffffffff8118e500>] __might_sleep+0x90/0x1a0
>      [<ffffffff81392761>] __alloc_pages_nodemask+0x5b1/0x2160
>      [<ffffffff814665ac>] alloc_pages_current+0xcc/0x370
>      [<ffffffff810d95b2>] pte_alloc_one+0x12/0x90
>      [<ffffffff814053cd>] __pte_alloc+0x1d/0x200
>      [<ffffffff8140be4e>] alloc_set_pte+0xe3e/0x14a0
>      [<ffffffff813792db>] filemap_map_pages+0x42b/0xdd0
>      [<ffffffff8140e0d5>] handle_mm_fault+0x17d5/0x28b0
>      [<ffffffff810ce460>] __do_page_fault+0x310/0x8f0
>      [<ffffffff810cec7d>] trace_do_page_fault+0x18d/0x310
>      [<ffffffff810c2177>] do_async_page_fault+0x27/0xa0
>      [<ffffffff8389e258>] async_page_fault+0x28/0x30
> 
> The important bits from the above is that filemap_map_pages() is calling
> into the page allocator while holding rcu_read_lock (sleeping is not
> allowed inside RCU read-side critical sections).
> 
> According to Kirill Shutemov, the prefaulting code in do_fault_around()
> is supposed to take care of this, but missing error handling means that
> the allocation failure can go unnoticed.
> 
Well it is fixed at this particular call site, thanks. 

On the other hand IIUC in alloc_set_pte() there is no acquiring of ptl if 
fe->pte is valid, so race still sits there. 

Would you please address both?

Hillf
> We don't need to return VM_FAULT_OOM (or any other error) here, since we
> can just let the normal fault path try again.
> 
> Fixes: 7267ec008b5c ("mm: postpone page table allocation until we have page to map")
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>
> ---
>  mm/memory.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 4425b60..0400483 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3133,6 +3133,8 @@ static int do_fault_around(struct fault_env *fe, pgoff_t start_pgoff)
> 
>  	if (pmd_none(*fe->pmd)) {
>  		fe->prealloc_pte = pte_alloc_one(fe->vma->vm_mm, fe->address);
> +		if (!fe->prealloc_pte)
> +			goto out;
>  		smp_wmb(); /* See comment in __pte_alloc() */
>  	}
> 
> --
> 1.9.1
> 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

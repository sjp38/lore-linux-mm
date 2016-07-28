Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 944C66B0253
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 08:21:41 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id 33so15403248lfw.1
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 05:21:41 -0700 (PDT)
Received: from mail-lf0-x242.google.com (mail-lf0-x242.google.com. [2a00:1450:4010:c07::242])
        by mx.google.com with ESMTPS id a140si5931747lfa.176.2016.07.28.05.21.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jul 2016 05:21:40 -0700 (PDT)
Received: by mail-lf0-x242.google.com with SMTP id l89so3581964lfi.2
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 05:21:40 -0700 (PDT)
Date: Thu, 28 Jul 2016 15:21:37 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: fail prefaulting if page table allocation fails
Message-ID: <20160728122137.GA24367@node.shutemov.name>
References: <1469708107-11868-1-git-send-email-vegard.nossum@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1469708107-11868-1-git-send-email-vegard.nossum@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vegard Nossum <vegard.nossum@oracle.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Thu, Jul 28, 2016 at 02:15:07PM +0200, Vegard Nossum wrote:
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
> We don't need to return VM_FAULT_OOM (or any other error) here, since we
> can just let the normal fault path try again.
> 
> Fixes: 7267ec008b5c ("mm: postpone page table allocation until we have page to map")
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Worth noticing that it's failure of order-0 allocation and unlikely to
ever happen under normal workloads without fault injection for page
allocator.

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
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

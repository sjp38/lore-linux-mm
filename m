Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id D230A6B0035
	for <linux-mm@kvack.org>; Thu, 29 May 2014 17:04:45 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id g10so157522pdj.29
        for <linux-mm@kvack.org>; Thu, 29 May 2014 14:04:45 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id px17si2525998pab.171.2014.05.29.14.04.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 29 May 2014 14:04:44 -0700 (PDT)
Received: by mail-pa0-f47.google.com with SMTP id ld10so897177pab.20
        for <linux-mm@kvack.org>; Thu, 29 May 2014 14:04:44 -0700 (PDT)
Date: Thu, 29 May 2014 14:03:33 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: BUG at mm/memory.c:1489!
In-Reply-To: <1401353983.4930.15.camel@concordia>
Message-ID: <alpine.LSU.2.11.1405291350260.10186@eggly.anvils>
References: <1401265922.3355.4.camel@concordia> <alpine.LSU.2.11.1405281712310.7156@eggly.anvils> <1401353983.4930.15.camel@concordia>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, trinity@vger.kernel.org

On Thu, 29 May 2014, Michael Ellerman wrote:
> 
> Unfortunately I don't know our mm/hugetlb code well enough to give you a good
> answer. Ben had a quick look at our follow_huge_addr() and thought it looked
> "fishy". He suggested something like what we do in gup_pte_range() with
> page_cache_get_speculative() might be in order.

Fishy indeed, ancient code that was only ever intended for stats-like
usage, not designed for actually getting a hold on the page.  But I
don't think there's a big problem to getting the locking right: just
hope it doesn't require a different strategy on each architecture -
often an irritation with hugetlb.  Naoya-san will sort it out in
due course (not 3.15) I expect, but will probably need testing help.

> 
> Applying your patch and running trinity pretty immediately results in the
> following, which looks related (sys_move_pages() again) ?
> 
> Unable to handle kernel paging request for data at address 0xf2000f80000000
> Faulting instruction address: 0xc0000000001e29bc
> cpu 0x1b: Vector: 300 (Data Access) at [c0000003c70f76f0]
>     pc: c0000000001e29bc: .remove_migration_pte+0x9c/0x320
>     lr: c0000000001e29b8: .remove_migration_pte+0x98/0x320
>     sp: c0000003c70f7970
>    msr: 8000000000009032
>    dar: f2000f80000000
>  dsisr: 40000000
>   current = 0xc0000003f9045800
>   paca    = 0xc000000001dc6c00   softe: 0        irq_happened: 0x01
>     pid   = 3585, comm = trinity-c27
> enter ? for help
> [c0000003c70f7a20] c0000000001bce88 .rmap_walk+0x328/0x470
> [c0000003c70f7ae0] c0000000001e2904 .remove_migration_ptes+0x44/0x60
> [c0000003c70f7b80] c0000000001e4ce8 .migrate_pages+0x6d8/0xa00
> [c0000003c70f7cc0] c0000000001e55ec .SyS_move_pages+0x5dc/0x7d0
> [c0000003c70f7e30] c00000000000a1d8 syscall_exit+0x0/0x98
> --- Exception: c01 (System Call) at 00003fff7b2b30a8
> SP (3fffe09728a0) is in userspace
> 1b:mon> 
> 
> I've hit it twice in two runs:
> 
> If I tell trinity to skip sys_move_pages() it runs for hours.

That's sad.  Sorry for wasting your time with my patch, thank you
for trying it.  What you see might be a consequence of the locking
deficiency I mentioned, given trinity's deviousness; though if it's
being clever like that, I would expect it to have already found the
equivalent issue on x86-64.  So probably not, probably another issue.

As I've said elsewhere, I think we need to go with disablement for now.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

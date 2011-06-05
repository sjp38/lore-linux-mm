Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8E1936B0111
	for <linux-mm@kvack.org>; Sun,  5 Jun 2011 15:16:21 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id p55JGF0i029425
	for <linux-mm@kvack.org>; Sun, 5 Jun 2011 12:16:19 -0700
Received: from pwi8 (pwi8.prod.google.com [10.241.219.8])
	by wpaz1.hot.corp.google.com with ESMTP id p55JGDiA004641
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 5 Jun 2011 12:16:14 -0700
Received: by pwi8 with SMTP id 8so2070273pwi.8
        for <linux-mm@kvack.org>; Sun, 05 Jun 2011 12:16:13 -0700 (PDT)
Date: Sun, 5 Jun 2011 12:16:08 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: ENOSPC returned by handle_mm_fault()
In-Reply-To: <20110605134317.GF11521@ZenIV.linux.org.uk>
Message-ID: <alpine.LSU.2.00.1106051141570.5792@sister.anvils>
References: <20110605134317.GF11521@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org

On Sun, 5 Jun 2011, Al Viro wrote:
> 	When alloc_huge_page() runs afoul of quota, it returns ERR_PTR(-ENOSPC).
> Callers do not expect that - hugetlb_cow() returns ENOSPC if it gets that
> and so does hugetlb_no_page().  Eventually the thing propagates back to
> hugetlb_fault() and is returned by it.
> 
> 	Callers of hugetlb_fault() clearly expect a bitmap of VM_... and
> not something from errno.h: one place is 
>                         ret = hugetlb_fault(mm, vma, vaddr,
>                                 (flags & FOLL_WRITE) ? FAULT_FLAG_WRITE : 0);
>                         spin_lock(&mm->page_table_lock);
>                         if (!(ret & VM_FAULT_ERROR))
>                                 continue;
> and another is handle_mm_fault(), which ends up returning ENOSPC and *its*
> callers are definitely not ready to deal with that.
> 
> ENOSPC is 28, i.e. VM_FAULT_MAJOR | VM_FAULT_WRITE | VM_FAULT_HWPOISON;
> it's also theoretically possible to get ENOMEM if region_chg() ends up
> hitting
>                 nrg = kmalloc(sizeof(*nrg), GFP_KERNEL);
>                 if (!nrg)
>                         return -ENOMEM;
> region_chg() <- vma_needs_reservation() <- alloc_huge_page() and from that
> point as with ENOSPC.  ENOMEM is 12, i.e. VM_FAULT_MAJOR | VM_FAULT_WRITE...

Good find, news to me.  Interesting uses of -PTR_ERR()!
Looks like we'd better not have more than 12 VM_FAULT_ flags.

> 
> Am I right assuming that we want VM_FAULT_OOM in both cases?

No, where hugetlb_get_quota() fails it should be VM_FAULT_SIGBUS:
there's no excuse to go on an OOM-killing spree just because hugetlb
quota is exhausted.

VM_FAULT_OOM is appropriate where vma_needs_reservation() fails,
because region_chg() couldn't kmalloc a structure, as you point out.

(Though that doesn't matter much, since the only way the kmalloc can
fail is when this task is already selected for OOM-kill - I think.)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

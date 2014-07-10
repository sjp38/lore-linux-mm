Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 1086482965
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 21:06:32 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so10142164pab.32
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 18:06:31 -0700 (PDT)
Received: from mail-pd0-x235.google.com (mail-pd0-x235.google.com [2607:f8b0:400e:c02::235])
        by mx.google.com with ESMTPS id d10si7955873pdp.26.2014.07.09.18.06.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 09 Jul 2014 18:06:30 -0700 (PDT)
Received: by mail-pd0-f181.google.com with SMTP id v10so9752069pde.26
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 18:06:30 -0700 (PDT)
Date: Wed, 9 Jul 2014 18:04:51 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: + shmem-fix-faulting-into-a-hole-while-its-punched-take-2.patch
 added to -mm tree
In-Reply-To: <alpine.LSU.2.11.1407091000410.11705@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1407091801160.16410@eggly.anvils>
References: <53b45c9b.2rlA0uGYBLzlXEeS%akpm@linux-foundation.org> <53BCBF1F.1000506@oracle.com> <alpine.LSU.2.11.1407082309040.7374@eggly.anvils> <53BD1053.5020401@suse.cz> <53BD39FC.7040205@oracle.com> <53BD67DC.9040700@oracle.com> <53BD6F4E.6030003@suse.cz>
 <alpine.LSU.2.11.1407091000410.11705@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Sasha Levin <sasha.levin@oracle.com>, akpm@linux-foundation.org, davej@redhat.com, koct9i@gmail.com, lczerner@redhat.com, stable@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 9 Jul 2014, Hugh Dickins wrote:
> On Wed, 9 Jul 2014, Vlastimil Babka wrote:
> > On 07/09/2014 06:03 PM, Sasha Levin wrote:
> > > 
> > > We can see that it's not blocked since it's in the middle of a spinlock
> > > unlock
> > > call, and we can guess it's been in that function for a while because of
> > > the hung
> > > task timer, and other processes waiting on that i_mmap_mutex:
> > 
> > Hm, zap_pte_range has potentially an endless loop due to the 'goto again'
> > path. Could it be a somewhat similar situation to the fallocate problem, but
> > where parallel faulters on shared memory are preventing a process from
> > exiting? Although they don't fault the pages into the same address space,
> > they could maybe somehow interact through the TLB flushing code? And only
> > after fixing the original problem we can observe this one?
> 
> That's a good thought.  It ought to make forward progress nonetheless,
> but I believe (please check, I'm rushing) that there's an off-by-one in
> that path which could leave us hanging - but only when __tlb_remove_page()
> repeatedly fails, which would only happen if exceptionally low on memory??
> 
> Does this patch look good, and does it make any difference to the hang?

I should add that I think that this patch is correct in itself, but
won't actually make any difference to anything.  I'm still looking
through Sasha's log for clues (but shall have to give up soon).

Hugh

> 
> --- mmotm/mm/memory.c	2014-07-02 15:32:22.212311544 -0700
> +++ linux/mm/memory.c	2014-07-09 09:56:33.724159443 -0700
> @@ -1145,6 +1145,7 @@ again:
>  			if (unlikely(page_mapcount(page) < 0))
>  				print_bad_pte(vma, addr, ptent, page);
>  			if (unlikely(!__tlb_remove_page(tlb, page))) {
> +				addr += PAGE_SIZE;
>  				force_flush = 1;
>  				break;
>  			}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

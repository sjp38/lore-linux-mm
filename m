Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 766676B0037
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 17:45:16 -0400 (EDT)
Received: by mail-ig0-f180.google.com with SMTP id h18so2541186igc.13
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 14:45:16 -0700 (PDT)
Received: from mail-ig0-x22d.google.com (mail-ig0-x22d.google.com [2607:f8b0:4001:c05::22d])
        by mx.google.com with ESMTPS id x13si3751495icq.42.2014.06.12.14.45.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Jun 2014 14:45:15 -0700 (PDT)
Received: by mail-ig0-f173.google.com with SMTP id r2so6242379igi.6
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 14:45:15 -0700 (PDT)
Date: Thu, 12 Jun 2014 14:45:13 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: Move __vma_address() to internal.h to be inlined in
 huge_memory.c
In-Reply-To: <539A1CDA.5000709@hp.com>
Message-ID: <alpine.DEB.2.02.1406121444140.12437@chino.kir.corp.google.com>
References: <1402600540-52031-1-git-send-email-Waiman.Long@hp.com> <20140612122546.cfdebdb22bb22c0f767e30b5@linux-foundation.org> <539A1CDA.5000709@hp.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <waiman.long@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Scott J Norton <scott.norton@hp.com>

On Thu, 12 Jun 2014, Waiman Long wrote:

> > > The vma_address() function which is used to compute the virtual address
> > > within a VMA is used only by 2 files in the mm subsystem - rmap.c and
> > > huge_memory.c. This function is defined in rmap.c and is inlined by
> > > its callers there, but it is also declared as an external function.
> > > 
> > > However, the __split_huge_page() function which calls vma_address()
> > > in huge_memory.c is calling it as a real function call. This is not
> > > as efficient as an inlined function. This patch moves the underlying
> > > inlined __vma_address() function to internal.h to be shared by both
> > > the rmap.c and huge_memory.c file.
> > This increases huge_memory.o's text+data_bss by 311 bytes, which makes
> > me suspect that it is a bad change due to its increase of kernel cache
> > footprint.
> > 
> > Perhaps we should be noinlining __vma_address()?
> 
> On my test machine, I saw an increase of 144 bytes in the text segment
> of huge_memory.o. The size in size is caused by an increase in the size
> of the __split_huge_page function. When I remove the
> 
>         if (unlikely(is_vm_hugetlb_page(vma)))
>                 pgoff = page->index << huge_page_order(page_hstate(page));
> 
> check, the increase in size drops down to 24 bytes. As a THP cannot be
> a hugetlb page, there is no point in doing this check for a THP. I will
> update the patch to pass in an additional argument to disable this
> check for __split_huge_page.
> 

I think we're seeking a reason or performance numbers that suggest 
__vma_address() being inline is appropriate and so far we lack any such 
evidence.  Adding additional parameters to determine checks isn't going to 
change the fact that it increases text size needlessly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

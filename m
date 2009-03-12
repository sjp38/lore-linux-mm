Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 91B446B004F
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 07:28:48 -0400 (EDT)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate7.de.ibm.com (8.14.3/8.13.8) with ESMTP id n2CBRv1R270488
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 11:27:57 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2CBRvjv3145810
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 12:27:57 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2CBRuQO000672
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 12:27:57 +0100
Date: Thu, 12 Mar 2009 12:24:41 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH] fix/improve generic page table walker
Message-ID: <20090312122441.46782f9b@skybase>
In-Reply-To: <20090312111916.5dbdb1e5@skybase>
References: <20090311144951.58c6ab60@skybase>
	<1236792263.3205.45.camel@calx>
	<20090312093335.6dd67251@skybase>
	<20090312111916.5dbdb1e5@skybase>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Gerald Schaefer <gerald.schaefer@de.ibm.com>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, 12 Mar 2009 11:19:16 +0100
Martin Schwidefsky <schwidefsky@de.ibm.com> wrote:

> On Thu, 12 Mar 2009 09:33:35 +0100
> Martin Schwidefsky <schwidefsky@de.ibm.com> wrote:
> 
> > > I've gone to lengths to keep VMAs out of the equation, so I can't say
> > > I'm excited about this solution.  
> > 
> > The minimum fix is to add the mmap_sem. If a vma is unmapped while you
> > walk the page tables, they can get freed. You do have a dependency on
> > the vma list. All the other page table walkers in mm/ start with the
> > vma, then do the four loops. It would be consistent if the generic page
> > table walker would do the same.
> > 
> > Having thought about the problem again, I think I found a way how to
> > deal with the problem in the s390 page table primitives. The fix is not
> > exactly nice but it will work. With it s390 will be able to walk
> > addresses outside of the vma address range.
> 
> Ok, the patch below fixes the problem without vma operations in the
> generic page table walker. We still need the mmap_sem part though.

Hmm, thinko on my part. If would need the address of the pgd entry to do
what I'm trying to achieve but I only have the pgd entry itself. Back
to the vma operation in walk_page_range I'm afraid.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

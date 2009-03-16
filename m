Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id C5BA16B003D
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 09:01:46 -0400 (EDT)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.14.3/8.13.8) with ESMTP id n2GD0k7M204712
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 13:00:46 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2GD0k8k3973222
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 14:00:46 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2GD0j8w030507
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 14:00:46 +0100
Date: Mon, 16 Mar 2009 13:55:44 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH] fix/improve generic page table walker
Message-ID: <20090316135544.52719f04@skybase>
In-Reply-To: <20090316123654.GF30802@wotan.suse.de>
References: <20090311144951.58c6ab60@skybase>
	<1236792263.3205.45.camel@calx>
	<20090312093335.6dd67251@skybase>
	<1236867014.3213.16.camel@calx>
	<20090312154229.3ee463eb@skybase>
	<1236873494.3213.55.camel@calx>
	<20090316132717.69f6f4ce@skybase>
	<20090316123654.GF30802@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Gerald Schaefer <gerald.schaefer@de.ibm.com>, akpm@linux-foundation.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Mon, 16 Mar 2009 13:36:54 +0100
Nick Piggin <npiggin@suse.de> wrote:

> > With the page table folding "3 levels removed from the bottom" doesn't
> > tell me much since there is no real representation in hardware AND in
> > memory for the missing page table levels. So the only valid meaning of
> > a pgd_t is that you have to use pud_offset, pmd_offset and pte_offset
> > to get to a pte. If I do the page table folding at runtime or at
> > compile time is a minor detail.  
> 
> I don't know if it would be helpful to you, but I solve a similar
> kind of problem in the lockless radix tree by encoding node height
> in the node itself. Maybe you could use some bits in the page table
> pointers or even in the struct pages for this.

That is what I already do: there are two bits in the region and segment
table entries that tell me at what level I am (well actually it is the
hardware definition that requires me to do that and I just make use of
it). The page table primitives (pxd_present, pxd_offset, etc) look at
these bits and then do the right thing.
What is killing me is the pgd++/pud++ operation. If there is only a 2
or 3 level page table the pointer increase may not happen. This is done
by a correct end address for the walk. 

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

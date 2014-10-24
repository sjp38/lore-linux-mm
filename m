Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id ADB3E82BDA
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 03:26:51 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id v10so967974pde.36
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 00:26:51 -0700 (PDT)
Received: from bombadil.infradead.org ([2001:1868:205::9])
        by mx.google.com with ESMTPS id sg8si3459012pbb.202.2014.10.24.00.26.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Oct 2014 00:26:48 -0700 (PDT)
Date: Fri, 24 Oct 2014 09:26:07 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC][PATCH 4/6] SRCU free VMAs
Message-ID: <20141024072607.GT21513@worktop.programming.kicks-ass.net>
References: <20141020215633.717315139@infradead.org>
 <20141020222841.419869904@infradead.org>
 <5448D515.90006@cn.fujitsu.com>
 <20141023110346.GP21513@worktop.programming.kicks-ass.net>
 <5449C8A6.9080403@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5449C8A6.9080403@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Cc: torvalds@linux-foundation.org, paulmck@linux.vnet.ibm.com, tglx@linutronix.de, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, oleg@redhat.com, mingo@redhat.com, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, viro@zeniv.linux.org.uk, dave@stgolabs.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Oct 24, 2014 at 11:33:58AM +0800, Lai Jiangshan wrote:
> On 10/23/2014 07:03 PM, Peter Zijlstra wrote:
> > On Thu, Oct 23, 2014 at 06:14:45PM +0800, Lai Jiangshan wrote:
> >>
> >>>  
> >>> +struct vm_area_struct *find_vma_srcu(struct mm_struct *mm, unsigned long addr)
> >>> +{
> >>> +	struct vm_area_struct *vma;
> >>> +	unsigned int seq;
> >>> +
> >>> +	WARN_ON_ONCE(!srcu_read_lock_held(&vma_srcu));
> >>> +
> >>> +	do {
> >>> +		seq = read_seqbegin(&mm->mm_seq);
> >>> +		vma = __find_vma(mm, addr);
> >>
> >> will the __find_vma() loops for ever due to the rotations in the RBtree?
> > 
> > No, a rotation takes a tree and generates a tree, furthermore the
> > rotation has a fairly strict fwd progress guarantee seeing how its now
> > done with preemption disabled.
> 
> I can't get the magic.
> 
> __find_vma is visiting vma_a,
> vma_a is rotated to near the top due to multiple updates to the mm.
> __find_vma is visiting down to near the bottom, vma_b.
> now vma_b is rotated up to near the top again.
> __find_vma is visiting down to near the bottom, vma_c.
> now vma_c is rotated up to near the top again.
> 
> ...

Why would there be that much rotations? Is this a scenario where someone
is endlessly changing the tree?

If you stop updating the tree, the traversal will finish.

This is no different to the reader starvation already present with
seqlocks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

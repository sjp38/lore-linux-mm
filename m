Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 231CC6B0069
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 07:03:53 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id z10so836255pdj.29
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 04:03:52 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id qo15si1319672pab.123.2014.10.23.04.03.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Oct 2014 04:03:52 -0700 (PDT)
Date: Thu, 23 Oct 2014 13:03:46 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC][PATCH 4/6] SRCU free VMAs
Message-ID: <20141023110346.GP21513@worktop.programming.kicks-ass.net>
References: <20141020215633.717315139@infradead.org>
 <20141020222841.419869904@infradead.org>
 <5448D515.90006@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5448D515.90006@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Cc: torvalds@linux-foundation.org, paulmck@linux.vnet.ibm.com, tglx@linutronix.de, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, oleg@redhat.com, mingo@redhat.com, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, viro@zeniv.linux.org.uk, dave@stgolabs.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Oct 23, 2014 at 06:14:45PM +0800, Lai Jiangshan wrote:
> 
> >  
> > +struct vm_area_struct *find_vma_srcu(struct mm_struct *mm, unsigned long addr)
> > +{
> > +	struct vm_area_struct *vma;
> > +	unsigned int seq;
> > +
> > +	WARN_ON_ONCE(!srcu_read_lock_held(&vma_srcu));
> > +
> > +	do {
> > +		seq = read_seqbegin(&mm->mm_seq);
> > +		vma = __find_vma(mm, addr);
> 
> will the __find_vma() loops for ever due to the rotations in the RBtree?

No, a rotation takes a tree and generates a tree, furthermore the
rotation has a fairly strict fwd progress guarantee seeing how its now
done with preemption disabled.

Therefore, even if we're in a node that's being rotated up, we can only
'loop' for as long as it takes for the new pointer stores to become
visible on our CPU.

Thus we have a tree descent termination guarantee.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

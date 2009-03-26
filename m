Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A53B06B003D
	for <linux-mm@kvack.org>; Thu, 26 Mar 2009 15:37:33 -0400 (EDT)
Date: Thu, 26 Mar 2009 13:39:29 -0700 (PDT)
Message-Id: <20090326.133929.157003101.davem@davemloft.net>
Subject: Re: tlb_gather_mmu() and semantics of "fullmm"
From: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0903261232060.27412@blonde.anvils>
References: <1238043674.25062.823.camel@pasglop>
	<Pine.LNX.4.64.0903261232060.27412@blonde.anvils>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: hugh@veritas.com
Cc: benh@kernel.crashing.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, npiggin@suse.de, zach@vmware.com, jeremy@goop.org
List-ID: <linux-mm.kvack.org>

From: Hugh Dickins <hugh@veritas.com>
Date: Thu, 26 Mar 2009 14:08:17 +0000 (GMT)

> On Thu, 26 Mar 2009, Benjamin Herrenschmidt wrote:
> > If it means the later (which it does in practice today, since we only
> > call it from exit_mmap(), unless I missed an important detail), then I
> > could implement some optimisations in my own arch code, but more
> 
> Yes, I'm pretty sure you can assume the latter.  The whole point
> of the "full mm" stuff (would have better been named "exit mm") is
> to allow optimizations, and I don't see what optimization there is to
> be made from knowing you're going the whole length of the mm; whereas
> optimizations can be made if you know nothing can happen in parallel.
> 
> Cc'ed DaveM who introduced it for sparc64, and Zach and Jeremy
> who have delved there, in case they wish to disagree.

The TLBs on sparc64 have a "context flush" which removes every entry
matching the current MMU context.  This is what flush_tlb_mm() does.

So we use tlb->fullmm so that the individual page and range TLB
flushes do nothing, and instead we do a flush_tlb_mm() before we walk
through the address space to tear it down.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

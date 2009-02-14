Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 850616B003D
	for <linux-mm@kvack.org>; Sat, 14 Feb 2009 04:56:17 -0500 (EST)
Subject: Re: [PATCH] mm: disable preemption in apply_to_pte_range
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <4995ACD5.9000201@goop.org>
References: <4994BCF0.30005@goop.org>	<4994C052.9060907@goop.org>
	 <20090212165539.5ce51468.akpm@linux-foundation.org>
	 <4994CF35.60507@goop.org> <1234525710.6519.17.camel@twins>
	 <4995ACD5.9000201@goop.org>
Content-Type: text/plain
Date: Sat, 14 Feb 2009 10:56:01 +0100
Message-Id: <1234605361.4698.23.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Fri, 2009-02-13 at 09:24 -0800, Jeremy Fitzhardinge wrote:
> Peter Zijlstra wrote:
> >> The specific rules are that 
> >> arch_enter_lazy_mmu_mode()/arch_leave_lazy_mmu_mode() require you to be 
> >> holding the appropriate pte locks for the ptes you're updating, so 
> >> preemption is naturally disabled in that case.
> >>     
> >
> > Right, except on -rt where the pte lock is a mutex.
> >   
> 
> Hm, that's interesting.  The requirement isn't really "no preemption", 
> its "must not migrate to another cpu".  Is there a better way to express 
> that?

Not really, in the past something like migrate_disable() has been
proposed, however that's problematic in that it can generate latencies
that are _very_ hard to track down, so we've always resisted that and
found other ways.

> >> This all goes a bit strange with init_mm's non-requirement for taking 
> >> pte locks.  The caller has to arrange for some kind of serialization on 
> >> updating the range in question, and that could be a mutex.  Explicitly 
> >> disabling preemption in enter_lazy_mmu_mode would make sense for this 
> >> case, but it would be redundant for the common case of batched updates 
> >> to usermode ptes.
> >>     
> >
> > I really utterly hate how you just plonk preempt_disable() in there
> > unconditionally and without very clear comments on how and why.
> >   
> 
> Well, there's the commit comment.  They're important, right?  That's why 
> we spend time writing good commit comments?  So they get read?  ;)

Andrew taught me that indeed, but still when looking at the code its
good to have some text there explaining things too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

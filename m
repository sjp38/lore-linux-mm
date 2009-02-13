Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id F3F1E6B003D
	for <linux-mm@kvack.org>; Fri, 13 Feb 2009 12:24:49 -0500 (EST)
Message-ID: <4995ACD5.9000201@goop.org>
Date: Fri, 13 Feb 2009 09:24:37 -0800
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: disable preemption in apply_to_pte_range
References: <4994BCF0.30005@goop.org>	<4994C052.9060907@goop.org>	 <20090212165539.5ce51468.akpm@linux-foundation.org>	 <4994CF35.60507@goop.org> <1234525710.6519.17.camel@twins>
In-Reply-To: <1234525710.6519.17.camel@twins>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:
>> The specific rules are that 
>> arch_enter_lazy_mmu_mode()/arch_leave_lazy_mmu_mode() require you to be 
>> holding the appropriate pte locks for the ptes you're updating, so 
>> preemption is naturally disabled in that case.
>>     
>
> Right, except on -rt where the pte lock is a mutex.
>   

Hm, that's interesting.  The requirement isn't really "no preemption", 
its "must not migrate to another cpu".  Is there a better way to express 
that?

>> This all goes a bit strange with init_mm's non-requirement for taking 
>> pte locks.  The caller has to arrange for some kind of serialization on 
>> updating the range in question, and that could be a mutex.  Explicitly 
>> disabling preemption in enter_lazy_mmu_mode would make sense for this 
>> case, but it would be redundant for the common case of batched updates 
>> to usermode ptes.
>>     
>
> I really utterly hate how you just plonk preempt_disable() in there
> unconditionally and without very clear comments on how and why.
>   

Well, there's the commit comment.  They're important, right?  That's why 
we spend time writing good commit comments?  So they get read?  ;)

OK, I'll add a comment, particularly if there's a more precise way to 
express "no migration".

> I'd rather we'd fix up the init_mm to also have a pte lock.
>   
Yes, I don't like the init_mm-exceptionalism either.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

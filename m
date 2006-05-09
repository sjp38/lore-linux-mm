Message-ID: <445FF2F2.6080102@yahoo.com.au>
Date: Tue, 09 May 2006 11:40:02 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Any reason for passing "tlb" to "free_pgtables()" by address?
References: <445B2EBD.4020803@bull.net> <Pine.LNX.4.64.0605051337520.6945@blonde.wat.veritas.com> <445FBD1B.6080404@free.fr>
In-Reply-To: <445FBD1B.6080404@free.fr>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zoltan Menyhart <Zoltan.Menyhart@free.fr>
Cc: Hugh Dickins <hugh@veritas.com>, Zoltan Menyhart <Zoltan.Menyhart@bull.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Zoltan Menyhart wrote:

> Hugh Dickins wrote:
>
>> Personally I'd prefer not to make your change right now - it seems
>> a shame to make that cosmetic change without addressing the real
>> latency issue; but I've no strong feeling against your patch.
>
>
> Could you please explain what your plans are?


Long term, we would like to make the mmu_gather paths preemptible and
reentrant so the latency hacks can go away, and we don't end up with
awful things like a tlb flush after unmapping every 8 pages for
CONFIG_PREEMPT.

I posted a quick RFC a while back to implement my "gather in place"
idea: http://www.ussg.iu.edu/hypermail/linux/kernel/0603.2/0499.html

Hugh has a different approach, but neither is particularly urgent at
this stage.

In the short term, we might still like to be able to do latency breaks
in free_pgtables so it would make sense to keep the code the way it is.

>
> How much do you think it is worth to optimize "free_pgtables()",
> knowing that:
> - PTE, PMD and PUD pages are freed seldom (wrt. the leaf pages)
> - The number of these pages is much more less than
>   that of the leaf pages.


Virtual address space can still be vast and sparse. Even with 32 bits,
we could probably trigger high latencies here.

Nick
--

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

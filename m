Message-ID: <4639DED0.2070507@yahoo.com.au>
Date: Thu, 03 May 2007 23:08:32 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: 2.6.22 -mm merge plans -- vm bugfixes
References: <20070430162007.ad46e153.akpm@linux-foundation.org> <4636FDD7.9080401@yahoo.com.au> <Pine.LNX.4.64.0705011931520.16502@blonde.wat.veritas.com> <4638009E.3070408@yahoo.com.au> <Pine.LNX.4.64.0705021418030.16517@blonde.wat.veritas.com> <46393BA7.6030106@yahoo.com.au> <Pine.LNX.4.64.0705031306300.24945@blonde.wat.veritas.com> <4639D8E8.2090608@yahoo.com.au> <Pine.LNX.4.64.0705031351180.29450@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0705031351180.29450@blonde.wat.veritas.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <andrea@suse.de>, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Thu, 3 May 2007, Nick Piggin wrote:
> 
>>>>@@ -568,6 +570,11 @@ __lock_page (diff -p would tell us!)
>>>>{
>>>> DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
>>>>
>>>>+	set_bit(PG_waiters, &page->flags);
>>>>+	if (unlikely(!TestSetPageLocked(page))) {
>>>
>>>What happens if another cpu is coming through __lock_page at the
>>>same time, did its set_bit, now finds PageLocked, and so proceeds
>>>to the __wait_on_bit_lock?  But this cpu now clears PG_waiters,
>>>so this task's unlock_page won't wake the other?
>>
>>You're right, we can't clear the bit here. Doubt it mattered much anyway?
> 
> 
> Ah yes, that's a good easy answer.  In fact, just remove this whole
> test and block (we already tried TestSetPageLocked outside just a
> short while ago, so this repeat won't often save anything).

Yeah, I was getting too clever for my own boots :)

I think the patch has merit though. Unfortunate that it uses another page
flag, however it seemed to have quite a bit speedup on unlock_page (probably
from both the barriers and an extra random cacheline load (from the hash)).

I guess it has to get good results from more benchmarks...


>>BTW. I also forgot an smp_mb__after_clear_bit() before the wake_up_page
>>above... that barrier is in the slow path as well though, so it shouldn't
>>matter either.
> 
> 
> I vaguely wondered how such barriers had managed to dissolve away,
> but cranking my brain up to think about barriers takes far too long.

That barrier was one too many :)

However I believe the fastpath barrier can go away because the PG_locked
operation is depending on the same cacheline as PG_waiters.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

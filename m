Message-ID: <461E30A6.5030203@yahoo.com.au>
Date: Thu, 12 Apr 2007 23:14:14 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] make MADV_FREE lazily free memory
References: <461C6452.1000706@redhat.com> <461D6413.6050605@cosmosbay.com> <461D67A9.5020509@redhat.com> <461DC75B.8040200@cosmosbay.com> <461DCCEB.70004@yahoo.com.au> <461DCDDA.2030502@yahoo.com.au> <461DDE44.2040409@redhat.com>
In-Reply-To: <461DDE44.2040409@redhat.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Eric Dumazet <dada1@cosmosbay.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Ulrich Drepper <drepper@redhat.com>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> Nick Piggin wrote:
> 
>> Nick Piggin wrote:
>>
>>> Eric Dumazet wrote:

>>>> ah ok, this is because accessed/dirty bits are set by hardware and 
>>>> not a page fault.
>>>
>>>
>>>
>>> No it isn't.
>>
>>
>> That is to say, it isn't required for correctness. But if the
>> question was about avoiding a fault, then yes ;)
> 
> 
> Making the pte clean also needs to clear the hardware writable
> bit on architectures where we do pte dirtying in software.
> 
> If we don't, we would have corruption problems all over the VM,
> for example in the code around pte_clean_one :)

Sure. Hence why I say that having hardware set a/d bits are not
required for correctness ;)

>> But as Linus recently said, even hardware handled faults still
>> take expensive microarchitectural traps.
> 
> 
> Nowhere near as expensive as a full page fault, though...

I don't doubt that. Do you know rough numbers?


> The lazy freeing is aimed at avoiding page faults on memory
> that is freed and later realloced, which is quite a common
> thing in many workloads.

I would be interested to see how it performs and what these
workloads look like, although we do need to fix the basic glibc and
madvise locking problems first.

The obvious concerns I have with the patch are complexity (versus
payoff), behaviour under reclaim, and behaviour when freed memory
isn't reallocated very quickly (eg. degrading cache performance).

We'll see, I guess...

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

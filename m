Message-ID: <43BF3A06.10502@yahoo.com.au>
Date: Sat, 07 Jan 2006 14:48:22 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] use local_t for page statistics
References: <20060106215332.GH8979@kvack.org> <200601070401.47618.ak@suse.de> <43BF3355.5060606@yahoo.com.au> <200601070425.24810.ak@suse.de>
In-Reply-To: <200601070425.24810.ak@suse.de>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Andrew Morton <akpm@osdl.org>, Benjamin LaHaise <bcrl@kvack.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
> On Saturday 07 January 2006 04:19, Nick Piggin wrote:
> 
>>Andi Kleen wrote:
>>
>>>On Saturday 07 January 2006 03:52, Nick Piggin wrote:
>>>
>>>
>>>
>>>>No. On many load/store architectures there is no good way to do local_t,
>>>>so something like ppc32 or ia64 just uses all atomic operations for
>>>
>>>
>>>well, they're just broken and need to be fixed to not do that.
>>>
>>
>>How?
> 
> 
> If anything use the 3x duplicated data setup, not atomic operations.
> 

At a 3x cache footprint cost? (and probably more than 3x for icache, though
I haven't checked) And I think hardware trends are against us. (Also, does
it have race issues with nested interrupts that Andrew noticed?)

> 
>>>Also I bet with some tricks a seqlock like setup could be made to work.
>>>
>>
>>I asked you how before. If you can come up with a way then it indeed
>>might be a good solution... 
> 
> 
> I'll try to work something up.
> 

Cool, I'd be interested to see.

> 
>>The problem I see with seqlock is that it 
>>is only fast in the read path. That path is not the issue here.
> 
> 
> The common case - not getting interrupted would be fast.
> 

The problem is that you can never do the final store without risking a
race with an interrupt. Because it is not a read-path.

The closest think I can see to a seqlock would be ll/sc operations, at
which point you're back to atomic ops.

> 
>>>>local_t, and ppc64 uses 3 counters per-cpu thus tripling the cache
>>>>footprint.
>>>
>>>
>>>and ppc64 has big caches so this also shouldn't be a problem.
>>>
>>
>>Well it is even less of a problem for them now, by about 1/3.
>>
>>Performance-wise there is really no benefit for even i386 or x86-64
>>to move to local_t now either so I don't see what the fuss is about.
> 
> 
> Actually P4 doesn't like CLI/STI. For AMD and P-M it's not that much an issue,
> but NetBurst really doesn't like it.
> 

Yes, it was worth over a second of real time and ~ 7% total kernel
time on kbuild on a P4.

(git: a74609fafa2e5cc31d558012abaaa55ec9ad9da4)

AMD and PM I didn't test but the improvement might still be noticable,
if much smaller.

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Message-ID: <456F4A95.2090503@yahoo.com.au>
Date: Fri, 01 Dec 2006 08:18:13 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: The VFS cache is not freed when there is not enough free memory
 to allocate
References: <6d6a94c50611212351if1701ecx7b89b3fe79371554@mail.gmail.com>	 <1164185036.5968.179.camel@twins>	 <6d6a94c50611220202t1d076b4cye70dcdcc19f56e55@mail.gmail.com>	 <456A964D.2050004@yahoo.com.au>	 <4e5ebad50611282317r55c22228qa5333306ccfff28e@mail.gmail.com>	 <6d6a94c50611290127u2b26976en1100217a69d651c0@mail.gmail.com>	 <456D5347.3000208@yahoo.com.au> <6d6a94c50611300454g22196d2frec54e701abaebf17@mail.gmail.com>
In-Reply-To: <6d6a94c50611300454g22196d2frec54e701abaebf17@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Aubrey <aubreylee@gmail.com>
Cc: Sonic Zhang <sonic.adi@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, vapier.adi@gmail.com
List-ID: <linux-mm.kvack.org>

Aubrey wrote:
> On 11/29/06, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
>> That was the order-9 allocation failure. Which is not going to be
>> solved properly by just dropping caches.
>>
>> But Sonic apparently saw failures with 4K allocations, where the
>> caches weren't getting shrunk properly. This would be more interesting
>> because it would indicate a real problem with the kernel.
>>
> I have done several test cases. when cat /proc/meminfo show MemFree < 
> 8192KB,
> 
> 1) malloc(1024 * 4),  256 times = 8MB, allocation successful.
> 2) malloc(1024 * 16),  64 times = 8MB, allocation successful.
> 3) malloc(1024 * 64),  16 times = 8MB, allocation successful.
> 4) malloc(1024 * 128),  8 times = 8MB, allocation failed.
> 5) malloc(1024 * 256),  4 times = 8MB, allocation failed.
> 
>> From those results,  we know, when allocation <=64K, cache can be
> 
> shrunk properly.
> That means the malloc size of an application on nommu should be
> <=64KB. That's exactly our problem. Some video programmes need a big
> block which has contiguous physical address. But yes, as you said, we
> must keep malloc not to alloc a big block to make the current kernel
> working robust on nommu.
> 
> So, my question is, Can we improve this issue? why malloc(64K) is ok
> but malloc(128K) not? Is there any existing parameters about this
> issue? why not kernel attempt to shrunk cache no matter how big memory
> allocation is requested?
> 
> Any thoughts?

The pattern you are seeing here is probably due to the page allocator
always retrying process context allocations which are <= order 3 (64K
with 4K pages).

You might be able to increase this limit a bit for your system, but it
could easily cause problems. Especially fragmentation on nommu systems
where the anonymous memory cannot be paged out.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

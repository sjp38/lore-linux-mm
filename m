Message-ID: <4113218F.5050803@yahoo.com.au>
Date: Fri, 06 Aug 2004 16:13:35 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] 3/4: writeout watermarks
References: <41130FB1.5020001@yahoo.com.au>	<41130FD2.5070608@yahoo.com.au>	<41131105.8040108@yahoo.com.au>	<20040805222733.477b3017.akpm@osdl.org>	<41131862.5050000@yahoo.com.au> <20040805224920.6755198d.akpm@osdl.org>
In-Reply-To: <20040805224920.6755198d.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
>>No, it is not that code I am worried about, you're actually doing
>> this too (disregarding the admin's wishes):
>>
>>          dirty_ratio = vm_dirty_ratio;
>>          if (dirty_ratio > unmapped_ratio / 2)
>>                  dirty_ratio = unmapped_ratio / 2;
>>
>>          if (dirty_ratio < 5)
>>                  dirty_ratio = 5;
>>
> 
> 
> hm, OK, that's some "try to avoid writeback off the LRU" stuff.
> 

Yep

> But you said "This ensures we should always attempt to start background
> writeout before synchronous writeout.".  Does not the current code do that?
> 

Basically what the above code, is scale the dirty_ratio with the
amount of unmapped pages, however it doesn't also scale the
dirty_background_ratio (it does after my patch).

So it isn't difficult to imagine this causing dirty_ratio to become
very close to dirty_background_ratio.

The crude check prevents the values from becoming exactly equal.

	if (background_ratio >= dirty_ratio)
		background_ratio = dirty_ratio / 2;


> 
>> So if the admin wants a dirty_ratio of 40 and dirty_background_ratio of 10
>> then that's good, but I'm sure if they knew you're moving dirty_ratio to 10
>> here, they'd want something like 2 for the dirty_background_ratio.
>>
>> I contend that the ratio between these two values is more important than
>> their absolue values -- especially considering one gets twiddled here.
> 
> 
> Maybe true, maybe false.  These things are demonstrable via testing, no?
> 
> 

Might be, I don't know how. Seemed straightforward (to me).
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

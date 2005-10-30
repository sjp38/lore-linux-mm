Message-ID: <436430BA.4010606@yahoo.com.au>
Date: Sun, 30 Oct 2005 13:32:26 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH]: Clean up of __alloc_pages
References: <20051028183326.A28611@unix-os.sc.intel.com>	<20051029184728.100e3058.pj@sgi.com>	<4364296E.1080905@yahoo.com.au> <20051029191946.1832adaf.pj@sgi.com>
In-Reply-To: <20051029191946.1832adaf.pj@sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: rohit.seth@intel.com, akpm@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Paul Jackson wrote:
> Nick, replying to pj:
> 
>>> 3) The "inline" you added to buffered_rmqueue() blew up my compile.
>>
>>How? Why? This should be solved because a future possible feature
>>(early allocation from pcp lists) will want inlining in order to
>>propogate the constant 'replenish' argument.
> 
> 
> 
> Perhaps "inline struct page *" would work better than "struct inline page *" ?
> ... yes ... that fixes my compiler complaints.
> 

Ah, yep.

> Also ... buffered_rmqueue() is a rather large function to be inlining.

It is, however there would only be 2 calls, and one I think would
also have a constant 0 for "order".

Though yeah, it may be better split another way. For this patch,
it shouldn't matter because it is static and will only have one
callsite so should be inlined anyway.

> And if it is inlined, then are you expecting to also have an out of
> line copy, for use by the call to it from mm/swap_prefetch.c
> prefetch_get_page()?
> 

No, that shouldn't be there though.

> Adding the 'inline' keyword increases my kernel text size by
> 1448 bytes, for the extra copy of this code used inline from
> the call to it from mm/page_alloc.c:get_page_from_freelist().
> Is that really worth it?
> 

Hmm, where is the other callsite? (sorry I don't have a copy
of -mm handy so I'm just looking at 2.6).

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

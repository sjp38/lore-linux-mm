Message-ID: <447F94B3.7030807@yahoo.com.au>
Date: Fri, 02 Jun 2006 11:30:27 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: ECC error correction - page isolation
References: <069061BE1B26524C85EC01E0F5CC3CC30163E1F1@rigel.headquarters.spacedev.com> <200606020146.33703.ak@suse.de>
In-Reply-To: <200606020146.33703.ak@suse.de>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Brian Lindahl <Brian.Lindahl@spacedev.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:

> If you get machine checks in normal accesses you have to bootstrap
> yourself. This means it has to be handed off to a thread to be able
> to take locks safely. For a scrubber that can be ignored. Doing 
> it from arbitary context requires some tricks.
> 
> Then you have to take a look at the struct page associated with
> the address. If it's a rmap page (you'll need a 2.6 kernel) you
> can walk the rmap chains to find the processes that have 
> the page mapped. You can look at the PTEs and 
> the page bits to see if it's dirty or not. For clean pages
> the page can be just dropped. Otherwise you have
> to kill the process (or send them a signal they could handle) 
> 
> There is no generic function to do the rmap walk right now, but it's not too 
> hard. 

Good summary. I'll just add a couple of things: in recent kernels
we have a page migration facility which should be able to take care
of moving process and pagecache pages for you, without walking rmap
or killing the process (assuming you're talking about correctable
ECC errors).

This may not quite have the right in-kernel API for you use yet, but
it shouldn't be difficult to add.

> 
> If it's kernel space there are several cases:
> - Free page (count == 0). Easy: ignore it.

Also, if you want to isolate the free page, you can allocate it,
and tuck it away in a list somewhere (or just forget about it
completely).

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

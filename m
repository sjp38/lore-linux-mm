Message-ID: <447BD31E.7000503@yahoo.com.au>
Date: Tue, 30 May 2006 15:07:42 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [rfc][patch] remove racy sync_page?
References: <447AC011.8050708@yahoo.com.au> <20060529121556.349863b8.akpm@osdl.org> <447B8CE6.5000208@yahoo.com.au> <20060529183201.0e8173bc.akpm@osdl.org> <447BB3FD.1070707@yahoo.com.au> <Pine.LNX.4.64.0605292117310.5623@g5.osdl.org>
In-Reply-To: <Pine.LNX.4.64.0605292117310.5623@g5.osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mason@suse.com, andrea@suse.de, hugh@veritas.com, axboe@suse.de
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> 
> On Tue, 30 May 2006, Nick Piggin wrote:
> 
>>I guess so. Is plugging still needed now that the IO layer should
>>get larger requests?
> 
> 
> Why do you think the IO layer should get larger requests?

For workloads where plugging helps (ie. lots of smaller, contiguous
requests going into the IO layer), should be pretty good these days
due to multiple readahead and writeback.

> 
> I really don't understand why people dislike plugging. It's obviously 
> superior to non-plugged variants, exactly because it starts the IO only 
> when _needed_, not at some random "IO request feeding point" boundary.

If you submit IO, it will be needed at some point in time. The benefit
of plugging is to hold it there in anticipation of more IO to merge
with this request.

Not sure what you mean by IO request feeding point...?

> 
> In other words, plugging works _correctly_ regardless of any random 
> up-stream patterns. That's the kind of algorithms we want, we do NOT want 
> to have the IO layer depend on upstream always doing the "Right 
> Thing(tm)".

It is a heuristic. I don't see anything obviously correct or incorrect
about it. If you were to submit some asynch requests and _knew_ that
no other requests would be merged with them, plugging would be the
wrong thing to do because the disks would be needlessly idle.

> 
> So exactly why would you want to remove it?

Because of this bug ;)

I'm not saying it would never be of any benefit; I was hoping that it
might be unneeded and getting rid of it would fix this bug and
simplify a lot too.

Anyway, clearly a plug friendly bugfix needs to be implemented
regardless.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

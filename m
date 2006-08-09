Message-ID: <44D97645.90104@google.com>
Date: Tue, 08 Aug 2006 22:44:37 -0700
From: Daniel Phillips <phillips@google.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 2/9] deadlock prevention core
References: <20060808193345.1396.16773.sendpatchset@lappy>	<20060808.151020.94555184.davem@davemloft.net>	<44D93BEE.4000001@google.com> <20060808.184144.71088399.davem@davemloft.net>
In-Reply-To: <20060808.184144.71088399.davem@davemloft.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: a.p.zijlstra@chello.nl, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

David Miller wrote:
>From: Daniel Phillips <phillips@google.com>
>>David Miller wrote:
>>>I think the new atomic operation that will seemingly occur on every
>>>device SKB free is unacceptable.
>>
>>Alternate suggestion?
> 
> Sorry, I have none.  But you're unlikely to get your changes
> considered seriously unless you can avoid any new overhead your patch
> has which is of this level.

We just skip anything new unless the socket is actively carrying block
IO traffic, in which case we pay a miniscule price to avoid severe
performance artifacts or in the worst case, deadlock.  So in this design
the new atomic operation does not occur on every device SKP free.

All atomic ops sit behind the cheap test:

    (dev->flags & IFF_MEMALLOC)

or if any have escaped that is just an oversight.   Peter?

> We're busy trying to make these data structures smaller, and eliminate
> atomic operations, as much as possible.  Therefore anything which adds
> new datastructure elements and new atomic operations will be met with
> fierce resistence unless it results an equal or greater shrink of
> datastructures elsewhere or removes atomic operations elsewhere in
> the critical path.

Right now we have a problem because our network stack cannot support
block IO reliably.  Without that, Linux is no enterprise storage
platform.

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

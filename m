Message-ID: <40C3E80E.1030200@yahoo.com.au>
Date: Mon, 07 Jun 2004 13:59:10 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: mmap() > phys mem problem
References: <Pine.LNX.4.44.0406061925550.29273-100000@chimarrao.boston.redhat.com>
In-Reply-To: <Pine.LNX.4.44.0406061925550.29273-100000@chimarrao.boston.redhat.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Ron Maeder <rlm@orionmulti.com>, Rik van Riel <riel@surriel.com>, linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> On Sun, 6 Jun 2004, Nick Piggin wrote:
> 
> 
>>OK, NFS is getting stuck in nfs_flush_one => mempool_alloc presumably
>>waiting for some network IO. Unfortunately at this point, the system
>>is so clogged up that order 0 GFP_ATOMIC allocations are failing in
>>this path: netedev_rx => refill_rx => alloc_skb. ie. deadlock.
> 
> 
> I wonder if there simply isn't enough memory available for
> GFP_ATOMIC network allocations, or if a mempool would alleviate
> the situation here.
> 

Well, no there isn't enough memory available: order 0 allocations
keep failing in the RX path (I assume each time the server retransmits)
and the machine is absolutely deadlocked.

> 
>>Sadly this seems to happen pretty easily here. I don't know the
>>network layer, so I don't know what might be required to fix it or if
>>it is even possible.
> 
> 
> The theoretically perfect fix is to have a little mempool for
> every critical socket.  That is, every NFS mount, e/g/nbd block
> device, etc...
> 

Yes. I assume there is some maximum amount of memory you might
have to allocate depending on things like fragmented and out of
order packets.

It would be cool if someone were able to come up with a formula
to capture that, and allow sockets to be marked as MEMALLOC to
enable mempool allocation.

> Of course, chances are that having one mempool for the network
> allocations might already do the trick for 95% 
> 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Date: Sun, 6 Jun 2004 19:51:21 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: Re: mmap() > phys mem problem
In-Reply-To: <40C2799B.1010306@yahoo.com.au>
Message-ID: <Pine.LNX.4.44.0406061925550.29273-100000@chimarrao.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Ron Maeder <rlm@orionmulti.com>, Rik van Riel <riel@surriel.com>, linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Sun, 6 Jun 2004, Nick Piggin wrote:

> OK, NFS is getting stuck in nfs_flush_one => mempool_alloc presumably
> waiting for some network IO. Unfortunately at this point, the system
> is so clogged up that order 0 GFP_ATOMIC allocations are failing in
> this path: netedev_rx => refill_rx => alloc_skb. ie. deadlock.

I wonder if there simply isn't enough memory available for
GFP_ATOMIC network allocations, or if a mempool would alleviate
the situation here.

> Sadly this seems to happen pretty easily here. I don't know the
> network layer, so I don't know what might be required to fix it or if
> it is even possible.

The theoretically perfect fix is to have a little mempool for
every critical socket.  That is, every NFS mount, e/g/nbd block
device, etc...

Of course, chances are that having one mempool for the network
allocations might already do the trick for 95% 

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Date: Mon, 7 Jun 2004 08:04:09 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: Re: mmap() > phys mem problem
In-Reply-To: <40C3E80E.1030200@yahoo.com.au>
Message-ID: <Pine.LNX.4.44.0406070800380.29273-100000@chimarrao.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Ron Maeder <rlm@orionmulti.com>, Rik van Riel <riel@surriel.com>, linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Mon, 7 Jun 2004, Nick Piggin wrote:

> Well, no there isn't enough memory available: order 0 allocations
> keep failing in the RX path (I assume each time the server retransmits)
> and the machine is absolutely deadlocked.

Yes, but did the memory get exhausted by the RX path itself,
or by something else that's allocating the last system memory?

If the memory exhaustion is because of something else, a
mempool for the RX path might alleviate the situation.

> > The theoretically perfect fix is to have a little mempool for
> > every critical socket.  That is, every NFS mount, e/g/nbd block
> > device, etc...

> It would be cool if someone were able to come up with a formula
> to capture that, and allow sockets to be marked as MEMALLOC to
> enable mempool allocation.

A per-socket mempool I guess.  At creation of a MEMALLOC
socket you'd set up the mempool, and the same mempool
would get destroyed when the socket is closed.

Then all memory allocations for that socket go via the
mempool.

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

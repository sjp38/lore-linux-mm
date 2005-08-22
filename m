Subject: Re: pagefault scalability patches
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20050817174359.0efc7a6a.akpm@osdl.org>
References: <20050817151723.48c948c7.akpm@osdl.org>
	 <20050817174359.0efc7a6a.akpm@osdl.org>
Content-Type: text/plain
Date: Mon, 22 Aug 2005 12:09:39 +1000
Message-Id: <1124676579.5189.10.camel@gaston>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: torvalds@osdl.org, hugh@veritas.com, clameter@engr.sgi.com, piggin@cyberone.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2005-08-17 at 17:43 -0700, Andrew Morton wrote:
> Andrew Morton <akpm@osdl.org> wrote:

> d) the fact that some architectures will be using atomic pte ops and
>    others will be using page_table_lock in core MM code.
> 
>    Using different locking/atomicity schemes in different architectures
>    has obvious complexity and test coverage drawbacks.
> 
>    Is it still the case that some architectures must retain the
>    page_table_lock approach because they use it to lock other arch-internal
>    things?

Yes. The ppc64 case for example isn't trivial due to the difference
between manipulating the linux page tables, and sync'ing the hash
table. 

If we go toward non-PTL page faults, I'll need to review all the hash
management code path that assume that thanks to the PTL, nothing will be
happening to the page tables between a PTL update and the matching hash
flush.

I think it shouldn't be too bad though as long as we are only ever doing
that to fill a previously !present PTE (no hash flush necessary). If we
ever want that for the COW case as well (where set_pte is called for an
already present PTE), then things would get more complicated and I may
have to rely more on the per-PTE locking mecanism we have (which is
currently mostly used to avoid duplicates in the hash table).

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

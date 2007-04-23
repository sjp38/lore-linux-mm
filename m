Date: Mon, 23 Apr 2007 06:44:29 -0400
From: Jakub Jelinek <jakub@redhat.com>
Subject: Re: [PATCH] lazy freeing of memory through MADV_FREE
Message-ID: <20070423104429.GJ355@devserv.devel.redhat.com>
Reply-To: Jakub Jelinek <jakub@redhat.com>
References: <462932BE.4020005@redhat.com> <20070420150618.179d31a4.akpm@linux-foundation.org> <4629524C.5040302@redhat.com> <462ACA40.8070407@yahoo.com.au> <462B0156.9020407@redhat.com> <462BFAF3.4040509@yahoo.com.au> <462C2DC7.5070709@redhat.com> <462C2F33.8090508@redhat.com> <462C7A6F.9030905@redhat.com> <462C88B1.8080906@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <462C88B1.8080906@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, shak <dshaks@redhat.com>, drepper@redhat.com
List-ID: <linux-mm.kvack.org>

On Mon, Apr 23, 2007 at 08:21:37PM +1000, Nick Piggin wrote:
> I guess it is a good idea to batch these things. But can you
> do that on all architectures? What happens if your tlb flush
> happens after another thread already accesses it again, or
> after it subsequently gets removed from the address space via
> another CPU?

Accessing the page by another thread before madvise (MADV_FREE)
returns is undefined behavior, it can act as if that access happened
right before the madvise (MADV_FREE) call or right after it.
That's ok for glibc and supposedly any other malloc implementation,
madvise (MADV_FREE) is called while holding containing's arena lock
and for whatever malloc implementaton, madvise (MADV_FREE) would be
part of free operations and you definitely need some synchronization
between one thread freeing some memory and other thread deciding
to reuse that memory and return it from malloc/realloc/calloc/etc.

My only concern is whether using non-atomic update of the pte is
ok or not.
ptep_test_and_clear_young/ptep_test_and_clear_dirty Rik's patch
was doing before are done using atomic instructions, at least on x86_64.
The operation we want for MADV_FREE is, clear young/dirty bits if they
have been set on entry to the MADV_FREE madvise call, undefined values
for these 2 bits if some other task modifies the young/dirty bits
concurrently with this MADV_FREE zap_page_range, but I'd say other
bits need to be unmodified.
Now, is there some kernel code which while either not holding corresponding
mmap_sem at all or holding it just down_read modifies other bits
in the pte?  If yes, we need to do this clearing atomically, basically
do a cmpxchg loop until we succeed to clear the 2 bits and then flush
the tlb if any of them was set before (ptep_test_and_clear_dirty_and_young?),
if not, set_pte_at is ok and faster than a lock prefixed insn.

	Jakub

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

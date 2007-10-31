From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch 09/10] SLUB: Do our own locking via slab_lock and slab_unlock.
Date: Wed, 31 Oct 2007 12:17:33 +1100
References: <20071028033156.022983073@sgi.com> <200710301550.55199.nickpiggin@yahoo.com.au> <Pine.LNX.4.64.0710301124520.11531@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0710301124520.11531@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710311217.34162.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Matthew Wilcox <matthew@wil.cx>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Wednesday 31 October 2007 05:32, Christoph Lameter wrote:
> On Tue, 30 Oct 2007, Nick Piggin wrote:
> > Is this actually a speedup on any architecture to roll your own locking
> > rather than using bit spinlock?
>
> It avoids one load from memory when allocating and the release is simply
> writing the page->flags back. Less instructions.

OK, but it probably isn't a measurable speedup, even on microbenchmarks,
right? And many architectures have to have more barriers around cmpxchg
than they do around a test_and_set_bit_lock, so it may even be slower
on some.


> > I am not exactly convinced that smp_wmb() is a good idea to have in your
> > unlock, rather than the normally required smp_mb() that every other open
> > coded lock in the kernel is using today. If you comment every code path
> > where a load leaking out of the critical section would not be a problem,
> > then OK it may be correct, but I still don't think it is worth the
> > maintenance overhead.
>
> I thought you agreed that release semantics only require a write barrier?

Not in general.


> The issue here is that other processors see the updates before the
> updates to page-flags.
>
> A load leaking out of a critical section would require that the result of
> the load is not used to update other information before the slab_unlock
> and that the source of the load is not overwritten in the critical
> section. That does not happen in sluib.

That may be the case, but I don't think there is enough performance
justification to add a hack like this. ia64 for example is going to
do an mf for smp_wmb so I doubt it is a clear win.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

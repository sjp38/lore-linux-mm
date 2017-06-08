Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 268D76B0279
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 08:16:48 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id m5so15164948pgn.1
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 05:16:48 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id p77si973506pfj.399.2017.06.08.05.16.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Jun 2017 05:16:47 -0700 (PDT)
Date: Thu, 8 Jun 2017 14:16:41 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 2/3] mm/page_ref: Ensure page_ref_unfreeze is ordered
 against prior accesses
Message-ID: <20170608121641.lpomved4hi74worl@hirez.programming.kicks-ass.net>
References: <1496771916-28203-1-git-send-email-will.deacon@arm.com>
 <1496771916-28203-3-git-send-email-will.deacon@arm.com>
 <b6677057-54d6-4336-93a0-5d0770434aa7@suse.cz>
 <20170608104056.ujuytybmwumuty64@black.fi.intel.com>
 <dac18c98-55e7-ea6b-d020-0f6065e969ad@suse.cz>
 <20170608112433.GH6071@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170608112433.GH6071@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mark.rutland@arm.com, akpm@linux-foundation.org, Punit.Agrawal@arm.com, mgorman@suse.de, steve.capper@arm.com

On Thu, Jun 08, 2017 at 12:24:33PM +0100, Will Deacon wrote:
> [+ PeterZ]
> 
> On Thu, Jun 08, 2017 at 01:07:02PM +0200, Vlastimil Babka wrote:
> > On 06/08/2017 12:40 PM, Kirill A. Shutemov wrote:
> > > On Thu, Jun 08, 2017 at 11:38:21AM +0200, Vlastimil Babka wrote:
> > >> On 06/06/2017 07:58 PM, Will Deacon wrote:
> > >>>  include/linux/page_ref.h | 1 +
> > >>>  1 file changed, 1 insertion(+)
> > >>>
> > >>> diff --git a/include/linux/page_ref.h b/include/linux/page_ref.h
> > >>> index 610e13271918..74d32d7905cb 100644
> > >>> --- a/include/linux/page_ref.h
> > >>> +++ b/include/linux/page_ref.h
> > >>> @@ -174,6 +174,7 @@ static inline void page_ref_unfreeze(struct page *page, int count)
> > >>>  	VM_BUG_ON_PAGE(page_count(page) != 0, page);
> > >>>  	VM_BUG_ON(count == 0);
> > >>>  
> > >>> +	smp_mb__before_atomic();
> > >>>  	atomic_set(&page->_refcount, count);

Yeah, that's broken. smp_mb__{before,after}_atomic() goes with the
atomic RmW ops that do not already imply barriers, such like
atomic_add() and atomic_fetch_add_relaxed().

atomic_set() and atomic_read() are not RmW ops, they are plain
write/read ops respectively.

> > > 
> > > I *think* it should be smp_mb(), not __before_atomic(). atomic_set() is
> > > not really atomic. For instance on x86 it's plain WRITE_ONCE() which CPU
> > > would happily reorder.
> > 
> > Yeah but there are compile barriers, and x86 is TSO, so that's enough?
> > Also I found other instances by git grep (not a proof, though :)
> 
> I think it boils down to whether:
> 
> 	smp_mb__before_atomic();
> 	atomic_set();
> 
> should have the same memory ordering semantics as:
> 
> 	smp_mb();
> 	atomic_set();
> 
> which it doesn't with the x86 implementation AFAICT.

Correct, it doesn't.

The smp_mb__{before,after}_atomic() are to provide those barriers that
are required to upgrade the atomic RmW primitive of the architecture.

x86 has LOCK prefix instructions that are SC and therefore don't need
any upgrading.

ARM OTOH has unordered LL/SC and will need full DMB(ISH) for both.

MIPS has pretty much all variants under the sun, strongly ordered LL/SC,
half ordered LL/SC and weakly ordered LL/SC..

> The horribly out-of-date atomic_ops.txt isn't so useful:
> 
> | If a caller requires memory barrier semantics around an atomic_t
> | operation which does not return a value, a set of interfaces are
> | defined which accomplish this::
> | 
> | 	void smp_mb__before_atomic(void);
> | 	void smp_mb__after_atomic(void);
> | 
> | For example, smp_mb__before_atomic() can be used like so::
> | 
> | 	obj->dead = 1;
> | 	smp_mb__before_atomic();
> | 	atomic_dec(&obj->ref_count);
> | 
> | It makes sure that all memory operations preceding the atomic_dec()
> | call are strongly ordered with respect to the atomic counter
> | operation.  In the above example, it guarantees that the assignment of
> | "1" to obj->dead will be globally visible to other cpus before the
> | atomic counter decrement.
> | 
> | Without the explicit smp_mb__before_atomic() call, the
> | implementation could legally allow the atomic counter update visible
> | to other cpus before the "obj->dead = 1;" assignment.
> 
> which makes it sound more like the barrier is ordering all prior accesses
> against the atomic operation itself (without going near cumulativity...),
> and not with respect to anything later in program order.

This is correct.

> Anyway, I think that's sufficient for what we want here, but we should
> probably iron out the semantics of this thing.

s/smp_mb__\(before\|after\)_atomic/smp_mb/g

should not change the semantics of the code in _any_ way, just make it
slower on architectures that already have SC atomic primitives (like
x86).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

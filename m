Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 470186B0279
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 08:19:47 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id s74so14344941pfe.10
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 05:19:47 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id c41si3210289plj.187.2017.06.08.05.19.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Jun 2017 05:19:46 -0700 (PDT)
Date: Thu, 8 Jun 2017 14:19:44 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 2/3] mm/page_ref: Ensure page_ref_unfreeze is ordered
 against prior accesses
Message-ID: <20170608121944.yx7z7bv47it6zxpq@hirez.programming.kicks-ass.net>
References: <1496771916-28203-1-git-send-email-will.deacon@arm.com>
 <1496771916-28203-3-git-send-email-will.deacon@arm.com>
 <b6677057-54d6-4336-93a0-5d0770434aa7@suse.cz>
 <20170608104056.ujuytybmwumuty64@black.fi.intel.com>
 <dac18c98-55e7-ea6b-d020-0f6065e969ad@suse.cz>
 <20170608112433.GH6071@arm.com>
 <20170608121641.lpomved4hi74worl@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170608121641.lpomved4hi74worl@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mark.rutland@arm.com, akpm@linux-foundation.org, Punit.Agrawal@arm.com, mgorman@suse.de, steve.capper@arm.com

On Thu, Jun 08, 2017 at 02:16:41PM +0200, Peter Zijlstra wrote:
> On Thu, Jun 08, 2017 at 12:24:33PM +0100, Will Deacon wrote:

> > The horribly out-of-date atomic_ops.txt isn't so useful:
> > 
> > | If a caller requires memory barrier semantics around an atomic_t
> > | operation which does not return a value, a set of interfaces are
> > | defined which accomplish this::
> > | 
> > | 	void smp_mb__before_atomic(void);
> > | 	void smp_mb__after_atomic(void);
> > | 
> > | For example, smp_mb__before_atomic() can be used like so::
> > | 
> > | 	obj->dead = 1;
> > | 	smp_mb__before_atomic();
> > | 	atomic_dec(&obj->ref_count);
> > | 
> > | It makes sure that all memory operations preceding the atomic_dec()
> > | call are strongly ordered with respect to the atomic counter
> > | operation.  In the above example, it guarantees that the assignment of
> > | "1" to obj->dead will be globally visible to other cpus before the
> > | atomic counter decrement.
> > | 
> > | Without the explicit smp_mb__before_atomic() call, the
> > | implementation could legally allow the atomic counter update visible
> > | to other cpus before the "obj->dead = 1;" assignment.
> > 
> > which makes it sound more like the barrier is ordering all prior accesses
> > against the atomic operation itself (without going near cumulativity...),
> > and not with respect to anything later in program order.
> 
> This is correct.

Ah, my bad, It orders against everything later, the first of which is
(obviously) the atomic op itself.

It being a full barrier means both the Read and the Write of the RmW
must happen _after_ everything preceding.

> > Anyway, I think that's sufficient for what we want here, but we should
> > probably iron out the semantics of this thing.
> 
> s/smp_mb__\(before\|after\)_atomic/smp_mb/g
> 
> should not change the semantics of the code in _any_ way, just make it
> slower on architectures that already have SC atomic primitives (like
> x86).
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

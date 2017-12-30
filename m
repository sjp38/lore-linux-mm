Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7758C6B0033
	for <linux-mm@kvack.org>; Sat, 30 Dec 2017 02:17:29 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id r8so7522705pgp.7
        for <linux-mm@kvack.org>; Fri, 29 Dec 2017 23:17:29 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id a20si29558503pfg.38.2017.12.29.23.17.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 29 Dec 2017 23:17:28 -0800 (PST)
Date: Fri, 29 Dec 2017 23:17:20 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 2/2] Introduce __cond_lock_err
Message-ID: <20171230071720.GE27959@bombadil.infradead.org>
References: <20171219165823.24243-1-willy@infradead.org>
 <20171219165823.24243-2-willy@infradead.org>
 <20171221214810.GC9087@linux.intel.com>
 <20171222011000.GB23624@bombadil.infradead.org>
 <20171222042120.GA18036@localhost>
 <20171222123112.GA6401@bombadil.infradead.org>
 <20171227142853.b5agfi2kzo25g5ot@ltop.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171227142853.b5agfi2kzo25g5ot@ltop.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Cc: Josh Triplett <josh@joshtriplett.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>

On Wed, Dec 27, 2017 at 03:28:54PM +0100, Luc Van Oostenryck wrote:
> On Fri, Dec 22, 2017 at 04:31:12AM -0800, Matthew Wilcox wrote:
> > On Thu, Dec 21, 2017 at 08:21:20PM -0800, Josh Triplett wrote:
> > 
> > While I've got you, I've been looking at some other sparse warnings from
> > this file.  There are several caused by sparse being unable to handle
> > the following construct:
> > 
> > 	if (foo)
> > 		x = NULL;
> > 	else {
> > 		x = bar;
> > 		__acquire(bar);
> > 	}
> > 	if (!x)
> > 		return -ENOMEM;
> > 
> > Writing it as:
> > 
> > 	if (foo)
> > 		return -ENOMEM;
> > 	else {
> > 		x = bar;
> > 		__acquire(bar);
> > 	}
> > 
> > works just fine.  ie this removes the warning:
> 
> It must be noted that these two versions are not equivalent
> (in the first version, it also returns with -ENOMEM if bar
> is NULL/zero).

They happen to be equivalent in the original; I was providing a simplified
version.  Here's the construct sparse can't understand:

        dst_pte = pte_alloc_map_lock(dst_mm, dst_pmd, addr, &dst_ptl);
        if (!dst_pte)
                return -ENOMEM;

with:

#define pte_alloc(mm, pmd, address)                     \
        (unlikely(pmd_none(*(pmd))) && __pte_alloc(mm, pmd, address))

#define pte_offset_map_lock(mm, pmd, address, ptlp)     \
({                                                      \
        spinlock_t *__ptl = pte_lockptr(mm, pmd);       \
        pte_t *__pte = pte_offset_map(pmd, address);    \
        *(ptlp) = __ptl;                                \
        spin_lock(__ptl);                               \
        __pte;                                          \
})

#define pte_alloc_map_lock(mm, pmd, address, ptlp)      \
        (pte_alloc(mm, pmd, address) ?                  \
                 NULL : pte_offset_map_lock(mm, pmd, address, ptlp))

If pte_alloc() succeeds, pte_offset_map_lock() will return non-NULL.
Manually inlining pte_alloc_map_lock() into the caller like so:

        if (pte_alloc(dst_mm, dst_pmd, addr)
		return -ENOMEM;
        dst_pte = pte_offset_map_lock(dst_mm, dst_pmd, addr, ptlp);

causes sparse to not warn.

> > Is there any chance sparse's dataflow analysis will be improved in the
> > near future?
> 
> A lot of functions in the kernel have this context imbalance,
> really a lot. For example, any function doing conditional locking
> is a problem here. Happily when these functions are inlined,
> sparse, thanks to its optimizations, can remove some paths and
> merge some others. 
> So yes, by adding some smartness to sparse, some of the false
> warnings will be removed, however:
> 1) some __must_hold()/__acquires()/__releases() annotations are
>    missing, making sparse's job impossible.

Partly there's a documentation problem here.  I'd really like to see a
document explaining how to add sparse annotations to a function which
intentionally does conditional locking.  For example, should we be
annotating the function as __acquires, and then marking the exits which
don't acquire the lock with __acquire(), or should we not annotate
the function, and annotate the exits which _do_ acquire the lock as
__release() with a comment like /* Caller will release */

> 2) a lot of the 'false warnings' are not so false because there is
>    indeed two possible paths with different lock state
> 3) it has its limits (at the end, giving the correct warning is
>    equivalent to the halting problem).
> 
> Now, to answer to your question, I'm not aware of any effort that would
> make a significant differences (it would need, IMO, code hoisting & 
> value range propagation).

That's fair.  I wonder if we were starting from scratch whether we'd
choose to make sparse a GCC plugin today.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

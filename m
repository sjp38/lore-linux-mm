Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 14F9B6B025F
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 03:17:10 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id v62so177655859pfd.10
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 00:17:10 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id k80si9112334pfb.572.2017.07.26.00.17.08
        for <linux-mm@kvack.org>;
        Wed, 26 Jul 2017 00:17:09 -0700 (PDT)
Date: Wed, 26 Jul 2017 16:16:09 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v7 08/16] lockdep: Avoid adding redundant direct links of
 crosslocks
Message-ID: <20170726071609.GN20323@X58A-UD3R>
References: <1495616389-29772-1-git-send-email-byungchul.park@lge.com>
 <1495616389-29772-9-git-send-email-byungchul.park@lge.com>
 <20170725154136.hu3f2mjfunkyidnd@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170725154136.hu3f2mjfunkyidnd@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Tue, Jul 25, 2017 at 05:41:36PM +0200, Peter Zijlstra wrote:
> On Wed, May 24, 2017 at 05:59:41PM +0900, Byungchul Park wrote:
> > We can skip adding a dependency 'AX -> B', in case that we ensure 'AX ->
> > the previous of B in hlocks' to be created, where AX is a crosslock and
> > B is a typical lock. Remember that two adjacent locks in hlocks generate
> > a dependency like 'prev -> next', that is, 'the previous of B in hlocks
> > -> B' in this case.
> > 
> > For example:
> > 
> >              in hlocks[]
> >              ------------
> >           ^  A (gen_id: 4) --+
> >           |                  | previous gen_id
> >           |  B (gen_id: 3) <-+
> >           |  C (gen_id: 3)
> >           |  D (gen_id: 2)
> >    oldest |  E (gen_id: 1)
> > 
> >              in xhlocks[]
> >              ------------
> >           ^  A (gen_id: 4, prev_gen_id: 3(B's gen id))
> >           |  B (gen_id: 3, prev_gen_id: 3(C's gen id))
> >           |  C (gen_id: 3, prev_gen_id: 2(D's gen id))
> >           |  D (gen_id: 2, prev_gen_id: 1(E's gen id))
> >    oldest |  E (gen_id: 1, prev_gen_id: NA)
> > 
> > On commit for a crosslock AX(gen_id = 3), it's engough to add 'AX -> C',
> > but adding 'AX -> B' and 'AX -> A' is unnecessary since 'AX -> C', 'C ->
> > B' and 'B -> A' cover them, which are guaranteed to be generated.
> > 
> > This patch intoduces a variable, prev_gen_id, to avoid adding this kind
> > of redundant dependencies. In other words, the previous in hlocks will
> > anyway handle it if the previous's gen_id >= the crosslock's gen_id.
> > 
> 
> Didn't we talk about an alternative to this?

Yes, we did. You said the optimazation was unnecessary, and I was not
sure if it's true, so added it at this time.

But *I will exclude this from next spin*.

> 
> /me goes dig
> 
>  https://lkml.kernel.org/r/20170303091338.GH6536@twins.programming.kicks-ass.net
> 
> There and replies.
> 
> So how much does this save vs avoiding redundant links?

No different on my qemu machine. The answer was:

https://lkml.org/lkml/2017/3/14/103

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

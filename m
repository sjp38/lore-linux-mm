Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1CE036B0311
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 11:41:48 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id j10so130215804ioi.7
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 08:41:48 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id k20si12271263iod.22.2017.07.25.08.41.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 08:41:47 -0700 (PDT)
Date: Tue, 25 Jul 2017 17:41:36 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v7 08/16] lockdep: Avoid adding redundant direct links of
 crosslocks
Message-ID: <20170725154136.hu3f2mjfunkyidnd@hirez.programming.kicks-ass.net>
References: <1495616389-29772-1-git-send-email-byungchul.park@lge.com>
 <1495616389-29772-9-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1495616389-29772-9-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Wed, May 24, 2017 at 05:59:41PM +0900, Byungchul Park wrote:
> We can skip adding a dependency 'AX -> B', in case that we ensure 'AX ->
> the previous of B in hlocks' to be created, where AX is a crosslock and
> B is a typical lock. Remember that two adjacent locks in hlocks generate
> a dependency like 'prev -> next', that is, 'the previous of B in hlocks
> -> B' in this case.
> 
> For example:
> 
>              in hlocks[]
>              ------------
>           ^  A (gen_id: 4) --+
>           |                  | previous gen_id
>           |  B (gen_id: 3) <-+
>           |  C (gen_id: 3)
>           |  D (gen_id: 2)
>    oldest |  E (gen_id: 1)
> 
>              in xhlocks[]
>              ------------
>           ^  A (gen_id: 4, prev_gen_id: 3(B's gen id))
>           |  B (gen_id: 3, prev_gen_id: 3(C's gen id))
>           |  C (gen_id: 3, prev_gen_id: 2(D's gen id))
>           |  D (gen_id: 2, prev_gen_id: 1(E's gen id))
>    oldest |  E (gen_id: 1, prev_gen_id: NA)
> 
> On commit for a crosslock AX(gen_id = 3), it's engough to add 'AX -> C',
> but adding 'AX -> B' and 'AX -> A' is unnecessary since 'AX -> C', 'C ->
> B' and 'B -> A' cover them, which are guaranteed to be generated.
> 
> This patch intoduces a variable, prev_gen_id, to avoid adding this kind
> of redundant dependencies. In other words, the previous in hlocks will
> anyway handle it if the previous's gen_id >= the crosslock's gen_id.
> 

Didn't we talk about an alternative to this?

/me goes dig

 https://lkml.kernel.org/r/20170303091338.GH6536@twins.programming.kicks-ass.net

There and replies.

So how much does this save vs avoiding redundant links?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

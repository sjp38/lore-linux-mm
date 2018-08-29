Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id E882B6B4E3B
	for <linux-mm@kvack.org>; Wed, 29 Aug 2018 19:12:24 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id g5-v6so3969942pgq.5
        for <linux-mm@kvack.org>; Wed, 29 Aug 2018 16:12:24 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r23-v6sor1476699pfj.74.2018.08.29.16.12.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 Aug 2018 16:12:23 -0700 (PDT)
Date: Thu, 30 Aug 2018 09:12:13 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH 2/3] mm/cow: optimise pte dirty/accessed bits handling
 in fork
Message-ID: <20180830091213.78b64354@roar.ozlabs.ibm.com>
In-Reply-To: <CA+55aFwbZrsdZEh0ds1W3AWUeTamDRheQPKSi9O=--cEOSjr5g@mail.gmail.com>
References: <20180828112034.30875-1-npiggin@gmail.com>
	<20180828112034.30875-3-npiggin@gmail.com>
	<CA+55aFwbZrsdZEh0ds1W3AWUeTamDRheQPKSi9O=--cEOSjr5g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, ppc-dev <linuxppc-dev@lists.ozlabs.org>, Andrew Morton <akpm@linux-foundation.org>

On Wed, 29 Aug 2018 08:42:09 -0700
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Tue, Aug 28, 2018 at 4:20 AM Nicholas Piggin <npiggin@gmail.com> wrote:
> >
> > fork clears dirty/accessed bits from new ptes in the child. This logic
> > has existed since mapped page reclaim was done by scanning ptes when
> > it may have been quite important. Today with physical based pte
> > scanning, there is less reason to clear these bits.  
> 
> Can you humor me, and make the dirty/accessed bit patches separate?

Yeah sure.

> There is actually a difference wrt the dirty bit: if we unmap an area
> with dirty pages, we have to do the special synchronous flush.
> 
> So a clean page in the virtual mapping is _literally_ cheaper to have.

Oh yeah true, that blasted thing. Good point.

Dirty micro fault seems to be the big one for my Skylake, takes 300
nanoseconds per access. Accessed takes about 100. (I think, have to
go over my benchmark a bit more carefully and re-test).

Dirty will happen less often though, particularly as most places we
do write to (stack, heap, etc) will be write protected for COW anyway,
I think. Worst case might be a big shared shm segment like a database
buffer cache, but those kind of forks should happen very very
infrequently I would hope.

Yes maybe we can do that. I'll split them up and try to get some
numbers for them individually.

Thanks,
Nick

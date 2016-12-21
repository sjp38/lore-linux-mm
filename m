Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id C483F6B03C3
	for <linux-mm@kvack.org>; Wed, 21 Dec 2016 13:12:37 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id n68so141486994itn.4
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 10:12:37 -0800 (PST)
Received: from mail-it0-x244.google.com (mail-it0-x244.google.com. [2607:f8b0:4001:c0b::244])
        by mx.google.com with ESMTPS id y7si20490135iod.33.2016.12.21.10.12.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Dec 2016 10:12:37 -0800 (PST)
Received: by mail-it0-x244.google.com with SMTP id b123so18361915itb.2
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 10:12:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161221223056.17c37dd6@roar.ozlabs.ibm.com>
References: <20161219225826.F8CB356F@viggo.jf.intel.com> <20161221223056.17c37dd6@roar.ozlabs.ibm.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 21 Dec 2016 10:12:36 -0800
Message-ID: <CA+55aFx83JS4ZcZUmQLL+e1gzTQ-y_0n_xWtg=T8qtJ0_cA5GA@mail.gmail.com>
Subject: Re: [RFC][PATCH] make global bitlock waitqueues per-node
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andreas Gruenbacher <agruenba@redhat.com>, Bob Peterson <rpeterso@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>, Andrew Lutomirski <luto@kernel.org>, Steven Whitehouse <swhiteho@redhat.com>

On Wed, Dec 21, 2016 at 4:30 AM, Nicholas Piggin <npiggin@gmail.com> wrote:
>
> I've been doing a bit of testing, and I don't know why you're seeing
> this.
>
> I don't think I've been able to trigger any actual page lock contention
> so nothing gets put on the waitqueue to really bounce cache lines around
> that I can see.

The "test is the waitqueue is empty" is going to cause cache misses
even if there is no contention.

In fact, that's why I want the contention bit in the struct page - not
because of any NUMA issues, but simply due to cache misses.

And yes, with no contention the bit waiting should hopefully be able
to cache things shared - which should make the bouncing much less -
but there's going to be a shitload of false sharing with any actual
IO, so you will get bouncing due to that.

And then regular bouncing due simply to capacity misses (rather than
the CPU's wanting exclusive access).

With the contention bit in place, the only people actually looking at
the wait queues are the ones doing IO. At which point false sharing is
going to go down dramatically, but even if it were to happen it goes
from a "big issue" to "who cares, the cachemiss is not noticeable
compared to the IO, even with a fast SSD".

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

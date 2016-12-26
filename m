Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2BE196B0038
	for <linux-mm@kvack.org>; Mon, 26 Dec 2016 14:07:54 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id o141so261661838itc.1
        for <linux-mm@kvack.org>; Mon, 26 Dec 2016 11:07:54 -0800 (PST)
Received: from mail-it0-x242.google.com (mail-it0-x242.google.com. [2607:f8b0:4001:c0b::242])
        by mx.google.com with ESMTPS id l8si30529428ioa.2.2016.12.26.11.07.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Dec 2016 11:07:53 -0800 (PST)
Received: by mail-it0-x242.google.com with SMTP id 75so31639743ite.1
        for <linux-mm@kvack.org>; Mon, 26 Dec 2016 11:07:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161226111654.76ab0957@roar.ozlabs.ibm.com>
References: <20161225030030.23219-1-npiggin@gmail.com> <20161225030030.23219-3-npiggin@gmail.com>
 <CA+55aFzqgtz-782MmLOjQ2A2nB5YVyLAvveo6G_c85jqqGDA0Q@mail.gmail.com> <20161226111654.76ab0957@roar.ozlabs.ibm.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 26 Dec 2016 11:07:52 -0800
Message-ID: <CA+55aFz1n_JSTc_u=t9Qgafk2JaffrhPAwMLn_Dr-L9UKxqHMg@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: add PageWaiters indicating tasks are waiting for
 a page bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Bob Peterson <rpeterso@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Steven Whitehouse <swhiteho@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Andreas Gruenbacher <agruenba@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>

On Sun, Dec 25, 2016 at 5:16 PM, Nicholas Piggin <npiggin@gmail.com> wrote:
>
> I did actually play around with that. I could not get my skylake
> to forward the result from a lock op to a subsequent load (the
> latency was the same whether you use lock ; andb or lock ; andl
> (32 cycles for my test loop) whereas with non-atomic versions I
> was getting about 15 cycles for andb vs 2 for andl.

Yes, interesting. It does look like the locked ops don't end up having
the partial write issue and the size of the op doesn't matter.

But it's definitely the case that the write buffer hit immediately
after the atomic read-modify-write ends up slowing things down, so the
profile oddity isn't just a profile artifact. I wrote a stupid test
program that did an atomic increment, and then read either the same
value, or an adjacent value in memory (so same instruvtion sequence,
the difference just being what memory location the read accessed).

Reading the same value after the atomic update was *much* more
expensive than reading the adjacent value, so it causes some kind of
pipeline hickup (by about 50% of the cost of the atomic op itself:
iow, the "atomic-op followed by read same location" was over 1.5x
slower than "atomic op followed by read of another location").

So the atomic ops don't serialize things entirely, but they *hate*
having the value read (regardless of size) right after being updated,
because it causes some kind of nasty pipeline issue.

A cmpxchg does seem to avoid the issue.

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

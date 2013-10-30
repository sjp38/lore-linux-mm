Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id AFE8C6B0035
	for <linux-mm@kvack.org>; Wed, 30 Oct 2013 15:49:08 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id w10so1427892pde.17
        for <linux-mm@kvack.org>; Wed, 30 Oct 2013 12:49:08 -0700 (PDT)
Received: from psmtp.com ([74.125.245.196])
        by mx.google.com with SMTP id a10si87790pac.308.2013.10.30.12.49.07
        for <linux-mm@kvack.org>;
        Wed, 30 Oct 2013 12:49:07 -0700 (PDT)
Received: by mail-vc0-f172.google.com with SMTP id ks9so1283112vcb.31
        for <linux-mm@kvack.org>; Wed, 30 Oct 2013 12:49:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20131030141616.GB16735@n2100.arm.linux.org.uk>
References: <20131030141616.GB16735@n2100.arm.linux.org.uk>
Date: Wed, 30 Oct 2013 12:49:05 -0700
Message-ID: <CA+55aFzmpzjt-o=R95i_EvvyKvYhwG00o6i324johxJ1bjSMiQ@mail.gmail.com>
Subject: Re: [PATCH] mm: list_lru: fix almost infinite loop causing effective livelock
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Dave Chinner <dchinner@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Oct 30, 2013 at 7:16 AM, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:
>
> So, if *nr_to_walk was zero when this function was entered, that means
> we're wanting to operate on (~0UL)+1 objects - which might as well be
> infinite.
>
> Clearly this is not correct behaviour.  If we think about the behaviour
> of this function when *nr_to_walk is 1, then clearly it's wrong - we
> decrement first and then test for zero - which results in us doing
> nothing at all.  A post-decrement would give the desired behaviour -
> we'd try to walk one object and one object only if *nr_to_walk were
> one.
>
> It also gives the correct behaviour for zero - we exit at this point.

Good analysis.

HOWEVER.

I actually think even your version is very dangerous, because we pass
in the *address* to that count, and the only real reason to do that is
because we might call it in a loop, and we want the function to update
that count.

And even your version still underflows from 0 to really-large-count.
It *returns* when underflow happens, but you end up with the counter
updated to a large value, and then anybody who uses it later would be
screwed.

See, for example, the inline list_lru_walk() function in <linux/list_lru.h>

So I think we should either change that "unsigned long" to just
"long", and then check for "<= 0" (like list_lru_walk() already does),
or we should do

    if (!*nr_to_walk)
        break;
    --*nr_to_walk;

to make sure that we never do that underflow.

I will modify your patch to do the latter, since it's the smaller
change, but I suspect we should think about making that thing signed.

Hmm?

                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

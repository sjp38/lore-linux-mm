Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 60B866B0035
	for <linux-mm@kvack.org>; Wed, 30 Oct 2013 16:00:50 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id kp14so1469407pab.29
        for <linux-mm@kvack.org>; Wed, 30 Oct 2013 13:00:49 -0700 (PDT)
Received: from psmtp.com ([74.125.245.193])
        by mx.google.com with SMTP id ru9si18876422pbc.198.2013.10.30.13.00.46
        for <linux-mm@kvack.org>;
        Wed, 30 Oct 2013 13:00:48 -0700 (PDT)
Date: Wed, 30 Oct 2013 20:00:31 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] mm: list_lru: fix almost infinite loop causing
	effective livelock
Message-ID: <20131030200030.GO16735@n2100.arm.linux.org.uk>
References: <20131030141616.GB16735@n2100.arm.linux.org.uk> <CA+55aFzmpzjt-o=R95i_EvvyKvYhwG00o6i324johxJ1bjSMiQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzmpzjt-o=R95i_EvvyKvYhwG00o6i324johxJ1bjSMiQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Dave Chinner <dchinner@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Oct 30, 2013 at 12:49:05PM -0700, Linus Torvalds wrote:
> On Wed, Oct 30, 2013 at 7:16 AM, Russell King - ARM Linux
> <linux@arm.linux.org.uk> wrote:
> >
> > So, if *nr_to_walk was zero when this function was entered, that means
> > we're wanting to operate on (~0UL)+1 objects - which might as well be
> > infinite.
> >
> > Clearly this is not correct behaviour.  If we think about the behaviour
> > of this function when *nr_to_walk is 1, then clearly it's wrong - we
> > decrement first and then test for zero - which results in us doing
> > nothing at all.  A post-decrement would give the desired behaviour -
> > we'd try to walk one object and one object only if *nr_to_walk were
> > one.
> >
> > It also gives the correct behaviour for zero - we exit at this point.
> 
> Good analysis.
> 
> HOWEVER.
> 
> I actually think even your version is very dangerous, because we pass
> in the *address* to that count, and the only real reason to do that is
> because we might call it in a loop, and we want the function to update
> that count.
> 
> And even your version still underflows from 0 to really-large-count.
> It *returns* when underflow happens, but you end up with the counter
> updated to a large value, and then anybody who uses it later would be
> screwed.

Yes, you're right... my failing case thankfully doesn't make use of the
counter again which is probably why I didn't think about that aspect.

> So I think we should either change that "unsigned long" to just
> "long", and then check for "<= 0" (like list_lru_walk() already does),
> or we should do
> 
>     if (!*nr_to_walk)
>         break;
>     --*nr_to_walk;
> 
> to make sure that we never do that underflow.
> 
> I will modify your patch to do the latter, since it's the smaller
> change, but I suspect we should think about making that thing signed.

Thanks... :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

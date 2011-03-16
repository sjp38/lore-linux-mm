Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E736E8D0039
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 00:24:56 -0400 (EDT)
Date: 16 Mar 2011 00:24:52 -0400
Message-ID: <20110316042452.21452.qmail@science.horizon.com>
From: "George Spelvin" <linux@horizon.com>
Subject: Re: [PATCH 2/8] drivers/char/random: Split out __get_random_int
In-Reply-To: <1300244636.3128.426.camel@calx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux@horizon.com, mpm@selenic.com
Cc: herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@cs.helsinki.fi

Thank you very much for your review!

> I've spent a while thinking about this over the past few weeks, and I
> really don't think it's productive to try to randomize the allocators.
> It provides negligible defense and just makes life harder for kernel
> hackers.
> 
> (And you definitely can't randomize SLOB like this.)

I'm not sure, either.  I *do* think it actually prevents an attacker
reliably allocating two consecutive kernel objects, but I expect that
most buffer overrun attacks can just allocate lots of taget objects and
figure out which one got smashed.

It's mostly for benchmarking and discussion.


>> The unlocked function is needed for following work.
>> No API change.

> As I mentioned last time this code was discussed, we're already one
> crypto-savvy attacker away from this code becoming a security hole. 
> We really need to give it a serious rethink before we make it look
> anything like a general-use API. 

If you like, and don't mind a few more bytes of per-cpu data, I'll
happily replace the whole dubious thing with a cryptographically secure
high-speed PRNG.  I'm thinking ChaCha/12, as Salsa20 was selected by
eSTREAM and ChaCha is generally agreed to be stronger.  (It's had more
review as the basis of the BLAKE hash function, a SHA-3 finalist.)

I've got some working SSE2 code for it, too.  Invoking it should be
conditional on the amount requested; there's no point context-switching
the FPU for one iteration.

I can also add a (configurable) /dev/frandom interface for it.

> And you've got it backwards here: __ should be the unlocked, dangerous
> version. But the locked version already has a __ because it's already
> dangerous.

I don't understand.  The old version did *not* have a __, and I added
__ in front of the dangerous unlocked version.  If, on re-reading it,
you still think I did something wrong, can you please explain in more
detail?


>> This is a function for generating random numbers modulo small
>> integers, with uniform distribution and parsimonious use of seed
>> material.

> This actually looks pretty reasonable, ignoring the scary API foundation
> it's built on. But as popular as rand() % m constructs are with
> programmers, it's better to design things so as to avoid the modulus
> entirely. We've done pretty well at that so far, so I'd rather not have
> such a thing in the kernel.

I was thinking of using it to implement randomize_range(), I just didn't
want to be too intrusive, and I'd need to extend the code to handle 64-bit
address spaces.

If you'd like, I can do that.  (Actually, looking at it, there are
only three callers and the range is always 0x02000000.  And the
use of PAGE_ALIGN is wrong; it should round down rather than up.)
On Mon, 2011-03-14 at 21:58 -0400, George Spelvin wrote:


>> For sysfs files that map a boolean to a flags bit.

> This one's actually pretty nice.

The old code just annoyed me; I couldn't stand to cut & paste one
more time.

I can probably do better; I can extend the slab_sttribute structure to
include the bit mask, have the slab_attr_show and slab_attr_store dispatch
functions pass the attribute pointer to the ->show and ->store functions,
and do away with all the per-bit functions.

> You should really try to put all the uncontroversial bits of a series
> first.

Is that really a more important principle than putting related changes
together?  I get the idea, but thought it made more sense to put
all the slub.c changes together.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

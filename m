Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id D5B8D6B0069
	for <linux-mm@kvack.org>; Wed, 28 Dec 2016 14:17:02 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id q186so309742539itb.0
        for <linux-mm@kvack.org>; Wed, 28 Dec 2016 11:17:02 -0800 (PST)
Received: from mail-io0-x242.google.com (mail-io0-x242.google.com. [2607:f8b0:4001:c06::242])
        by mx.google.com with ESMTPS id u124si31425394ita.51.2016.12.28.11.17.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Dec 2016 11:17:02 -0800 (PST)
Received: by mail-io0-x242.google.com with SMTP id n85so17678889ioi.1
        for <linux-mm@kvack.org>; Wed, 28 Dec 2016 11:17:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161228135358.59f47204@roar.ozlabs.ibm.com>
References: <20161225030030.23219-1-npiggin@gmail.com> <20161225030030.23219-3-npiggin@gmail.com>
 <CA+55aFzqgtz-782MmLOjQ2A2nB5YVyLAvveo6G_c85jqqGDA0Q@mail.gmail.com>
 <20161226111654.76ab0957@roar.ozlabs.ibm.com> <CA+55aFz1n_JSTc_u=t9Qgafk2JaffrhPAwMLn_Dr-L9UKxqHMg@mail.gmail.com>
 <20161227211946.3770b6ce@roar.ozlabs.ibm.com> <CA+55aFw22e6njM9L4sareRRJw3RjW9XwGH3B7p-ND86EtTWWDQ@mail.gmail.com>
 <20161228135358.59f47204@roar.ozlabs.ibm.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 28 Dec 2016 11:17:00 -0800
Message-ID: <CA+55aFz-evT+NiZY0GhO719M+=u==TbCqxTJTjp+pJevhDnRrw@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: add PageWaiters indicating tasks are waiting for
 a page bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Bob Peterson <rpeterso@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Steven Whitehouse <swhiteho@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Andreas Gruenbacher <agruenba@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>

On Tue, Dec 27, 2016 at 7:53 PM, Nicholas Piggin <npiggin@gmail.com> wrote:
>>
>> Yeah, that patch is disgusting, and doesn't even help x86.
>
> No, although it would help some cases (but granted the bitops tend to
> be problematic in this regard). To be clear I'm not asking to merge it,
> just wondered your opinion. (We need something more for unlock_page
> anyway because the memory barrier in the way).

The thing is, the patch seems pointless anyway. The "add_return()"
kind of cases already return the value, so any code that cares can
just use that. And the other cases are downright incorrect, like the
removal of "volatile" from the bit test ops.

>> It also
>> depends on the compiler doing the right thing in ways that are not
>> obviously true.
>
> Can you elaborate on this? GCC will do the optimization (modulo a
> regression https://gcc.gnu.org/bugzilla/show_bug.cgi?id=77647)

So the removal of volatile is just one example of that. You're
basically forcing magical side effects. I've never seen this trick
_documented_, and quite frankly, the gcc people have had a history of
changing their own documentation when it came to their own extensions
(ie they've changed how inline functions work etc).

But I also worry about interactions with different gcc versions, or
with the LLVM people who try to build the kernel with non-gcc
compilers.

Finally, it fundamentally can't work on x86 anyway, except for the
add-return type of operations, which by definitions are pointless (see
above).

So everything just screams "this is a horrible approach" to me.

> Patch seems okay, but it's kind of a horrible primitive. What if you
> did clear_bit_unlock_and_test_bit, which does a __builtin_constant_p
> test on the bit numbers and if they are < 7 and == 7, then do the
> fastpath?

So the problem with that is that it makes no sense *except* in the
case where the bit is 7. So why add a "generic" function for something
that really isn't generic?

I agree that it's a hacky interface, but I also happen to believe that
being explicit about what you are actually doing causes less pain.
It's not magical, and it's not subtle. There's no question about what
it does behind your back, and people won't use it by mistake in the
wrong context where it doesn't actually work any better than just
doing the obvious thing.

                         Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id B96DA6B0261
	for <linux-mm@kvack.org>; Tue, 27 Dec 2016 13:59:10 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id x2so258819392itf.6
        for <linux-mm@kvack.org>; Tue, 27 Dec 2016 10:59:10 -0800 (PST)
Received: from mail-io0-x242.google.com (mail-io0-x242.google.com. [2607:f8b0:4001:c06::242])
        by mx.google.com with ESMTPS id b133si29324130iti.88.2016.12.27.10.59.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Dec 2016 10:59:00 -0800 (PST)
Received: by mail-io0-x242.google.com with SMTP id f73so41440784ioe.2
        for <linux-mm@kvack.org>; Tue, 27 Dec 2016 10:59:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161227211946.3770b6ce@roar.ozlabs.ibm.com>
References: <20161225030030.23219-1-npiggin@gmail.com> <20161225030030.23219-3-npiggin@gmail.com>
 <CA+55aFzqgtz-782MmLOjQ2A2nB5YVyLAvveo6G_c85jqqGDA0Q@mail.gmail.com>
 <20161226111654.76ab0957@roar.ozlabs.ibm.com> <CA+55aFz1n_JSTc_u=t9Qgafk2JaffrhPAwMLn_Dr-L9UKxqHMg@mail.gmail.com>
 <20161227211946.3770b6ce@roar.ozlabs.ibm.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 27 Dec 2016 10:58:59 -0800
Message-ID: <CA+55aFw22e6njM9L4sareRRJw3RjW9XwGH3B7p-ND86EtTWWDQ@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: add PageWaiters indicating tasks are waiting for
 a page bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Bob Peterson <rpeterso@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Steven Whitehouse <swhiteho@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Andreas Gruenbacher <agruenba@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>

On Tue, Dec 27, 2016 at 3:19 AM, Nicholas Piggin <npiggin@gmail.com> wrote:
>
> Attached is part of a patch I've been mulling over for a while. I
> expect you to hate it, and it does not solve this problem for x86,
> but I like being able to propagate values from atomic ops back
> to the compiler. Of course, volatile then can't be used either which
> is another spanner...

Yeah, that patch is disgusting, and doesn't even help x86. It also
depends on the compiler doing the right thing in ways that are not
obviously true.

I'd much rather just add the "xyz_return()" primitives for and/or, the
way we already have atomic_add_return() and friends.

In fact, we could probably play games with bit numbering, and actually
use the atomic ops we already have. For example, if the lock bit was
the top bit, we could unlock by doing "atomic_add_return()" with that
bit, and look at the remaining bits that way.

That would actually work really well on x86, since there we have
"xadd", but we do *not* have "set/clear bit and return old word".

We could make a special case for just the page lock bit, make it bit #7, and use

   movb $128,%al
   lock xaddb %al,flags

and then test the bits in %al.

And all the RISC architectures would be ok with that too, because they
can just use ll/sc and test the bits with that. So for them, adding a
"atomic_long_and_return()" would be very natural in the general case.

Hmm?

The other alternative is to keep the lock bit as bit #0, and just make
the contention bit be the high bit. Then, on x86, you can do

    lock andb $0xfe,flags
    js contention

which might be even better. Again, it would be a very special
operation just for unlock. Something like

   bit_clear_and_branch_if_negative_byte(mem, label);

and again, it would be trivial to do on most architectures.

Let me try to write a patch or two for testing.

                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

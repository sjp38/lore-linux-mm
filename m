Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id C44F06B0253
	for <linux-mm@kvack.org>; Tue, 27 Dec 2016 22:54:13 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id a190so769263818pgc.0
        for <linux-mm@kvack.org>; Tue, 27 Dec 2016 19:54:13 -0800 (PST)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id v84si38195943pfd.55.2016.12.27.19.54.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Dec 2016 19:54:12 -0800 (PST)
Received: by mail-pf0-x243.google.com with SMTP id i88so18787357pfk.2
        for <linux-mm@kvack.org>; Tue, 27 Dec 2016 19:54:11 -0800 (PST)
Date: Wed, 28 Dec 2016 13:53:58 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH 2/2] mm: add PageWaiters indicating tasks are waiting
 for a page bit
Message-ID: <20161228135358.59f47204@roar.ozlabs.ibm.com>
In-Reply-To: <CA+55aFw22e6njM9L4sareRRJw3RjW9XwGH3B7p-ND86EtTWWDQ@mail.gmail.com>
References: <20161225030030.23219-1-npiggin@gmail.com>
	<20161225030030.23219-3-npiggin@gmail.com>
	<CA+55aFzqgtz-782MmLOjQ2A2nB5YVyLAvveo6G_c85jqqGDA0Q@mail.gmail.com>
	<20161226111654.76ab0957@roar.ozlabs.ibm.com>
	<CA+55aFz1n_JSTc_u=t9Qgafk2JaffrhPAwMLn_Dr-L9UKxqHMg@mail.gmail.com>
	<20161227211946.3770b6ce@roar.ozlabs.ibm.com>
	<CA+55aFw22e6njM9L4sareRRJw3RjW9XwGH3B7p-ND86EtTWWDQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Bob Peterson <rpeterso@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Steven Whitehouse <swhiteho@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Andreas Gruenbacher <agruenba@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>

On Tue, 27 Dec 2016 10:58:59 -0800
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Tue, Dec 27, 2016 at 3:19 AM, Nicholas Piggin <npiggin@gmail.com> wrote:
> >
> > Attached is part of a patch I've been mulling over for a while. I
> > expect you to hate it, and it does not solve this problem for x86,
> > but I like being able to propagate values from atomic ops back
> > to the compiler. Of course, volatile then can't be used either which
> > is another spanner...  
> 
> Yeah, that patch is disgusting, and doesn't even help x86.

No, although it would help some cases (but granted the bitops tend to
be problematic in this regard). To be clear I'm not asking to merge it,
just wondered your opinion. (We need something more for unlock_page
anyway because the memory barrier in the way).

> It also
> depends on the compiler doing the right thing in ways that are not
> obviously true.

Can you elaborate on this? GCC will do the optimization (modulo a
regression https://gcc.gnu.org/bugzilla/show_bug.cgi?id=77647)

> I'd much rather just add the "xyz_return()" primitives for and/or, the
> way we already have atomic_add_return() and friends.
> 
> In fact, we could probably play games with bit numbering, and actually
> use the atomic ops we already have. For example, if the lock bit was
> the top bit, we could unlock by doing "atomic_add_return()" with that
> bit, and look at the remaining bits that way.
> 
> That would actually work really well on x86, since there we have
> "xadd", but we do *not* have "set/clear bit and return old word".
> 
> We could make a special case for just the page lock bit, make it bit #7, and use
> 
>    movb $128,%al
>    lock xaddb %al,flags
> 
> and then test the bits in %al.
> 
> And all the RISC architectures would be ok with that too, because they
> can just use ll/sc and test the bits with that. So for them, adding a
> "atomic_long_and_return()" would be very natural in the general case.
> 
> Hmm?
> 
> The other alternative is to keep the lock bit as bit #0, and just make
> the contention bit be the high bit. Then, on x86, you can do
> 
>     lock andb $0xfe,flags
>     js contention
> 
> which might be even better. Again, it would be a very special
> operation just for unlock. Something like
> 
>    bit_clear_and_branch_if_negative_byte(mem, label);
> 
> and again, it would be trivial to do on most architectures.
> 
> Let me try to write a patch or two for testing.

Patch seems okay, but it's kind of a horrible primitive. What if you
did clear_bit_unlock_and_test_bit, which does a __builtin_constant_p
test on the bit numbers and if they are < 7 and == 7, then do the
fastpath?

Nitpick, can the enum do "= 7" to catch careless bugs? Or BUILD_BUG_ON.

And I'd to do the same for PG_writeback. AFAIKS whatever approach is
used for PG_locked should work just the same, so no problem there.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

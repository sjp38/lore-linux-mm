Date: Thu, 12 Oct 2000 10:13:48 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: [RFC] atomic pte updates for x86 smp
In-Reply-To: <Pine.LNX.4.10.10010112318110.2852-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0010120921510.1191-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Benjamin C.R. LaHaise" <blah@kvack.org>, "Theodore Y. Ts'o" <tytso@mit.edu>, linux-kernel@vger.kernel.org, MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 11 Oct 2000, Linus Torvalds wrote:

> (Instead of doing an atomic 64-bit memory write, we would be doing the
> atomic "pte_xchg_clear()" followed by two _non_atomic 32-bit writes where
> the second write would set the present bit. Although maybe the erratum
> about the PAE pgd entry not honoring the P bit correctly makes this be
> unworkable).
> 
> Ingo? I'd really like you to take a long look at this patch for sanity,
> especially wrt PAE.

the PAE pgd 'anomaly' should not affect this case, because we never clear
neither user-space pgds, nor user-space pmds in PAE mode. Unless we start
swapping pagetables i dont think this will ever happen in the future. The
PAE anomaly only affects the four top-level pgds, so even if we started
swapping pagetables, we'll never have to swap the pgds themselves.

i completely agree with the need to clean the pte-setting atomicity
interface up. And getting rid of cmpxch8b will be a definite performance
(and GCC-optimization) improvement.

> After this patch, are there any cases where we do a "set_pte()" where
> the PTE wasn't clear before? That might be a good sanity-test to add,
> just to make sure. And I'd really like to speed up the PAE set_pte() -
> as far as I can tell both set_pte and set_pmd really should be safe
> without the atomic 64-bit crap with your changes.

yep, the two 32-bit writes idea is very nice - this should be safe - and
there isnt even any need for any barriers (except optimization barrier),
given that writes are strongly ordered on x86.

my gut feeling is that all these things will only benefit PAE support, and
the risk of those changes is low, none of those should bite us in the
future, design-wise. And it's also a nice speedup. And after this we could
finally get rid of the 'unsigned long long' as well and just define two
32-bit fields in pte.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 6AB936B006E
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 19:23:52 -0400 (EDT)
Received: by wefh52 with SMTP id h52so1470509wef.14
        for <linux-mm@kvack.org>; Wed, 27 Jun 2012 16:23:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1340838807.10063.90.camel@twins>
References: <20120627211540.459910855@chello.nl> <20120627212831.137126018@chello.nl>
 <CA+55aFwZoVK76ue7tFveV0XZpPUmoCVXJx8550OxPm+XKCSSZA@mail.gmail.com>
 <1340838154.10063.86.camel@twins> <1340838807.10063.90.camel@twins>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 27 Jun 2012 16:23:30 -0700
Message-ID: <CA+55aFy6m967fMxyBsRoXVecdpGtSphXi_XdhwS0DB81Qaocdw@mail.gmail.com>
Subject: Re: [PATCH 08/20] mm: Optimize fullmm TLB flushing
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Alex Shi <alex.shi@intel.com>, "Nikunj A. Dadhania" <nikunj@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Russell King <rmk@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tony Luck <tony.luck@intel.com>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Ralf Baechle <ralf@linux-mips.org>, Kyle McMartin <kyle@mcmartin.ca>, James Bottomley <jejb@parisc-linux.org>, Chris Zankel <chris@zankel.net>

On Wed, Jun 27, 2012 at 4:13 PM, Peter Zijlstra <peterz@infradead.org> wrote:
>
> That triggered.. is this a problem though, at this point userspace is
> very dead so it shouldn't matter, right?

It still matters. Even if user space is dead, kernel space accesses
can result in TLB fills in user space. Exactly because of things like
speculative fills etc.

So what can happen - for example - is that the kernel does a indirect
jump, and the CPU predicts the destination of the jump that using the
branch prediction tables.

But the branch prediction tables are obviously just predictions, and
they easily contain user addresses etc in them. So the kernel may well
end up speculatively doing a TLB fill on a user access.

And your whole optimization depends on this not happening, unless I
read the logic wrong. The whole "invalidate the TLB just once
up-front" approach is *only* valid if you know that nothing is going
to ever fill that TLB again. But see above - if we're still running
within that TLB context, we have no idea what speculative execution
may or may not end up filling.

That said, maybe I misread your patch?

                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

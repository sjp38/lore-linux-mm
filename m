Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 03C4D6B0071
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 19:34:06 -0400 (EDT)
Received: by wibhq4 with SMTP id hq4so1392160wib.8
        for <linux-mm@kvack.org>; Wed, 27 Jun 2012 16:34:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFy6m967fMxyBsRoXVecdpGtSphXi_XdhwS0DB81Qaocdw@mail.gmail.com>
References: <20120627211540.459910855@chello.nl> <20120627212831.137126018@chello.nl>
 <CA+55aFwZoVK76ue7tFveV0XZpPUmoCVXJx8550OxPm+XKCSSZA@mail.gmail.com>
 <1340838154.10063.86.camel@twins> <1340838807.10063.90.camel@twins> <CA+55aFy6m967fMxyBsRoXVecdpGtSphXi_XdhwS0DB81Qaocdw@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 27 Jun 2012 16:33:44 -0700
Message-ID: <CA+55aFzLNsVRkp_US8rAmygEkQpp1s1YdakV86Ck-4RZM7TTdA@mail.gmail.com>
Subject: Re: [PATCH 08/20] mm: Optimize fullmm TLB flushing
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Alex Shi <alex.shi@intel.com>, "Nikunj A. Dadhania" <nikunj@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Russell King <rmk@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tony Luck <tony.luck@intel.com>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Ralf Baechle <ralf@linux-mips.org>, Kyle McMartin <kyle@mcmartin.ca>, James Bottomley <jejb@parisc-linux.org>, Chris Zankel <chris@zankel.net>

On Wed, Jun 27, 2012 at 4:23 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> But the branch prediction tables are obviously just predictions, and
> they easily contain user addresses etc in them. So the kernel may well
> end up speculatively doing a TLB fill on a user access.

That should be ".. on a user *address*", hopefully that was clear from
the context, if not from the text.

IOW, the point I'm trying to make is that even if there are zero
*actual* accesses of user space (because user space is dead, and the
kernel hopefully does no "get_user()/put_user()" stuff at this point
any more), the CPU may speculatively use user addresses for the
bog-standard kernel addresses that happen.

Taking a user address from the BTB is just one example. Speculative
memory accesses might happen after a mis-predicted branch, where we
test a pointer against NULL, and after the branch we access it. So
doing a speculative TLB walk of the NULL address would not necessarily
even be unusual. Obviously normally nothing is actually mapped there,
but these kinds of things can *easily* result in the page tables
themselves being cached, even if the final page doesn't exist.

Also, all of this obviously depends on how aggressive the speculation
is. It's entirely possible that effects like these are really hard to
see in practice, and you'll almost never hit it. But stale TLB
contents (or stale page directory caches) are *really* nasty when they
do happen, and almost impossible to debug. So we want to be insanely
anal in this area.

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

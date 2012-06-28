Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 0A3BF6B0062
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 06:56:41 -0400 (EDT)
Message-ID: <1340880904.28750.13.camel@twins>
Subject: Re: [PATCH 08/20] mm: Optimize fullmm TLB flushing
From: Peter Zijlstra <peterz@infradead.org>
Date: Thu, 28 Jun 2012 12:55:04 +0200
In-Reply-To: <CA+55aFzLNsVRkp_US8rAmygEkQpp1s1YdakV86Ck-4RZM7TTdA@mail.gmail.com>
References: <20120627211540.459910855@chello.nl>
	 <20120627212831.137126018@chello.nl>
	 <CA+55aFwZoVK76ue7tFveV0XZpPUmoCVXJx8550OxPm+XKCSSZA@mail.gmail.com>
	 <1340838154.10063.86.camel@twins> <1340838807.10063.90.camel@twins>
	 <CA+55aFy6m967fMxyBsRoXVecdpGtSphXi_XdhwS0DB81Qaocdw@mail.gmail.com>
	 <CA+55aFzLNsVRkp_US8rAmygEkQpp1s1YdakV86Ck-4RZM7TTdA@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Alex Shi <alex.shi@intel.com>, "Nikunj A.
 Dadhania" <nikunj@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Russell King <rmk@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tony Luck <tony.luck@intel.com>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Ralf Baechle <ralf@linux-mips.org>, Kyle McMartin <kyle@mcmartin.ca>, James Bottomley <jejb@parisc-linux.org>, Chris Zankel <chris@zankel.net>

On Wed, 2012-06-27 at 16:33 -0700, Linus Torvalds wrote:
> IOW, the point I'm trying to make is that even if there are zero
> *actual* accesses of user space (because user space is dead, and the
> kernel hopefully does no "get_user()/put_user()" stuff at this point
> any more), the CPU may speculatively use user addresses for the
> bog-standard kernel addresses that happen.=20

Right.. and s390 having done this only says that s390 appears to be ok
with it. Martin, does s390 hardware guarantee no speculative stuff like
Linus explained, or might there even be a latent issue on s390?

But it looks like we cannot do this in general, and esp. ARM (as already
noted by Catalin) has very aggressive speculative behaviour.

The alternative is that we do a switch_mm() to init_mm instead of the
TLB flush. On x86 that should be about the same cost, but I've not
looked at other architectures yet.

The second and least favourite alternative is of course special casing
this for s390 if it turns out its a safe thing to do for them.

/me goes look through arch code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

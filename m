Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 0C1A86B0068
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 12:52:54 -0400 (EDT)
Message-ID: <1340902329.28750.83.camel@twins>
Subject: Re: [PATCH 08/20] mm: Optimize fullmm TLB flushing
From: Peter Zijlstra <peterz@infradead.org>
Date: Thu, 28 Jun 2012 18:52:09 +0200
In-Reply-To: <CA+55aFwByDWu5bP__e3sw34E7s88f_2P=8m=i6SuP6s+NZgF6w@mail.gmail.com>
References: <20120627211540.459910855@chello.nl>
	 <20120627212831.137126018@chello.nl>
	 <CA+55aFwZoVK76ue7tFveV0XZpPUmoCVXJx8550OxPm+XKCSSZA@mail.gmail.com>
	 <1340838154.10063.86.camel@twins> <1340838807.10063.90.camel@twins>
	 <CA+55aFy6m967fMxyBsRoXVecdpGtSphXi_XdhwS0DB81Qaocdw@mail.gmail.com>
	 <CA+55aFzLNsVRkp_US8rAmygEkQpp1s1YdakV86Ck-4RZM7TTdA@mail.gmail.com>
	 <20120628091627.GB8573@arm.com> <1340879984.20977.80.camel@pasglop>
	 <1340881196.28750.16.camel@twins> <20120628145327.GA17242@arm.com>
	 <1340900425.28750.73.camel@twins>
	 <CA+55aFwByDWu5bP__e3sw34E7s88f_2P=8m=i6SuP6s+NZgF6w@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Alex Shi <alex.shi@intel.com>, "Nikunj A. Dadhania" <nikunj@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, David Miller <davem@davemloft.net>, Russell King <rmk@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tony Luck <tony.luck@intel.com>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Ralf Baechle <ralf@linux-mips.org>, Kyle McMartin <kyle@mcmartin.ca>, James Bottomley <jejb@parisc-linux.org>, Chris Zankel <chris@zankel.net>

On Thu, 2012-06-28 at 09:45 -0700, Linus Torvalds wrote:
> On Thu, Jun 28, 2012 at 9:20 AM, Peter Zijlstra <peterz@infradead.org> wr=
ote:
> >
> > How horrid is something like the below. It detaches the mm so that
> > hardware speculation simply doesn't matter.
>=20
> Actually, that's wrong. Even when detached, kernel threads may still
> use that mm lazily. Now, that only happens on other CPU's (if any
> scheduling happens on *this* CPU, they will lazily take the mm of the
> thread it scheduled away from), but even if you detach the VM that
> doesn't mean that hardware speculation wouldn't matter. Kernel threads
> on other CPU's may still be doing TLB accesses.
>=20
> Of course, I *think* that if we do an IPI on the thing, we also kick
> those kernel threads out of using that mm. So it may actually work if
> you also do that explicit TLB flush to make sure other CPU's don't
> have this MM. I don't think switch_mm() does that for you, it only
> does a local-cpu invalidate.
>=20
> I didn't look at the code, though. Maybe I'm wrong in thinking that
> you are wrong.

No I think you're right (as always).. also an IPI will not force
schedule the thread that might be running on the receiving cpu, also
we'd have to wait for any such schedule to complete in order to
guarantee the mm isn't lazily used anymore.

Bugger.. it would've been nice to do this. I guess I'd better go special
case s390 for now until we can come up with something that would work.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

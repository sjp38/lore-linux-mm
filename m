Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 918BE6B0075
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 12:45:32 -0400 (EDT)
Received: by wibhm2 with SMTP id hm2so299352wib.2
        for <linux-mm@kvack.org>; Thu, 28 Jun 2012 09:45:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1340900425.28750.73.camel@twins>
References: <20120627211540.459910855@chello.nl> <20120627212831.137126018@chello.nl>
 <CA+55aFwZoVK76ue7tFveV0XZpPUmoCVXJx8550OxPm+XKCSSZA@mail.gmail.com>
 <1340838154.10063.86.camel@twins> <1340838807.10063.90.camel@twins>
 <CA+55aFy6m967fMxyBsRoXVecdpGtSphXi_XdhwS0DB81Qaocdw@mail.gmail.com>
 <CA+55aFzLNsVRkp_US8rAmygEkQpp1s1YdakV86Ck-4RZM7TTdA@mail.gmail.com>
 <20120628091627.GB8573@arm.com> <1340879984.20977.80.camel@pasglop>
 <1340881196.28750.16.camel@twins> <20120628145327.GA17242@arm.com> <1340900425.28750.73.camel@twins>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 28 Jun 2012 09:45:10 -0700
Message-ID: <CA+55aFwByDWu5bP__e3sw34E7s88f_2P=8m=i6SuP6s+NZgF6w@mail.gmail.com>
Subject: Re: [PATCH 08/20] mm: Optimize fullmm TLB flushing
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Alex Shi <alex.shi@intel.com>, "Nikunj A. Dadhania" <nikunj@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, David Miller <davem@davemloft.net>, Russell King <rmk@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tony Luck <tony.luck@intel.com>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Ralf Baechle <ralf@linux-mips.org>, Kyle McMartin <kyle@mcmartin.ca>, James Bottomley <jejb@parisc-linux.org>, Chris Zankel <chris@zankel.net>

On Thu, Jun 28, 2012 at 9:20 AM, Peter Zijlstra <peterz@infradead.org> wrote:
>
> How horrid is something like the below. It detaches the mm so that
> hardware speculation simply doesn't matter.

Actually, that's wrong. Even when detached, kernel threads may still
use that mm lazily. Now, that only happens on other CPU's (if any
scheduling happens on *this* CPU, they will lazily take the mm of the
thread it scheduled away from), but even if you detach the VM that
doesn't mean that hardware speculation wouldn't matter. Kernel threads
on other CPU's may still be doing TLB accesses.

Of course, I *think* that if we do an IPI on the thing, we also kick
those kernel threads out of using that mm. So it may actually work if
you also do that explicit TLB flush to make sure other CPU's don't
have this MM. I don't think switch_mm() does that for you, it only
does a local-cpu invalidate.

I didn't look at the code, though. Maybe I'm wrong in thinking that
you are wrong.

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

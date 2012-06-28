Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 0256F6B0068
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 18:00:00 -0400 (EDT)
Message-ID: <1340920696.20977.104.camel@pasglop>
Subject: Re: [PATCH 08/20] mm: Optimize fullmm TLB flushing
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Fri, 29 Jun 2012 07:58:16 +1000
In-Reply-To: <1340920641.20977.103.camel@pasglop>
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
	 <1340902329.28750.83.camel@twins> <1340920641.20977.103.camel@pasglop>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Alex Shi <alex.shi@intel.com>, "Nikunj A. Dadhania" <nikunj@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, David Miller <davem@davemloft.net>, Russell King <rmk@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tony Luck <tony.luck@intel.com>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Ralf Baechle <ralf@linux-mips.org>, Kyle McMartin <kyle@mcmartin.ca>, James Bottomley <jejb@parisc-linux.org>, Chris Zankel <chris@zankel.net>

On Fri, 2012-06-29 at 07:57 +1000, Benjamin Herrenschmidt wrote:
> On Thu, 2012-06-28 at 18:52 +0200, Peter Zijlstra wrote:
> > No I think you're right (as always).. also an IPI will not force
> > schedule the thread that might be running on the receiving cpu, also
> > we'd have to wait for any such schedule to complete in order to
> > guarantee the mm isn't lazily used anymore.
> > 
> > Bugger.. 
> 
> You can still do it if the mm count is 1 no ? Ie, current is the last
> holder of a reference to the mm struct... which will probably be the
> common case for short lived programs.

Also I just remembered... x86 flushes in SMP via IPIs right ? So maybe
you can invent a "detach and flush" variant of it ? 

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

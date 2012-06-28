Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 096556B0062
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 07:20:25 -0400 (EDT)
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Thu, 28 Jun 2012 12:20:24 +0100
Received: from d06av06.portsmouth.uk.ibm.com (d06av06.portsmouth.uk.ibm.com [9.149.37.217])
	by d06nrmr1707.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5SBJsob2560204
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 12:19:54 +0100
Received: from d06av06.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av06.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5SBJq17016228
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 05:19:54 -0600
Date: Thu, 28 Jun 2012 13:19:50 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH 08/20] mm: Optimize fullmm TLB flushing
Message-ID: <20120628131950.0afe39f0@de.ibm.com>
In-Reply-To: <1340880904.28750.13.camel@twins>
References: <20120627211540.459910855@chello.nl>
	<20120627212831.137126018@chello.nl>
	<CA+55aFwZoVK76ue7tFveV0XZpPUmoCVXJx8550OxPm+XKCSSZA@mail.gmail.com>
	<1340838154.10063.86.camel@twins>
	<1340838807.10063.90.camel@twins>
	<CA+55aFy6m967fMxyBsRoXVecdpGtSphXi_XdhwS0DB81Qaocdw@mail.gmail.com>
	<CA+55aFzLNsVRkp_US8rAmygEkQpp1s1YdakV86Ck-4RZM7TTdA@mail.gmail.com>
	<1340880904.28750.13.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Alex Shi <alex.shi@intel.com>, "Nikunj A.
 Dadhania" <nikunj@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Russell King <rmk@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Chris Metcalf <cmetcalf@tilera.com>, Tony Luck <tony.luck@intel.com>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Ralf Baechle <ralf@linux-mips.org>, Kyle McMartin <kyle@mcmartin.ca>, James Bottomley <jejb@parisc-linux.org>, Chris Zankel <chris@zankel.net>

On Thu, 28 Jun 2012 12:55:04 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

> On Wed, 2012-06-27 at 16:33 -0700, Linus Torvalds wrote:
> > IOW, the point I'm trying to make is that even if there are zero
> > *actual* accesses of user space (because user space is dead, and the
> > kernel hopefully does no "get_user()/put_user()" stuff at this point
> > any more), the CPU may speculatively use user addresses for the
> > bog-standard kernel addresses that happen. 
> 
> Right.. and s390 having done this only says that s390 appears to be ok
> with it. Martin, does s390 hardware guarantee no speculative stuff like
> Linus explained, or might there even be a latent issue on s390?

The cpu can create speculative TLB entries, but only if it runs in the
mode that uses the respective mm. We have two mm's active at the same
time, the kernel mm (init_mm) and the user mm. While the cpu runs only
in kernel mode it is not allowed to create TLBs for the user mm.
While running in user mode it is allowed to speculatively create TLBs.
 
> But it looks like we cannot do this in general, and esp. ARM (as already
> noted by Catalin) has very aggressive speculative behaviour.
> 
> The alternative is that we do a switch_mm() to init_mm instead of the
> TLB flush. On x86 that should be about the same cost, but I've not
> looked at other architectures yet.
> 
> The second and least favourite alternative is of course special casing
> this for s390 if it turns out its a safe thing to do for them.
> 
> /me goes look through arch code.

Basically we have two special requirements on s390:
1) do not modify ptes while attached to another cpu except with the
   special IPTE / IDTE instructions
2) do a TLB flush before freeing any kind of page table page, s390
   needs a flush for pud, pmd & pte tables.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

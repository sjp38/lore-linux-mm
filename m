Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 2B1506B0088
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 18:23:53 -0400 (EDT)
Received: by wibhq4 with SMTP id hq4so1354240wib.8
        for <linux-mm@kvack.org>; Wed, 27 Jun 2012 15:23:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120627212830.693232452@chello.nl>
References: <20120627211540.459910855@chello.nl> <20120627212830.693232452@chello.nl>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 27 Jun 2012 15:23:28 -0700
Message-ID: <CA+55aFwa41fzvx8EZG_gODvw7hSpr+iP+w5fXp6jUcQh-4nFgQ@mail.gmail.com>
Subject: Re: [PATCH 02/20] mm: Add optional TLB flush to generic RCU
 page-table freeing
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Alex Shi <alex.shi@intel.com>, "Nikunj A. Dadhania" <nikunj@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Russell King <rmk@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tony Luck <tony.luck@intel.com>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Hans-Christian Egtvedt <hans-christian.egtvedt@atmel.com>, Ralf Baechle <ralf@linux-mips.org>, Kyle McMartin <kyle@mcmartin.ca>, James Bottomley <jejb@parisc-linux.org>, Chris Zankel <chris@zankel.net>

On Wed, Jun 27, 2012 at 2:15 PM, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
>
> Certain architectures (viz. x86, arm, s390) have hardware page-table
> walkers (#PF). So during the RCU page-table teardown process make sure
> we do a tlb flush of page-table pages on all relevant CPUs to
> synchronize against hardware walkers, and then free the pages.

NACK.

Why would hw page table walkers be that special? Plus your config
option is horribly done anyway, where you do it as some kind of
"default y" and then have complex conditionals on it.

Plus it really isn't about hardware page table walkers at all. It's
more about the possibility of speculative TLB fils, it has nothing to
do with *how* they are done. Sure, it's likely that a software
pagetable walker wouldn't be something that gets called speculatively,
but it's not out of the question.

So I think your config option is totally mis-designed and actively
misleading. It's also horrible from a design standpoint, since it's
entirely possible that some day POWERPC will actually see the light
and do speculative TLB fills etc.

So *if* this needs to be done, it needs to be done right. That means:

 - don't talk about HW walking, since it's not about that

 - don't say "if you have speculative walkers", and use an ifndef. Say
"If you can *guarantee* that nothing else walks page tables
speculatively, and we have only one thread that owns the mmu, and that
one thread is us, *then* we can do this optimization". So switch the
config option around.

 - make it a per-architecture thing to say "I guarantee that I never
fill the TLB speculatively". Don't do that "default y" with complex
conditionals crap.

IOW, if Sparc/PPC really want to guarantee that they never fill TLB
entries speculatively, and that if we are in a kernel thread they will
*never* fill the TLB with anything else, then make them enable
CONFIG_STRICT_TLB_FILL or something in their architecture Kconfig
files.

Not like this patch. And not with the misleading names and comments.

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

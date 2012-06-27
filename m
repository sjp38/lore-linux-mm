Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 4D0E66B0069
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 19:43:15 -0400 (EDT)
Received: by wgbdt14 with SMTP id dt14so1497724wgb.26
        for <linux-mm@kvack.org>; Wed, 27 Jun 2012 16:43:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1340838106.10063.85.camel@twins>
References: <20120627211540.459910855@chello.nl> <20120627212830.693232452@chello.nl>
 <CA+55aFwa41fzvx8EZG_gODvw7hSpr+iP+w5fXp6jUcQh-4nFgQ@mail.gmail.com> <1340838106.10063.85.camel@twins>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 27 Jun 2012 16:42:52 -0700
Message-ID: <CA+55aFw0RLsnh5j2c=YcN9ooM3vesj7MCZx5d-V5CXC0tQ6Asg@mail.gmail.com>
Subject: Re: [PATCH 02/20] mm: Add optional TLB flush to generic RCU
 page-table freeing
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Alex Shi <alex.shi@intel.com>, "Nikunj A. Dadhania" <nikunj@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Russell King <rmk@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tony Luck <tony.luck@intel.com>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Ralf Baechle <ralf@linux-mips.org>, Kyle McMartin <kyle@mcmartin.ca>, James Bottomley <jejb@parisc-linux.org>, Chris Zankel <chris@zankel.net>

On Wed, Jun 27, 2012 at 4:01 PM, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
>
> How about something like this

Looks better.

I'd be even happier if you made the whole

  "When there's less then two users.."

(There's a misspelling there, btw, I didn't notice until I
cut-and-pasted that) logic be a helper function, and have that helper
function be inside that same #ifdef CONFIG_STRICT_TLB_FILL block
together witht he tlb_table_flush_mmu() function.

IOW, something like

  static int tlb_remove_table_quick( struct mmu_gather *tlb, void *table)
  {
        if (atomic_read(&tlb->mm->mm_users) < 2) {
            __tlb_remove_table(table);
            return 1;
        }
        return 0;
  }

for the CONFIG_STRICT_TLB_FILL case, and then the default case just
does an unconditional "return 0".

So that the actual code can avoid having #ifdef's in the middle of a
function, and could just do

    if (tlb_remove_table_quick(tlb, table))
        return;

instead.

Maybe it's just me, but I detest seeing #ifdef's in the middle of
code. I'd much rather have the #ifdef's *outside* the code and have
these kinds of helper functions that sometimes end up becoming empty.

                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

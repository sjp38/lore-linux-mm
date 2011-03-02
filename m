Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 1AACB8D0039
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 14:27:45 -0500 (EST)
Received: from mail-iy0-f169.google.com (mail-iy0-f169.google.com [209.85.210.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p22JR2mq017900
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Wed, 2 Mar 2011 11:27:02 -0800
Received: by iyf13 with SMTP id 13so308967iyf.14
        for <linux-mm@kvack.org>; Wed, 02 Mar 2011 11:27:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110302180258.956518392@chello.nl>
References: <20110302175928.022902359@chello.nl> <20110302180258.956518392@chello.nl>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 2 Mar 2011 11:19:48 -0800
Message-ID: <AANLkTimhWKhHojZ-9XZGSh3OzfPhvo__Dib9VfeMWoBQ@mail.gmail.com>
Subject: Re: [RFC][PATCH 2/6] mm: Change flush_tlb_range() to take an mm_struct
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Russell King <rmk@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Wed, Mar 2, 2011 at 9:59 AM, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> In order to be able to properly support architecture that want/need to
> support TLB range invalidation, we need to change the
> flush_tlb_range() argument from a vm_area_struct to an mm_struct
> because the range might very well extend past one VMA, or not have a
> VMA at all.

I really don't think this is right. The whole "drop the icache
information" thing is a total anti-optimization, since for some
architectures, the icache flush is the _big_ deal. Possibly much
bigger than the TLB flush itself. Doing an icache flush was much more
expensive than the TLB flush on alpha, for example (the tlb had ASI's
etc, the icache did not).

> There are various reasons that we need to flush TLBs _after_ freeing
> the page-tables themselves. For some architectures (x86 among others)
> this serializes against (both hardware and software) page table
> walkers like gup_fast().

This part of the changelog also makes no sense what-so-ever. It's
actively wrong.

On x86, we absolutely *must* do the TLB flush _before_ we release the
page tables. So your commentary is actively wrong and misleading.

The order has to be:
 - clear the page table entry, queue the page to be free'd
 - flush the TLB
 - free the page (and page tables)

and nothing else is correct, afaik. So the changelog is pure and utter
garbage. I didn't look at what the patch actually changed.

NAK.

                         Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 296D28D0039
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 16:00:00 -0500 (EST)
Message-ID: <4D6EAF93.5000000@redhat.com>
Date: Wed, 02 Mar 2011 15:58:59 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 2/6] mm: Change flush_tlb_range() to take an mm_struct
References: <20110302175928.022902359@chello.nl> <20110302180258.956518392@chello.nl> <AANLkTimhWKhHojZ-9XZGSh3OzfPhvo__Dib9VfeMWoBQ@mail.gmail.com>
In-Reply-To: <AANLkTimhWKhHojZ-9XZGSh3OzfPhvo__Dib9VfeMWoBQ@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Russell King <rmk@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On 03/02/2011 02:19 PM, Linus Torvalds wrote:

>> There are various reasons that we need to flush TLBs _after_ freeing
>> the page-tables themselves. For some architectures (x86 among others)
>> this serializes against (both hardware and software) page table
>> walkers like gup_fast().
>
> This part of the changelog also makes no sense what-so-ever. It's
> actively wrong.
>
> On x86, we absolutely *must* do the TLB flush _before_ we release the
> page tables. So your commentary is actively wrong and misleading.
>
> The order has to be:
>   - clear the page table entry, queue the page to be free'd
>   - flush the TLB
>   - free the page (and page tables)
>
> and nothing else is correct, afaik. So the changelog is pure and utter
> garbage. I didn't look at what the patch actually changed.

The patch seems to preserve the correct behaviour.

The changelog should probably read something along the
lines of:

"There are various reasons that we need to flush TLBs _after_
  clearing the page-table entries themselves."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

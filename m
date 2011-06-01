Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 01F4C6B004A
	for <linux-mm@kvack.org>; Wed,  1 Jun 2011 17:40:25 -0400 (EDT)
Date: Wed, 1 Jun 2011 22:40:18 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: compaction: Abort compaction if too many pages are
 isolated and caller is asynchronous
Message-ID: <20110601214018.GC7306@suse.de>
References: <20110530153748.GS5044@csn.ul.ie>
 <20110530165546.GC5118@suse.de>
 <20110530175334.GI19505@random.random>
 <20110531121620.GA3490@barrios-laptop>
 <20110531122437.GJ19505@random.random>
 <20110531133340.GB3490@barrios-laptop>
 <20110531141402.GK19505@random.random>
 <20110601005747.GC7019@csn.ul.ie>
 <20110601175809.GB7306@suse.de>
 <20110601191529.GY19505@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110601191529.GY19505@random.random>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, akpm@linux-foundation.org, Ury Stankevich <urykhy@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org

On Wed, Jun 01, 2011 at 09:15:29PM +0200, Andrea Arcangeli wrote:
> On Wed, Jun 01, 2011 at 06:58:09PM +0100, Mel Gorman wrote:
> > Umm, HIGHMEM4G implies a two-level pagetable layout so where are
> > things like _PAGE_BIT_SPLITTING being set when THP is enabled?
> 
> They should be set on the pgd, pud_offset/pgd_offset will just bypass.
> The splitting bit shouldn't be special about it, the present bit
> should work the same.

This comment is misleading at best then.

#define _PAGE_BIT_SPLITTING     _PAGE_BIT_UNUSED1 /* only valid on a PSE pmd */

At the PGD level, it can have PSE set obviously but it's not a
PMD. I confess I haven't checked the manual to see if it's safe to
use _PAGE_BIT_UNUSED1 like this so am taking your word for it. I
found that the bug is far harder to reproduce with 3 pagetable levels
than with 2 but that is just timing. So far it has proven impossible
on x86-64 at least within 27 hours so that has me looking at how
pagetable management between x86 and x86-64 differ.

Barriers are a big different between how 32-bit !SMP and X86-64 but
don't know yet which one is relevant or if this is even the right
direction.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

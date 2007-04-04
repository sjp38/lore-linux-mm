Date: Wed, 4 Apr 2007 08:35:30 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [rfc] no ZERO_PAGE?
In-Reply-To: <20070404033726.GE18507@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0704040830500.6730@woody.linux-foundation.org>
References: <20070329075805.GA6852@wotan.suse.de>
 <Pine.LNX.4.64.0703291324090.21577@blonde.wat.veritas.com>
 <20070330024048.GG19407@wotan.suse.de> <20070404033726.GE18507@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, tee@sgi.com, holt@sgi.com, Andrea Arcangeli <andrea@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


On Wed, 4 Apr 2007, Nick Piggin wrote:
> 
> Shall I do a more complete patchset and ask Andrew to give it a
> run in -mm?

Do this trivial one first. See how it fares.

Although I don't know how much -mm will do for it. There is certainly not 
going to be any correctness problems, afaik, just *performance* problems. 
Does anybody do any performance testing on -mm?

That said, talking about correctness/performance problems:

> +	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
> +	if (likely(!pte_none(*page_table))) {
>  		inc_mm_counter(mm, anon_rss);
>  		lru_cache_add_active(page);
>  		page_add_new_anon_rmap(page, vma, address);

Isn't that test the wrong way around?

Shouldn't it be

	if (likely(pte_none(*page_table))) {

without any logical negation? Was this patch tested?

Anyway, I'm not against this, but I can see somebody actually *wanting* 
the ZERO page in some cases. I've used the fact for TLB testing, for 
example, by just doing a big malloc(), and knowing that the kernel will 
re-use the ZERO_PAGE so that I don't get any cache effects (well, at least 
not any *physical* cache effects. Virtually indexed cached will still show 
effects of it, of course, but I haven't cared).

That's an example of an app that actually cares about the page allocation 
(or, in this case, the lack there-of). Not an important one, but maybe 
there are important ones that care?

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

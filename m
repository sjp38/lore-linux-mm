Subject: Re: [RFC][PATCH 0/10] alternate 4-level page tables patches
From: Nick Piggin <nickpiggin@yahoo.com.au>
In-Reply-To: <Pine.LNX.4.44.0412210230500.24496-100000@localhost.localdomain>
References: <Pine.LNX.4.44.0412210230500.24496-100000@localhost.localdomain>
Content-Type: text/plain
Date: Tue, 21 Dec 2004 14:21:29 +1100
Message-Id: <1103599289.5121.27.camel@npiggin-nld.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andi Kleen <ak@suse.de>, Linus Torvalds <torvalds@osdl.org>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2004-12-21 at 02:55 +0000, Hugh Dickins wrote:
> On Tue, 21 Dec 2004, Nick Piggin wrote:
> > 
> > Anyway, I'll continue to try to get more architecture support,
> 
> Sorry for being dense: despite your earlier explanation,
> I've yet again lost track of why pud needs any flag day through
> the architectures - beyond the inclusion of some generic nopud.h,
> but different from the one you're rightly aiming for.
> 
> Good as they are, imagine setting aside your nopmd.h mods as a cleanup
> for some other occasion.  Then wouldn't a generic nopud.h something like
> 
> #define pud_t				pgd_t
> #define pud_alloc(mm, pgd, address)	(pgd)
> #define pud_offset(pgd, start)		(pgd)
> #define pud_none(pud)			0
> #define pud_bad(pud)			0
> #define pud_ERROR(pud)
> #define pud_clear(pud)
> #define PUD_SIZE			PGDIR_SIZE
> #define PUD_MASK			PGDIR_MASK
> 
> get your kernel with common patch 6/10 compiling and working correctly
> on all architectures?  with just a one-line mod to each architecture
> to include it?
> 
> Your answer seems to be no, so I guess there's a place in the code
> you can point to, which shows up the nonsense of this suggestion:
> please humiliate me!
> 

Hmm yeah that would be ideal, I think.

Maybe I didn't explore it far enough... but __pmd_alloc will be now
doing a pud_populate to set up the allocated pmd, that pud_populate
needs to be what pgd_populate was before the conversion...

Hmm, so I guess

#define pud_populate pgd_populate

would do it.

I did get about that far, but that was in the context of the nopmd
cleanup, where I was getting tangled up on these (and other) things.
You may be right in that it is much easier to do the above conversion
in terms of nopud only, because you are starting with a cleaner slate...



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

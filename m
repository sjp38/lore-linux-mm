Date: Tue, 6 May 2008 21:30:44 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] x86: fix PAE pmd_bad bootup warning
In-Reply-To: <alpine.LFD.1.10.0805061302080.32269@woody.linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0805062120120.16053@blonde.site>
References: <b6a2187b0805051806v25fa1272xb08e0b70b9c3408@mail.gmail.com>
 <20080506124946.GA2146@elte.hu> <Pine.LNX.4.64.0805061435510.32567@blonde.site>
 <alpine.LFD.1.10.0805061138580.32269@woody.linux-foundation.org>
 <Pine.LNX.4.64.0805062043580.11647@blonde.site>
 <alpine.LFD.1.10.0805061302080.32269@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, Jeff Chua <jeff.chua.linux@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Gabriel C <nix.or.die@googlemail.com>, Hans Rosenfeld <hans.rosenfeld@amd.com>, Arjan van de Ven <arjan@linux.intel.com>, Nishanth Aravamudan <nacc@us.ibm.com>, Jeremy Fitzhardinge <jeremy@goop.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 6 May 2008, Linus Torvalds wrote:
> On Tue, 6 May 2008, Hugh Dickins wrote:
> >
> > Fix Hans' good observation that follow_page() will never find pmd_huge()
> > because that would have already failed the pmd_bad test: test pmd_huge in
> > between the pmd_none and pmd_bad tests.  Tighten x86's pmd_huge() check?
> > No, once it's a hugepage entry, it can get quite far from a good pmd: for
> > example, PROT_NONE leaves it with only ACCESSED of the KERN_PGTABLE bits.
> 
> I'd much rather have pdm_bad() etc fixed up instead, so that they do a 
> more proper test (not thinking that a PSE page is bad, since it clearly 
> isn't). And then, make them dependent on DEBUG_VM, because doing the 
> proper test will be more expensive.

But everywhere we use pmd_bad() etc (most are hidden inside
pmd_none_or_clear_bad() etc) we are expecting never to encounter
a pmd_huge, unless there's corruption.  follow_page() is the one
exception, and even in its case I can't find a current user that
actually could meet a hugepage.  I'd rather tighten up pmd_bad
(in the PAE and x86_64 cases), than weaken it so far as to let
hugepages slip through.  Not that pmd_bad often catches anything:
just coincidentally that 90909090 one today.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

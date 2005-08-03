Date: Wed, 3 Aug 2005 12:47:14 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch 2.6.13-rc4] fix get_user_pages bug
In-Reply-To: <42F09B41.3050409@yahoo.com.au>
Message-ID: <Pine.LNX.4.61.0508031231540.13845@goblin.wat.veritas.com>
References: <OF3BCB86B7.69087CF8-ON42257051.003DCC6C-42257051.00420E16@de.ibm.com>
 <Pine.LNX.4.58.0508020829010.3341@g5.osdl.org>
 <Pine.LNX.4.61.0508021645050.4921@goblin.wat.veritas.com>
 <Pine.LNX.4.58.0508020911480.3341@g5.osdl.org>
 <Pine.LNX.4.61.0508021809530.5659@goblin.wat.veritas.com>
 <Pine.LNX.4.58.0508021127120.3341@g5.osdl.org>
 <Pine.LNX.4.61.0508022001420.6744@goblin.wat.veritas.com>
 <Pine.LNX.4.58.0508021244250.3341@g5.osdl.org>
 <Pine.LNX.4.61.0508022150530.10815@goblin.wat.veritas.com>
 <42F09B41.3050409@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linus Torvalds <torvalds@osdl.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@osdl.org>, Robin Holt <holt@sgi.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>, Roland McGrath <roland@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 3 Aug 2005, Nick Piggin wrote:
> Hugh Dickins wrote:
> > 
> > Here we are: get_user_pages quite untested, let alone the racy case,
> > but I think it should work.  Please all hack it around as you see fit,
> > I'll check mail when I get home, but won't be very responsive...
> 
> Seems OK to me. I don't know why you think handle_mm_fault can't
> be inline, but if it can be, then I have a modification attached
> that removes the condition - any good?

Stupidity was the reason I thought handle_mm_fault couldn't be inline:
I was picturing it static inline within mm/memory.c, failed to make the
great intellectual leap you've achieved by moving it to include/linux/mm.h.

> Oh, it gets rid of the -1 for VM_FAULT_OOM. Doesn't seem like there
> is a good reason for it, but might that break out of tree drivers?

No, I don't think it would break anything: it's just an historic oddity,
used to be -1 for failure, and only got given a name recently, I think
when wli added the proper major/minor counting.

Your version of the patch looks less hacky to me (not requiring
VM_FAULT_WRITE_EXPECTED arg), though we could perfectly well remove
that at leisure by adding VM_FAULT_WRITE case into all the arches in
2.6.14 (which might be preferable to leaving the __inline obscurity?).

I don't mind either way, but since you've not yet found an actual
error in mine, I'd prefer you to make yours a tidyup patch on top,
Signed-off-by your own good self, and let Linus decide whether he
wants to apply yours on top or not.  Or perhaps the decision rests
for the moment with Robin, whether he gets his customer to test
yours or mine - whichever is tested is the one which should go in.

Hugh
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

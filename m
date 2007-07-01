Date: Sun, 1 Jul 2007 09:54:45 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch 5/5] Optimize page_mkclean_one
In-Reply-To: <1183274153.15924.6.camel@localhost>
Message-ID: <Pine.LNX.4.64.0707010926130.11148@blonde.wat.veritas.com>
References: <20070629135530.912094590@de.ibm.com>  <20070629141528.511942868@de.ibm.com>
  <Pine.LNX.4.64.0706301448450.13752@blonde.wat.veritas.com>
 <1183274153.15924.6.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 1 Jul 2007, Martin Schwidefsky wrote:
> > 
> > Expect you're right, but I _really_ don't want to comment, when I don't
> > understand that "|| pte_write" in the first place, and don't know the
> > consequence of pte_dirty && !pte_write or !pte_dirty && pte_write there.
> 
> The pte_write() part is for the shared dirty page tracking. If you want
> to make sure that a max of x% of your pages are dirty then you cannot
> allow to have more than x% to be writable. Thats why page_mkclean_one
> clears the dirty bit and makes the page read-only.

The whole of page_mkclean_one is for the dirty page tracking: so it's
obvious why it tests pte_dirty, but not obvious why it tests pte_write.

> 
> > My suspicion is that the "|| pte_write" is precisely to cover your
> > s390 case where pte is never dirty (it may even have been me who got
> > Peter to put it in for that reason).  In which case your patch would
> > be fine - though I think it'd be improved a lot by a comment or
> > rearrangement or new macro in place of the pte_dirty || pte_write
> > line (perhaps adjust my pte_maybe_dirty in asm-generic/pgtable.h,
> > and use that - its former use in msync has gone away now).
> 
> No, s390 is covered by the page_test_dirty / page_clear_dirty pair in
> page_mkclean. 

That's where its dirty page count comes from, yes: but since the s390
pte_dirty just says no, if page_mkclean_one tested only pte_dirty,
then it wouldn't do anything on s390, and in particular wouldn't
write protect the ptes to re-enforce dirty counting from then on.

So in answering your denials, I grow more confident that the pte_write
test is precisely for the s390 case.  Though it might also be to cover
some defect in the write-protection scheme on other arches.

Come to think of it, would your patch really make any difference?
Although page_mkclean's "count" of dirty ptes on s390 will be nonsense,
that count would anyway be unknown, and it's only used as a boolean;
and now I don't think your patch changes the boolean value - if any
pte is found writable (and if the scheme is working) that implies
that the page was written to, and so should give the same answer
as the page_test_dirty.

But I could easily be overlooking something: Peter will recall.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

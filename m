Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D4E636B02AC
	for <linux-mm@kvack.org>; Thu,  6 May 2010 05:54:43 -0400 (EDT)
Date: Thu, 6 May 2010 10:54:22 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/2] mm,migration: Prevent rmap_walk_[anon|ksm] seeing
	the wrong VMA information
Message-ID: <20100506095422.GA20979@csn.ul.ie>
References: <1273065281-13334-1-git-send-email-mel@csn.ul.ie> <1273065281-13334-2-git-send-email-mel@csn.ul.ie> <alpine.LFD.2.00.1005050729000.5478@i5.linux-foundation.org> <20100505145620.GP20979@csn.ul.ie> <alpine.LFD.2.00.1005050815060.5478@i5.linux-foundation.org> <20100505175311.GU20979@csn.ul.ie> <alpine.LFD.2.00.1005051058380.27218@i5.linux-foundation.org> <20100506002255.GY20979@csn.ul.ie> <p2s28c262361005060247m2983625clff01aeaa1668402f@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <p2s28c262361005060247m2983625clff01aeaa1668402f@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, May 06, 2010 at 06:47:12PM +0900, Minchan Kim wrote:
> On Thu, May 6, 2010 at 9:22 AM, Mel Gorman <mel@csn.ul.ie> wrote:
> > On Wed, May 05, 2010 at 11:02:25AM -0700, Linus Torvalds wrote:
> >>
> >>
> >> On Wed, 5 May 2010, Mel Gorman wrote:
> >> >
> >> > If the same_vma list is properly ordered then maybe something like the
> >> > following is allowed?
> >>
> >> Heh. This is the same logic I just sent out. However:
> >>
> >> > +   anon_vma = page_rmapping(page);
> >> > +   if (!anon_vma)
> >> > +           return NULL;
> >> > +
> >> > +   spin_lock(&anon_vma->lock);
> >>
> >> RCU should guarantee that this spin_lock() is valid, but:
> >>
> >> > +   /*
> >> > +    * Get the oldest anon_vma on the list by depending on the ordering
> >> > +    * of the same_vma list setup by __page_set_anon_rmap
> >> > +    */
> >> > +   avc = list_entry(&anon_vma->head, struct anon_vma_chain, same_anon_vma);
> >>
> >> We're not guaranteed that the 'anon_vma->head' list is non-empty.
> >>
> >> Somebody could have freed the list and the anon_vma and we have a stale
> >> 'page->anon_vma' (that has just not been _released_ yet).
> >>
> >> And shouldn't that be 'list_first_entry'? Or &anon_vma->head.next?
> >>
> >> How did that line actually work for you? Or was it just a "it boots", but
> >> no actual testing of the rmap walk?
> >>
> >
> > This is what I just started testing on a 4-core machine. Lockdep didn't
> > complain but there are two potential sources of badness in anon_vma_lock_root
> > marked with XXX. The second is the most important because I can't see how the
> > local and root anon_vma locks can be safely swapped - i.e. release local and
> > get the root without the root disappearing. I haven't considered the other
> > possibilities yet such as always locking the root anon_vma. Going to
> > sleep on it.
> >
> > Any comments?
> 
> <snip>
> > +/* Given an anon_vma, find the root of the chain, lock it and return the root */
> > +struct anon_vma *anon_vma_lock_root(struct anon_vma *anon_vma)
> > +{
> > +       struct anon_vma *root_anon_vma;
> > +       struct anon_vma_chain *avc, *root_avc;
> > +       struct vm_area_struct *vma;
> > +
> > +       /* Lock the same_anon_vma list and make sure we are on a chain */
> > +       spin_lock(&anon_vma->lock);
> > +       if (list_empty(&anon_vma->head)) {
> > +               spin_unlock(&anon_vma->lock);
> > +               return NULL;
> > +       }
> > +
> > +       /*
> > +        * Get the root anon_vma on the list by depending on the ordering
> > +        * of the same_vma list setup by __page_set_anon_rmap. Basically
> > +        * we are doing
> > +        *
> > +        * local anon_vma -> local vma -> deepest vma -> anon_vma
> > +        */
> > +       avc = list_first_entry(&anon_vma->head, struct anon_vma_chain, same_anon_vma);
> 
> Dumb question.
> 
> I can't understand why we should use list_first_entry.
> 
> I looked over the code.
> anon_vma_chain_link uses list_add_tail so I think that's right.
> But anon_vma_prepare uses list_add. So it's not consistent.
> How do we make sure list_first_entry returns deepest vma?
> 

list_first_entry is not getting the root (what you called deepest but lets
pick a name and stick with it or this will be worse than it already is). That
list_first entry is what gets us from

local anon_vma -> avc for the local anon_vma -> local vma

It's the ordering of the same_vma list hanging off the local_vma that is
important according to this comment in __page_set_anon_rmap

                /*
                 * The page may be shared between multiple processes.
                 * We must use the _oldest_ possible anon_vma for the
                 * page mapping!  That anon_vma is guaranteed to be
                 * present in all processes that could share this page.
                 *
                 * So take the last AVC chain entry in the vma, which is the
                 * deepest ancestor, and use the anon_vma from that.
                 */
                avc = list_entry(vma->anon_vma_chain.prev, struct anon_vma_chain, same_vma);
                anon_vma = avc->anon_vma;
        }

> Sorry if I am missing.
> 

Not at all. The more people that look at this the better.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

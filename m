Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 2A4C76B0047
	for <linux-mm@kvack.org>; Sun, 31 Jan 2010 11:25:35 -0500 (EST)
Date: Sun, 31 Jan 2010 16:25:22 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: Bug in find_vma_prev - mmap.c
In-Reply-To: <201001301929.47659.rjw@sisk.pl>
Message-ID: <alpine.LSU.2.00.1001311616590.5897@sister.anvils>
References: <6cafb0f01001291657q4ccbee86rce3143a4be7a1433@mail.gmail.com> <201001301929.47659.rjw@sisk.pl>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Tony Perkins <da.perk@gmail.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 30 Jan 2010, Rafael J. Wysocki wrote:

> [Adding CCs]
> 
> On Saturday 30 January 2010, Tony Perkins wrote:
> > This code returns vma (mm->mmap) if it sees that addr is lower than first VMA.
> > However, I think it falsely returns vma (mm->mmap) on the case where
> > addr is in the first VMA.
> > 
> > If it is the first VMA region:
> > - *pprev should be set to NULL
> > - implying prev is NULL
> > - and should therefore return vma (so in this case, I just added if
> > it's the first VMA and it's within range)
> > 
> > /* Same as find_vma, but also return a pointer to the previous VMA in *pprev. */
> > struct vm_area_struct *
> > find_vma_prev(struct mm_struct *mm, unsigned long addr,
> >             struct vm_area_struct **pprev)
> > {
> >     struct vm_area_struct *vma = NULL, *prev = NULL;
> >     struct rb_node *rb_node;
> >     if (!mm)
> >         goto out;
> > 
> >     /* Guard against addr being lower than the first VMA */
> >     vma = mm->mmap;
> > 
> >     /* Go through the RB tree quickly. */
> >     rb_node = mm->mm_rb.rb_node;
> > 
> >     while (rb_node) {
> >         struct vm_area_struct *vma_tmp;
> >         vma_tmp = rb_entry(rb_node, struct vm_area_struct, vm_rb);
> > 
> >         if (addr < vma_tmp->vm_end) {
> >             // TONY: if (vma_tmp->vm_start <= addr) vma = vma_tmp; //
> > this returns the correct 'vma' when vma is the first node (i.e., no
> > prev)
> >             rb_node = rb_node->rb_left;
> >         } else {
> >             prev = vma_tmp;
> >             if (!prev->vm_next || (addr < prev->vm_next->vm_end))
> >                 break;
> >             rb_node = rb_node->rb_right;
> >         }
> >     }
> > 
> > out:
> >     *pprev = prev;
> >     return prev ? prev->vm_next : vma;
> > }
> > 
> > Is this a known issue and/or has this problem been addressed?
> > Also, please CC my email address with responses.
> 
> Well, I guess you should let the mm people know (CCs added).

Sorry, I don't see what the problem is: I may be misunderstanding.
Why do you think it is wrong to return the vma which addr is in
(whether or not that's the first vma)?

find_vma_prev() is supposed to return the same vma as find_vma()
does, but additionally fill in *pprev.  And find_vma() is supposed
to return the vma containing or the next vma above the addr supplied.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

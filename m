Received: from zps76.corp.google.com (zps76.corp.google.com [172.25.146.76])
	by smtp-out.google.com with ESMTP id l9PIi32F002645
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 11:44:03 -0700
Received: from nf-out-0910.google.com (nfdg16.prod.google.com [10.48.133.16])
	by zps76.corp.google.com with ESMTP id l9PIfTN3006084
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 11:44:02 -0700
Received: by nf-out-0910.google.com with SMTP id g16so546025nfd
        for <linux-mm@kvack.org>; Thu, 25 Oct 2007 11:44:02 -0700 (PDT)
Message-ID: <d43160c70710251144t172cfd1exef99e0d53fb9be73@mail.gmail.com>
Date: Thu, 25 Oct 2007 14:44:02 -0400
From: "Ross Biro" <rossb@google.com>
Subject: Re: RFC/POC Make Page Tables Relocatable
In-Reply-To: <1193335725.24087.19.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <d43160c70710250816l44044f31y6dd20766d1f2840b@mail.gmail.com>
	 <1193330774.4039.136.camel@localhost>
	 <d43160c70710251040u23feeaf9l16fafc2685b2ce52@mail.gmail.com>
	 <1193335725.24087.19.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm@kvack.org, Mel Gorman <MELGOR@ie.ibm.com>
List-ID: <linux-mm.kvack.org>

On 10/25/07, Dave Hansen <haveblue@us.ibm.com> wrote:
> Right, but we're talking about pagetable pages here, right?  What fields
> in 'struct page' are used by pagetable pages, but will allow 'struct
> page' to shrink in size if pagetables pages stop using them?

At the moment we are only talking about page tables, but I hope in the
future to do more.  Perhaps page tables were a bad place to start, but
like I said I thought they would be the hardest, and hence a good
place to start.

>
> On a more general note: so it's all about saving memory in the end?

Sort of. As you pointed out, right now struct page is pretty well
tuned, but it's also not easy to add something.  If I need an extra
pointer or two to do something, then I more or less totally trash all
sorts of efficiencies we are getting now.  It's about having
flexibility without losing efficeincy.

>
> I dunno.  I'm highly skeptical this can work.

Skepticism is good.  I think I can pull it off, and possibly even make
it more efficient.  The big gotcha is going to be caching issues if we
end up bouncing back and forth between struct page and the new meta
data, we might end up being toast.  On the other hand, if we are
looking at multiple pages and we fit multiple smaller structures into
a cache line, we might still win.  This is why I asked for some micro
benchmarks.  I figured people would send the ones they feel are most
likely to fail.

Remember, this change doesn't stand on it's own.  In a vacuum, I don't
think this change is worth doing at all.  But it enables the other
changes and a lot more going forward.

> > > get a pte page back, I might simply hold the page table lock, walk the
> > > pagetables to the pmd, lock and invalidate the pmd, copy the pagetable
> > > contents into a new page, update the pmd, and be on my merry way.  Why
> > > doesn't this work?  I'm just fishing for a good explanation why we need
> > > all the slab silliness.
> >
> > This would almost work, but to do it properly, you find you'll need
> > some more locks and a couple of extra pointers and such.
>
> Could you be specific?

Well to go quickly from an arbitrary page that happens to be part of a
page table to the appropriate mm to get a lock, I had to store a
pointer to the mm.  Then I also needed to know where the particular
page fit into the page table tree.  Once I had those, it turned out I
needed a spinlock to protect them to deallocate the page with out
racing against the relocation.  I think I could have used the ptl lock
struct page, but I wasn't really clear on it when I started.

So I needed 2 pointers which I could have squeezed into struct page
somewhere, but then what about when I needed a third or forth pointer
to make something else work well?  I'm pretty sure I can clean up some
of the tlb flushing and make all levels of the page tables relocatable
with out a problem by adding another flag.  Of course, I could put a
flag into the page flags, but it doesn't take long to run out of flag
space.  The meta data change we are talking about above is to make the
code flexible enough to support things like this with out killing
performance.

Your argument against the meta data change above is that it will kill
performance.  I don't think so, but I could be wrong.  However, if the
only objection is that it will kill performance, then it's worth doing
and running some benchmarks.  If it turns out I'm correct and it's a
win or not a big loss from a performance point of view, then it goes
in.  If not, it doesn't.

>
> You may want to have a talk with Mel about memory fragmentation, and
> whether there is any lower hanging fruit (cc'd). :)

I usually like to go for the high hanging fruit with the idea if I do
that well, the low hanging fruit becomes a cake walk.  However, any
input on this is welcome.

>
> your code.  The posted patch is hard to understand in some areas because
> of indenting bracketing.  If you'd like people to read, review, and give
> suggestions on what they see, I'd suggest trying to make it as easy as

I'm sorry about that.  It must have happened when I hand applied the
patch to 2.6.23 (it was developed under 2.6.22).  I should have had
emacs reflow all the changes after deleting all the +'s that diff
sticks in front of the lines.

    Ross

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

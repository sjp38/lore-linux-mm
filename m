Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f173.google.com (mail-ie0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 158646B0069
	for <linux-mm@kvack.org>; Mon, 17 Nov 2014 20:41:38 -0500 (EST)
Received: by mail-ie0-f173.google.com with SMTP id y20so6350796ier.32
        for <linux-mm@kvack.org>; Mon, 17 Nov 2014 17:41:37 -0800 (PST)
Received: from cosmos.ssec.wisc.edu ([2607:f388:1090:0:fab1:56ff:fedf:5d9c])
        by mx.google.com with ESMTP id l10si57181056icx.43.2014.11.17.17.41.36
        for <linux-mm@kvack.org>;
        Mon, 17 Nov 2014 17:41:36 -0800 (PST)
Date: Mon, 17 Nov 2014 19:41:35 -0600
From: Daniel Forrest <dan.forrest@ssec.wisc.edu>
Subject: Re: [PATCH] Repeated fork() causes SLAB to grow without bound
Message-ID: <20141118014135.GA17252@cosmos.ssec.wisc.edu>
Reply-To: Daniel Forrest <dan.forrest@ssec.wisc.edu>
References: <502D42E5.7090403@redhat.com>
 <20120818000312.GA4262@evergreen.ssec.wisc.edu>
 <502F100A.1080401@redhat.com>
 <alpine.LSU.2.00.1208200032450.24855@eggly.anvils>
 <CANN689Ej7XLh8VKuaPrTttDrtDGQbXuYJgS2uKnZL2EYVTM3Dg@mail.gmail.com>
 <20120822032057.GA30871@google.com>
 <50345232.4090002@redhat.com>
 <20130603195003.GA31275@evergreen.ssec.wisc.edu>
 <20141114163053.GA6547@cosmos.ssec.wisc.edu>
 <20141117160212.b86d031e1870601240b0131d@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141117160212.b86d031e1870601240b0131d@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tim Hartrick <tim@edgecast.com>, Michal Hocko <mhocko@suse.cz>

On Mon, Nov 17, 2014 at 04:02:12PM -0800, Andrew Morton wrote:
> On Fri, 14 Nov 2014 10:30:53 -0600 Daniel Forrest <dan.forrest@ssec.wisc.edu> wrote:
> 
> > There have been a couple of inquiries about the status of this patch
> > over the last few months, so I am going to try pushing it out.
> > 
> > Andrea Arcangeli has commented:
> > 
> > > Agreed. The only thing I don't like about this patch is the hardcoding
> > > of number 5: could we make it a variable to tweak with sysfs/sysctl so
> > > if some weird workload arises we have a tuning tweak? It'd cost one
> > > cacheline during fork, so it doesn't look excessive overhead.
> > 
> > Adding this is beyond my experience level, so if it is required then
> > someone else will have to make it so.
> > 
> > Rik van Riel has commented:
> > 
> > > I believe we should just merge that patch.
> > > 
> > > I have not seen any better ideas come by.
> > > 
> > > The comment should probably be fixed to reflect the
> > > chain length of 5 though :)
> > 
> > So here is Michel's patch again with "(length > 1)" modified to
> > "(length > 5)" and fixed comments.
> > 
> > I have been running with this patch (with the threshold set to 5) for
> > over two years now and it does indeed solve the problem.
> > 
> > ---
> > 
> > anon_vma_clone() is modified to return the length of the existing
> > same_vma anon vma chain, and we create a new anon_vma in the child
> > if it is more than five forks after the anon_vma was created, as we
> > don't want the same_vma chain to grow arbitrarily large.
> 
> hoo boy, what's going on here.
> 
> - Under what circumstances are we seeing this slab windup?

The original bug report is here:

https://lkml.org/lkml/2012/8/15/765

> - What are the consequences?  Can it OOM the machine?

Yes, eventually you run out of SLAB space.

> - Why is this occurring?  There aren't an infinite number of vmas, so
>   there shouldn't be an infinite number of anon_vmas or
>   anon_vma_chains.

Because of the serial forking there does indeed end up being an infinite
number of vmas.  The initial vma can never be deleted (even though the
initial parent process has long since terminated) because the initial
vma is referenced by the children.

> - IOW, what has to be done to fix this properly?

As far as I know, this is the best solution.  I tried a refcounting
solution based on comments by Rik van Riel:

https://lkml.org/lkml/2012/8/17/536

But it didn't fully work, probably because I didn't quite get the
locking done properly.  In any case, at this point questions came up
about the overhead of the page refcounting and Michel Lespinasse
suggested the initial version of this patch:

https://lkml.org/lkml/2012/8/21/730

> - What are the runtime consequences of limiting the length of the chain?

I can't say, but it only affects users who fork more than five levels
deep without doing an exec.  On the other hand, there are at least three
users (Tim Hartrick, Michal Hocko, and myself) who have real world
applications where the consequence of no patch is a crashed system.

I would suggest reading the thread starting with my initial bug report
for what others have had to say about this.

> > ...
> >
> > @@ -331,10 +334,17 @@ int anon_vma_fork(struct vm_area_struct *vma, struct vm_area_struct *pvma)
> >  	 * First, attach the new VMA to the parent VMA's anon_vmas,
> >  	 * so rmap can find non-COWed pages in child processes.
> >  	 */
> > -	if (anon_vma_clone(vma, pvma))
> > +	length = anon_vma_clone(vma, pvma);
> > +	if (length < 0)
> >  		return -ENOMEM;
> 
> This should propagate the anon_vma_clone() return val instead of
> assuming ENOMEM.  But that won't fix anything...

Agreed, but the only failure return value of anon_vma_clone is -ENOMEM.

Scanning the code in __split_vma (mm/mmap.c) it looks like the error
return is lost (between Linux 3.11 and 3.12 the err variable is now
used before the call to anon_vma_clone and the default initial value of
-ENOMEM is overwritten).  This is an actual bug in the current code.

I can update the patch to fix these issues.

> > +	else if (length > 5)
> > +		return 0;
> >  
> > -	/* Then add our own anon_vma. */
> > +	/*
> > +	 * Then add our own anon_vma. We do this only for five forks after
> > +	 * the anon_vma was created, as we don't want the same_vma chain to
> > +	 * grow arbitrarily large.
> > +	 */
> >  	anon_vma = anon_vma_alloc();

-- 
Daniel K. Forrest		Space Science and
dan.forrest@ssec.wisc.edu	Engineering Center
(608) 890 - 0558		University of Wisconsin, Madison

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

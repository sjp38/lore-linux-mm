Date: Thu, 15 May 2003 11:46:56 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: Race between vmtruncate and mapped areas?
Message-ID: <20030515094656.GB1429@dualathlon.random>
References: <20030515004915.GR1429@dualathlon.random> <Pine.LNX.4.44.0305142234120.20800-100000@chimarrao.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0305142234120.20800-100000@chimarrao.boston.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Dave McCracken <dmccr@us.ibm.com>, Andrew Morton <akpm@digeo.com>, mika.penttila@kolumbus.fi, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, May 14, 2003 at 10:36:23PM -0400, Rik van Riel wrote:
> On Thu, 15 May 2003, Andrea Arcangeli wrote:
> 
> > --- x/include/linux/fs.h.~1~	2003-05-14 23:26:19.000000000 +0200
> > +++ x/include/linux/fs.h	2003-05-15 02:35:57.000000000 +0200
> > @@ -421,6 +421,8 @@ struct address_space {
> >  	struct vm_area_struct	*i_mmap;	/* list of private mappings */
> >  	struct vm_area_struct	*i_mmap_shared; /* list of shared mappings */
> >  	spinlock_t		i_shared_lock;  /* and spinlock protecting it */
> > +	int			truncate_sequence1; /* serialize ->nopage against truncate */
> > +	int			truncate_sequence2; /* serialize ->nopage against truncate */
> 
> How about calling them truncate_start and truncate_end ?

Normally we use start/end for ranges, this is not a range, so I wouldn't
suggest it, but I don't care about names.

> > --- x/mm/vmscan.c.~1~	2003-05-14 23:26:12.000000000 +0200
> > +++ x/mm/vmscan.c	2003-05-15 00:22:57.000000000 +0200
> > @@ -165,11 +165,10 @@ drop_pte:
> >  		goto drop_pte;
> >  
> >  	/*
> > -	 * Anonymous buffercache pages can be left behind by
> > +	 * Anonymous buffercache pages can't be left behind by
> >  	 * concurrent truncate and pagefault.
> >  	 */
> > -	if (page->buffers)
> > -		goto preserve;
> > +	BUG_ON(page->buffers);
> 
> I wonder if there is nothing else that can leave behind
> buffers in this way.

that's why I left the BUG_ON, if there's anything else I want to know,
there shouldn't be anything else as the comment also suggest. I recall
when we discussed this single check with Andrew and that was the only
reason we left it AFIK.

> > +	mb(); /* spin_lock has inclusive semantics */
> > +	if (unlikely(truncate_sequence != mapping->truncate_sequence1)) {
> > +		struct inode *inode;
> 
> This code looks like it should work, but IMHO it is very subtle
> so it should really get some documentation.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k5LJhIdK006792
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Wed, 21 Jun 2006 15:43:20 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5LJhHVC211298
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Wed, 21 Jun 2006 15:43:18 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5LJhC9D015906
	for <linux-mm@kvack.org>; Wed, 21 Jun 2006 15:43:13 -0400
Date: Wed, 21 Jun 2006 14:42:50 -0500
From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: Possible bug in do_execve()
Message-ID: <20060621194250.GD16576@sergelap.austin.ibm.com>
References: <20060620022506.GA3673@kevlar.burdell.org> <20060621184129.GB16576@sergelap.austin.ibm.com> <20060621185508.GA9234@kevlar.burdell.org> <20060621190910.GC16576@sergelap.austin.ibm.com> <20060621192726.GA10052@kevlar.burdell.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060621192726.GA10052@kevlar.burdell.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Sonny Rao <sonny@burdell.org>
Cc: "Serge E. Hallyn" <serue@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, anton@samba.org
List-ID: <linux-mm.kvack.org>

Quoting Sonny Rao (sonny@burdell.org):
> On Wed, Jun 21, 2006 at 02:09:10PM -0500, Serge E. Hallyn wrote:
> <snip>
> > > Yeah, I proposed a similar patch to Anton, and it would quiet the
> > > warning on powerpc, but that's not the point.  It happens that powerpc
> > > doesn't use 0 as a context id, but that may not be true on another
> > > architecture.  That's really what I'm concerned about.
> > 
> > FWIW, ppc and cris do the NO_CONTEXT check, while others don't
> > even have a arch-specific 'mm->context.id'.
> 
> Good point.  I probably stated that concern too narrowly.  Probably
> what I should say is: What is the pre-condition for calling
> destroy_context() ?  Is it that init_new_context() must have
> succeeded?  Or is it merely that mm.context has been zeroed
> out?

Right, that may be the right question.  If that's the case, then the
problem is really include/linux/sched.h:__mmdrop() which is what's
calling destroy_context().  Separating that out becomes a pretty
big patch affecting at least all mmput() and mmdrop() callers.

> Here's destroy context on sparc64:
> 
> void destroy_context(struct mm_struct *mm)
> {
>         unsigned long flags, i;
> 
>         for (i = 0; i < MM_NUM_TSBS; i++)
>                 tsb_destroy_one(&mm->context.tsb_block[i]);
> 
>         spin_lock_irqsave(&ctx_alloc_lock, flags);
> 
>         if (CTX_VALID(mm->context)) {
>                 unsigned long nr = CTX_NRBITS(mm->context);
>                 mmu_context_bmap[nr>>6] &= ~(1UL << (nr & 63));
>         }
> 
>         spin_unlock_irqrestore(&ctx_alloc_lock, flags);
> }
> 
> It seems to assume that mm->context is valid before doing a check.
> 
> Since I don't have a sparc64 box, I can't check to see if this
> actually breaks things or not.

So we can either go through all arch's and make sure destroy_context is
safe for invalid context, or split mmput() and destroy_context()...

The former seems easier, but the latter seems more robust in the face of
future code changes I guess.

-serge

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

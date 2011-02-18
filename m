Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 50CE48D0039
	for <linux-mm@kvack.org>; Fri, 18 Feb 2011 06:29:29 -0500 (EST)
Received: from j77219.upc-j.chello.nl ([24.132.77.219] helo=dyad.programming.kicks-ass.net)
	by casper.infradead.org with esmtpsa (Exim 4.72 #1 (Red Hat Linux))
	id 1PqOWd-0001Hy-B2
	for linux-mm@kvack.org; Fri, 18 Feb 2011 11:29:27 +0000
Subject: Re: [PATCH 3/3] mm: Simplify anon_vma refcounts
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <AANLkTimj1d6QpzuNZ6NJvLDVvvC++mPodggFaBziU8Bj@mail.gmail.com>
References: <20110217161948.045410404@chello.nl>
	 <20110217162124.457572646@chello.nl>
	 <AANLkTimj1d6QpzuNZ6NJvLDVvvC++mPodggFaBziU8Bj@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 18 Feb 2011 12:30:35 +0100
Message-ID: <1298028635.5226.685.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Hugh Dickins <hughd@google.com>

On Thu, 2011-02-17 at 10:30 -0800, Linus Torvalds wrote:
> On Thu, Feb 17, 2011 at 8:19 AM, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> >
> > +void __put_anon_vma(struct anon_vma *anon_vma)
> > +{
> > +       if (anon_vma->root != anon_vma)
> > +               put_anon_vma(anon_vma->root);
> > +       anon_vma_free(anon_vma);
> >  }
> 
> So this makes me nervous. It looks like recursion.
> 
> Now, I don't think we can ever get a chain of these things (because
> the root should be the root of everything),

Exactly.

>  but I still preferred the
> older code that made that "one-level root" case explicit, and didn't
> have recursion.
> 
> IOW, even though it should be entirely equivalent, I think I'd really
> prefer something like
> 
>   void __put_anon_vma(struct anon_vma *anon_vma)
>   {
>     struct anon_vma *root = anon_vma->root;
> 
>     if (root != anon_vma && atomic_dec_and_test(&root->refcount))
>       anon_vma_free(root);
>     anon_vma_free(anon_vma);
>   }
> 
> instead. Exactly because it makes it very clear that the "root" is a
> root, and we're not doing some possibly arbitrarily deep list like the
> dentry tree (which avoids recursion by open-coding its freeing as a
> loop).
> 
> Hmm? (The above is obviously untested, maybe it has some stupid bug)

Looks about right, I'll give it a spin. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

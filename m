Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 21B286B0089
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 23:19:08 -0400 (EDT)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 2 Apr 2013 21:19:07 -0600
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 9C8CA3E4003E
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 21:18:53 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r333J5f7160004
	for <linux-mm@kvack.org>; Tue, 2 Apr 2013 21:19:05 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r333LnHJ030696
	for <linux-mm@kvack.org>; Tue, 2 Apr 2013 21:21:49 -0600
Date: Tue, 2 Apr 2013 20:19:02 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: prevent mmap_cache race in find_vma()
Message-ID: <20130403031902.GM3804@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <3ae9b7e77e8428cfeb34c28ccf4a25708cbea1be.1364938782.git.jstancek@redhat.com>
 <alpine.DEB.2.02.1304021532220.25286@chino.kir.corp.google.com>
 <alpine.LNX.2.00.1304021600420.22412@eggly.anvils>
 <alpine.DEB.2.02.1304021643260.3217@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1304021643260.3217@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Hugh Dickins <hughd@google.com>, Jan Stancek <jstancek@redhat.com>, Ian Lance Taylor <iant@google.com>, linux-mm@kvack.org

On Tue, Apr 02, 2013 at 04:55:45PM -0700, David Rientjes wrote:
> On Tue, 2 Apr 2013, Hugh Dickins wrote:
> 
> > > > find_vma() can be called by multiple threads with read lock
> > > > held on mm->mmap_sem and any of them can update mm->mmap_cache.
> > > > Prevent compiler from re-fetching mm->mmap_cache, because other
> > > > readers could update it in the meantime:
> > > 
> > > FWIW, ACCESS_ONCE() does not guarantee that the compiler will not refetch 
> > > mm->mmap_cache whatsoever; there is nothing that prevents this either in 
> > > the C standard.  You'll be relying solely on gcc's implementation of how 
> > > it dereferences volatile-qualified pointers.
> > 
> > Jan is using ACCESS_ONCE() as it should be used, for its intended
> > purpose.  If the kernel's implementation of ACCESS_ONCE() is deficient,
> > then we should fix that, not discourage its use.
> > 
> 
> My comment is about the changelog, quoted above, saying "prevent compiler 
> from re-fetching mm->mmap_cache..."  ACCESS_ONCE(), as implemented, does 
> not prevent the compiler from re-fetching anything.  It is entirely 
> plausible that in gcc's current implementation that this guarantee is 
> made, but it is not prevented by the language standard and I think the 
> changelog should be reworded for anybody who reads it in the future.  
> There is a dependency here on gcc's implementation, it's a meaningful 
> distinction.
> 
> I never discouraged its use since for gcc's current implementation it 
> appears to work as desired and without gcc extensions there is no way to 
> make such a guarantee by the standard.  In fact, I acked a patch from Eric 
> Dumazet that fixes a NULL pointer dereference by using ACCESS_ONCE() with 
> gcc in slub.

This LWN comment from user "nix" is helpful here:

https://lwn.net/Articles/509731/

In particular:

	... volatile's meaning as 'minimize optimizations applied to
	things manipulating anything of volatile type, do not duplicate,
	elide, move, fold, spindle or mutilate' is of long standing.

So although I agree that the standard does not say as much as one might
like about volatile, ACCESS_ONCE()'s use of volatile should be expected
to work in a wide range of C compilers.  ACCESS_ONCE()'s use of typeof()
might not be quite so generally applicable, but a fair range of C
compilers do seem to support typeof() as well as ACCESS_ONCE()'s use
of volatile.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

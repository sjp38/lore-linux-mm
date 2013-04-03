Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 0B3136B0006
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 12:38:46 -0400 (EDT)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 3 Apr 2013 10:38:45 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 9A8B8C40003
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 10:33:28 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r33GcRIM369856
	for <linux-mm@kvack.org>; Wed, 3 Apr 2013 10:38:27 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r33GfAvw006110
	for <linux-mm@kvack.org>; Wed, 3 Apr 2013 10:41:10 -0600
Date: Wed, 3 Apr 2013 09:38:23 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: prevent mmap_cache race in find_vma()
Message-ID: <20130403163823.GE28522@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <3ae9b7e77e8428cfeb34c28ccf4a25708cbea1be.1364938782.git.jstancek@redhat.com>
 <alpine.DEB.2.02.1304021532220.25286@chino.kir.corp.google.com>
 <alpine.LNX.2.00.1304021600420.22412@eggly.anvils>
 <alpine.DEB.2.02.1304021643260.3217@chino.kir.corp.google.com>
 <20130403031902.GM3804@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1304022110160.32184@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1304022110160.32184@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Hugh Dickins <hughd@google.com>, Jan Stancek <jstancek@redhat.com>, Ian Lance Taylor <iant@google.com>, linux-mm@kvack.org

On Tue, Apr 02, 2013 at 09:21:49PM -0700, David Rientjes wrote:
> On Tue, 2 Apr 2013, Paul E. McKenney wrote:
> 
> > So although I agree that the standard does not say as much as one might
> > like about volatile, ACCESS_ONCE()'s use of volatile should be expected
> > to work in a wide range of C compilers.  ACCESS_ONCE()'s use of typeof()
> > might not be quite so generally applicable, but a fair range of C
> > compilers do seem to support typeof() as well as ACCESS_ONCE()'s use
> > of volatile.
> > 
> 
> Agreed and I have nothing against code that uses it in that manner based 
> on the implementations of those compilers.  The _only_ thing I've said in 
> this thread is that ACCESS_ONCE() does not "prevent the compiler from 
> re-fetching."  The only thing that is going to prevent the compiler from 
> doing anything is the standard and, as you eluded, it's legal for a 
> compiler to compile code such as 
> 
> 	vma = ACCESS_ONCE(mm->mmap_cache);
> 	if (vma && vma->vm_start <= addr && vma->vm_end > addr)
> 		return vma;
> 
> to be equivalent as if it had been written
> 
> 	if (mm->mmap_cache && mm->mmap_cache->vm_start <= addr &&
> 	    mm->mmap_cache->vm_end > addr)
> 		return mm->mmap_cache;
> 
> and still be a conforming implementation.  We know gcc doesn't do that, so 
> nobody is arguing the code in this patch as being incorrect.  In fact, to 
> remove any question about it:
> 
> Acked-by: David Rientjes <rientjes@google.com>

Thank you!

> However, as originally stated, I would prefer that the changelog be 
> reworded so nobody believes ACCESS_ONCE() prevents the compiler from 
> re-fetching anything.

If you were to instead say:

	However, as originally stated, I would prefer that the changelog
	be reworded so nobody believes that the C standard guarantees that
	volatile casts prevent the compiler from re-fetching anything.

I might agree with you.  But ACCESS_ONCE() really is defined to prevent
the compiler from refetching anything.  If a new version of gcc appears
for which volatile casts does not protect against refetching, then we
will change either (1) gcc or (2) the implementation of ACCESS_ONCE().
Whatever is needed to provide the guarantee against refetching.  The
Linux kernel absolutely needs -something- that provides this guarantee.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

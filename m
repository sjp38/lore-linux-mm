Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 0011F6B009F
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 00:21:51 -0400 (EDT)
Received: by mail-da0-f53.google.com with SMTP id n34so483265dal.26
        for <linux-mm@kvack.org>; Tue, 02 Apr 2013 21:21:51 -0700 (PDT)
Date: Tue, 2 Apr 2013 21:21:49 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: prevent mmap_cache race in find_vma()
In-Reply-To: <20130403031902.GM3804@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.02.1304022110160.32184@chino.kir.corp.google.com>
References: <3ae9b7e77e8428cfeb34c28ccf4a25708cbea1be.1364938782.git.jstancek@redhat.com> <alpine.DEB.2.02.1304021532220.25286@chino.kir.corp.google.com> <alpine.LNX.2.00.1304021600420.22412@eggly.anvils> <alpine.DEB.2.02.1304021643260.3217@chino.kir.corp.google.com>
 <20130403031902.GM3804@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Hugh Dickins <hughd@google.com>, Jan Stancek <jstancek@redhat.com>, Ian Lance Taylor <iant@google.com>, linux-mm@kvack.org

On Tue, 2 Apr 2013, Paul E. McKenney wrote:

> So although I agree that the standard does not say as much as one might
> like about volatile, ACCESS_ONCE()'s use of volatile should be expected
> to work in a wide range of C compilers.  ACCESS_ONCE()'s use of typeof()
> might not be quite so generally applicable, but a fair range of C
> compilers do seem to support typeof() as well as ACCESS_ONCE()'s use
> of volatile.
> 

Agreed and I have nothing against code that uses it in that manner based 
on the implementations of those compilers.  The _only_ thing I've said in 
this thread is that ACCESS_ONCE() does not "prevent the compiler from 
re-fetching."  The only thing that is going to prevent the compiler from 
doing anything is the standard and, as you eluded, it's legal for a 
compiler to compile code such as 

	vma = ACCESS_ONCE(mm->mmap_cache);
	if (vma && vma->vm_start <= addr && vma->vm_end > addr)
		return vma;

to be equivalent as if it had been written

	if (mm->mmap_cache && mm->mmap_cache->vm_start <= addr &&
	    mm->mmap_cache->vm_end > addr)
		return mm->mmap_cache;

and still be a conforming implementation.  We know gcc doesn't do that, so 
nobody is arguing the code in this patch as being incorrect.  In fact, to 
remove any question about it:

Acked-by: David Rientjes <rientjes@google.com>

However, as originally stated, I would prefer that the changelog be 
reworded so nobody believes ACCESS_ONCE() prevents the compiler from 
re-fetching anything.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

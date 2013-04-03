Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id D2B1C6B0096
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 00:14:58 -0400 (EDT)
Date: Wed, 3 Apr 2013 00:14:47 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: prevent mmap_cache race in find_vma()
Message-ID: <20130403041447.GC4611@cmpxchg.org>
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
Cc: Hugh Dickins <hughd@google.com>, Jan Stancek <jstancek@redhat.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Ian Lance Taylor <iant@google.com>, linux-mm@kvack.org

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

The definition of ACCESS_ONCE() relies on gcc's current
implementation, the users of ACCESS_ONCE() only rely on ACCESS_ONCE()
being defined.

Should it ever break you have to either fix it at the implementation
level or remove/replace the abstraction in its entirety, how does the
individual callsite matter in this case?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

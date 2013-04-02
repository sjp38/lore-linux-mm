Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 969CF6B0044
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 19:55:48 -0400 (EDT)
Received: by mail-da0-f50.google.com with SMTP id t1so402501dae.37
        for <linux-mm@kvack.org>; Tue, 02 Apr 2013 16:55:47 -0700 (PDT)
Date: Tue, 2 Apr 2013 16:55:45 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: prevent mmap_cache race in find_vma()
In-Reply-To: <alpine.LNX.2.00.1304021600420.22412@eggly.anvils>
Message-ID: <alpine.DEB.2.02.1304021643260.3217@chino.kir.corp.google.com>
References: <3ae9b7e77e8428cfeb34c28ccf4a25708cbea1be.1364938782.git.jstancek@redhat.com> <alpine.DEB.2.02.1304021532220.25286@chino.kir.corp.google.com> <alpine.LNX.2.00.1304021600420.22412@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Jan Stancek <jstancek@redhat.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Ian Lance Taylor <iant@google.com>, linux-mm@kvack.org

On Tue, 2 Apr 2013, Hugh Dickins wrote:

> > > find_vma() can be called by multiple threads with read lock
> > > held on mm->mmap_sem and any of them can update mm->mmap_cache.
> > > Prevent compiler from re-fetching mm->mmap_cache, because other
> > > readers could update it in the meantime:
> > 
> > FWIW, ACCESS_ONCE() does not guarantee that the compiler will not refetch 
> > mm->mmap_cache whatsoever; there is nothing that prevents this either in 
> > the C standard.  You'll be relying solely on gcc's implementation of how 
> > it dereferences volatile-qualified pointers.
> 
> Jan is using ACCESS_ONCE() as it should be used, for its intended
> purpose.  If the kernel's implementation of ACCESS_ONCE() is deficient,
> then we should fix that, not discourage its use.
> 

My comment is about the changelog, quoted above, saying "prevent compiler 
from re-fetching mm->mmap_cache..."  ACCESS_ONCE(), as implemented, does 
not prevent the compiler from re-fetching anything.  It is entirely 
plausible that in gcc's current implementation that this guarantee is 
made, but it is not prevented by the language standard and I think the 
changelog should be reworded for anybody who reads it in the future.  
There is a dependency here on gcc's implementation, it's a meaningful 
distinction.

I never discouraged its use since for gcc's current implementation it 
appears to work as desired and without gcc extensions there is no way to 
make such a guarantee by the standard.  In fact, I acked a patch from Eric 
Dumazet that fixes a NULL pointer dereference by using ACCESS_ONCE() with 
gcc in slub.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

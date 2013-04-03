Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id D75D86B00D8
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 05:37:26 -0400 (EDT)
Date: Wed, 3 Apr 2013 11:37:21 +0200
From: Jakub Jelinek <jakub@redhat.com>
Subject: Re: [PATCH] mm: prevent mmap_cache race in find_vma()
Message-ID: <20130403093721.GA20003@tucnak.redhat.com>
Reply-To: Jakub Jelinek <jakub@redhat.com>
References: <3ae9b7e77e8428cfeb34c28ccf4a25708cbea1be.1364938782.git.jstancek@redhat.com>
 <alpine.DEB.2.02.1304021532220.25286@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1304021532220.25286@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Jan Stancek <jstancek@redhat.com>, linux-mm@kvack.org

On Tue, Apr 02, 2013 at 03:33:58PM -0700, David Rientjes wrote:
> On Tue, 2 Apr 2013, Jan Stancek wrote:
> 
> > find_vma() can be called by multiple threads with read lock
> > held on mm->mmap_sem and any of them can update mm->mmap_cache.
> > Prevent compiler from re-fetching mm->mmap_cache, because other
> > readers could update it in the meantime:
> > 
> 
> FWIW, ACCESS_ONCE() does not guarantee that the compiler will not refetch 
> mm->mmap_cache whatsoever; there is nothing that prevents this either in 
> the C standard.  You'll be relying solely on gcc's implementation of how 
> it dereferences volatile-qualified pointers.

FYI, the volatile access can be also unnecessarily pessimizing, other
projects like glibc use a friendlier alternative to the kernel's
ACCESS_ONCE.  In glibc it is:
# define atomic_forced_read(x) \
  ({ __typeof (x) __x; __asm ("" : "=r" (__x) : "0" (x)); __x; })
(could as well use "=g" instead).  This isn't volatile, so it can be
scheduled freely but if you store the result of it in a local variable and
use only that local variable everywhere in the function (and don't modify
it), there is a guarantee that you'll always see the same value.
The above should work fine with any GCC versions that can be used to compile
kernel.

Or of course, starting with GCC 4.7 you have also the alternative to use
# define ATOMIC_ONCE(x) __atomic_load_n (&x, __ATOMIC_RELAXED)

	Jakub

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id AA59E6B024B
	for <linux-mm@kvack.org>; Tue,  6 Jul 2010 21:39:46 -0400 (EDT)
Date: Wed, 7 Jul 2010 09:39:19 +0800
From: Shaohua Li <shaohua.li@intel.com>
Subject: Re: [PATCH]shmem: reduce one time of locking in pagefault
Message-ID: <20100707013919.GA22097@sli10-desk.sh.intel.com>
References: <1278465346.11107.8.camel@sli10-desk.sh.intel.com>
 <20100706183254.cf67e29e.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100706183254.cf67e29e.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, "Zhang, Yanmin" <yanmin.zhang@intel.com>, Hugh Dickins <hughd@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 07, 2010 at 09:32:54AM +0800, Andrew Morton wrote:
> On Wed, 07 Jul 2010 09:15:46 +0800 Shaohua Li <shaohua.li@intel.com> wrote:
> 
> > I'm running a shmem pagefault test case (see attached file) under a 64 CPU
> > system. Profile shows shmem_inode_info->lock is heavily contented and 100%
> > CPUs time are trying to get the lock.
> 
> I seem to remember complaining about that in 2002 ;) Faulting in a
> mapping of /dev/zero is just awful on a 4-way(!).
> 
> > In the pagefault (no swap) case,
> > shmem_getpage gets the lock twice, the last one is avoidable if we prealloc a
> > page so we could reduce one time of locking. This is what below patch does.
> > 
> > The result of the test case:
> > 2.6.35-rc3: ~20s
> > 2.6.35-rc3 + patch: ~12s
> > so this is 40% improvement.
> > 
> > One might argue if we could have better locking for shmem. But even shmem is lockless,
> > the pagefault will soon have pagecache lock heavily contented because shmem must add
> > new page to pagecache. So before we have better locking for pagecache, improving shmem
> > locking doesn't have too much improvement. I did a similar pagefault test against
> > a ramfs file, the test result is ~10.5s.
> > 
> > Signed-off-by: Shaohua Li <shaohua.li@intel.com>
> > 
> > diff --git a/mm/shmem.c b/mm/shmem.c
> > index f65f840..c5f2939 100644
> > --- a/mm/shmem.c
> > +++ b/mm/shmem.c
> 
> The patch doesn't make shmem_getpage() any clearer :(
> 
> shmem_inode_info.lock appears to be held too much.  Surely
> lookup_swap_cache() didn't need it (for example).
> 
> What data does shmem_inode_info.lock actually protect?
As far as my understanding, it protects shmem swp_entry, which is most used
to support swap. It also protects some accounting. If no swap, the lock almost
can be removed like tiny-shmem.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

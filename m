Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id DEBE46B0031
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 01:04:07 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so2168444pab.1
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 22:04:07 -0700 (PDT)
Message-ID: <1381381437.2297.32.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH v8 0/9] rwsem performance optimizations
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Wed, 09 Oct 2013 22:03:57 -0700
In-Reply-To: <CA+55aFwECx-zQpzDunhNCd2PEbkQ7KYOfuPyzKM1X-SJ-88ZXA@mail.gmail.com>
References: <cover.1380748401.git.tim.c.chen@linux.intel.com>
	 <1380753493.11046.82.camel@schen9-DESK> <20131003073212.GC5775@gmail.com>
	 <1381186674.11046.105.camel@schen9-DESK> <20131009061551.GD7664@gmail.com>
	 <20131009072838.GY3081@twins.programming.kicks-ass.net>
	 <CA+55aFwECx-zQpzDunhNCd2PEbkQ7KYOfuPyzKM1X-SJ-88ZXA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Jason Low <jason.low2@hp.com>, Waiman Long <Waiman.Long@hp.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Wed, 2013-10-09 at 20:14 -0700, Linus Torvalds wrote:
> On Wed, Oct 9, 2013 at 12:28 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> >
> > The workload that I got the report from was a virus scanner, it would
> > spawn nr_cpus threads and {mmap file, scan content, munmap} through your
> > filesystem.
> 
> So I suspect we could make the mmap_sem write area *much* smaller for
> the normal cases.
> 
> Look at do_mmap_pgoff(), for example: it is run entirely under
> mmap_sem, but 99% of what it does doesn't actually need the lock.
> 
> The part that really needs the lock is
> 
>         addr = get_unmapped_area(file, addr, len, pgoff, flags);
>         addr = mmap_region(file, addr, len, vm_flags, pgoff);
> 
> but we hold it over all the other stuff too.
> 

True. By looking at the callers, we're always doing:

down_write(&mm->mmap_sem);
do_mmap_pgoff()
...
up_write(&mm->mmap_sem);

That goes for shm, aio, and of course mmap_pgoff().

While I know you hate two level locking, one way to go about this is to
take the lock inside do_mmap_pgoff() after the initial checks (flags,
page align, etc.) and return with the lock held, leaving the caller to
unlock it. 

> In fact, even if we moved the mmap_sem down into do_mmap(), and moved
> code around a bit to only hold it over those functions, it would still
> cover unnecessarily much. For example, while merging is common, not
> merging is pretty common too, and we do that
> 
>         vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
> 
> allocation under the lock. We could easily do things like preallocate
> it outside the lock.
> 

AFAICT there are also checks that should be done at the beginning of the
function, such as checking for MAP_LOCKED and VM_LOCKED flags before
calling get_unmapped_area().

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id A1F016B0031
	for <linux-mm@kvack.org>; Wed,  9 Oct 2013 23:14:54 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id w10so1904577pde.23
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 20:14:54 -0700 (PDT)
Received: by mail-vb0-f42.google.com with SMTP id e12so1185835vbg.15
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 20:14:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20131009072838.GY3081@twins.programming.kicks-ass.net>
References: <cover.1380748401.git.tim.c.chen@linux.intel.com>
	<1380753493.11046.82.camel@schen9-DESK>
	<20131003073212.GC5775@gmail.com>
	<1381186674.11046.105.camel@schen9-DESK>
	<20131009061551.GD7664@gmail.com>
	<20131009072838.GY3081@twins.programming.kicks-ass.net>
Date: Wed, 9 Oct 2013 20:14:51 -0700
Message-ID: <CA+55aFwECx-zQpzDunhNCd2PEbkQ7KYOfuPyzKM1X-SJ-88ZXA@mail.gmail.com>
Subject: Re: [PATCH v8 0/9] rwsem performance optimizations
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Jason Low <jason.low2@hp.com>, Waiman Long <Waiman.Long@hp.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Wed, Oct 9, 2013 at 12:28 AM, Peter Zijlstra <peterz@infradead.org> wrote:
>
> The workload that I got the report from was a virus scanner, it would
> spawn nr_cpus threads and {mmap file, scan content, munmap} through your
> filesystem.

So I suspect we could make the mmap_sem write area *much* smaller for
the normal cases.

Look at do_mmap_pgoff(), for example: it is run entirely under
mmap_sem, but 99% of what it does doesn't actually need the lock.

The part that really needs the lock is

        addr = get_unmapped_area(file, addr, len, pgoff, flags);
        addr = mmap_region(file, addr, len, vm_flags, pgoff);

but we hold it over all the other stuff too.

In fact, even if we moved the mmap_sem down into do_mmap(), and moved
code around a bit to only hold it over those functions, it would still
cover unnecessarily much. For example, while merging is common, not
merging is pretty common too, and we do that

        vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);

allocation under the lock. We could easily do things like preallocate
it outside the lock.

Right now mmap_sem covers pretty much the whole system call (we do do
some security checks outside of it).

I think the main issue is that nobody has ever cared deeply enough to
see how far this could be pushed. I suspect there is some low-hanging
fruit for anybody who is willing to handle the pain..

            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

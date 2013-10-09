Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 8DAD66B0031
	for <linux-mm@kvack.org>; Wed,  9 Oct 2013 02:15:58 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id z10so432399pdj.3
        for <linux-mm@kvack.org>; Tue, 08 Oct 2013 23:15:58 -0700 (PDT)
Received: by mail-ee0-f54.google.com with SMTP id e53so139739eek.27
        for <linux-mm@kvack.org>; Tue, 08 Oct 2013 23:15:54 -0700 (PDT)
Date: Wed, 9 Oct 2013 08:15:51 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v8 0/9] rwsem performance optimizations
Message-ID: <20131009061551.GD7664@gmail.com>
References: <cover.1380748401.git.tim.c.chen@linux.intel.com>
 <1380753493.11046.82.camel@schen9-DESK>
 <20131003073212.GC5775@gmail.com>
 <1381186674.11046.105.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1381186674.11046.105.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Jason Low <jason.low2@hp.com>, Waiman Long <Waiman.Long@hp.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>


* Tim Chen <tim.c.chen@linux.intel.com> wrote:

> Ingo,
> 
> I ran the vanilla kernel, the kernel with all rwsem patches and the 
> kernel with all patches except the optimistic spin one.  I am listing 
> two presentations of the data.  Please note that there is about 5% 
> run-run variation.
> 
> % change in performance vs vanilla kernel
> #threads	all	without optspin
> mmap only		
> 1		1.9%	1.6%
> 5		43.8%	2.6%
> 10		22.7%	-3.0%
> 20		-12.0%	-4.5%
> 40		-26.9%	-2.0%
> mmap with mutex acquisition		
> 1		-2.1%	-3.0%
> 5		-1.9%	1.0%
> 10		4.2%	12.5%
> 20		-4.1%	0.6%
> 40		-2.8%	-1.9%

Silly question: how do the two methods of starting N threads compare to 
each other? Do they have identical runtimes? I think PeterZ's point was 
that the pthread_mutex case, despite adding extra serialization, actually 
runs faster in some circumstances.

Also, mind posting the testcase? What 'work' do the threads do - clear 
some memory area? How big is the memory area?

I'd expect this to be about large enough mmap()s showing page fault 
processing to be mmap_sem bound and the serialization via pthread_mutex() 
sets up a 'train' of threads in one case, while the parallel startup would 
run into the mmap_sem in the regular case.

So I'd expect this to be a rather sensitive workload and you'd have to 
actively engineer it to hit the effect PeterZ mentioned. I could imagine 
MPI workloads to run into such patterns - but not deterministically.

Only once you've convinced yourself that you are hitting that kind of 
effect reliably on the vanilla kernel, could/should the effects of an 
improved rwsem implementation be measured.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

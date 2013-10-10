Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 0E14C6B0031
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 03:54:50 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id v10so2214433pde.24
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 00:54:50 -0700 (PDT)
Received: by mail-ee0-f54.google.com with SMTP id e53so947575eek.13
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 00:54:47 -0700 (PDT)
Date: Thu, 10 Oct 2013 09:54:44 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v8 0/9] rwsem performance optimizations
Message-ID: <20131010075444.GD17990@gmail.com>
References: <cover.1380748401.git.tim.c.chen@linux.intel.com>
 <1380753493.11046.82.camel@schen9-DESK>
 <20131003073212.GC5775@gmail.com>
 <1381186674.11046.105.camel@schen9-DESK>
 <20131009061551.GD7664@gmail.com>
 <1381336441.11046.128.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1381336441.11046.128.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Jason Low <jason.low2@hp.com>, Waiman Long <Waiman.Long@hp.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>


* Tim Chen <tim.c.chen@linux.intel.com> wrote:

> The throughput of pure mmap with mutex is below vs pure mmap is below:
> 
> % change in performance of the mmap with pthread-mutex vs pure mmap
> #threads        vanilla 	all rwsem    	without optspin
> 				patches
> 1               3.0%    	-1.0%   	-1.7%
> 5               7.2%    	-26.8%  	5.5%
> 10              5.2%    	-10.6%  	22.1%
> 20              6.8%    	16.4%   	12.5%
> 40              -0.2%   	32.7%   	0.0%
> 
> So with mutex, the vanilla kernel and the one without optspin both run 
> faster.  This is consistent with what Peter reported.  With optspin, the 
> picture is more mixed, with lower throughput at low to moderate number 
> of threads and higher throughput with high number of threads.

So, going back to your orignal table:

> % change in performance of the mmap with pthread-mutex vs pure mmap
> #threads        vanilla all     without optspin
> 1               3.0%    -1.0%   -1.7%
> 5               7.2%    -26.8%  5.5%
> 10              5.2%    -10.6%  22.1%
> 20              6.8%    16.4%   12.5%
> 40              -0.2%   32.7%   0.0%
>
> In general, vanilla and no-optspin case perform better with 
> pthread-mutex.  For the case with optspin, mmap with pthread-mutex is 
> worse at low to moderate contention and better at high contention.

it appears that 'without optspin' appears to be a pretty good choice - if 
it wasn't for that '1 thread' number, which, if I correctly assume is the 
uncontended case, is one of the most common usecases ...

How can the single-threaded case get slower? None of the patches should 
really cause noticeable overhead in the non-contended case. That looks 
weird.

It would also be nice to see the 2, 3, 4 thread numbers - those are the 
most common contention scenarios in practice - where do we see the first 
improvement in performance?

Also, it would be nice to include a noise/sttdev figure, it's really hard 
to tell whether -1.7% is statistically significant.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

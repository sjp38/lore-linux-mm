Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 6897F6B0039
	for <linux-mm@kvack.org>; Wed,  9 Oct 2013 12:34:06 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id kx10so1312864pab.27
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 09:34:06 -0700 (PDT)
Subject: Re: [PATCH v8 0/9] rwsem performance optimizations
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <20131009061551.GD7664@gmail.com>
References: <cover.1380748401.git.tim.c.chen@linux.intel.com>
	 <1380753493.11046.82.camel@schen9-DESK> <20131003073212.GC5775@gmail.com>
	 <1381186674.11046.105.camel@schen9-DESK>  <20131009061551.GD7664@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 09 Oct 2013 09:34:01 -0700
Message-ID: <1381336441.11046.128.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Jason Low <jason.low2@hp.com>, Waiman Long <Waiman.Long@hp.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Wed, 2013-10-09 at 08:15 +0200, Ingo Molnar wrote:
> * Tim Chen <tim.c.chen@linux.intel.com> wrote:
> 
> > Ingo,
> > 
> > I ran the vanilla kernel, the kernel with all rwsem patches and the 
> > kernel with all patches except the optimistic spin one.  I am listing 
> > two presentations of the data.  Please note that there is about 5% 
> > run-run variation.
> > 
> > % change in performance vs vanilla kernel
> > #threads	all	without optspin
> > mmap only		
> > 1		1.9%	1.6%
> > 5		43.8%	2.6%
> > 10		22.7%	-3.0%
> > 20		-12.0%	-4.5%
> > 40		-26.9%	-2.0%
> > mmap with mutex acquisition		
> > 1		-2.1%	-3.0%
> > 5		-1.9%	1.0%
> > 10		4.2%	12.5%
> > 20		-4.1%	0.6%
> > 40		-2.8%	-1.9%
> 
> Silly question: how do the two methods of starting N threads compare to 
> each other? 

They both started N pthreads and run for a fixed time. 
The throughput of pure mmap with mutex is below vs pure mmap is below:

% change in performance of the mmap with pthread-mutex vs pure mmap
#threads        vanilla 	all rwsem    	without optspin
				patches
1               3.0%    	-1.0%   	-1.7%
5               7.2%    	-26.8%  	5.5%
10              5.2%    	-10.6%  	22.1%
20              6.8%    	16.4%   	12.5%
40              -0.2%   	32.7%   	0.0%

So with mutex, the vanilla kernel and the one without optspin both
run faster.  This is consistent with what Peter reported.  With
optspin, the picture is more mixed, with lower throughput at low to
moderate number of threads and higher throughput with high number
of threads.

> Do they have identical runtimes? 

Yes, they both have identical runtimes.  I look at the number 
of mmap and munmap operations I could push through.

> I think PeterZ's point was 
> that the pthread_mutex case, despite adding extra serialization, actually 
> runs faster in some circumstances.

Yes, I also see the pthread mutex run faster for the vanilla kernel
from the data above.

> 
> Also, mind posting the testcase? What 'work' do the threads do - clear 
> some memory area? 

The test case do simple mmap and munmap 1MB memory per iteration.

> How big is the memory area?

1MB

The two cases are created as:

#define MEMSIZE (1 * 1024 * 1024)

char *testcase_description = "Anonymous memory mmap/munmap of 1MB";

void testcase(unsigned long long *iterations)
{
        while (1) {
                char *c = mmap(NULL, MEMSIZE, PROT_READ|PROT_WRITE,
                               MAP_PRIVATE|MAP_ANONYMOUS, -1, 0);
                assert(c != MAP_FAILED);
                munmap(c, MEMSIZE);

                (*iterations)++;
        }
}

and adding mutex to serialize:

#define MEMSIZE (1 * 1024 * 1024)

char *testcase_description = "Anonymous memory mmap/munmap of 1MB with
mutex";

pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;

void testcase(unsigned long long *iterations)
{
        while (1) {
                pthread_mutex_lock(&mutex);
                char *c = mmap(NULL, MEMSIZE, PROT_READ|PROT_WRITE,
                               MAP_PRIVATE|MAP_ANONYMOUS, -1, 0);
                assert(c != MAP_FAILED);
                munmap(c, MEMSIZE);
                pthread_mutex_unlock(&mutex);

                (*iterations)++;
        }
}

and run as a pthread.
> 
> I'd expect this to be about large enough mmap()s showing page fault 
> processing to be mmap_sem bound and the serialization via pthread_mutex() 
> sets up a 'train' of threads in one case, while the parallel startup would 
> run into the mmap_sem in the regular case.
> 
> So I'd expect this to be a rather sensitive workload and you'd have to 
> actively engineer it to hit the effect PeterZ mentioned. I could imagine 
> MPI workloads to run into such patterns - but not deterministically.
> 
> Only once you've convinced yourself that you are hitting that kind of 
> effect reliably on the vanilla kernel, could/should the effects of an 
> improved rwsem implementation be measured.
> 
> Thanks,
> 
> 	Ingo
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

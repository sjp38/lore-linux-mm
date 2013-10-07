Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 7C6126B0038
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 18:58:01 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id y10so7706302pdj.25
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 15:58:01 -0700 (PDT)
Subject: Re: [PATCH v8 0/9] rwsem performance optimizations
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <20131003073212.GC5775@gmail.com>
References: <cover.1380748401.git.tim.c.chen@linux.intel.com>
	 <1380753493.11046.82.camel@schen9-DESK>  <20131003073212.GC5775@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 07 Oct 2013 15:57:54 -0700
Message-ID: <1381186674.11046.105.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Jason Low <jason.low2@hp.com>, Waiman Long <Waiman.Long@hp.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Thu, 2013-10-03 at 09:32 +0200, Ingo Molnar wrote:
> * Tim Chen <tim.c.chen@linux.intel.com> wrote:
> 
> > For version 8 of the patchset, we included the patch from Waiman to 
> > streamline wakeup operations and also optimize the MCS lock used in 
> > rwsem and mutex.
> 
> I'd be feeling a lot easier about this patch series if you also had 
> performance figures that show how mmap_sem is affected.
> 
> These:
> 
> > Tim got the following improvement for exim mail server 
> > workload on 40 core system:
> > 
> > Alex+Tim's patchset:    	   +4.8%
> > Alex+Tim+Waiman's patchset:        +5.3%
> 
> appear to be mostly related to the anon_vma->rwsem. But once that lock is 
> changed to an rwlock_t, this measurement falls away.
> 
> Peter Zijlstra suggested the following testcase:
> 
> ===============================>
> In fact, try something like this from userspace:
> 
> n-threads:
> 
>   pthread_mutex_lock(&mutex);
>   foo = mmap();
>   pthread_mutex_lock(&mutex);
> 
>   /* work */
> 
>   pthread_mutex_unlock(&mutex);
>   munma(foo);
>   pthread_mutex_unlock(&mutex);
> 
> vs
> 
> n-threads:
> 
>   foo = mmap();
>   /* work */
>   munmap(foo);


Ingo,

I ran the vanilla kernel, the kernel with all rwsem patches and the
kernel with all patches except the optimistic spin one.  
I am listing two presentations of the data.  Please note that
there is about 5% run-run variation.

% change in performance vs vanilla kernel
#threads	all	without optspin
mmap only		
1		1.9%	1.6%
5		43.8%	2.6%
10		22.7%	-3.0%
20		-12.0%	-4.5%
40		-26.9%	-2.0%
mmap with mutex acquisition		
1		-2.1%	-3.0%
5		-1.9%	1.0%
10		4.2%	12.5%
20		-4.1%	0.6%
40		-2.8%	-1.9%

The optimistic spin case does very well at low to moderate contentions,
but worse when there are very heavy contentions for the pure mmap case.
For the case with pthread mutex, there's not much change from vanilla
kernel.

% change in performance of the mmap with pthread-mutex vs pure mmap
#threads	vanilla	all	without optspin
1		3.0%	-1.0%	-1.7%
5		7.2%	-26.8%	5.5%
10		5.2%	-10.6%	22.1%
20		6.8%	16.4%	12.5%
40		-0.2%	32.7%	0.0%

In general, vanilla and no-optspin case perform better with 
pthread-mutex.  For the case with optspin, mmap with 
pthread-mutex is worse at low to moderate contention and better
at high contention.

Tim

> 
> I've had reports that the former was significantly faster than the
> latter.
> <===============================
> 
> this could be put into a standalone testcase, or you could add it as a new 
> subcommand of 'perf bench', which already has some pthread code, see for 
> example in tools/perf/bench/sched-messaging.c. Adding:
> 
>    perf bench mm threads
> 
> or so would be a natural thing to have.
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

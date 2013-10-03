Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id CAC7C6B0037
	for <linux-mm@kvack.org>; Thu,  3 Oct 2013 03:32:19 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id md4so2064947pbc.2
        for <linux-mm@kvack.org>; Thu, 03 Oct 2013 00:32:19 -0700 (PDT)
Received: by mail-ee0-f52.google.com with SMTP id c41so879220eek.39
        for <linux-mm@kvack.org>; Thu, 03 Oct 2013 00:32:16 -0700 (PDT)
Date: Thu, 3 Oct 2013 09:32:12 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v8 0/9] rwsem performance optimizations
Message-ID: <20131003073212.GC5775@gmail.com>
References: <cover.1380748401.git.tim.c.chen@linux.intel.com>
 <1380753493.11046.82.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1380753493.11046.82.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Jason Low <jason.low2@hp.com>, Waiman Long <Waiman.Long@hp.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>


* Tim Chen <tim.c.chen@linux.intel.com> wrote:

> For version 8 of the patchset, we included the patch from Waiman to 
> streamline wakeup operations and also optimize the MCS lock used in 
> rwsem and mutex.

I'd be feeling a lot easier about this patch series if you also had 
performance figures that show how mmap_sem is affected.

These:

> Tim got the following improvement for exim mail server 
> workload on 40 core system:
> 
> Alex+Tim's patchset:    	   +4.8%
> Alex+Tim+Waiman's patchset:        +5.3%

appear to be mostly related to the anon_vma->rwsem. But once that lock is 
changed to an rwlock_t, this measurement falls away.

Peter Zijlstra suggested the following testcase:

===============================>
In fact, try something like this from userspace:

n-threads:

  pthread_mutex_lock(&mutex);
  foo = mmap();
  pthread_mutex_lock(&mutex);

  /* work */

  pthread_mutex_unlock(&mutex);
  munma(foo);
  pthread_mutex_unlock(&mutex);

vs

n-threads:

  foo = mmap();
  /* work */
  munmap(foo);

I've had reports that the former was significantly faster than the
latter.
<===============================

this could be put into a standalone testcase, or you could add it as a new 
subcommand of 'perf bench', which already has some pthread code, see for 
example in tools/perf/bench/sched-messaging.c. Adding:

   perf bench mm threads

or so would be a natural thing to have.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

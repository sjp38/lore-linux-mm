Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 648C36B0032
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 05:20:44 -0400 (EDT)
Received: by mail-ea0-f172.google.com with SMTP id q10so922142eaj.31
        for <linux-mm@kvack.org>; Fri, 28 Jun 2013 02:20:42 -0700 (PDT)
Date: Fri, 28 Jun 2013 11:20:39 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: Performance regression from switching lock to rw-sem for
 anon-vma tree
Message-ID: <20130628092039.GA29205@gmail.com>
References: <1371165992.27102.573.camel@schen9-DESK>
 <20130619131611.GC24957@gmail.com>
 <1371660831.27102.663.camel@schen9-DESK>
 <1372205996.22432.119.camel@schen9-DESK>
 <20130626095108.GB29181@gmail.com>
 <1372282560.22432.139.camel@schen9-DESK>
 <1372292701.22432.152.camel@schen9-DESK>
 <20130627083651.GA3730@gmail.com>
 <1372366385.22432.185.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1372366385.22432.185.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, "Shi, Alex" <alex.shi@intel.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>


* Tim Chen <tim.c.chen@linux.intel.com> wrote:

> > Yet the 17.6% sleep percentage is still much higher than the 1% in the 
> > mutex case. Why doesn't spinning work - do we time out of spinning 
> > differently?
> 
> I have some stats for the 18.6% cases (including 1% more than 1 sleep 
> cases) that go to sleep and failed optimistic spinning. There are 3 
> abort points in the rwsem_optimistic_spin code:
> 
> 1. 11.8% is due to abort point #1, where we don't find an owner and 
> assumed that probably a reader owned lock as we've just tried to acquire 
> lock previously for lock stealing.  I think I will need to actually 
> check the sem->count to make sure we have reader owned lock before 
> aborting spin.

That looks like to be the biggest remaining effect.

> 2. 6.8% is due to abort point #2, where the mutex owner switches
> to another writer or we need rescheduling.
> 
> 3. Minuscule amount due to abort point #3, where we don't have
> a owner of the lock but need rescheduling

The percentages here might go down if #1 is fixed. Excessive scheduling 
creates wakeups and has a higher rate of preemption as well as waiting 
writers are woken.

There's a chance that if you fix #1 you'll get to the mutex equivalency 
Holy Grail! :-)

> See the other thread for complete patch of rwsem optimistic spin code: 
> https://lkml.org/lkml/2013/6/26/692
> 
> Any suggestions on tweaking this is appreciated.

I think you are on the right track: the goal is to eliminate these sleeps, 
the mutex case proves that it's possible to just spin and not sleep much.

It would be even more complex to match it if the mutex workload showed 
significant internal complexity - but it does not, it still just behaves 
like spinlocks, right?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

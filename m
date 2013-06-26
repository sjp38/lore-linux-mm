Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id DD8C86B0032
	for <linux-mm@kvack.org>; Wed, 26 Jun 2013 05:51:14 -0400 (EDT)
Received: by mail-ee0-f44.google.com with SMTP id c13so7369857eek.31
        for <linux-mm@kvack.org>; Wed, 26 Jun 2013 02:51:13 -0700 (PDT)
Date: Wed, 26 Jun 2013 11:51:08 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: Performance regression from switching lock to rw-sem for
 anon-vma tree
Message-ID: <20130626095108.GB29181@gmail.com>
References: <1371165992.27102.573.camel@schen9-DESK>
 <20130619131611.GC24957@gmail.com>
 <1371660831.27102.663.camel@schen9-DESK>
 <1372205996.22432.119.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1372205996.22432.119.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, "Shi, Alex" <alex.shi@intel.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>


* Tim Chen <tim.c.chen@linux.intel.com> wrote:

> On Wed, 2013-06-19 at 09:53 -0700, Tim Chen wrote: 
> > On Wed, 2013-06-19 at 15:16 +0200, Ingo Molnar wrote:
> > 
> > > > vmstat for mutex implementation: 
> > > > procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu-----
> > > >  r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
> > > > 38  0      0 130957920  47860 199956    0    0     0    56 236342 476975 14 72 14  0  0
> > > > 41  0      0 130938560  47860 219900    0    0     0     0 236816 479676 14 72 14  0  0
> > > > 
> > > > vmstat for rw-sem implementation (3.10-rc4)
> > > > procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu-----
> > > >  r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
> > > > 40  0      0 130933984  43232 202584    0    0     0     0 321817 690741 13 71 16  0  0
> > > > 39  0      0 130913904  43232 224812    0    0     0     0 322193 692949 13 71 16  0  0
> > > 
> > > It appears the main difference is that the rwsem variant context-switches 
> > > about 36% more than the mutex version, right?
> > > 
> > > I'm wondering how that's possible - the lock is mostly write-locked, 
> > > correct? So the lock-stealing from Davidlohr Bueso and Michel Lespinasse 
> > > ought to have brought roughly the same lock-stealing behavior as mutexes 
> > > do, right?
> > > 
> > > So the next analytical step would be to figure out why rwsem lock-stealing 
> > > is not behaving in an equivalent fashion on this workload. Do readers come 
> > > in frequently enough to disrupt write-lock-stealing perhaps?
> 
> Ingo, 
> 
> I did some instrumentation on the write lock failure path.  I found that
> for the exim workload, there are no readers blocking for the rwsem when
> write locking failed.  The lock stealing is successful for 9.1% of the
> time and the rest of the write lock failure caused the writer to go to
> sleep.  About 1.4% of the writers sleep more than once. Majority of the
> writers sleep once.
> 
> It is weird that lock stealing is not successful more often.

For this to be comparable to the mutex scalability numbers you'd have to 
compare wlock-stealing _and_ adaptive spinning for failed-wlock rwsems.

Are both techniques applied in the kernel you are running your tests on?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 217436B0033
	for <linux-mm@kvack.org>; Sun, 22 Oct 2017 22:08:30 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 15so3232563pgc.16
        for <linux-mm@kvack.org>; Sun, 22 Oct 2017 19:08:30 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id u186si4176698pgb.578.2017.10.22.19.08.27
        for <linux-mm@kvack.org>;
        Sun, 22 Oct 2017 19:08:28 -0700 (PDT)
Date: Mon, 23 Oct 2017 11:08:22 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [RESEND PATCH 1/3] completion: Add support for initializing
 completion with lockdep_map
Message-ID: <20171023020822.GI3310@X58A-UD3R>
References: <1508319532-24655-1-git-send-email-byungchul.park@lge.com>
 <1508319532-24655-2-git-send-email-byungchul.park@lge.com>
 <1508455438.4542.4.camel@wdc.com>
 <alpine.DEB.2.20.1710200829340.3083@nanos>
 <1508529532.3029.15.camel@wdc.com>
 <CANrsvRNnOp_rgEWG2FGg7qaEQi=yEyhiZkpWSW62w21BvJ9Shg@mail.gmail.com>
 <1508682894.2564.8.camel@wdc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1508682894.2564.8.camel@wdc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bart Van Assche <Bart.VanAssche@wdc.com>
Cc: "max.byungchul.park@gmail.com" <max.byungchul.park@gmail.com>, "mingo@kernel.org" <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "hch@infradead.org" <hch@infradead.org>, "amir73il@gmail.com" <amir73il@gmail.com>, "linux-xfs@vger.kernel.org" <linux-xfs@vger.kernel.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "oleg@redhat.com" <oleg@redhat.com>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "darrick.wong@oracle.com" <darrick.wong@oracle.com>, "johannes.berg@intel.com" <johannes.berg@intel.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "idryomov@gmail.com" <idryomov@gmail.com>, "tj@kernel.org" <tj@kernel.org>, "kernel-team@lge.com" <kernel-team@lge.com>, "david@fromorbit.com" <david@fromorbit.com>

On Sun, Oct 22, 2017 at 02:34:56PM +0000, Bart Van Assche wrote:
> On Sat, 2017-10-21 at 11:23 +0900, Byungchul Park wrote:
> > On Sat, Oct 21, 2017 at 4:58 AM, Bart Van Assche <Bart.VanAssche@wdc.com> wrote:
> > > As explained in another e-mail thread, unlike the lock inversion checking
> > > performed by the <= v4.13 lockdep code, cross-release checking is a heuristic
> > > that does not have a sound theoretical basis. The lock validator is an
> > 
> > It's not heuristic but based on the same theoretical basis as <=4.13
> > lockdep. I mean, the key basis is:
> > 
> >    1) What causes deadlock
> >    2) What is a dependency
> >    3) Build a dependency when identified
> 
> Sorry but I doubt that that statement is correct. The publication [1] contains

IMHO, the paper is talking about totally different things wrt
deadlocks by wait_for_event/event, that is, lost events.

Furthermore, it doesn't rely on dependencies itself, but just lock
ordering 'case by case', which is a subset of the more general concept.

> a proof that an algorithm that is closely related to the traditional lockdep
> lock inversion detector is able to detect all deadlocks and does not report

I can admit this.

> false positives for programs that only use mutexes as synchronization objects.

I want to ask you. What makes false positives avoidable in the paper?

> The comment of the authors of that paper for programs that use mutexes,
> condition variables and semaphores is as follows: "It is unclear how to extend
> the lock-graph-based algorithm in Section 3 to efficiently consider the effects
> of condition variables and semaphores. Therefore, when considering all three
> synchronization mechanisms, we currently use a naive algorithm that checks each

Right. The paper seems to use a naive algorigm for that cases, not
replying on dependencies, which they should.

> feasible permutation of the trace for deadlock." In other words, if you have
> found an approach for detecting potential deadlocks for programs that use these
> three kinds of synchronization objects and that does not report false positives
> then that's a breakthrough that's worth publishing in a journal or in the
> proceedings of a scientific conference.

Please, point out logical problems of cross-release than saying it's
impossbile according to the paper. I think you'd better understand how
cross-release works *first*. I'll do my best to help you do.

> Bart.
> 
> [1] Agarwal, Rahul, and Scott D. Stoller. "Run-time detection of potential
> deadlocks for programs with locks, semaphores, and condition variables." In
> Proceedings of the 2006 workshop on Parallel and distributed systems: testing
> and debugging, pp. 51-60. ACM, 2006.
> (https://pdfs.semanticscholar.org/9324/fc0b5d5cd5e05d551a3e98757122039946a2.pdf).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f42.google.com (mail-qa0-f42.google.com [209.85.216.42])
	by kanga.kvack.org (Postfix) with ESMTP id 968A76B0037
	for <linux-mm@kvack.org>; Tue, 13 May 2014 11:44:41 -0400 (EDT)
Received: by mail-qa0-f42.google.com with SMTP id j5so545375qaq.15
        for <linux-mm@kvack.org>; Tue, 13 May 2014 08:44:41 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id t9si7947589qct.53.2014.05.13.08.44.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 May 2014 08:44:41 -0700 (PDT)
Date: Tue, 13 May 2014 17:44:35 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 19/19] mm: filemap: Avoid unnecessary barries and
 waitqueue lookups in unlock_page fastpath
Message-ID: <20140513154435.GG2485@laptop.programming.kicks-ass.net>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de>
 <1399974350-11089-20-git-send-email-mgorman@suse.de>
 <20140513125313.GR23991@suse.de>
 <20140513141748.GD2485@laptop.programming.kicks-ass.net>
 <20140513152719.GF18164@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <20140513152719.GF18164@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, David Howells <dhowells@redhat.com>

On Tue, May 13, 2014 at 08:27:19AM -0700, Paul E. McKenney wrote:
> > Subject: doc: Update wakeup barrier documentation
> >=20
> > As per commit e0acd0a68ec7 ("sched: fix the theoretical signal_wake_up()
> > vs schedule() race") both wakeup and schedule now imply a full barrier.
> >=20
> > Furthermore, the barrier is unconditional when calling try_to_wake_up()
> > and has been for a fair while.
> >=20
> > Cc: Oleg Nesterov <oleg@redhat.com>
> > Cc: Linus Torvalds <torvalds@linux-foundation.org>
> > Cc: David Howells <dhowells@redhat.com>
> > Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> > Signed-off-by: Peter Zijlstra <peterz@infradead.org>
>=20
> Some questions below.
>=20
> 							Thanx, Paul
>=20
> > ---
> >  Documentation/memory-barriers.txt | 6 +++---
> >  1 file changed, 3 insertions(+), 3 deletions(-)
> >=20
> > diff --git a/Documentation/memory-barriers.txt b/Documentation/memory-b=
arriers.txt
> > index 46412bded104..dae5158c2382 100644
> > --- a/Documentation/memory-barriers.txt
> > +++ b/Documentation/memory-barriers.txt
> > @@ -1881,9 +1881,9 @@ The whole sequence above is available in various =
canned forms, all of which
> >  	event_indicated =3D 1;
> >  	wake_up_process(event_daemon);
> >=20
> > -A write memory barrier is implied by wake_up() and co. if and only if =
they wake
> > -something up.  The barrier occurs before the task state is cleared, an=
d so sits
> > -between the STORE to indicate the event and the STORE to set TASK_RUNN=
ING:
> > +A full memory barrier is implied by wake_up() and co. The barrier occu=
rs
>=20
> Last I checked, the memory barrier was guaranteed only if a wakeup
> actually occurred.  If there is a sleep-wakeup race, for example,
> between wait_event_interruptible() and wake_up(), then it looks to me
> that the following can happen:
>=20
> o	Task A invokes wait_event_interruptible(), waiting for
> 	X=3D=3D1.
>=20
> o	Before Task A gets anywhere, Task B sets Y=3D1, does
> 	smp_mb(), then sets X=3D1.
>=20
> o	Task B invokes wake_up(), which invokes __wake_up(), which
> 	acquires the wait_queue_head_t's lock and invokes
> 	__wake_up_common(), which sees nothing to wake up.
>=20
> o	Task A tests the condition, finds X=3D=3D1, and returns without
> 	locks, memory barriers, atomic instructions, or anything else
> 	that would guarantee ordering.
>=20
> o	Task A then loads from Y.  Because there have been no memory
> 	barriers, it might well see Y=3D=3D0.
>=20
> So what am I missing here?

Ah, that's what was meant :-) The way I read it was that
wake_up_process() would only imply the barrier if the task actually got
a wakeup (ie. the return value is 1).

But yes, this makes a lot more sense. Sorry for the confusion.

> On the wake_up() side, wake_up() calls __wake_up(), which as mentioned
> earlier calls __wake_up_common() under a lock.  This invokes the
> wake-up function stored by the sleeping task, for example,
> autoremove_wake_function(), which calls default_wake_function(),
> which invokes try_to_wake_up(), which does smp_mb__before_spinlock()
> before acquiring the to-be-waked task's PI lock.
>=20
> The definition of smp_mb__before_spinlock() is smp_wmb().  There is
> also an smp_rmb() in try_to_wake_up(), which still does not get us
> to a full memory barrier.  It also calls select_task_rq(), which
> does not seem to guarantee any particular memory ordering (but
> I could easily have missed something).  It also calls ttwu_queue(),
> which invokes ttwu_do_activate() under the RQ lock.  I don't see a
> full memory barrier in ttwu_do_activate(), but again could easily
> have missed one.  Ditto for ttwu_stat().

Ah, yes, so I'll defer to Oleg and Linus to explain that one. As per the
name: smp_mb__before_spinlock() should of course imply a full barrier.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

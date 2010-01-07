Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 2F4336B007B
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 11:12:15 -0500 (EST)
Date: Thu, 7 Jan 2010 10:11:07 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
In-Reply-To: <20100105192243.1d6b2213@infradead.org>
Message-ID: <alpine.DEB.2.00.1001071007210.901@router.home>
References: <20100104182429.833180340@chello.nl> <20100104182813.753545361@chello.nl> <20100105054536.44bf8002@infradead.org> <alpine.DEB.2.00.1001050916300.1074@router.home> <20100105192243.1d6b2213@infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Arjan van de Ven <arjan@infradead.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 5 Jan 2010, Arjan van de Ven wrote:

> On Tue, 5 Jan 2010 09:17:11 -0600 (CST)
> Christoph Lameter <cl@linux-foundation.org> wrote:
>
> > On Tue, 5 Jan 2010, Arjan van de Ven wrote:
> >
> > > while I appreciate the goal of reducing contention on this lock...
> > > wouldn't step one be to remove the page zeroing from under this
> > > lock? that's by far (easily by 10x I would guess) the most
> > > expensive thing that's done under the lock, and I would expect a
> > > first order of contention reduction just by having the zeroing of a
> > > page not done under the lock...
> >
> > The main issue is cacheline bouncing. mmap sem is a rw semaphore and
> > only held for read during a fault.
>
> depends on the workload; on a many-threads-java workload, you also get
> it for write quite a bit (lots of malloc/frees in userspace in addition
> to pagefaults).. at which point you do end up serializing on the
> zeroing.
>
> There's some real life real big workloads that show this pretty badly;
> so far the workaround is to have glibc batch up a lot of the free()s..
> but that's just pushing it a little further out.

Again mmap_sem is a rwsem and only a read lock is held. Zeroing in
do_anonymous_page can occur concurrently on multiple processors in the
same address space. The pte lock is intentionally taken *after* zeroing to
allow concurrent zeroing to occur.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

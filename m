Subject: Re: [RFC][PATCH] lru_add_drain_all() don't use
 schedule_on_each_cpu()
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20081027120405.1B45.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <2f11576a0810260851h15cb7e1ahb454b70a2e99e1a8@mail.gmail.com>
	 <1225037872.32713.22.camel@twins>
	 <20081027120405.1B45.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Mon, 27 Oct 2008 08:56:30 +0100
Message-Id: <1225094190.16159.3.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Gautham Shenoy <ego@in.ibm.com>, Oleg Nesterov <oleg@tv-sign.ru>, Rusty Russell <rusty@rustcorp.com.au>, mpm <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2008-10-27 at 12:14 +0900, KOSAKI Motohiro wrote:
> > Right, and would be about 4k+sizeof(task_struct), some people might be
> > bothered, but most won't care.
> > 
> > > Perhaps, I misunderstand your intension. so can you point your
> > > previous discussion url?
> > 
> > my google skillz fail me, but once in a while people complain that we
> > have too many kernel threads.
> > 
> > Anyway, if we can re-use this per-cpu workqueue for more goals, I guess
> > there is even less of an objection.
> 
> In general, you are right.
> but this is special case. mmap_sem is really widely used various subsystem and drivers.
> (because page fault via copy_user introduce to depend on mmap_sem)
> 
> Then, any work-queue reu-sing can cause similar dead-lock easily.

Yeah, I know, and the cpu-hotplug discussion needed another thread due
to yet another locking incident. I was hoping these two could go
together.

Neither are general-purpose workqueues, both need to stay away from the
normal eventd due to deadlocks.

ego, does you extra thread ever use mmap_sem?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

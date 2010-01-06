Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 1F9876B003D
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 04:40:13 -0500 (EST)
Date: Wed, 6 Jan 2010 01:39:17 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
In-Reply-To: <20100106160614.ff756f82.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.LFD.2.00.1001060119010.3630@localhost.localdomain>
References: <20100104182429.833180340@chello.nl> <20100104182813.753545361@chello.nl> <20100105092559.1de8b613.kamezawa.hiroyu@jp.fujitsu.com> <28c262361001042029w4b95f226lf54a3ed6a4291a3b@mail.gmail.com> <20100105134357.4bfb4951.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.LFD.2.00.1001042052210.3630@localhost.localdomain> <20100105143046.73938ea2.kamezawa.hiroyu@jp.fujitsu.com> <20100105163939.a3f146fb.kamezawa.hiroyu@jp.fujitsu.com> <alpine.LFD.2.00.1001050707520.3630@localhost.localdomain>
 <20100106092212.c8766aa8.kamezawa.hiroyu@jp.fujitsu.com> <alpine.LFD.2.00.1001051718100.3630@localhost.localdomain> <20100106115233.5621bd5e.kamezawa.hiroyu@jp.fujitsu.com> <alpine.LFD.2.00.1001051917000.3630@localhost.localdomain>
 <20100106125625.b02c1b3a.kamezawa.hiroyu@jp.fujitsu.com> <alpine.LFD.2.00.1001052007090.3630@localhost.localdomain> <20100106160614.ff756f82.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>



On Wed, 6 Jan 2010, KAMEZAWA Hiroyuki wrote:
>
>      9.08%  multi-fault-all  [kernel]                  [k] down_read_trylock

Btw, the "trylock" implementation of rwsemaphores doesn't look very good 
on x86, even after teaching x64-64 to use the xadd versions of rwsems.

The reason? It sadly does a "load/inc/cmpxchg" sequence to do an "add if 
there are no writers", and that may be the obvious model, but it sucks 
from a cache access standpoint.

Why? Because it starts the sequence with a plain read. So if it doesn't 
have the cacheline, it will likely get it first in non-exclusive mode, and 
then the cmpxchg a few instructions later will need to turn it into an 
exclusive ownership.

So now that trylock may well end up doing two bus accesses rather than 
one.

It's possible that an OoO x86 CPU might notice the "read followed by 
r-m-w" pattern and just turn it into an exclusive cache fetch immediately, 
but I don't think they are quite that smart. But who knows? 

Anyway, for the above reason it might actually be better to _avoid_ the 
load entirely, and just make __down_read_trylock() assume the rwsem starts 
out unlocked - replace the initial memory load with just loading a 
constant.

That way, it will do the cmpxchg first, and if it wasn't unlocked and had 
other readers active, it will end up doing an extra cmpxchg, but still 
hopefully avoid the extra bus cycles.

So it might be worth testing this trivial patch on top of my other one.

UNTESTED. But the patch is small and simple, so maybe it works anyway. It 
would be interesting to hear if it makes any difference. Better? Worse? Or 
is it a "There's no difference at all, Linus. You're on drugs with that 
whole initial bus cycle thing"

		Linus

---
 arch/x86/include/asm/rwsem.h |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/asm/rwsem.h b/arch/x86/include/asm/rwsem.h
index 625baca..275c0a1 100644
--- a/arch/x86/include/asm/rwsem.h
+++ b/arch/x86/include/asm/rwsem.h
@@ -123,7 +123,6 @@ static inline int __down_read_trylock(struct rw_semaphore *sem)
 {
 	__s32 result, tmp;
 	asm volatile("# beginning __down_read_trylock\n\t"
-		     "  movl      %0,%1\n\t"
 		     "1:\n\t"
 		     "  movl	     %1,%2\n\t"
 		     "  addl      %3,%2\n\t"
@@ -133,7 +132,7 @@ static inline int __down_read_trylock(struct rw_semaphore *sem)
 		     "2:\n\t"
 		     "# ending __down_read_trylock\n\t"
 		     : "+m" (sem->count), "=&a" (result), "=&r" (tmp)
-		     : "i" (RWSEM_ACTIVE_READ_BIAS)
+		     : "i" (RWSEM_ACTIVE_READ_BIAS), "1" (RWSEM_UNLOCKED_VALUE)
 		     : "memory", "cc");
 	return result >= 0 ? 1 : 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C33A66007E1
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 11:15:24 -0500 (EST)
Date: Tue, 5 Jan 2010 08:14:51 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
In-Reply-To: <alpine.LFD.2.00.1001050707520.3630@localhost.localdomain>
Message-ID: <alpine.LFD.2.00.1001050810380.3630@localhost.localdomain>
References: <20100104182429.833180340@chello.nl> <20100104182813.753545361@chello.nl> <20100105092559.1de8b613.kamezawa.hiroyu@jp.fujitsu.com> <28c262361001042029w4b95f226lf54a3ed6a4291a3b@mail.gmail.com> <20100105134357.4bfb4951.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.LFD.2.00.1001042052210.3630@localhost.localdomain> <20100105143046.73938ea2.kamezawa.hiroyu@jp.fujitsu.com> <20100105163939.a3f146fb.kamezawa.hiroyu@jp.fujitsu.com> <alpine.LFD.2.00.1001050707520.3630@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>



On Tue, 5 Jan 2010, Linus Torvalds wrote:
> 
> Lookie here:
> 
>  - arch/x86/Kconfig.cpu:
> 
> 	config X86_XADD
> 		def_bool y
> 		depends on X86_32 && !M386
> 
>  - arch/x86/Kconfig:
> 
> 	config RWSEM_GENERIC_SPINLOCK
> 	        def_bool !X86_XADD
> 
> 	config RWSEM_XCHGADD_ALGORITHM
> 	        def_bool X86_XADD   
> 
> it looks like X86_XADD only gets enabled on 32-bit builds. Which means 
> that x86-64 in turn seems to end up always using the slower "generic 
> spinlock" version.

Sadly, it's not as easy as just changing the X86_XADD "depends on" to say 
"X86_64 || !M386" instead. That just results in

	kernel/built-in.o: In function `up_read':
	(.text+0x2d8e5): undefined reference to `call_rwsem_wake'

etc, because the x86-64 code has obviously never seen the optimized 
call-paths, and they need the asm wrappers for full semantics.

Oh well. Somebody who is bored might look at trying to make the wrapper 
code in arch/x86/lib/semaphore_32.S work on x86-64 too. It should make the 
successful rwsem cases much faster.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

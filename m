Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 121486B010A
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 19:25:32 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o060PUR6030873
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 6 Jan 2010 09:25:30 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0128445DE52
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 09:25:30 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C814E45DE50
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 09:25:29 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id AA1AA1DB803F
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 09:25:29 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C4A21DB8038
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 09:25:29 +0900 (JST)
Date: Wed, 6 Jan 2010 09:22:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
Message-Id: <20100106092212.c8766aa8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LFD.2.00.1001050707520.3630@localhost.localdomain>
References: <20100104182429.833180340@chello.nl>
	<20100104182813.753545361@chello.nl>
	<20100105092559.1de8b613.kamezawa.hiroyu@jp.fujitsu.com>
	<28c262361001042029w4b95f226lf54a3ed6a4291a3b@mail.gmail.com>
	<20100105134357.4bfb4951.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LFD.2.00.1001042052210.3630@localhost.localdomain>
	<20100105143046.73938ea2.kamezawa.hiroyu@jp.fujitsu.com>
	<20100105163939.a3f146fb.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LFD.2.00.1001050707520.3630@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Tue, 5 Jan 2010 07:26:31 -0800 (PST)
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> 
> 
> On Tue, 5 Jan 2010, KAMEZAWA Hiroyuki wrote:
> > #
> > # Overhead          Command             Shared Object  Symbol
> > # ........  ...............  ........................  ......
> > #
> >     43.23%  multi-fault-all  [kernel]                  [k] smp_invalidate_interrupt
> >     16.27%  multi-fault-all  [kernel]                  [k] flush_tlb_others_ipi
> >     11.55%  multi-fault-all  [kernel]                  [k] _raw_spin_lock_irqsave    <========(*)
> >      6.23%  multi-fault-all  [kernel]                  [k] intel_pmu_enable_all
> >      2.17%  multi-fault-all  [kernel]                  [k] _raw_spin_unlock_irqrestore
> 
> Hmm.. The default rwsem implementation shouldn't have any spin-locks in 
> the fast-path. And your profile doesn't seem to have any scheduler 
> footprint, so I wonder what is going on.
> 
> Oh.
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
> 
> Are you sure this isn't the reason why your profiles are horrible?
> 
I think this is the 1st reason but haven't rewrote rwsem itself and tested,
sorry.

This is a profile in other test.
==
2.6.33-rc2's score of the same test program is here.

    75.42%  multi-fault-all  [kernel]                  [k] _raw_spin_lock_irqsav
            |
            --- _raw_spin_lock_irqsave
               |
               |--49.13%-- __down_read_trylock
               |          down_read_trylock
               |          do_page_fault
               |          page_fault
               |          0x400950
               |          |
               |           --100.00%-- (nil)
               |
               |--46.92%-- __up_read
               |          up_read
               |          |
               |          |--99.99%-- do_page_fault
               |          |          page_fault
               |          |          0x400950
               |          |          (nil)
               |           --0.01%-- [...]
==
yes, spinlock is from rwsem.

Why I tried "skipping rwsem" is because I like avoid locking rather than rewrite
lock itself when I think of the influence of the patch....


Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

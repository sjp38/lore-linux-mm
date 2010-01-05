Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6CEB36005A4
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 00:11:08 -0500 (EST)
Date: Mon, 4 Jan 2010 21:10:29 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
In-Reply-To: <20100105134357.4bfb4951.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.LFD.2.00.1001042052210.3630@localhost.localdomain>
References: <20100104182429.833180340@chello.nl> <20100104182813.753545361@chello.nl> <20100105092559.1de8b613.kamezawa.hiroyu@jp.fujitsu.com> <28c262361001042029w4b95f226lf54a3ed6a4291a3b@mail.gmail.com>
 <20100105134357.4bfb4951.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>



On Tue, 5 Jan 2010, KAMEZAWA Hiroyuki wrote:
> 
> Then, my patch dropped speculative trial of page fault and did synchronous
> job here. I'm still considering how to insert some barrier to delay calling
> remove_vma() until all page fault goes. One idea was reference count but
> it was said not-enough crazy.

What lock would you use to protect the vma lookup (in order to then 
increase the refcount)? A sequence lock with RCU lookup of the vma?

Sounds doable. But it also sounds way more expensive than the current VM 
fault handling, which is pretty close to optimal for single-threaded 
cases.. That RCU lookup might be cheap, but just the refcount is generally 
going to be as expensive as a lock.

Are there some particular mappings that people care about more than 
others? If we limit the speculative lookup purely to anonymous memory, 
that might simplify the problem space?

[ From past experiences, I suspect DB people would be upset and really 
  want it for the general file mapping case.. But maybe the main usage 
  scenario is something else this time? ]

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

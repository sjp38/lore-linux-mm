Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id B91D760021B
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 16:45:02 -0500 (EST)
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <alpine.LFD.2.00.1001071031440.7821@localhost.localdomain>
References: <20100104182429.833180340@chello.nl>
	 <20100104182813.753545361@chello.nl>
	 <20100105054536.44bf8002@infradead.org>
	 <alpine.DEB.2.00.1001050916300.1074@router.home>
	 <20100105192243.1d6b2213@infradead.org>
	 <alpine.DEB.2.00.1001071007210.901@router.home>
	 <alpine.LFD.2.00.1001070814080.7821@localhost.localdomain>
	 <1262884960.4049.106.camel@laptop>
	 <alpine.LFD.2.00.1001070934060.7821@localhost.localdomain>
	 <alpine.LFD.2.00.1001070937180.7821@localhost.localdomain>
	 <alpine.LFD.2.00.1001071031440.7821@localhost.localdomain>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 07 Jan 2010 22:44:43 +0100
Message-ID: <1262900683.4049.139.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, Arjan van de Ven <arjan@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Thu, 2010-01-07 at 10:44 -0800, Linus Torvalds wrote:
> 
> On Thu, 7 Jan 2010, Linus Torvalds wrote:
> > 
> > For example: there's no real reason why we take mmap_sem for writing when 
> > extending an existing vma. And while 'brk()' is a very oldfashioned way of 
> > doing memory management, it's still quite common. So rather than looking 
> > at subtle lockless algorithms, why not look at doing the common cases of 
> > an extending brk? Make that one take the mmap_sem for _reading_, and then 
> > do the extending of the brk area with a simple cmpxchg or something?
> 
> I didn't use cmpxchg, because we actually want to update both 
> 'current->brk' _and_ the vma->vm_end atomically, so here's a totally 
> untested patch that uses the page_table_lock spinlock for it instead (it 
> could be a new spinlock, not worth it).
> 
> It's also totally untested and might be horribly broken. But you get the 
> idea.
> 
> We could probably do things like this in regular mmap() too for the 
> "extend a mmap" case. brk() is just especially simple.

I haven't yet looked at the patch, but isn't expand_stack() kinda like
what you want? That serializes using anon_vma_lock().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

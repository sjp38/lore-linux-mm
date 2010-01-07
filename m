Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id E5513600580
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 14:20:42 -0500 (EST)
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e3.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o07JArIF005020
	for <linux-mm@kvack.org>; Thu, 7 Jan 2010 14:10:53 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o07JKc4J132086
	for <linux-mm@kvack.org>; Thu, 7 Jan 2010 14:20:38 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o07JKaI2015627
	for <linux-mm@kvack.org>; Thu, 7 Jan 2010 14:20:38 -0500
Date: Thu, 7 Jan 2010 11:20:35 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
Message-ID: <20100107192035.GO6764@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20100104182813.753545361@chello.nl> <20100105054536.44bf8002@infradead.org> <alpine.DEB.2.00.1001050916300.1074@router.home> <20100105192243.1d6b2213@infradead.org> <alpine.DEB.2.00.1001071007210.901@router.home> <alpine.LFD.2.00.1001070814080.7821@localhost.localdomain> <1262884960.4049.106.camel@laptop> <alpine.LFD.2.00.1001070934060.7821@localhost.localdomain> <alpine.LFD.2.00.1001070937180.7821@localhost.localdomain> <alpine.LFD.2.00.1001071031440.7821@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1001071031440.7821@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Christoph Lameter <cl@linux-foundation.org>, Arjan van de Ven <arjan@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 07, 2010 at 10:44:13AM -0800, Linus Torvalds wrote:
> 
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

One question on the final test...

> 		Linus
> 
> ---
>  mm/mmap.c |   89 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-------
>  1 files changed, 79 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index ee22989..3d07e5f 100644

[ . . . ]

> +	if (!vma)
> +		goto slow_case;
> +
> +	spin_lock(&mm->page_table_lock);
> +	if (vma->vm_end == cur_brk) {
> +		vma->vm_end = brk;
> +		mm->brk = brk;
> +		cur_brk = brk;
> +	}
> +	spin_unlock(&mm->page_table_lock);
> +
> +	if (cur_brk != brk)

Can this be "if (cur_brk < brk)"?  Seems like it should, given the
earlier tests, but I don't claim to understand the VM code.

							Thanx, Paul

> +		goto slow_case;
> +
> +out:
> +	up_read(&mm->mmap_sem);
> +	return cur_brk;
> +
> +slow_case:
> +	up_read(&mm->mmap_sem);
> +	return slow_brk(brk);
> +}
> +
>  #ifdef DEBUG_MM_RB
>  static int browse_rb(struct rb_root *root)
>  {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

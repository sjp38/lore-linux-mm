Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 04A94600580
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 15:25:34 -0500 (EST)
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e2.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o07KGJ6u015850
	for <linux-mm@kvack.org>; Thu, 7 Jan 2010 15:16:19 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o07KPRv8128786
	for <linux-mm@kvack.org>; Thu, 7 Jan 2010 15:25:27 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o07KPQxT001462
	for <linux-mm@kvack.org>; Thu, 7 Jan 2010 15:25:27 -0500
Date: Thu, 7 Jan 2010 12:25:26 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
Message-ID: <20100107202526.GQ6764@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <alpine.DEB.2.00.1001050916300.1074@router.home> <20100105192243.1d6b2213@infradead.org> <alpine.DEB.2.00.1001071007210.901@router.home> <alpine.LFD.2.00.1001070814080.7821@localhost.localdomain> <1262884960.4049.106.camel@laptop> <alpine.LFD.2.00.1001070934060.7821@localhost.localdomain> <alpine.LFD.2.00.1001070937180.7821@localhost.localdomain> <alpine.LFD.2.00.1001071031440.7821@localhost.localdomain> <20100107192035.GO6764@linux.vnet.ibm.com> <alpine.LFD.2.00.1001071204490.7821@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1001071204490.7821@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Christoph Lameter <cl@linux-foundation.org>, Arjan van de Ven <arjan@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 07, 2010 at 12:06:48PM -0800, Linus Torvalds wrote:
> 
> 
> On Thu, 7 Jan 2010, Paul E. McKenney wrote:
> > > +
> > > +	spin_lock(&mm->page_table_lock);
> > > +	if (vma->vm_end == cur_brk) {
> > > +		vma->vm_end = brk;
> > > +		mm->brk = brk;
> > > +		cur_brk = brk;
> > > +	}
> > > +	spin_unlock(&mm->page_table_lock);
> > > +
> > > +	if (cur_brk != brk)
> > 
> > Can this be "if (cur_brk < brk)"?  Seems like it should, given the
> > earlier tests, but I don't claim to understand the VM code.
> 
> It's really just a flag, to test whether the final check (inside the 
> spinlock) succeeded, or whether we perhaps raced with _another_ brk() call 
> that also had the mm_sem for reading.
> 
> We know that cur_brk was different from brk before - because otherwise 
> we'd have just returned early (or done the slow case). So testing whether 
> it's different afterwards really only tests whether that 
> 
> 	cur_brk = brk;
> 
> statment was executed or not.
> 
> I could have used a separate flag called "success" or something. 

I was (perhaps confusedly) thinking of a pair of threads both trying
to sbrk() at the same time.  One of them wins by acquiring the
->page_table_lock first.  Then the other acquires the spinlock, but
sees vma->vm_end != cur_brk.  But if the first one extended the region
at least as far as the second intended to, the second one's work is done.

Of course, we can debate the sanity of an application that actually does
concurrent sbrk() calls.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

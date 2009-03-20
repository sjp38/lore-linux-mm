Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DD8746B0047
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 11:56:55 -0400 (EDT)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n2KFsW3x016561
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 11:54:32 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2KFvVhT166448
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 11:57:31 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2KFvVMO010220
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 11:57:31 -0400
Date: Fri, 20 Mar 2009 08:57:31 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Question about x86/mm/gup.c's use of disabled interrupts
Message-ID: <20090320155730.GD6698@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <49C148AF.5050601@goop.org> <200903191232.05459.nickpiggin@yahoo.com.au> <49C2818B.9060201@goop.org> <20090320044029.GD6807@linux.vnet.ibm.com> <49C3B886.8080408@goop.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <49C3B886.8080408@goop.org>
Sender: owner-linux-mm@kvack.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Avi Kivity <avi@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Xen-devel <xen-devel@lists.xensource.com>, Jan Beulich <jbeulich@novell.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Fri, Mar 20, 2009 at 08:38:46AM -0700, Jeremy Fitzhardinge wrote:
> Paul E. McKenney wrote:
>>> Ah, interesting.  So disabling interrupts prevents the RCU free from 
>>> happening, and non-atomic pte fetching is a non-issue.  So it doesn't 
>>> address the PAE side of the problem.
>>
>> This would be rcu_sched, correct?
>
> I guess?  Whatever it is that ends up calling all the rcu callbacks after 
> the idle.  A cpu with disabled interrupts can't go through idle, right?  Or 
> is there an explicit way to hold off rcu?

For synchronize_rcu() and call_rcu(), the only guaranteed way to hold
off RCU is rcu_read_lock() and rcu_read_unlock().

For call_rcu_bh, the only guaranteed way to hold off RCU is
rcu_read_lock_bh() and rcu_read_unlock_bh().

For synchronize_srcu(), the only guaranteed way to hold off RCU is
srcu_read_lock() and srcu_read_unlock().

For synchronize_sched() and call_rcu_sched(), anything that disables
preemption, including disabling irqs, holds off RCU.

Although disabling irqs can indeed hold off RCU in some other cases,
the only guarantee is for synchronize_sched() and call_rcu_sched().

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

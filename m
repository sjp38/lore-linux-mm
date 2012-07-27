Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 2B2806B0044
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 02:57:50 -0400 (EDT)
Received: from /spool/local
	by e06smtp18.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Fri, 27 Jul 2012 07:57:48 +0100
Received: from d06av12.portsmouth.uk.ibm.com (d06av12.portsmouth.uk.ibm.com [9.149.37.247])
	by d06nrmr1507.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6R6vKIE2633826
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 07:57:20 +0100
Received: from d06av12.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av12.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6R6vJC7027099
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 00:57:20 -0600
Date: Fri, 27 Jul 2012 08:57:18 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [RFC][PATCH 0/2] fun with tlb flushing on s390
Message-ID: <20120727085718.19c33cce@de.ibm.com>
In-Reply-To: <1343331770.32120.6.camel@twins>
References: <1343317634-13197-1-git-send-email-schwidefsky@de.ibm.com>
	<1343331770.32120.6.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, Zachary Amsden <zach@vmware.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Chris Metcalf <cmetcalf@tilera.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>

On Thu, 26 Jul 2012 21:42:50 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

> On Thu, 2012-07-26 at 17:47 +0200, Martin Schwidefsky wrote:
> > A code review revealed another potential race in regard to TLB flushing
> > on s390. See patch #2 for the ugly details. To fix this I would like
> > to use the arch_enter_lazy_mmu_mode/arch_leave_lazy_mmu_mode but to do
> > that the pointer to the mm in question needs to be added to the functions.
> > To keep things symmetrical arch_flush_lazy_mmu_mode should grow an mm
> > argument as well.
> > 
> > powerpc 
> 
> I have a patch that makes sparc64 do the same thing.

That is good, I guess we are in agreement then to add the mm argument.
 
> > and x86 have a non-empty implementation for the lazy mmu flush
> > primitives and tile calls the generic definition in the architecture
> > files (which is a bit strange because the generic definition is empty).
> > Comments?
> 
> argh.. you're making my head hurt.

Fun, isn't it ?

> I guess my first question is where is lazy_mmu_mode active crossing an
> mm? I thought it was only ever held across operations on a single mm.

My take is never, it is only ever used in a single mm.

> The second question would be if you could use that detach_mm thing I
> proposed a while back ( http://marc.info/?l=linux-mm&m=134090072917840 )
> or can we rework the active_mm magic in general to make all this easier?

No, that is not good enough. The issue I'm trying to fix is for a multi-
threaded application where the same mm is attached to multiple cpus. To
detach it on the local cpu won't help, it would have to be detached
everywhere.

> Your 2/2 patch makes me shiver..
 
Ask me about it :-/

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

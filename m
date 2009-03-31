Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7B26A6B003D
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 14:16:55 -0400 (EDT)
Subject: Re: Detailed Stack Information Patch [0/3]
From: Stefani Seibold <stefani@seibold.net>
In-Reply-To: <87eiwdn15a.fsf@basil.nowhere.org>
References: <1238511498.364.60.camel@matrix>
	 <87eiwdn15a.fsf@basil.nowhere.org>
Content-Type: text/plain
Date: Tue, 31 Mar 2009 20:22:15 +0200
Message-Id: <1238523735.3692.30.camel@matrix>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@elte.hu>, Joerg Engel <joern@logfs.org>
List-ID: <linux-mm.kvack.org>

Hi Andi,

Am Dienstag, den 31.03.2009, 17:49 +0200 schrieb Andi Kleen:
> Stefani Seibold <stefani@seibold.net> writes:
> >
> > - Get out of virtual memory by creating a lot of threads
> >  (f.e. the developer did assign each of them the default size)
> 
> The application just fails then? I don't think that needs
> a new monitoring tool.
> 

First, this patch is not only a monitoring tool. Only the last part 3/3
is the monitoring tool.

Patch 1/3 enhance the the proc/<pid>/task/<tid>/maps by the marking the
thread stack.

Patch 2/3 gives you an overview of the current process/thread stack
usage with the /proc/stackmon entry.

> > - Misuse the thread stack for big temporary data buffers
> 
> That would be better checked for at compile time
> (except for alloca, but that is quite rare)

Fine but it did not work for functions like:

void foo(int n)
{
	char buf[n*1024];

}

This is valid with gcc.

> 
> > - Thread stack overruns
> 
> Your method would be racy at best to determine this because
> you don't keep track of the worst case, only the current case.
> 
> So e.g. if you monitoring app checks once per second the stack
> could overflow between your monitoring intervals, but already
> have bounced back before the checker comes in.
> 

The Monitor is part 3/3. And you are right it is not a complete rock
solid solution. But it works in many cases and thats is what counts.

> Alternatively you could keep
> track of consumption in the VMA that has the stack,  but
> that can't handle very large jumps (like f() { char x[1<<30]; } )
> The later can only be handled well by the compiler.

Thats is exactly what i am doing, i walk through the pages of the thread
stack mapped memory and keep track of the highest access page. So i have
the high water mark of the used stack.

The patches are not intrusive, especially part 1.

> 

Stefani


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

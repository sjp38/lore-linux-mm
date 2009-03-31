Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id F0EB36B003D
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 11:48:42 -0400 (EDT)
Subject: Re: Detailed Stack Information Patch [0/3]
From: Andi Kleen <andi@firstfloor.org>
References: <1238511498.364.60.camel@matrix>
Date: Tue, 31 Mar 2009 17:49:05 +0200
In-Reply-To: <1238511498.364.60.camel@matrix> (Stefani Seibold's message of "Tue, 31 Mar 2009 16:58:18 +0200")
Message-ID: <87eiwdn15a.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Stefani Seibold <stefani@seibold.net>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@elte.hu>, Joerg Engel <joern@logfs.org>
List-ID: <linux-mm.kvack.org>

Stefani Seibold <stefani@seibold.net> writes:
>
> - Get out of virtual memory by creating a lot of threads
>  (f.e. the developer did assign each of them the default size)

The application just fails then? I don't think that needs
a new monitoring tool.

> - Misuse the thread stack for big temporary data buffers

That would be better checked for at compile time
(except for alloca, but that is quite rare)

> - Thread stack overruns

Your method would be racy at best to determine this because
you don't keep track of the worst case, only the current case.

So e.g. if you monitoring app checks once per second the stack
could overflow between your monitoring intervals, but already
have bounced back before the checker comes in.

gcc has support to generate stack overflow checking code,
that would be more reliable. Alternatively you could keep
track of consumption in the VMA that has the stack,  but
that can't handle very large jumps (like f() { char x[1<<30]; } )
The later can only be handled well by the compiler.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

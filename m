Date: Fri, 12 Jul 2002 10:48:06 -0700
From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Subject: Re: scalable kmap (was Re: vm lock contention reduction)
Message-ID: <253370000.1026496086@flay>
In-Reply-To: <3D2CBE6A.53A720A0@zip.com.au>
References: <3D2BC6DB.B60E010D@zip.com.au> <91460000.1026341000@flay> <3D2CBE6A.53A720A0@zip.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Andrea Arcangeli <andrea@suse.de>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

OK, preliminary results we've seen about another 15% reduction in CPU load
on Apache Specweb99 on an 8-way machine with Andrew's kmap patches!
Will send out some more detailed numbers later from the official specweb
machine (thanks to Dave Hansen for running the prelim tests).

Secondly, I'd like to propose yet another mechanism, which would
also be a cheaper way to do things .... based vaguely on an RCU
type mechanism:

When you go to allocate a new global kmap, the danger is that its PTE
entry has not been TLB flushed, and the old value is still in some CPUs 
TLB cache.

If only this task context is going to use this kmap (eg copy_to_user), 
all we need do is check that we have context switched since we last 
used this kmap entry (since it was freed is easiest). If we have not, we 
merely do a local single line invalidate of that entry. If we switch to 
running on any other CPU in the future, we'll do a global TLB flush on 
the switch, so no problem there. I suspect that 99% of the time, this 
means no TLB flush at all, or even an invalidate.

If multiple task contexts might use this kmap, we need to check that
ALL cpus have done an context switch since this entry was last used.
If not, we send a single line invalidate to only those other CPUs that
have not switched, and thus might still have a dirty entry ...

I believe RCU already has all the mechanisms for checking context
switches. By context switch, I really mean TLB flush - ie switched
processes, not just threads.

Madness?

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

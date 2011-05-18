Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 605FC6B0011
	for <linux-mm@kvack.org>; Wed, 18 May 2011 03:58:27 -0400 (EDT)
Date: Wed, 18 May 2011 09:58:15 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 0/4] v6 Improve task->comm locking situation
Message-ID: <20110518075815.GE2945@elte.hu>
References: <1305682865-27111-1-git-send-email-john.stultz@linaro.org>
 <20110518062554.GB2945@elte.hu>
 <20110518000527.bcced636.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110518000527.bcced636.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: John Stultz <john.stultz@linaro.org>, LKML <linux-kernel@vger.kernel.org>, Joe Perches <joe@perches.com>, Michal Nazarewicz <mina86@mina86.com>, Andy Whitcroft <apw@canonical.com>, Jiri Slaby <jirislaby@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>


* Andrew Morton <akpm@linux-foundation.org> wrote:

> On Wed, 18 May 2011 08:25:54 +0200 Ingo Molnar <mingo@elte.hu> wrote:
> 
> >   " Hey, this looks a bit racy and 'top' very rarely, on rare workloads that 
> >     play with ->comm[], might display a weird reading task name for a second, 
> >     amongst the many other temporarily nonsensical statistical things it 
> >     already prints every now and then. "
> 
> Well we should at least make sure that `top' won't run off the end of comm[] 
> and go oops.  I think that's guaranteed by the fact(s) that init_tasks's 
> comm[15] is zero and is always copied-by-value across fork and can never be 
> overwritten in any task_struct.

Correct.

> But I didn't check that.

I actually have a highly threaded app that uses PR_SET_NAME heavily and would 
have noticed any oopsing potential long ago.

Since ->comm is often observed from other tasks, regardless whether it's set 
from the prctl() or from the newfangled /proc vector, the race for seeing 
partial updates to ->comm always existed - for more than 10 years.

So the premise of the whole series is wrong: temporarily incomplete ->comm[]s 
were *always* possible and did not start 1.5+ years ago with:

  4614a696bd1c: procfs: allow threads to rename siblings via /proc/pid/tasks/tid/comm

when i see series being built on a fundamentally wrong premise i get a bit sad!

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 4920F60021D
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 17:16:59 -0400 (EDT)
From: Andreas Schwab <schwab@linux-m68k.org>
Subject: Re: [patch] procfs: provide stack information for threads
References: <1238511505.364.61.camel@matrix> <20090401193135.GA12316@elte.hu>
	<1244146873.20012.6.camel@wall-e>
Date: Fri, 02 Oct 2009 23:17:14 +0200
In-Reply-To: <1244146873.20012.6.camel@wall-e> (Stefani Seibold's message of
	"Thu, 04 Jun 2009 22:21:13 +0200")
Message-ID: <m2eipl7axx.fsf@igel.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Stefani Seibold <stefani@seibold.net>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Stefani Seibold <stefani@seibold.net> writes:

> This is the newest version of the formaly named "detailed stack info"
> patch which give you a better overview of the userland application stack
> usage, especially for embedded linux.
>
> Currently you are only able to dump the main process/thread stack usage
> which is showed in /proc/pid/status by the "VmStk" Value. But you get no
> information about the consumed stack memory of the the threads.
>
> There is an enhancement in the /proc/<pid>/{task/*,}/*maps and which
> marks the vm mapping where the thread stack pointer reside with "[thread
> stack xxxxxxxx]". xxxxxxxx is the start address of the stack.
>
> Also there is a new entry "stack usage" in /proc/<pid>/{task/*,}/status
> which will you give the current stack usage in kb.
>
> I also fixed stack base address in /proc/<pid>/task/*/stat to the base
> address of the associated thread stack and not the one of the main
> process. This makes more sense.

That does not work right.  I sometimes get meaningless values printed
for the stack usage in /proc/*/status (like 18014398509480456 kB), and
the stack start in /proc/*/stat is wrong.  Apparently task->stack_start
contains the stack start of the _parent_ process.

$ awk '{printf "%x\n", $28}' /proc/self/stat; grep stack /proc/self/maps /proc/$$/maps
ffd34990
/proc/self/maps:ffa9c000-ffab1000 rw-p 00000000 00:00 0                                  [stack]
/proc/4054/maps:ffd22000-ffd37000 rw-p 00000000 00:00 0                                  [stack]

Andreas.

-- 
Andreas Schwab, schwab@linux-m68k.org
GPG Key fingerprint = 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

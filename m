Date: Wed, 15 May 2002 11:15:21 -0400 (EDT)
From: Bill Davidsen <davidsen@tmr.com>
Subject: Re: [RFC][PATCH] iowait statistics
In-Reply-To: <200205151214.g4FCEqY13273@Port.imtp.ilyichevsk.odessa.ua>
Message-ID: <Pine.LNX.3.96.1020515111134.5026B-100000@gatekeeper.tmr.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Cc: Rik van Riel <riel@conectiva.com.br>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 15 May 2002, Denis Vlasenko wrote:

> Since you are working on this piece of kernel,
> 
> I was investigating why sometimes in top I see idle % like
> 9384729374923.43%. It was caused by idle count in /proc/stat
> going backward sometimes.
> 
> I found the race responsible for that and have a fix for it
> (attached below). It checks for jiffies change and regenerate
> stats if jiffies++ hit us.
> 
> Unfortunately it is for UP case only, in SMP race still exists,
> even on SMP kernel on UP box.
> 
> Why: system/user/idle[/iowait] stats are collected at timer int
> on UP but _on local APIC int_ on SMP.
> 
> It can be fixed for SMP:
> * add spinlock
> or
> * add per_cpu_idle, account it too at timer/APIC int
>   and get rid of idle % calculations for /proc/stat
> 
> As a user, I vote for glitchless statistics even if they
> consume extra i++ cycle every timer int on every CPU.

You have pointed out the problem, but since your fix is UP only and
doesn't have the iowait stuff, I think more of same is needed. I don't
recall seeing this with preempt, but I am not a top user unless I'm
looking for problems.

Thanks for the pointer.

-- 
bill davidsen <davidsen@tmr.com>
  CTO, TMR Associates, Inc
Doing interesting things with little computers since 1979.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

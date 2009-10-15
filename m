Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0E5186B004F
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 19:33:50 -0400 (EDT)
Date: Thu, 15 Oct 2009 16:33:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 14403] New: Kernel freeze when going out of memory
Message-Id: <20091015163345.4898b34e.akpm@linux-foundation.org>
In-Reply-To: <bug-14403-27@http.bugzilla.kernel.org/>
References: <bug-14403-27@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: arnout@mind.be
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Wed, 14 Oct 2009 11:44:08 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=14403
> 
>            Summary: Kernel freeze when going out of memory
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 2.6.24.6 through 2.6.31.1
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Other
>         AssignedTo: akpm@linux-foundation.org
>         ReportedBy: arnout@mind.be
>                 CC: arnout@mind.be
>         Regression: No
> 
> 
> Created an attachment (id=23404)
>  --> (http://bugzilla.kernel.org/attachment.cgi?id=23404)
> console log during freeze (bzip2)
> 
> I get very frequent kernel freezes on two of my systems when they go out of
> memory.  This happens with all kernels I tried (2.6.24 through 2.6.31).  These
> systems run a set of applications that occupy most of the memory, they have no
> swap space, and they have very high network and disk activity (xfs).  The
> network chip varies (tg3, bnx2, r8169).
> 
> Symptoms are that no user processes make any progress, though SysRq interaction
> is still possible.  SysRq-I recovers the system (init starts new gettys).
> 
> During the freeze, there are a lot of page allocation failures from the network
> interrupt handler.  There doesn't seem to be any invocation of the OOM killer
> (I can't find any 'kill process ... score ...' messages), although before the
> freeze the OOM killer is usually called successfully a couple of times.  Note
> that the killed processes are restarted soon after (but with lower memory
> consumption).
> 
> During the freeze, pinging and arping the system is (usually) still possible. 
> There is very little traffic on the network interface, most of it is broadcast.
>  There are also TCP ACKs still going around.  The amount of page allocation
> failures seems to correspond more or less with the amount of traffic on the
> interface, but it's hard to be sure (serial line has delay and printks are not
> timestamped).  Still, some skb allocations must be successful or the ping would
> never get a reply.
> 
> Manual invocation of the OOM killer doesn't seem to do anything (nothing is
> killed, no memory is freed).
> 
> Attached is a long log taken over the serial console.  In the beginning there
> are some invocations of the OOM killer which bring userspace back (as can be
> seen from the syslog output that appears after a while).  Then, while the
> system is frozen there is a continuous stream of page allocation failures (2158
> in this hour).  This log corresponds to about 1 hour of frozen time (from 11:48
> till 12:47).  In this time I did a couple of SysRq-T's, a SysRq-F with no
> results, a SysRq-E with no results (not surprising since userspace is never
> invoked), and finally a SysRq-I where the SysRq-M immediately before and after
> show that it was successful.
> 
> About the memory usage: 620MB is due to files in tmpfs that I created in order
> to trigger the out of memory situation sooner.
> 

It would help if we could see the result of the sysrq-t output when the
kernel is frozen.

- enable and configure a serial console or netconsole
  (Documentation/networking/netconsole.txt)

- boot with log_buf_len=1M

- run `dmesg -n 7'

- freeze the kernel

- hit sysrq-t

- send us the resulting output.  Please don't let it get wordwrapped
  by your email client!


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

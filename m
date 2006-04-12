Date: Wed, 12 Apr 2006 10:11:54 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] [PATCH] support for oom_die
Message-Id: <20060412101154.019e9cb3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0604111025110.564@schroedinger.engr.sgi.com>
References: <20060411142909.1899c4c4.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0604111025110.564@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 11 Apr 2006 10:28:32 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Tue, 11 Apr 2006, KAMEZAWA Hiroyuki wrote:
> 
> > I think 2.6 kernel is very robust against OOM situation but sometimes
> > it occurs. Yes, oom_kill works enough and exit oom situation, *when*
> > the system wants to survive.
> A user process can cause an oops by using too much memory?
Yes. if oom_die=1.

> Would it not be better to terminate the rogue process instead? Otherwise 
> any user can bring down the system?
> 
I thought so until met system admins. And this panic works only if oom_die=1,
this is set by system admin. This is admin's choice.

When OOM-kill occurs on customer's system, I(we) am usually blamed by them 
"Why does the kernel kill process ? Please panic, then we can switch 
 system to sub-system immediately and crash-dump tells us what was happened."
(Note: RHELX has crashdump support.)

More description:
Why they want panic at OOM ?

One reason is to take crashdump at OOM. They just send dump image
to support team, support team can know what happend.Support team can have
precise evidence of 'who is rogue ?'

Another is failover system. Because they can replace system immediately at
panic, they doesn't need oom_kill. 

When implementing failover system , there is two ways in general.
(1) driver-level heartbeat check.
(2) process-level heartbeat check. (check specified process is alive or not)

(1) cannot detect OOM situation. driver is always alive.
(2) can check what process is alive (by kill -0). but sometimes this check is
    delayed. and checking hundreds of applications (all they need) is 

If panic at OOM, (1) can do all we (and customers) want.

Third is we can catch oom caued by kernel-memory-leak and chase it by dump. :)

Note:
I proposed them to use overcommit_memory=2, but that didn't work well.
(because of Java and multithreaded system.....)


We have oom_adj. I think this is very useful (only if used in sane way..)
But it looks difficult to use....When hundreds of applications runs on the server,
they are all important. It's impossible to attach valid oom_adj value to all of them.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

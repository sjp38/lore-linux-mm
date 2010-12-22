Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8C1676B0087
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 03:03:18 -0500 (EST)
Date: Tue, 21 Dec 2010 23:59:24 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] memcg: add oom killer delay
Message-Id: <20101221235924.b5c1aecc.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1012212318140.22773@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1012212318140.22773@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Divyesh Shah <dpshah@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 21 Dec 2010 23:27:25 -0800 (PST) David Rientjes <rientjes@google.com> wrote:

> Completely disabling the oom killer for a memcg is problematic if
> userspace is unable to address the condition itself, usually because
> userspace is unresponsive.  This scenario creates a memcg livelock:
> tasks are continuously trying to allocate memory and nothing is getting
> killed, so memory freeing is impossible since reclaim has failed, and
> all work stalls with no remedy in sight.

Userspace was buggy, surely.  If userspace has elected to disable the
oom-killer then it should ensure that it can cope with the ensuing result.

One approach might be to run a mlockall()ed watchdog which monitors the
worker tasks via shared memory.  Another approach would be to run that
watchdog in a different memcg, without mlockall().  There are surely
plenty of other ways of doing it.

> This patch adds an oom killer delay so that a memcg may be configured to
> wait at least a pre-defined number of milliseconds before calling the
> oom killer.  If the oom condition persists for this number of
> milliseconds, the oom killer will be called the next time the memory
> controller attempts to charge a page (and memory.oom_control is set to
> 0).  This allows userspace to have a short period of time to respond to
> the condition before timing out and deferring to the kernel to kill a
> task.
> 
> Admins may set the oom killer timeout using the new interface:
> 
> 	# echo 60000 > memory.oom_delay
> 
> This will defer oom killing to the kernel only after 60 seconds has
> elapsed.  When setting memory.oom_delay, all pending timeouts are
> restarted.
> 

eww, ick ick ick.


Minutea:

- changelog and docs forgot to mention that oom_delay=0 disables.

- it's called oom_kill_delay in the kernel and oom_delay in userspace.

- oom_delay_millisecs would be a better name for the pseudo file.

- Also, ick.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 3EBAF6B0012
	for <linux-mm@kvack.org>; Mon, 30 May 2011 21:33:11 -0400 (EDT)
Date: Mon, 30 May 2011 21:33:02 -0400 (EDT)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <2135926037.315785.1306805582148.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <4DD61F80.1020505@jp.fujitsu.com>
Subject: Re: [PATCH v2 0/5] Fix oom killer doesn't work at all if system
 have > gigabytes memory  (aka CAI founded issue)
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, rientjes@google.com, hughd@google.com, kamezawa hiroyu <kamezawa.hiroyu@jp.fujitsu.com>, minchan kim <minchan.kim@gmail.com>, oleg@redhat.com

Hello,

Have tested those patches rebased from KOSAKI for the latest mainline.
It still killed random processes and recevied a panic at the end by
using root user. The full oom output can be found here.
http://people.redhat.com/qcai/oom

Cheers,
CAI Qian

----- Original Message -----
> CAI Qian reported current oom logic doesn't work at all on his 16GB
> RAM
> machine. oom killer killed all system daemon at first and his system
> stopped responding.
> 
> The brief log is below.
> 
> > Out of memory: Kill process 1175 (dhclient) score 1 or sacrifice
> > child
> > Out of memory: Kill process 1247 (rsyslogd) score 1 or sacrifice
> > child
> > Out of memory: Kill process 1284 (irqbalance) score 1 or sacrifice
> > child
> > Out of memory: Kill process 1303 (rpcbind) score 1 or sacrifice
> > child
> > Out of memory: Kill process 1321 (rpc.statd) score 1 or sacrifice
> > child
> > Out of memory: Kill process 1333 (mdadm) score 1 or sacrifice child
> > Out of memory: Kill process 1365 (rpc.idmapd) score 1 or sacrifice
> > child
> > Out of memory: Kill process 1403 (dbus-daemon) score 1 or sacrifice
> > child
> > Out of memory: Kill process 1438 (acpid) score 1 or sacrifice child
> > Out of memory: Kill process 1447 (hald) score 1 or sacrifice child
> > Out of memory: Kill process 1447 (hald) score 1 or sacrifice child
> > Out of memory: Kill process 1487 (hald-addon-inpu) score 1 or
> > sacrifice child
> > Out of memory: Kill process 1488 (hald-addon-acpi) score 1 or
> > sacrifice child
> > Out of memory: Kill process 1507 (automount) score 1 or sacrifice
> > child
> 
> 
> The problems are three.
> 
> 1) if two processes have the same oom score, we should kill younger
> process.
> but current logic kill older. Typically oldest processes are system
> daemons.
> 2) Current logic use 'unsigned int' for internal score calculation.
> (exactly says,
> it only use 0-1000 value). its very low precision calculation makes a
> lot of
> same oom score and kill an ineligible process.
> 3) Current logic give 3% of SystemRAM to root processes. It obviously
> too big
> if you have plenty memory. Now, your fork-bomb processes have 500MB
> OOM immune
> bonus. then your fork-bomb never ever be killed.
> 
> 
> KOSAKI Motohiro (5):
> oom: improve dump_tasks() show items
> oom: kill younger process first
> oom: oom-killer don't use proportion of system-ram internally
> oom: don't kill random process
> oom: merge oom_kill_process() with oom_kill_task()
> 
> fs/proc/base.c | 13 ++-
> include/linux/oom.h | 10 +--
> include/linux/sched.h | 11 +++
> mm/oom_kill.c | 201 +++++++++++++++++++++++++++----------------------
> 4 files changed, 135 insertions(+), 100 deletions(-)
> 
> --
> 1.7.3.1
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign
> http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

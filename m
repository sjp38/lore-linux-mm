Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id B85B26B0087
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 03:23:48 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oBM8NjMd007362
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 22 Dec 2010 17:23:46 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B9B1345DE5E
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 17:23:45 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 92EE545DE59
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 17:23:45 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8609BE08001
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 17:23:45 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3FF361DB8038
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 17:23:45 +0900 (JST)
Date: Wed, 22 Dec 2010 17:17:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch] memcg: add oom killer delay
Message-Id: <20101222171749.06ef5559.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101221235924.b5c1aecc.akpm@linux-foundation.org>
References: <alpine.DEB.2.00.1012212318140.22773@chino.kir.corp.google.com>
	<20101221235924.b5c1aecc.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Divyesh Shah <dpshah@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 21 Dec 2010 23:59:24 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Tue, 21 Dec 2010 23:27:25 -0800 (PST) David Rientjes <rientjes@google.com> wrote:
> 
> > Completely disabling the oom killer for a memcg is problematic if
> > userspace is unable to address the condition itself, usually because
> > userspace is unresponsive.  This scenario creates a memcg livelock:
> > tasks are continuously trying to allocate memory and nothing is getting
> > killed, so memory freeing is impossible since reclaim has failed, and
> > all work stalls with no remedy in sight.
> 
> Userspace was buggy, surely.  If userspace has elected to disable the
> oom-killer then it should ensure that it can cope with the ensuing result.
> 
> One approach might be to run a mlockall()ed watchdog which monitors the
> worker tasks via shared memory.  Another approach would be to run that
> watchdog in a different memcg, without mlockall().  There are surely
> plenty of other ways of doing it.
> 
> > This patch adds an oom killer delay so that a memcg may be configured to
> > wait at least a pre-defined number of milliseconds before calling the
> > oom killer.  If the oom condition persists for this number of
> > milliseconds, the oom killer will be called the next time the memory
> > controller attempts to charge a page (and memory.oom_control is set to
> > 0).  This allows userspace to have a short period of time to respond to
> > the condition before timing out and deferring to the kernel to kill a
> > task.
> > 
> > Admins may set the oom killer timeout using the new interface:
> > 
> > 	# echo 60000 > memory.oom_delay
> > 
> > This will defer oom killing to the kernel only after 60 seconds has
> > elapsed.  When setting memory.oom_delay, all pending timeouts are
> > restarted.
> > 
> 
> eww, ick ick ick.
> 
> 
> Minutea:
> 
> - changelog and docs forgot to mention that oom_delay=0 disables.
> 
> - it's called oom_kill_delay in the kernel and oom_delay in userspace.
> 
> - oom_delay_millisecs would be a better name for the pseudo file.
> 
> - Also, ick.
> 

seems to be hard to use. No one can estimate "milisecond" for avoidling
OOM-kill. I think this is very bad. Nack to this feature itself.


If you want something smart _in kernel_, please implement followings.

 - When hit oom, enlarge limit to some extent.
 - All processes in cgroup should be stopped.
 - A helper application will be called by usermode_helper().
 - When a helper application exit(), automatically release all processes
   to run again.

Then, you can avoid oom-kill situation in automatic with kernel's help.

BTW, don't call cgroup_lock(). It's always dangerous. You can add your own
lock.


Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

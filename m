Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E237E6B00A4
	for <linux-mm@kvack.org>; Sun, 26 Dec 2010 20:53:45 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oBR1rgmT008294
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 27 Dec 2010 10:53:42 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5576D2E68C1
	for <linux-mm@kvack.org>; Mon, 27 Dec 2010 10:53:42 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 338A31EF083
	for <linux-mm@kvack.org>; Mon, 27 Dec 2010 10:53:42 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 248DC1DB803A
	for <linux-mm@kvack.org>; Mon, 27 Dec 2010 10:53:42 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id DDDAA1DB8047
	for <linux-mm@kvack.org>; Mon, 27 Dec 2010 10:53:41 +0900 (JST)
Date: Mon, 27 Dec 2010 10:47:52 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch] memcg: add oom killer delay
Message-Id: <20101227104752.3fb5fc3b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1012220110480.25848@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1012212318140.22773@chino.kir.corp.google.com>
	<20101221235924.b5c1aecc.akpm@linux-foundation.org>
	<20101222171749.06ef5559.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1012220043040.24462@chino.kir.corp.google.com>
	<20101222174829.226ef641.kamezawa.hiroyu@jp.fujitsu.com>
	<20101222175515.9e88917a.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1012220110480.25848@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Divyesh Shah <dpshah@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 22 Dec 2010 01:21:01 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Wed, 22 Dec 2010, KAMEZAWA Hiroyuki wrote:
> 
> > For example. oom_check_deadlockd can work as
> > 
> >   1. disable oom by memory.oom_disable=1
> >   2. check memory.oom_notify and wait it by poll()
> >   3. At oom, it wakes up.
> >   4. wait for 60 secs.
> >   5. If the cgroup is still in OOM, set oom_disalble=0
> > 
> > This daemon will not use much memory and can run in /roog memory cgroup.
> > 
> 
> Yes, this is almost the same as the "simple and perfect implementation" 
> that I eluded to in my response to Andrew (and I think KOSAKI-san 
> suggested something similiar), although it doesn't quite work because all 
> threads in the cgroup are sitting on the waitqueue and don't get woken up 
> to see oom_control == 0 unless memory is freed, a task is moved, or the 
> limit is resized so this daemon will need to trigger that as step #6.
> 
> That certainly works if it is indeed perfect and guaranteed to always be 
> running.  In the interest of a robust resource isolation model, I don't 
> think we can ever make that conclusion, though, so this discussion is 
> really only about how fault tolerant the kernel is because the end result 
> is if this daemon fails, the kernel livelocks.
> 
> I'd personally prefer not to allow a buggy or imperfect userspace to allow 
> the kernel to livelock; we control the kernel so I think it would be best 
> to ensure that it cannot livelock no matter what userspace happens to do 
> despite its best effort.  If you or Andrew come to the conclusion that 
> it's overkill and at the end of the day we have to trust userspace, I 
> really can't argue that philosophy though :)
> 

It's not livelock. A user can create a new thread in a cgroup not under OOM.
IMHO, oom-kill itself is totally of-no-use and panic_at_oom or the system
stop is always good. We can do cluster keep alive.

If I was you, I'll add a "pool of memory for emergency cgroup" and run 
watchdog tasks in it.

Thanks,
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

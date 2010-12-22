Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id ADFC66B0089
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 04:21:41 -0500 (EST)
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id oBM9LccS005208
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 01:21:39 -0800
Received: from pxi15 (pxi15.prod.google.com [10.243.27.15])
	by kpbe16.cbf.corp.google.com with ESMTP id oBM9LYkB030013
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 01:21:36 -0800
Received: by pxi15 with SMTP id 15so1251511pxi.5
        for <linux-mm@kvack.org>; Wed, 22 Dec 2010 01:21:34 -0800 (PST)
Date: Wed, 22 Dec 2010 01:21:01 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] memcg: add oom killer delay
In-Reply-To: <20101222175515.9e88917a.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1012220110480.25848@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1012212318140.22773@chino.kir.corp.google.com> <20101221235924.b5c1aecc.akpm@linux-foundation.org> <20101222171749.06ef5559.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1012220043040.24462@chino.kir.corp.google.com>
 <20101222174829.226ef641.kamezawa.hiroyu@jp.fujitsu.com> <20101222175515.9e88917a.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Divyesh Shah <dpshah@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 22 Dec 2010, KAMEZAWA Hiroyuki wrote:

> For example. oom_check_deadlockd can work as
> 
>   1. disable oom by memory.oom_disable=1
>   2. check memory.oom_notify and wait it by poll()
>   3. At oom, it wakes up.
>   4. wait for 60 secs.
>   5. If the cgroup is still in OOM, set oom_disalble=0
> 
> This daemon will not use much memory and can run in /roog memory cgroup.
> 

Yes, this is almost the same as the "simple and perfect implementation" 
that I eluded to in my response to Andrew (and I think KOSAKI-san 
suggested something similiar), although it doesn't quite work because all 
threads in the cgroup are sitting on the waitqueue and don't get woken up 
to see oom_control == 0 unless memory is freed, a task is moved, or the 
limit is resized so this daemon will need to trigger that as step #6.

That certainly works if it is indeed perfect and guaranteed to always be 
running.  In the interest of a robust resource isolation model, I don't 
think we can ever make that conclusion, though, so this discussion is 
really only about how fault tolerant the kernel is because the end result 
is if this daemon fails, the kernel livelocks.

I'd personally prefer not to allow a buggy or imperfect userspace to allow 
the kernel to livelock; we control the kernel so I think it would be best 
to ensure that it cannot livelock no matter what userspace happens to do 
despite its best effort.  If you or Andrew come to the conclusion that 
it's overkill and at the end of the day we have to trust userspace, I 
really can't argue that philosophy though :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 9ABA68D003B
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 20:35:21 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 1535F3EE0B6
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 09:35:18 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E691145DE60
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 09:35:17 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C616A45DE56
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 09:35:17 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B813A1DB804F
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 09:35:17 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 82D521DB8047
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 09:35:17 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/4] remove boost_dying_task_prio()
In-Reply-To: <20110411145832.ae133cf8.akpm@linux-foundation.org>
References: <20110411143215.0074.A69D9226@jp.fujitsu.com> <20110411145832.ae133cf8.akpm@linux-foundation.org>
Message-Id: <20110412093503.43EF.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 12 Apr 2011 09:35:16 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrey Vagin <avagin@openvz.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>

Hi

> On Mon, 11 Apr 2011 14:31:18 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > This is a almost revert commit 93b43fa (oom: give the dying
> > task a higher priority).
> > 
> > The commit dramatically improve oom killer logic when fork-bomb
> > occur. But, I've found it has nasty corner case. Now cpu cgroup
> > has strange default RT runtime. It's 0! That said, if a process
> > under cpu cgroup promote RT scheduling class, the process never
> > run at all.
> 
> hm.  How did that happen?  I thought that sched_setscheduler() modifies
> only a single thread, and that thread is in the process of exiting?

If admin insert !RT process into a cpu cgroup of setting rtruntime=0,
usually it run perfectly because !RT task isn't affected from rtruntime
knob, but If it promote RT task, by explicit setscheduler() syscall or
OOM, the task can't run at all.

In short, now oom killer don't work at all if admin are using cpu
cgroup and don't touch rtruntime knob.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

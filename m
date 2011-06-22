Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 7F3BD6B0164
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 20:17:23 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 16FBB3EE0AE
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 09:17:19 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id F35D145DE6A
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 09:17:18 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id CFF1B45DE61
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 09:17:18 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id BFBB31DB802C
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 09:17:18 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7CA85E08002
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 09:17:18 +0900 (JST)
Date: Wed, 22 Jun 2011 09:10:18 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: "make -j" with memory.(memsw.)limit_in_bytes smaller than
 required -> livelock,  even for unlimited processes
Message-Id: <20110622091018.16c14c78.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4E00AFE6.20302@5t9.de>
References: <4E00AFE6.20302@5t9.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lutz Vieweg <lvml@5t9.de>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org

On Tue, 21 Jun 2011 16:51:18 +0200
Lutz Vieweg <lvml@5t9.de> wrote:

> Dear Memory Ressource Controller maintainers,
> 
> by using per-user control groups with a limit on memory (and swap) I am
> trying to secure a shared development server against memory exhaustion
> by any one single user - as it happened before when somebody imprudently
> issued "make -j" (which has the infamous habit to spawn an unlimited
> number of processes) on a large software project with many source files.
> 
> The memory limitation using control groups works just fine when
> only a few processes sum up to a usage that exceeds the limits - the
> processes are OOM-killed, then, and the others users are unaffected.
> 
> But the original cause, a "make -j" on many source files, leads to
> the following ugly symptom:
> 
> - make starts numerous (~ 100 < x < 200) gcc processes
> 
> - some of those gcc processes get OOM-killed quickly, then
>    a few more are killed, but with increasing pauses in between
> 
> - then after a few seconds, no more gcc processes are killed, but
>    the "make" process and its childs do not show any progress anymore
> 

This is a famous fork-bomb problem. I posted fork-bomb-killer patch sets once
but not welcomed. And, there are OOM-killer trouble in kernel, too.
(I think it's recently fixed.)



Don't you use your test set under some cpu cgroup ?
If so, you can see  deadlock in some versions of kernel.


Then, you can stop oom-kill by echo 1 > .../memory.oom_control.
All processes under memcg will be blocked. you can kill all process under memcg
by you hands.

> - at this time, top indicates 100% "system" CPU usage, mostly by
>    "[kworker/*]" threads (one per CPU). But processes from other
>    users, that only require CPU, proceed to run.
> 

This is a known bug and it's now fixed.


> - but also at this time, if any other user (who has not exhausted
>    his memory limits) tries to access any file (at least on /tmp/,
>    as e.g. gcc does), even a simple "ls /tmp/", this operation
>    waits forever. (But "iostat" does not indicate any I/O activity.)
> 

Hmm, it means your 'ls' gets some lock and wait for it. Then, what lock
you wait for ? what w_chan is shown in 'ps -elf' ?


> - as soon as you press "CTRL-C" to abort the "make -j", everything
>    goes back to normal, quickly - also the other users' processes proceed.
> 

yes.


> 
> To reproduce the problem, the attached "Makefile" to a directory
> on a filesystem with at least 70MB free space, then
> 
>   mount -o memory none /cgroup
>   mkdir /cgroup/test
>   echo 64M >/cgroup/test/memory.limit_in_bytes
>   echo 64M >/cgroup/test/memory.memsw.limit_in_bytes
> 

64M is crazy small limit for make -j , I use 300M for my test...



>   cd /somewhere/with/70mb/free
>   echo $$ >/cgroup/test/tasks
>   make sources
>   make -j compile
> 
> Notice that "make sources" will create 200 bogus "*.c" files from
> /dev/urandom to make sure that "gcc" will use up some memory.
> 
> The "make -j compile" reliably reproduces the above mentioned syndrome,
> here.
> 
> Please notice that the livelock does happen only with a significant
> number of parallel compiler runs - it did e.g. not happen with
> only 100 for me, and it also did not happen when I started "make"
> with "strace" - so timing seems to be an issue, here.
> 
> Thanks for any hints towards a solution of this issue in advance!
> 

I think the most of problem comes from oom-killer logic.

Anyway, please post oom-killer log.

and plesse see what hapeens when 

 echo 1 > /memory.oom_control
 (See Documentation/cgroup/memory.txt)




Thsnks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

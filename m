Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E50C790016F
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 06:45:58 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id A20813EE0BC
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 19:45:54 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 833E245DE69
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 19:45:54 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 628EA45DE4D
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 19:45:54 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 538ACE08002
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 19:45:54 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 16B481DB803A
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 19:45:54 +0900 (JST)
Message-ID: <4E01C7D5.3060603@jp.fujitsu.com>
Date: Wed, 22 Jun 2011 19:45:41 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH v3 0/6]  Fix oom killer doesn't work at all if system have
 > gigabytes memory  (aka CAI founded issue)
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, caiqian@redhat.com, rientjes@google.com, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, oleg@redhat.com
Cc: kosaki.motohiro@jp.fujitsu.com

CAI Qian reported current oom logic doesn't work at all on his 16GB RAM
machine. oom killer killed all system daemon at first and his system
stopped responding.

The brief log is below.

> > Out of memory: Kill process 1175 (dhclient) score 1 or sacrifice child
> > Out of memory: Kill process 1247 (rsyslogd) score 1 or sacrifice child
> > Out of memory: Kill process 1284 (irqbalance) score 1 or sacrifice child
> > Out of memory: Kill process 1303 (rpcbind) score 1 or sacrifice child
> > Out of memory: Kill process 1321 (rpc.statd) score 1 or sacrifice child
> > Out of memory: Kill process 1333 (mdadm) score 1 or sacrifice child
> > Out of memory: Kill process 1365 (rpc.idmapd) score 1 or sacrifice child
> > Out of memory: Kill process 1403 (dbus-daemon) score 1 or sacrifice child
> > Out of memory: Kill process 1438 (acpid) score 1 or sacrifice child
> > Out of memory: Kill process 1447 (hald) score 1 or sacrifice child
> > Out of memory: Kill process 1447 (hald) score 1 or sacrifice child
> > Out of memory: Kill process 1487 (hald-addon-inpu) score 1 or sacrifice child
> > Out of memory: Kill process 1488 (hald-addon-acpi) score 1 or sacrifice child
> > Out of memory: Kill process 1507 (automount) score 1 or sacrifice child

The problems are three.

1) if two processes have the same oom score, we should kill younger process.
but current logic kill older. Typically oldest processes are system daemons.
2) Current logic use 'unsigned int' for internal score calculation. (exactly says,
it only use 0-1000 value). its very low precision calculation makes a lot of
same oom score and kill an ineligible process.
3) Current logic give 3% of SystemRAM to root processes. It obviously too big
if you have plenty memory. Now, your fork-bomb processes have 500MB OOM immune
bonus. then your fork-bomb never ever be killed.

Changes from v2
 o added [patch 1/5] use euid instead of CAP_SYS_ADMIN


KOSAKI Motohiro (6):
  oom: use euid instead of CAP_SYS_ADMIN for protection root process
  oom: improve dump_tasks() show items
  oom: kill younger process first
  oom: oom-killer don't use proportion of system-ram internally
  oom: don't kill random process
  oom: merge oom_kill_process() with oom_kill_task()

 fs/proc/base.c        |   13 ++-
 include/linux/oom.h   |    5 +-
 include/linux/sched.h |   11 +++
 mm/oom_kill.c         |  201 ++++++++++++++++++++++++++----------------------
 4 files changed, 131 insertions(+), 99 deletions(-)

-- 
1.7.3.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

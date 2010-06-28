Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9E7FE6B01B5
	for <linux-mm@kvack.org>; Sun, 27 Jun 2010 22:08:02 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5S27wri029476
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 28 Jun 2010 11:07:58 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 419F345DE50
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 11:07:58 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F95845DE4F
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 11:07:57 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id C9C1DE08002
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 11:07:57 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 859F91DB8013
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 11:07:57 +0900 (JST)
Date: Mon, 28 Jun 2010 11:03:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [ATTEND][LSF/VM TOPIC] deterministic cgroup charging using file
 path
Message-Id: <20100628110327.8cb51c0e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTin2PcB6PwKnuazv3oAy6Arg8yntylVvdCj7Mzz-@mail.gmail.com>
References: <AANLkTin2PcB6PwKnuazv3oAy6Arg8yntylVvdCj7Mzz-@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: lsf10-pc@lists.linuxfoundation.org, linux-mm@kvack.org, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, 25 Jun 2010 13:43:45 -0700
Greg Thelen <gthelen@google.com> wrote:

> For the upcoming Linux VM summit, I am interesting in discussing the
> following proposal.
> 
> Problem: When tasks from multiple cgroups share files the charging can be
> non-deterministic.  This requires that all such cgroups have unnecessarily high
> limits.  It would be nice if the charging was deterministic, using the file's
> path to determine which cgroup to charge.  This would benefit charging of
> commonly used files (eg: libc) as well as large databases shared by only a few
> tasks.
> 
> Example: assume two tasks (T1 and T2), each in a separate cgroup.  Each task
> wants to access a large (1GB) database file.  To catch memory leaks a tight
> memory limit on each task's cgroup is set.  However, the large database file
> presents a problem.  If the file has not been cached, then the first task to
> access the file is charged, thereby requiring that task's cgroup to have a limit
> large enough to include the database file.  If the order of access is unknown
> (due to process restart, etc), then all cgroups accessing the file need to have
> a limit large enough to include the database.  This is wasteful because the
> database won't be charged to both T1 and T2.  It would be useful to introduce
> determinism by declaring that a particular cgroup is charged for a particular
> set of files.
> 
> /dev/cgroup/cg1/cg11  # T1: want memory.limit = 30MB
> /dev/cgroup/cg1/cg12  # T2: want memory.limit = 100MB
> /dev/cgroup/cg1       # want memory.limit = 1GB + 30MB + 100MB
> 
> I have implemented a prototype that allows a file system hierarchy be charge a
> particular cgroup using a new bind mount option:
> + mount -t cgroup none /cgroup -o memory
> + mount --bind /tmp/db /tmp/db -o cgroup=/dev/cgroup/cg1
> 
> Any accesses to files within /tmp/db are charged to /dev/cgroup/cg1.  Access to
> other files behave normally - they charge the cgroup of the current task.
> 

Interesting, but I want to use madvice() etc..for this kind of jobs, rather than
deep hooks into the kernel.

madvise(addr, size, MEMORY_RECHAEGE_THIS_PAGES_TO_ME);

Then, you can write a command as:

  file_recharge [path name] [cgroup]
  - this commands move a file cache to specified cgroup.

A daemon program which uses this command + inotify will give us much
flexible controls on file cache on memcg. Do you have some requirements
that this move-charge shouldn't be done in lazy manner ?

Status:
We have codes for move-charge, inotify but have no code for new madvise.


Thanks,
-Kame






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 23D926B01B2
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 01:07:31 -0400 (EDT)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e3.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o5S4rYvT029731
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 00:53:34 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o5S57SeZ130030
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 01:07:28 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o5S57S2Q027275
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 01:07:28 -0400
Date: Mon, 28 Jun 2010 10:37:23 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [ATTEND][LSF/VM TOPIC] deterministic cgroup charging using file
 path
Message-ID: <20100628050723.GR4306@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <AANLkTin2PcB6PwKnuazv3oAy6Arg8yntylVvdCj7Mzz-@mail.gmail.com>
 <20100628110327.8cb51c0e.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100628110327.8cb51c0e.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Greg Thelen <gthelen@google.com>, lsf10-pc@lists.linuxfoundation.org, linux-mm@kvack.org, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-06-28 11:03:27]:

> On Fri, 25 Jun 2010 13:43:45 -0700
> Greg Thelen <gthelen@google.com> wrote:
> 
> > For the upcoming Linux VM summit, I am interesting in discussing the
> > following proposal.
> > 
> > Problem: When tasks from multiple cgroups share files the charging can be
> > non-deterministic.  This requires that all such cgroups have unnecessarily high
> > limits.  It would be nice if the charging was deterministic, using the file's
> > path to determine which cgroup to charge.  This would benefit charging of
> > commonly used files (eg: libc) as well as large databases shared by only a few
> > tasks.
> > 
> > Example: assume two tasks (T1 and T2), each in a separate cgroup.  Each task
> > wants to access a large (1GB) database file.  To catch memory leaks a tight
> > memory limit on each task's cgroup is set.  However, the large database file
> > presents a problem.  If the file has not been cached, then the first task to
> > access the file is charged, thereby requiring that task's cgroup to have a limit
> > large enough to include the database file.  If the order of access is unknown
> > (due to process restart, etc), then all cgroups accessing the file need to have
> > a limit large enough to include the database.  This is wasteful because the
> > database won't be charged to both T1 and T2.  It would be useful to introduce
> > determinism by declaring that a particular cgroup is charged for a particular
> > set of files.
> > 
> > /dev/cgroup/cg1/cg11  # T1: want memory.limit = 30MB
> > /dev/cgroup/cg1/cg12  # T2: want memory.limit = 100MB
> > /dev/cgroup/cg1       # want memory.limit = 1GB + 30MB + 100MB
> > 
> > I have implemented a prototype that allows a file system hierarchy be charge a
> > particular cgroup using a new bind mount option:
> > + mount -t cgroup none /cgroup -o memory
> > + mount --bind /tmp/db /tmp/db -o cgroup=/dev/cgroup/cg1
> > 
> > Any accesses to files within /tmp/db are charged to /dev/cgroup/cg1.  Access to
> > other files behave normally - they charge the cgroup of the current task.
> > 
> 
> Interesting, but I want to use madvice() etc..for this kind of jobs, rather than
> deep hooks into the kernel.
> 
> madvise(addr, size, MEMORY_RECHAEGE_THIS_PAGES_TO_ME);
> 
> Then, you can write a command as:
> 
>   file_recharge [path name] [cgroup]
>   - this commands move a file cache to specified cgroup.
> 
> A daemon program which uses this command + inotify will give us much
> flexible controls on file cache on memcg. Do you have some requirements
> that this move-charge shouldn't be done in lazy manner ?
> 
> Status:
> We have codes for move-charge, inotify but have no code for new madvise.

I have not see the approach yet, but ideally one would want to avoid
changing the application, otherwise we are going to get very tightly
bound in the API issues.

I want to understand why do we need bind mounts? I think this needs
more discussion.

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

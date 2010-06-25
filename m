Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7BC0E6B01AD
	for <linux-mm@kvack.org>; Fri, 25 Jun 2010 16:44:12 -0400 (EDT)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id o5PKi8HV031312
	for <linux-mm@kvack.org>; Fri, 25 Jun 2010 13:44:08 -0700
Received: from iwn38 (iwn38.prod.google.com [10.241.68.102])
	by wpaz13.hot.corp.google.com with ESMTP id o5PKhs3R010050
	for <linux-mm@kvack.org>; Fri, 25 Jun 2010 13:44:07 -0700
Received: by iwn38 with SMTP id 38so2135086iwn.7
        for <linux-mm@kvack.org>; Fri, 25 Jun 2010 13:44:07 -0700 (PDT)
MIME-Version: 1.0
From: Greg Thelen <gthelen@google.com>
Date: Fri, 25 Jun 2010 13:43:45 -0700
Message-ID: <AANLkTin2PcB6PwKnuazv3oAy6Arg8yntylVvdCj7Mzz-@mail.gmail.com>
Subject: [ATTEND][LSF/VM TOPIC] deterministic cgroup charging using file path
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: lsf10-pc@lists.linuxfoundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

For the upcoming Linux VM summit, I am interesting in discussing the
following proposal.

Problem: When tasks from multiple cgroups share files the charging can be
non-deterministic.  This requires that all such cgroups have unnecessarily high
limits.  It would be nice if the charging was deterministic, using the file's
path to determine which cgroup to charge.  This would benefit charging of
commonly used files (eg: libc) as well as large databases shared by only a few
tasks.

Example: assume two tasks (T1 and T2), each in a separate cgroup.  Each task
wants to access a large (1GB) database file.  To catch memory leaks a tight
memory limit on each task's cgroup is set.  However, the large database file
presents a problem.  If the file has not been cached, then the first task to
access the file is charged, thereby requiring that task's cgroup to have a limit
large enough to include the database file.  If the order of access is unknown
(due to process restart, etc), then all cgroups accessing the file need to have
a limit large enough to include the database.  This is wasteful because the
database won't be charged to both T1 and T2.  It would be useful to introduce
determinism by declaring that a particular cgroup is charged for a particular
set of files.

/dev/cgroup/cg1/cg11  # T1: want memory.limit = 30MB
/dev/cgroup/cg1/cg12  # T2: want memory.limit = 100MB
/dev/cgroup/cg1       # want memory.limit = 1GB + 30MB + 100MB

I have implemented a prototype that allows a file system hierarchy be charge a
particular cgroup using a new bind mount option:
+ mount -t cgroup none /cgroup -o memory
+ mount --bind /tmp/db /tmp/db -o cgroup=/dev/cgroup/cg1

Any accesses to files within /tmp/db are charged to /dev/cgroup/cg1.  Access to
other files behave normally - they charge the cgroup of the current task.

--
Greg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

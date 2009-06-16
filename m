Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 375926B0055
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 14:38:59 -0400 (EDT)
Subject: [RFC] set the thread name
From: Stefani Seibold <stefani@seibold.net>
Content-Type: text/plain
Date: Tue, 16 Jun 2009 20:39:52 +0200
Message-Id: <1245177592.14543.1.camel@wall-e>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Currently it is not easy to identify a thread in linux, because there is
no thread name like in some other OS. 

If there were are thread name then we could extend a kernel segv message
and the /proc/<pid>/task/<tid>/... entries by a TName value like this:

cat /proc/492/task/495/status
Name:   test
TName:  RX-Data          <- this is the thread identification field
State:  S (sleeping)
Tgid:   492
Pid:    495
PPid:   1
.
.
.

This will it make much easier to determinate which thread id is
associated to a logical thread.

It would be possible do this without add a new entry to the task_struct.
Just use the comm entry which is available, because it has the same
value as the group_leader->comm entry.

The only thing to do is to replace all task_struct->comm access by
task_struct->group_leader->comm to have the old behavior. This can be
eventually encapsulated by a macro.

The task_struct->comm of a non group_leader would be than the name of
the thread.

The only drawback is that there are a lot of files which must be
modified. A quick
 find linux-2.6.30 -type f | xargs grep -l -e "->comm\>"  | wc -l
shows 215 files. But this can be handled.

So i propose a new system call to give a thread a name.

What do you think?

Greetings,
Stefani


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

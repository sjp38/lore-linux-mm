Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id C7DE16B0025
	for <linux-mm@kvack.org>; Tue, 17 May 2011 16:47:51 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p4HKOenJ012171
	for <linux-mm@kvack.org>; Tue, 17 May 2011 16:24:40 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4HKln2I077316
	for <linux-mm@kvack.org>; Tue, 17 May 2011 16:47:49 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4HGlbP1015783
	for <linux-mm@kvack.org>; Tue, 17 May 2011 13:47:38 -0300
From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 0/3] v5 Improve task->comm locking situation
Date: Tue, 17 May 2011 13:47:40 -0700
Message-Id: <1305665263-20933-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, Joe Perches <joe@perches.com>, Michal Nazarewicz <mina86@mina86.com>, Andy Whitcroft <apw@canonical.com>, Jiri Slaby <jirislaby@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

Ok. Here's v5. Hopefully this is getting close to something
that can be queued for 2.6.40.

Since my commit 4614a696bd1c3a9af3a08f0e5874830a85b889d4, the
current->comm value could be changed by other threads.

This changed the comm locking rules, which previously allowed for
unlocked current->comm access, since only the thread itself could
change its comm.

While this was brought up at the time, it was not considered
problematic, as the comm writing was done in such a way that
only null or incomplete comms could be read. However, recently
folks have made it clear they want to see this issue resolved.

So fair enough, as I opened this can of worms, I should work
to resolve it and this patchset is my initial attempt.

The proposed solution here is to introduce a new spinlock that
exclusively protects the comm value. We use it to serialize
access via get_task_comm() and set_task_comm(). Since some 
comm access is open-coded using the task lock, we preserve
the task locking in set_task_comm for now. Once all comm 
access is converted to using get_task_comm, we can clean that
up as well.

I've also introduced a printk %ptc accessor, which makes the
conversion to locked access simpler (as most uses are for printks)
as well as a checkpatch rule to try to catch any new current->comm
users from being introduced.

New in this version: Added a spin_lock_init in copy_process as
caught by Jiri. Also tweaked the regex as suggested by Joe.

Hopefully this will allow for a smooth transition, where we can
slowly fix up the unlocked current->comm access bit by bit,
reducing the race window with each patch, while not making the
situation any worse then it was yesterday.

Thanks for the comments and feedback so far. 
Any additional comments/feedback would still be appreciated.

thanks
-john


CC: Joe Perches <joe@perches.com>
CC: Michal Nazarewicz <mina86@mina86.com>
CC: Andy Whitcroft <apw@canonical.com>
CC: Jiri Slaby <jirislaby@gmail.com>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: David Rientjes <rientjes@google.com>
CC: Dave Hansen <dave@linux.vnet.ibm.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: linux-mm@kvack.org

John Stultz (3):
  comm: Introduce comm_lock spinlock to protect task->comm access
  printk: Add %ptc to safely print a task's comm
  checkpatch.pl: Add check for task comm references

 fs/exec.c                 |   19 ++++++++++++++++---
 include/linux/init_task.h |    1 +
 include/linux/sched.h     |    5 ++---
 kernel/fork.c             |    1 +
 lib/vsprintf.c            |   24 ++++++++++++++++++++++++
 scripts/checkpatch.pl     |    7 +++++++
 6 files changed, 51 insertions(+), 6 deletions(-)

-- 
1.7.3.2.146.gca209

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

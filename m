Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A8D9890011A
	for <linux-mm@kvack.org>; Mon, 16 May 2011 17:19:27 -0400 (EDT)
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e38.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p4GLBKOf019924
	for <linux-mm@kvack.org>; Mon, 16 May 2011 15:11:20 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4GLJLw5081046
	for <linux-mm@kvack.org>; Mon, 16 May 2011 15:19:21 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4GFJKmT027899
	for <linux-mm@kvack.org>; Mon, 16 May 2011 09:19:20 -0600
From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 0/3] v4 Improve task->comm locking situation
Date: Mon, 16 May 2011 14:19:14 -0700
Message-Id: <1305580757-13175-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, Ted Ts'o <tytso@mit.edu>, Michal Nazarewicz <mina86@mina86.com>, Jiri Slaby <jirislaby@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

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

New in this version: Improved checkpatch regex from Jiri Slaby and
Michal Nazarewicz. Also replaced the seqlock with a spinlock to
address the possible starvation case brought up by KOSAKI Motohiro.

Hopefully this will allow for a smooth transition, where we can
slowly fix up the unlocked current->comm access bit by bit,
reducing the race window with each patch, while not making the
situation any worse then it was yesterday.

Thanks for the comments and feedback so far. 
Any additional comments/feedback would still be appreciated.

thanks
-john


CC: Ted Ts'o <tytso@mit.edu>
CC: Michal Nazarewicz <mina86@mina86.com>
CC: Jiri Slaby <jirislaby@gmail.com>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: David Rientjes <rientjes@google.com>
CC: Dave Hansen <dave@linux.vnet.ibm.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: linux-mm@kvack.org

John Stultz (3):
  comm: Introduce comm_lock seqlock to protect task->comm access
  printk: Add %ptc to safely print a task's comm
  checkpatch.pl: Add check for task comm references

 fs/exec.c                 |   19 ++++++++++++++++---
 include/linux/init_task.h |    1 +
 include/linux/sched.h     |    5 ++---
 lib/vsprintf.c            |   24 ++++++++++++++++++++++++
 scripts/checkpatch.pl     |    4 ++++
 5 files changed, 47 insertions(+), 6 deletions(-)

-- 
1.7.3.2.146.gca209

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

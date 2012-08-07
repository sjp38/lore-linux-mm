Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id C286D6B0044
	for <linux-mm@kvack.org>; Mon,  6 Aug 2012 20:44:50 -0400 (EDT)
Received: by bkcjc3 with SMTP id jc3so1661806bkc.14
        for <linux-mm@kvack.org>; Mon, 06 Aug 2012 17:44:49 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [RFC v3 0/7] generic hashtable implementation
Date: Tue,  7 Aug 2012 02:45:09 +0200
Message-Id: <1344300317-23189-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, mathieu.desnoyers@efficios.com, Sasha Levin <levinsasha928@gmail.com>

There are quite a few places in the kernel which implement a hashtable
in a very similar way. Instead of having implementations of a hashtable
all over the kernel, we can re-use the code.

This patch series introduces a very simple hashtable implementation, and
modifies three (random) modules to use it. I've limited it to 3 only
so that it would be easy to review and modify, and to show that even
at this number we already eliminate a big amount of duplicated code.

If this basic hashtable looks ok, future code will include:

 - RCU support
 - Self locking (list_bl?)
 - Converting more code to use the hashtable


Changes in V3:

 - Address review comments by Tejun Heo, Josh Triplett, Eric Beiderman,
   Mathieu Desnoyers, Eric Dumazet and Linus Torvalds.
 - Removed hash_get due to being too Gandalf.
 - Rewrote the user namespaces hash implementation.
 - Hashtable went back to being a simple array of buckets, but without any
   of the macro tricks to get the size automatically.
 - Optimize hasing if key is 32 bits long.

Changes in V2:

 - Address review comments by Tejun Heo, Josh Triplett and Eric Beiderman (Thanks all!).
 - Rebase on top of latest master.
 - Convert more places to use the hashtable. Hopefully it will trigger more reviews by
 touching more subsystems.


Sasha Levin (7):
  hashtable: introduce a small and naive hashtable
  user_ns: use new hashtable implementation
  mm,ksm: use new hashtable implementation
  workqueue: use new hashtable implementation
  mm/huge_memory: use new hashtable implementation
  tracepoint: use new hashtable implementation
  net,9p: use new hashtable implementation

 include/linux/hashtable.h |   82 +++++++++++++++++++++++++++++++++++++++++
 kernel/tracepoint.c       |   26 +++++--------
 kernel/user.c             |   35 ++++++++----------
 kernel/workqueue.c        |   89 +++++++++------------------------------------
 mm/huge_memory.c          |   56 +++++++---------------------
 mm/ksm.c                  |   31 +++++++---------
 net/9p/error.c            |   21 +++++------
 7 files changed, 162 insertions(+), 178 deletions(-)
 create mode 100644 include/linux/hashtable.h

-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

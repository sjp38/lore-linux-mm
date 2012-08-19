Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id A73FA6B005A
	for <linux-mm@kvack.org>; Sat, 18 Aug 2012 20:52:06 -0400 (EDT)
Received: by bkcjc3 with SMTP id jc3so2035235bkc.14
        for <linux-mm@kvack.org>; Sat, 18 Aug 2012 17:52:04 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH v2 00/16] generic hashtable implementation
Date: Sun, 19 Aug 2012 02:52:13 +0200
Message-Id: <1345337550-24304-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, mathieu.desnoyers@efficios.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com, Sasha Levin <levinsasha928@gmail.com>

There are quite a few places in the kernel which implement a hashtable
in a very similar way. Instead of having implementations of a hashtable
all over the kernel, we can re-use the code.

Since it looks like all the major issues we're addressed in the RFC phase
and no major issues were raised with this patch set, I'd be happy to see
this getting merged so that work could continue on different aspects of
the hashtable. Some interesting directions include:

 - Introducing a dynamic RCU hashtable such as the one Mathieu Desnoyers
 wrote about out in the userspace RCU.

 - Replacing the rest of the the kernel structures which use the same basec
 hashtable construct to use this new interface.

 - Same as above, but for non-obvious places (for example, I'm looking into
 using the hashtable to store KVM vcpus instead of the linked list being used
 there now - this should help performance with a large amount of vcpus).


Changes since v1:

 - Added missing hash_init in rds and lockd.
 - Addressed the userns comments by Eric Biederman.
 - Ran a small test to confirm hash_32 does a good job for low key
 values (1-10000), which showed it did - this resulted in no changes to the
 code.


Sasha Levin (16):
  hashtable: introduce a small and naive hashtable
  userns: use new hashtable implementation
  mm,ksm: use new hashtable implementation
  workqueue: use new hashtable implementation
  mm/huge_memory: use new hashtable implementation
  tracepoint: use new hashtable implementation
  net,9p: use new hashtable implementation
  block,elevator: use new hashtable implementation
  SUNRPC/cache: use new hashtable implementation
  dlm: use new hashtable implementation
  net,l2tp: use new hashtable implementation
  dm: use new hashtable implementation
  lockd: use new hashtable implementation
  net,rds: use new hashtable implementation
  openvswitch: use new hashtable implementation
  tracing output: use new hashtable implementation

 block/blk.h                                        |    2 +-
 block/elevator.c                                   |   23 +--
 drivers/md/dm-snap.c                               |   24 +--
 drivers/md/persistent-data/dm-block-manager.c      |    1 -
 .../persistent-data/dm-persistent-data-internal.h  |   19 --
 .../md/persistent-data/dm-transaction-manager.c    |   30 +--
 fs/dlm/lowcomms.c                                  |   47 +---
 fs/lockd/svcsubs.c                                 |   66 +++--
 include/linux/elevator.h                           |    5 +-
 include/linux/hashtable.h                          |  284 ++++++++++++++++++++
 kernel/trace/trace_output.c                        |   20 +-
 kernel/tracepoint.c                                |   27 +--
 kernel/user.c                                      |   33 +--
 kernel/workqueue.c                                 |   86 +-----
 mm/huge_memory.c                                   |   57 +---
 mm/ksm.c                                           |   33 +--
 net/9p/error.c                                     |   21 +-
 net/l2tp/l2tp_core.c                               |  134 ++++------
 net/l2tp/l2tp_core.h                               |    8 +-
 net/l2tp/l2tp_debugfs.c                            |   19 +-
 net/openvswitch/vport.c                            |   30 +--
 net/rds/bind.c                                     |   28 ++-
 net/rds/connection.c                               |  102 +++----
 net/sunrpc/cache.c                                 |   20 +-
 24 files changed, 591 insertions(+), 528 deletions(-)
 delete mode 100644 drivers/md/persistent-data/dm-persistent-data-internal.h
 create mode 100644 include/linux/hashtable.h

-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

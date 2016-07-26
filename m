Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 07BE26B0005
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 23:47:14 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id j124so235711439ith.1
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 20:47:14 -0700 (PDT)
Received: from cliff.cs.toronto.edu (cliff.cs.toronto.edu. [128.100.3.120])
        by mx.google.com with ESMTPS id h189si22856344ioa.32.2016.07.25.20.47.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jul 2016 20:47:13 -0700 (PDT)
Message-Id: <cover.1469489884.git.gamvrosi@gmail.com>
From: George Amvrosiadis <gamvrosi@gmail.com>
Subject: [PATCH 0/3] new feature: monitoring page cache events
Date: Mon, 25 Jul 2016 23:47:11 -0400 (EDT)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: George Amvrosiadis <gamvrosi@gmail.com>

I'm attaching a patch set implementing a mechanism we call Duet, which allows
applications to monitor events at the page cache level: page additions,
removals, dirtying, and flushing. Using such events, applications can identify
and prioritize processing of cached data, thereby reducing their I/O footprint.

One user of these events are maintenance tasks that scan large amounts of data
(e.g., backup, defrag, scrubbing). Knowing what is currently cached allows them
to piggy-back on each other and other applications running in the system. I've
managed to run up to 3 such applications together (backup, scrubbing, defrag)
and have them finish their work with 1/3rd of the I/O by using Duet. In this
case, the task that traversed the data the fastest (scrubber) allowed the rest
of the tasks to piggyback on the data brought into the cache. I.e., a file that
was read to be backed up was also picked up by the scrubber and defrag process.

I've found adapting applications to be straight-forward. Although I don't
include examples in this patch set, I've adapted btrfs scrubbing, btrfs send
(backup), btrfs defrag, rsync, and f2fs garbage collection in a few hundred
lines of code each (basically just had to add an event handler and wire it up
to the task's processing loop). You can read more about this in our full paper:
http://dl.acm.org/citation.cfm?id=2815424. I'd be happy to generate subsequent
patch sets for individual tasks if there's interest in this one. We've also
used Duet to speed up Hadoop and Spark by taking into account cache residency
of HDFS blocks across the cluster, when scheduling tasks, by up to 54%
depending on overlap on the data processed:
https://www.usenix.org/conference/hotstorage16/workshop-program/presentation/deslauriers


Syscall interface (and how it works): Duet uses hooks into the page cache (see
the "mm: support for duet hooks" patch). These hooks inform Duet of page events,
which are stored in a hash table. Only events that are of interest to running
tasks are stored, and only one copy of each event is stored for all interested
tasks. To register for events, the following syscalls are used (see the
"mm/duet: syscall wiring" patch for prototypes):

- sys_duet_init(char *taskname, u32 regmask, char *path): returns an fd that
  watches for events under PATH (e.g. '/home') and are also described in the
  REGMASK (e.g. DUET_PAGE_ADDED | DUET_PAGE_REMOVED). TASKNAME is an optional,
  human-readable name for the task.

- sys_duet_bmap(u16 flags, struct duet_uuid_arg *uuid): Duet allows applications
  to track processed items on an internal bitmap (which improves performance by
  being used to filter unnecessary events). The specified UUID is what read()
  returns on the fd created with sys_duet_init(), and uniquely identifies a
  file. FLAGS allow the bitmap to be set, reset, or have its state checked.

- sys_duet_get_path(struct duet_uuid_arg *uuid, char *buf, int bufsize):
  Applications running with Duet do not understand UUIDs, but pathnames. This
  syscall traverses the dentry cache and returns the corresponding path in BUF.

- sys_duet_status(u16 flags, struct duet_status_args *arg): Currently, the Duet
  framework can be turned on/off manually. This allows the admin to specify the
  number of max applications that will be registered concurrently, which allows
  us to size the internal hash table nodes appropriately (and limit performance
  or memory overhead). The syscall is also used for debugging purposes. I think
  this functionality should probably be exposed through ioctl()s to a device,
  and I'm open to suggestions on how to improve the current implementation.

The framework itself (a bit less than 2300 LoC) is currently placed under
mm/duet and the code is included in the "mm/duet: framework code" patch.


Application interface: Applications interface with Duet through a user library,
which is available at https://github.com/gamvrosi/duet-tools. In the same repo,
I have included a dummy_task application which provides an example of how Duet
can be used.


Changelog: The patches are based on Linus' v4.7 tag, and touch on the following
parts of the kernel:

- mm/filemap.c and include/linux/page-flags.h: hooks in the page cache to track
  page events on page addition, removal, dirtying, and flushing.

- arch/x86/*, include/linux/syscalls.h, kernel/sys_ni.h: wiring the 4 syscalls

- mm/duet/*: framework code



George Amvrosiadis (3):
  mm: support for duet hooks
  mm/duet: syscall wiring
  mm/duet: framework code

 arch/x86/entry/syscalls/syscall_32.tbl |   4 +
 arch/x86/entry/syscalls/syscall_64.tbl |   4 +
 include/linux/duet.h                   |  43 +++
 include/linux/page-flags.h             |  53 +++
 include/linux/syscalls.h               |   8 +
 include/uapi/asm-generic/unistd.h      |  12 +-
 init/Kconfig                           |   2 +
 kernel/sys_ni.c                        |   6 +
 mm/Makefile                            |   1 +
 mm/duet/Kconfig                        |  31 ++
 mm/duet/Makefile                       |   7 +
 mm/duet/bittree.c                      | 537 ++++++++++++++++++++++++++++++
 mm/duet/common.h                       | 211 ++++++++++++
 mm/duet/debug.c                        |  98 ++++++
 mm/duet/hash.c                         | 315 ++++++++++++++++++
 mm/duet/hook.c                         |  81 +++++
 mm/duet/init.c                         | 172 ++++++++++
 mm/duet/path.c                         | 184 +++++++++++
 mm/duet/syscall.h                      |  61 ++++
 mm/duet/task.c                         | 584 +++++++++++++++++++++++++++++++++
 mm/filemap.c                           |  11 +
 21 files changed, 2424 insertions(+), 1 deletion(-)
 create mode 100644 include/linux/duet.h
 create mode 100644 mm/duet/Kconfig
 create mode 100644 mm/duet/Makefile
 create mode 100644 mm/duet/bittree.c
 create mode 100644 mm/duet/common.h
 create mode 100644 mm/duet/debug.c
 create mode 100644 mm/duet/hash.c
 create mode 100644 mm/duet/hook.c
 create mode 100644 mm/duet/init.c
 create mode 100644 mm/duet/path.c
 create mode 100644 mm/duet/syscall.h
 create mode 100644 mm/duet/task.c

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

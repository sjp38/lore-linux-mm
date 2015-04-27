Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id D30E66B006E
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 07:56:43 -0400 (EDT)
Received: by pdea3 with SMTP id a3so126212046pde.3
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 04:56:43 -0700 (PDT)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id w10si29585643pas.114.2015.04.27.04.56.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 27 Apr 2015 04:56:42 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NNG002YIRUE1J70@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 27 Apr 2015 12:56:38 +0100 (BST)
From: Beata Michalska <b.michalska@samsung.com>
Subject: [RFC v2 0/4] fs: Add generic file system event notifications
Date: Mon, 27 Apr 2015 13:51:40 +0200
Message-id: <1430135504-24334-1-git-send-email-b.michalska@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org
Cc: jack@suse.cz, tytso@mit.edu, adilger.kernel@dilger.ca, hughd@google.com, lczerner@redhat.com, hch@infradead.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com, kmpark@infradead.org

Hi All,

This series is a follow-up of the RFC patchset for generic filesystem
events interface [1]. As there have been some rather significant changes
to the synchronization method being used, more extensive testing (stress
testing) has been performed (thus the delay).

Changes from v1:
	- Improved synchronization: switched to RCU accompanied with
	  ref counting mechanism
	- Limiting scope of supported event types along with default
	  event codes
	- Slightly modified configuration (event types followed by arguments
	  where required)
	- Updated documentation
	- Unified naming for netlink attributes
	- Updated netlink message format to include dev minor:major numbers
	  despite the filesystem type
	- Switched to single cmd id for messages
	- Removed the per-config-entry ids

---
[1] https://lkml.org/lkml/2015/4/15/46
---


Beata Michalska (4):
  fs: Add generic file system event notifications
  ext4: Add helper function to mark group as corrupted
  ext4: Add support for generic FS events
  shmem: Add support for generic FS events

 Documentation/filesystems/events.txt |  231 ++++++++++
 fs/Makefile                          |    1 +
 fs/events/Makefile                   |    6 +
 fs/events/fs_event.c                 |  770 ++++++++++++++++++++++++++++++++++
 fs/events/fs_event.h                 |   25 ++
 fs/events/fs_event_netlink.c         |   99 +++++
 fs/ext4/balloc.c                     |   25 +-
 fs/ext4/ext4.h                       |   10 +
 fs/ext4/ialloc.c                     |    5 +-
 fs/ext4/inode.c                      |    2 +-
 fs/ext4/mballoc.c                    |   17 +-
 fs/ext4/resize.c                     |    1 +
 fs/ext4/super.c                      |   39 ++
 fs/namespace.c                       |    1 +
 include/linux/fs.h                   |    6 +-
 include/linux/fs_event.h             |   58 +++
 include/uapi/linux/fs_event.h        |   54 +++
 include/uapi/linux/genetlink.h       |    1 +
 mm/shmem.c                           |   33 +-
 net/netlink/genetlink.c              |    7 +-
 20 files changed, 1357 insertions(+), 34 deletions(-)
 create mode 100644 Documentation/filesystems/events.txt
 create mode 100644 fs/events/Makefile
 create mode 100644 fs/events/fs_event.c
 create mode 100644 fs/events/fs_event.h
 create mode 100644 fs/events/fs_event_netlink.c
 create mode 100644 include/linux/fs_event.h
 create mode 100644 include/uapi/linux/fs_event.h

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id E20FF6B006E
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 09:09:46 -0400 (EDT)
Received: by pdbnf5 with SMTP id nf5so14253877pdb.2
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 06:09:46 -0700 (PDT)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id ke5si1293944pab.238.2015.06.16.06.09.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 16 Jun 2015 06:09:45 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NQ100JJCGK5NJ80@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 16 Jun 2015 14:09:41 +0100 (BST)
From: Beata Michalska <b.michalska@samsung.com>
Subject: [RFC v3 0/4] fs: Add generic file system event notifications
Date: Tue, 16 Jun 2015 15:09:29 +0200
Message-id: <1434460173-18427-1-git-send-email-b.michalska@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org
Cc: greg@kroah.com, jack@suse.cz, tytso@mit.edu, adilger.kernel@dilger.ca, hughd@google.com, lczerner@redhat.com, hch@infradead.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com, kmpark@infradead.org

Hi All,

First of all, apologies for the delay: illness ruled out my plans
for having this out for a review as intended.

Anyway this is an updated version of the patchset for generic filesystem
events interface [1][2], hopefully handling issues raised during the previous
run.

Changes from v2:
	- Switched to kref for reference counting
	- Support for the events has been made optional (config option)
	- Use dynamically assigned id for multicast group instead of
	  using static one
	- Verify if there are any net listeners prior to sending the msg
	- Make the interface more namespace-aware (handling mount dropped
	  and showing the content of config file). As for the network
	  namespaces - as before only the init net namespace is being
	  supported.

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
[2] https://lkml.org/lkml/2015/4/27/244
---

Beata Michalska (4):
  fs: Add generic file system event notifications
  ext4: Add helper function to mark group as corrupted
  ext4: Add support for generic FS events
  shmem: Add support for generic FS events

 Documentation/filesystems/events.txt |  232 ++++++++++
 fs/Kconfig                           |    2 +
 fs/Makefile                          |    1 +
 fs/events/Kconfig                    |    7 +
 fs/events/Makefile                   |    5 +
 fs/events/fs_event.c                 |  809 ++++++++++++++++++++++++++++++++++
 fs/events/fs_event.h                 |   22 +
 fs/events/fs_event_netlink.c         |  104 +++++
 fs/ext4/balloc.c                     |   25 +-
 fs/ext4/ext4.h                       |   10 +
 fs/ext4/ialloc.c                     |    5 +-
 fs/ext4/inode.c                      |    2 +-
 fs/ext4/mballoc.c                    |   17 +-
 fs/ext4/resize.c                     |    1 +
 fs/ext4/super.c                      |   39 ++
 fs/namespace.c                       |    1 +
 include/linux/fs.h                   |    6 +-
 include/linux/fs_event.h             |   72 +++
 include/uapi/linux/Kbuild            |    1 +
 include/uapi/linux/fs_event.h        |   58 +++
 mm/shmem.c                           |   33 +-
 21 files changed, 1419 insertions(+), 33 deletions(-)
 create mode 100644 Documentation/filesystems/events.txt
 create mode 100644 fs/events/Kconfig
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

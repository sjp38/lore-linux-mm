Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 34E926B0005
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 07:23:16 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id y77so122064146qkb.2
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 04:23:16 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o188si5654179qkf.158.2016.06.22.04.23.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jun 2016 04:23:15 -0700 (PDT)
From: Brian Foster <bfoster@redhat.com>
Subject: [PATCH v8 0/2] improve sync efficiency with sb inode wb list
Date: Wed, 22 Jun 2016 07:23:11 -0400
Message-Id: <1466594593-6757-1-git-send-email-bfoster@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <dchinner@redhat.com>, Josef Bacik <jbacik@fb.com>, Jan Kara <jack@suse.cz>, Holger Hoffstatte <holger.hoffstaette@applied-asynchrony.com>

This is just a rebase to linus' latest master. I haven't heard any
feedback on this one so Jan suggested I send to a wider audience.

Brian

v8:
- Rebased to latest master.
- Added Holger's Tested-by.
v7: http://marc.info/?l=linux-fsdevel&m=145349651407631&w=2
- Updated patch 1/2 commit log description to reference performance
  impact.
v6: http://marc.info/?l=linux-fsdevel&m=145322635828644&w=2
- Use rcu locking instead of s_inode_list_lock spinlock in
  wait_sb_inodes().
- Refactor wait_sb_inodes() to keep inode on wb list.
- Drop remaining, unnecessary lazy list removal bits and relocate inode
  list check to clear_inode().
- Fix up some comments, etc.
v5: http://marc.info/?l=linux-fsdevel&m=145262374402798&w=2
- Converted from per-bdi list to per-sb list. Also marked as RFC and
  dropped testing/review tags.
- Updated to use new irq-safe lock for wb list.
- Dropped lazy list removal. Inodes are removed when the mapping is
  cleared of the writeback tag.
- Tweaked wait_sb_inodes() to remove deferred iput(), other cleanups.
- Added wb list tracepoint patch.
v4: http://marc.info/?l=linux-fsdevel&m=143511628828000&w=2

Brian Foster (1):
  wb: inode writeback list tracking tracepoints

Dave Chinner (1):
  sb: add a new writeback list for sync

 fs/fs-writeback.c                | 111 ++++++++++++++++++++++++++++++---------
 fs/inode.c                       |   2 +
 fs/super.c                       |   2 +
 include/linux/fs.h               |   4 ++
 include/linux/writeback.h        |   3 ++
 include/trace/events/writeback.h |  22 ++++++--
 mm/page-writeback.c              |  18 +++++++
 7 files changed, 133 insertions(+), 29 deletions(-)

-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

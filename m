Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id BB5405F0006
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 14:17:42 -0400 (EDT)
From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Mon,  1 Jun 2009 14:50:39 -0700
Message-Id: <1243893048-17031-14-git-send-email-ebiederm@xmission.com>
In-Reply-To: <m1oct739xu.fsf@fess.ebiederm.org>
References: <m1oct739xu.fsf@fess.ebiederm.org>
Subject: [PATCH 14/23] vfs: Teach flock to use file_hotplug_lock
Sender: owner-linux-mm@kvack.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, "Eric W. Biederman" <ebiederm@maxwell.arastra.com>, "Eric W. Biederman" <ebiederm@aristanetworks.com>
List-ID: <linux-mm.kvack.org>

From: Eric W. Biederman <ebiederm@maxwell.arastra.com>

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 fs/locks.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index ec3deea..f74794e 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1584,9 +1584,13 @@ SYSCALL_DEFINE2(flock, unsigned int, fd, unsigned int, cmd)
 	    !(filp->f_mode & (FMODE_READ|FMODE_WRITE)))
 		goto out_putf;
 
+	error = -EIO;
+	if (!file_hotplug_read_trylock(filp))
+		goto out_putf;
+
 	error = flock_make_lock(filp, &lock, cmd);
 	if (error)
-		goto out_putf;
+		goto out_unlock;
 	if (can_sleep)
 		lock->fl_flags |= FL_SLEEP;
 
@@ -1604,6 +1608,8 @@ SYSCALL_DEFINE2(flock, unsigned int, fd, unsigned int, cmd)
  out_free:
 	locks_free_lock(lock);
 
+ out_unlock:
+	file_hotplug_read_unlock(filp);
  out_putf:
 	fput(filp);
  out:
-- 
1.6.3.1.54.g99dd.dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

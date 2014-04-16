Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id 70A096B007B
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 00:19:52 -0400 (EDT)
Received: by mail-ee0-f48.google.com with SMTP id b57so8238661eek.35
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 21:19:51 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u5si28115538een.263.2014.04.15.21.19.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 15 Apr 2014 21:19:51 -0700 (PDT)
From: NeilBrown <neilb@suse.de>
Date: Wed, 16 Apr 2014 14:03:37 +1000
Subject: [PATCH 17/19] VFS: set PF_FSTRANS while namespace_sem is held.
Message-ID: <20140416040337.10604.86740.stgit@notabene.brown>
In-Reply-To: <20140416033623.10604.69237.stgit@notabene.brown>
References: <20140416033623.10604.69237.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: xfs@oss.sgi.com

namespace_sem can be taken while various i_mutex locks are held, so we
need to avoid reclaim from blocking on an FS (particularly loop-back
NFS).

A memory allocation happens under namespace_sem at least in:

[<ffffffff8119d16f>] kmem_cache_alloc+0x4f/0x290
[<ffffffff811c2fff>] alloc_vfsmnt+0x1f/0x1d0
[<ffffffff811c339a>] clone_mnt+0x2a/0x310
[<ffffffff811c57e3>] copy_tree+0x53/0x380
[<ffffffff811c6aef>] copy_mnt_ns+0x7f/0x280
[<ffffffff810c16fc>] create_new_namespaces+0x5c/0x190
[<ffffffff810c1ab9>] unshare_nsproxy_namespaces+0x59/0x90

So set PF_FSTRANS in namespace_lock() and restore in
namespace_unlock().

Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/namespace.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/namespace.c b/fs/namespace.c
index 2ffc5a2905d4..83dcd5083dbb 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -63,6 +63,7 @@ static struct hlist_head *mount_hashtable __read_mostly;
 static struct hlist_head *mountpoint_hashtable __read_mostly;
 static struct kmem_cache *mnt_cache __read_mostly;
 static DECLARE_RWSEM(namespace_sem);
+static unsigned long namespace_sem_pflags;
 
 /* /sys/fs */
 struct kobject *fs_kobj;
@@ -1196,6 +1197,8 @@ static void namespace_unlock(void)
 	struct mount *mnt;
 	struct hlist_head head = unmounted;
 
+	current_restore_flags_nested(&namespace_sem_pflags, PF_FSTRANS);
+
 	if (likely(hlist_empty(&head))) {
 		up_write(&namespace_sem);
 		return;
@@ -1220,6 +1223,7 @@ static void namespace_unlock(void)
 static inline void namespace_lock(void)
 {
 	down_write(&namespace_sem);
+	current_set_flags_nested(&namespace_sem_pflags, PF_FSTRANS);
 }
 
 /*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

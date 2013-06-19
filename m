Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 723006B005A
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 21:19:06 -0400 (EDT)
From: Davidlohr Bueso <davidlohr.bueso@hp.com>
Subject: [PATCH 11/11] ipc: document general ipc locking scheme
Date: Tue, 18 Jun 2013 18:18:36 -0700
Message-Id: <1371604716-3439-12-git-send-email-davidlohr.bueso@hp.com>
In-Reply-To: <1371604716-3439-1-git-send-email-davidlohr.bueso@hp.com>
References: <1371604716-3439-1-git-send-email-davidlohr.bueso@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Davidlohr Bueso <davidlohr.bueso@hp.com>

As suggested by Andrew, add a generic initial locking scheme
used throughout all sysv ipc mechanisms. Documenting the ids
rwsem, how rcu can be enough to do the initial checks and when
to actually acquire the kern_ipc_perm.lock spinlock.

I found that adding it to util.c was generic enough.

Signed-off-by: Davidlohr Bueso <davidlohr.bueso@hp.com>
---
 ipc/util.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/ipc/util.c b/ipc/util.c
index 8f12fe3..639bf38 100644
--- a/ipc/util.c
+++ b/ipc/util.c
@@ -15,6 +15,14 @@
  * Jun 2006 - namespaces ssupport
  *            OpenVZ, SWsoft Inc.
  *            Pavel Emelianov <xemul@openvz.org>
+ *
+ * General sysv ipc locking scheme:
+ *  when doing ipc id lookups, take the ids->rwsem
+ *      rcu_read_lock()
+ *          obtain the ipc object (kern_ipc_perm)
+ *          perform security, capabilities, auditing and permission checks, etc.
+ *          acquire the ipc lock (kern_ipc_perm.lock) throught ipc_lock_object()
+ *             perform data updates (ie: SET, RMID, LOCK/UNLOCK commands)
  */
 
 #include <linux/mm.h>
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

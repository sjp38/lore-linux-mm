Date: Wed, 27 Jul 2005 18:14:24 -0400
From: Martin Hicks <mort@sgi.com>
Subject: [PATCH] VM: add capabilites check to set_zone_reclaim
Message-ID: <20050727221424.GW9492@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Andrew,

Here's a patch to add a capability check to sys_set_zone_reclaim().
This syscall is not something that should be available to a user.

Against a recent .git tree.

mh

-- 
Martin Hicks   ||   Silicon Graphics Inc.   ||   mort@sgi.com


Add capabilities check on the set_zone_reclaim() syscall.

Signed-off-by:  Martin Hicks <mort@sgi.com>

---
commit 3297435cafea4822b23d74b051f046694b40beb8
tree 6b64393e98968719818b05b2562714c6f44db531
parent e17fbedb41baa72f5e24ee02f4f43f44e2d3114d
author Martin Hicks,,,,,,,engr <mort@tomahawk.engr.sgi.com> Wed, 27 Jul 2005 09:14:48 -0700
committer Martin Hicks,,,,,,,engr <mort@tomahawk.engr.sgi.com> Wed, 27 Jul 2005 09:14:48 -0700

 include/linux/capability.h |    1 +
 mm/vmscan.c                |    3 +++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/include/linux/capability.h b/include/linux/capability.h
--- a/include/linux/capability.h
+++ b/include/linux/capability.h
@@ -233,6 +233,7 @@ typedef __u32 kernel_cap_t;
 /* Allow enabling/disabling tagged queuing on SCSI controllers and sending
    arbitrary SCSI commands */
 /* Allow setting encryption key on loopback filesystem */
+/* Allow setting zone reclaim policy */
 
 #define CAP_SYS_ADMIN        21
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1376,6 +1376,9 @@ asmlinkage long sys_set_zone_reclaim(uns
 	struct zone *z;
 	int i;
 
+        if (!capable(CAP_SYS_ADMIN))
+                return -EACCES;
+
 	if (node >= MAX_NUMNODES || !node_online(node))
 		return -EINVAL;
 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

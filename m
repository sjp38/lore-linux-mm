Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 3D6B16B004A
	for <linux-mm@kvack.org>; Tue,  6 Mar 2012 21:26:15 -0500 (EST)
Received: by yenm8 with SMTP id m8so3303889yen.14
        for <linux-mm@kvack.org>; Tue, 06 Mar 2012 18:26:14 -0800 (PST)
Date: Tue, 6 Mar 2012 18:26:11 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, hugetlb: add thread name and pid to SHM_HUGETLB mlock
 rlimit warning
Message-ID: <alpine.DEB.2.00.1203061825070.9015@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Jones <davej@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Add the thread name and pid of the application that is allocating shm
segments with MAP_HUGETLB without being a part of
/proc/sys/vm/hugetlb_shm_group or having CAP_IPC_LOCK.

This identifies the application so it may be fixed by avoiding using the
deprecated exception (see Documentation/feature-removal-schedule.txt).

Signed-off-by: David Rientjes <rientjes@google.com>
---
 fs/hugetlbfs/inode.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -946,7 +946,11 @@ struct file *hugetlb_file_setup(const char *name, size_t size,
 	if (creat_flags == HUGETLB_SHMFS_INODE && !can_do_hugetlb_shm()) {
 		*user = current_user();
 		if (user_shm_lock(size, *user)) {
-			printk_once(KERN_WARNING "Using mlock ulimits for SHM_HUGETLB is deprecated\n");
+			task_lock(current);
+			printk_once(KERN_WARNING
+				"%s (%d): Using mlock ulimits for SHM_HUGETLB is deprecated\n",
+				current->comm, current->pid);
+			task_unlock(current);
 		} else {
 			*user = NULL;
 			return ERR_PTR(-EPERM);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

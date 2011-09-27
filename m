Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E13449000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 13:55:47 -0400 (EDT)
Received: by bkbzs2 with SMTP id zs2so9567546bkb.14
        for <linux-mm@kvack.org>; Tue, 27 Sep 2011 10:55:44 -0700 (PDT)
Date: Tue, 27 Sep 2011 21:54:53 +0400
From: Vasiliy Kulikov <segoon@openwall.com>
Subject: [PATCH 1/2] mm: restrict access to slab files under procfs and
 sysfs
Message-ID: <20110927175453.GA3393@albatros>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-hardening@lists.openwall.com, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>
Cc: linux-mm@kvack.org, Kees Cook <kees@ubuntu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Valdis.Kletnieks@vt.edu, Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, Alan Cox <alan@linux.intel.com>, linux-kernel@vger.kernel.org

Historically /proc/slabinfo and files under /sys/kernel/slab/* have
world read permissions and are accessible to the world.  slabinfo
contains rather private information related both to the kernel and
userspace tasks.  Depending on the situation, it might reveal either
private information per se or information useful to make another
targeted attack.  Some examples of what can be learned by
reading/watching for /proc/slabinfo entries:

1) dentry (and different *inode*) number might reveal other processes fs
activity.  The number of dentry "active objects" doesn't strictly show
file count opened/touched by a process, however, there is a good
correlation between them.  The patch "proc: force dcache drop on
unauthorized access" relies on the privacy of dentry count.

2) different inode entries might reveal the same information as (1), but
these are more fine granted counters.  If a filesystem is mounted in a
private mount point (or even a private namespace) and fs type differs from
other mounted fs types, fs activity in this mount point/namespace is
revealed.  If there is a single ecryptfs mount point, the whole fs
activity of a single user is revealed.  Number of files in ecryptfs
mount point is a private information per se.

3) fuse_* reveals number of files / fs activity of a user in a user
private mount point.  It is approx. the same severity as ecryptfs
infoleak in (2).

4) sysfs_dir_cache similar to (2) reveals devices' addition/removal,
which can be otherwise hidden by "chmod 0700 /sys/".  With 0444 slabinfo
the precise number of sysfs files is known to the world.

5) buffer_head might reveal some kernel activity.  With other
information leaks an attacker might identify what specific kernel
routines generate buffer_head activity.

6) *kmalloc* infoleaks are very situational.  Attacker should watch for
the specific kmalloc size entry and filter the noise related to the unrelated
kernel activity.  If an attacker has relatively silent victim system, he
might get rather precise counters.

Additional information sources might significantly increase the slabinfo
infoleak benefits.  E.g. if an attacker knows that the processes
activity on the system is very low (only core daemons like syslog and
cron), he may run setxid binaries / trigger local daemon activity /
trigger network services activity / await sporadic cron jobs activity
/ etc. and get rather precise counters for fs and network activity of
these privileged tasks, which is unknown otherwise.


Also hiding slabinfo and /sys/kernel/slab/* is a one step to complicate
exploitation of kernel heap overflows (and possibly, other bugs).  The
related discussion:

http://thread.gmane.org/gmane.linux.kernel/1108378


To keep compatibility with old permission model where non-root
monitoring daemon could watch for kernel memleaks though slabinfo one
should do:

    groupadd slabinfo
    usermod -a -G slabinfo $MONITOR_USER

And add the following commands to init scripts (to mountall.conf in
Ubuntu's upstart case):

    chmod g+r /proc/slabinfo /sys/kernel/slab/*/*
    chgrp slabinfo /proc/slabinfo /sys/kernel/slab/*/*

Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>
Reviewed-by: Kees Cook <kees@ubuntu.com>
Reviewed-by: Dave Hansen <dave@linux.vnet.ibm.com>
CC: Christoph Lameter <cl@gentwo.org>
CC: Pekka Enberg <penberg@cs.helsinki.fi>
CC: Valdis.Kletnieks@vt.edu
CC: Linus Torvalds <torvalds@linux-foundation.org>
CC: David Rientjes <rientjes@google.com>
CC: Alan Cox <alan@linux.intel.com>
---
 mm/slab.c |    2 +-
 mm/slub.c |    7 ++++---
 2 files changed, 5 insertions(+), 4 deletions(-)

--
diff --git a/mm/slab.c b/mm/slab.c
index 6d90a09..10a0052 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4584,7 +4584,7 @@ static const struct file_operations proc_slabstats_operations = {
 
 static int __init slab_proc_init(void)
 {
-	proc_create("slabinfo",S_IWUSR|S_IRUGO,NULL,&proc_slabinfo_operations);
+	proc_create("slabinfo",S_IWUSR|S_IRUSR,NULL,&proc_slabinfo_operations);
 #ifdef CONFIG_DEBUG_SLAB_LEAK
 	proc_create("slab_allocators", 0, NULL, &proc_slabstats_operations);
 #endif
diff --git a/mm/slub.c b/mm/slub.c
index 9f662d7..527a66e 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4412,11 +4412,12 @@ struct slab_attribute {
 };
 
 #define SLAB_ATTR_RO(_name) \
-	static struct slab_attribute _name##_attr = __ATTR_RO(_name)
+	static struct slab_attribute _name##_attr = \
+	__ATTR(_name, 0400, _name##_show, NULL)
 
 #define SLAB_ATTR(_name) \
 	static struct slab_attribute _name##_attr =  \
-	__ATTR(_name, 0644, _name##_show, _name##_store)
+	__ATTR(_name, 0600, _name##_show, _name##_store)
 
 static ssize_t slab_size_show(struct kmem_cache *s, char *buf)
 {
@@ -5257,7 +5258,7 @@ static const struct file_operations proc_slabinfo_operations = {
 
 static int __init slab_proc_init(void)
 {
-	proc_create("slabinfo", S_IRUGO, NULL, &proc_slabinfo_operations);
+	proc_create("slabinfo", S_IRUSR, NULL, &proc_slabinfo_operations);
 	return 0;
 }
 module_init(slab_proc_init);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

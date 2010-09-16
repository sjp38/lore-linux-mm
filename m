Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 00D526B0088
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 12:50:48 -0400 (EDT)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e2.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o8GGa003017464
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 12:36:00 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o8GGom3P118140
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 12:50:48 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o8GGomRc031926
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 12:50:48 -0400
Subject: [RFCv2][PATCH] add some drop_caches documentation and info messsge
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Thu, 16 Sep 2010 09:50:47 -0700
Message-Id: <20100916165047.DAD42998@kernel.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, lnxninja@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, kosaki.motohiro@jp.fujitsu.com, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>


This version tones down the BUG_ON().  I also noticed that the
documentation fails to mention that more than just the inode
and dentry slabs are shrunk.

--

There is plenty of anecdotal evidence and a load of blog posts
suggesting that using "drop_caches" periodically keeps your system
running in "tip top shape".  Perhaps adding some kernel
documentation will increase the amount of accurate data on its use.

If we are not shrinking caches effectively, then we have real bugs.
Using drop_caches will simply mask the bugs and make them harder
to find, but certainly does not fix them, nor is it an appropriate
"workaround" to limit the size of the caches.

It's a great debugging tool, and is really handy for doing things
like repeatable benchmark runs.  So, add a bit more documentation
about it, and add a little KERN_NOTICE.  It should help developers
who are chasing down reclaim-related bugs.

Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---

 linux-2.6.git-dave/Documentation/sysctl/vm.txt |   33 ++++++++++++++++++++-----
 linux-2.6.git-dave/fs/drop_caches.c            |    2 +
 2 files changed, 29 insertions(+), 6 deletions(-)

diff -puN Documentation/sysctl/vm.txt~update-drop_caches-documentation Documentation/sysctl/vm.txt
--- linux-2.6.git/Documentation/sysctl/vm.txt~update-drop_caches-documentation	2010-09-16 09:43:52.000000000 -0700
+++ linux-2.6.git-dave/Documentation/sysctl/vm.txt	2010-09-16 09:43:52.000000000 -0700
@@ -135,18 +135,39 @@ Setting this to zero disables periodic w
 
 drop_caches
 
-Writing to this will cause the kernel to drop clean caches, dentries and
-inodes from memory, causing that memory to become free.
+Writing to this will cause the kernel to drop clean caches, as well as
+reclaimable slab objects like dentries and inodes.  Once dropped, their
+memory becomes free.
 
 To free pagecache:
 	echo 1 > /proc/sys/vm/drop_caches
-To free dentries and inodes:
+To free reclaimable slab objects (includes dentries and inodes):
 	echo 2 > /proc/sys/vm/drop_caches
-To free pagecache, dentries and inodes:
+To free slab objects and pagecache:
 	echo 3 > /proc/sys/vm/drop_caches
 
-As this is a non-destructive operation and dirty objects are not freeable, the
-user should run `sync' first.
+This is a non-destructive operation and will not free any dirty objects.
+To increase the number of objects freed by this operation, the user may run
+`sync' prior to writing to /proc/sys/vm/drop_caches.  This will minimize the
+number of dirty objects on the system and create more candidates to be
+dropped.
+
+This file is not a means to control the growth of the various kernel caches
+(inodes, dentries, pagecache, etc...)  These objects are automatically
+reclaimed by the kernel when memory is needed elsewhere on the system.
+
+Use of this file can cause performance problems.  Since it discards cached
+objects, it may cost a significant amount of I/O and CPU to recreate the
+dropped objects, especially if they were under heavy use.  Because of this,
+use outside of a testing or debugging environment is not recommended.
+
+You may see informational messages in your kernel log when this file is
+used:
+
+	cat (1234): dropped kernel caches: 3
+
+These are informational only.  They do not mean that anything is wrong
+with your system.
 
 ==============================================================
 
diff -puN fs/drop_caches.c~update-drop_caches-documentation fs/drop_caches.c
--- linux-2.6.git/fs/drop_caches.c~update-drop_caches-documentation	2010-09-16 09:43:52.000000000 -0700
+++ linux-2.6.git-dave/fs/drop_caches.c	2010-09-16 09:43:52.000000000 -0700
@@ -47,6 +47,8 @@ int drop_caches_sysctl_handler(ctl_table
 {
 	proc_dointvec_minmax(table, write, buffer, length, ppos);
 	if (write) {
+		printk(KERN_NOTICE "%s (%d): dropped kernel caches: %d\n",
+			current->comm, task_pid_nr(current), sysctl_drop_caches);
 		if (sysctl_drop_caches & 1)
 			iterate_supers(drop_pagecache_sb, NULL);
 		if (sysctl_drop_caches & 2)
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 45E096B0047
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 19:47:17 -0400 (EDT)
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e38.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o8ENddd6027329
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 17:39:39 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o8ENlFNW162940
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 17:47:15 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o8ENlFmT032738
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 17:47:15 -0600
Subject: [RFC][PATCH] update /proc/sys/vm/drop_caches documentation
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Tue, 14 Sep 2010 16:47:14 -0700
Message-Id: <20100914234714.8AF506EA@kernel.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, lnxninja@linux.vnet.ibm.com, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>


There seems to be an epidemic spreading around.  People get the idea
in their heads that the kernel caches are evil.  They eat too much
memory, and there's no way to set a size limit on them!  Stupid
kernel!

There is plenty of anecdotal evidence and a load of blog posts
suggesting that using "drop_caches" periodically keeps your system
running in "tip top shape".  I do not think that is true.

If we are not shrinking caches effectively, then we have real bugs.
Using drop_caches will simply mask the bugs and make them harder
to find, but certainly does not fix them, nor is it an appropriate
"workaround" to limit the size of the caches.

It's a great debugging tool, and is really handy for doing things
like repeatable benchmark runs.  So, add a bit more documentation
about it, and add a WARN_ONCE().  Maybe the warning will scare
some sense into people.


Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---

 linux-2.6.git-dave/Documentation/sysctl/vm.txt |   14 ++++++++++++--
 linux-2.6.git-dave/fs/drop_caches.c            |    2 ++
 2 files changed, 14 insertions(+), 2 deletions(-)

diff -puN Documentation/sysctl/vm.txt~update-drop_caches-documentation Documentation/sysctl/vm.txt
--- linux-2.6.git/Documentation/sysctl/vm.txt~update-drop_caches-documentation	2010-09-14 15:30:19.000000000 -0700
+++ linux-2.6.git-dave/Documentation/sysctl/vm.txt	2010-09-14 16:40:58.000000000 -0700
@@ -145,8 +145,18 @@ To free dentries and inodes:
 To free pagecache, dentries and inodes:
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
+Outside of a testing or debugging environment, use of
+/proc/sys/vm/drop_caches is not recommended.
 
 ==============================================================
 
diff -puN fs/drop_caches.c~update-drop_caches-documentation fs/drop_caches.c
--- linux-2.6.git/fs/drop_caches.c~update-drop_caches-documentation	2010-09-14 15:44:29.000000000 -0700
+++ linux-2.6.git-dave/fs/drop_caches.c	2010-09-14 15:58:31.000000000 -0700
@@ -47,6 +47,8 @@ int drop_caches_sysctl_handler(ctl_table
 {
 	proc_dointvec_minmax(table, write, buffer, length, ppos);
 	if (write) {
+		WARN_ONCE(1, "kernel caches forcefully dropped, "
+			     "see Documentation/sysctl/vm.txt\n");
 		if (sysctl_drop_caches & 1)
 			iterate_supers(drop_pagecache_sb, NULL);
 		if (sysctl_drop_caches & 2)
diff -puN include/linux/kernel.h~update-drop_caches-documentation include/linux/kernel.h
diff -puN drivers/pci/intel-iommu.c~update-drop_caches-documentation drivers/pci/intel-iommu.c
diff -puN drivers/pci/dmar.c~update-drop_caches-documentation drivers/pci/dmar.c
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

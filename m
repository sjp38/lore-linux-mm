Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l56GVb6R025145
	for <linux-mm@kvack.org>; Wed, 6 Jun 2007 12:31:37 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l56GQEji256376
	for <linux-mm@kvack.org>; Wed, 6 Jun 2007 10:31:36 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l56G6GVw002704
	for <linux-mm@kvack.org>; Wed, 6 Jun 2007 10:06:16 -0600
Subject: [RFC][PATCH] /proc/pid/maps doesn't match "ipcs -m" shmid
From: Badari Pulavarty <pbadari@us.ibm.com>
Content-Type: text/plain
Date: Wed, 06 Jun 2007 09:07:24 -0700
Message-Id: <1181146045.9503.67.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi Eric,

Your recent cleanup to shm code, namely

[PATCH] shm: make sysv ipc shared memory use stacked files

took away one of the debugging feature for shm segments.
Originally, shmid were forced to be the inode numbers and
they show up in /proc/pid/maps for the process which mapped
this shared memory segments (vma listing). That way, its easy
to find out who all mapped this shared memory segment. Your
patchset, took away the inode# setting. So, we can't easily
match the shmem segments to /proc/pid/maps easily. (It was
really useful in tracking down a customer problem recently). 
Is this done deliberately ? Anything wrong in setting this back ?

Comments ?

Thanks,
Badari

Without patch:
--------------

# ipcs -m

------ Shared Memory Segments --------
key        shmid      owner      perms      bytes      nattch     status
0x00000000 884737     db2inst1  767        33554432   13

# grep 884737 /proc/*/maps
#

With patch:
-----------

# ipcs -m

------ Shared Memory Segments --------
key        shmid      owner      perms      bytes      nattch     status
0x00000000 884737     db2inst1  767        33554432   13

# grep 884737 /proc/*/maps
/proc/11110/maps:40006724000-40008724000 rw-s 00000000 00:08 884737 /SYSV00000000 (deleted)
/proc/11111/maps:40006724000-40008724000 rw-s 00000000 00:08 884737 /SYSV00000000 (deleted)
/proc/11112/maps:40006724000-40008724000 rw-s 00000000 00:08 884737 /SYSV00000000 (deleted)
/proc/11113/maps:40006724000-40008724000 rw-s 00000000 00:08 884737 /SYSV00000000 (deleted)
/proc/11114/maps:40006724000-40008724000 rw-s 00000000 00:08 884737 /SYSV00000000 (deleted)
/proc/11115/maps:40006724000-40008724000 rw-s 00000000 00:08 884737 /SYSV00000000 (deleted)
/proc/11116/maps:40006724000-40008724000 rw-s 00000000 00:08 884737 /SYSV00000000 (deleted)
/proc/11117/maps:40006724000-40008724000 rw-s 00000000 00:08 884737 /SYSV00000000 (deleted)
/proc/11118/maps:40006724000-40008724000 rw-s 00000000 00:08 884737 /SYSV00000000 (deleted)
/proc/11121/maps:40006724000-40008724000 rw-s 00000000 00:08 884737 /SYSV00000000 (deleted)
/proc/11122/maps:40006724000-40008724000 rw-s 00000000 00:08 884737 /SYSV00000000 (deleted)
/proc/11124/maps:4000389c000-4000589c000 rw-s 00000000 00:08 884737 /SYSV00000000 (deleted)
/proc/11575/maps:40006724000-40008724000 rw-s 00000000 00:08 884737 /SYSV00000000 (deleted)



Here is the patch.

"ino#" in /proc/pid/maps used to match "ipcs -m" output for shared 
memory (shmid). It was useful in debugging, but its changed recently. 
This patch sets inode number to shared memory id to match /proc/pid/maps.

Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com>

Index: linux-2.6.22-rc4/ipc/shm.c
===================================================================
--- linux-2.6.22-rc4.orig/ipc/shm.c	2007-06-04 17:57:25.000000000 -0700
+++ linux-2.6.22-rc4/ipc/shm.c	2007-06-06 08:23:57.000000000 -0700
@@ -397,6 +397,7 @@ static int newseg (struct ipc_namespace 
 	shp->shm_nattch = 0;
 	shp->id = shm_buildid(ns, id, shp->shm_perm.seq);
 	shp->shm_file = file;
+	file->f_dentry->d_inode->i_ino = shp->id;
 
 	ns->shm_tot += numpages;
 	shm_unlock(shp);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

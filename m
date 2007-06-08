Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l58MU80O008847
	for <linux-mm@kvack.org>; Fri, 8 Jun 2007 18:30:08 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l58MU7Fg207206
	for <linux-mm@kvack.org>; Fri, 8 Jun 2007 16:30:07 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l58MU7N6025227
	for <linux-mm@kvack.org>; Fri, 8 Jun 2007 16:30:07 -0600
Subject: [PATCH] Restore shmid as inode# to fix /proc/pid/maps ABI breakage
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <787b0d920706072351s6917ad77oe0bf381a5d5817d0@mail.gmail.com>
References: <787b0d920706062027s5a8fd35q752f8da5d446afc@mail.gmail.com>
	 <20070606204432.b670a7b1.akpm@linux-foundation.org>
	 <787b0d920706062153u7ad64179p1c4f3f663c3882f@mail.gmail.com>
	 <20070607162004.GA27802@vino.hallyn.com>
	 <m1ir9zrtwe.fsf@ebiederm.dsl.xmission.com>
	 <787b0d920706072141s5a34ecb3n97007ad857ba4dc9@mail.gmail.com>
	 <m1ejknrnva.fsf@ebiederm.dsl.xmission.com>
	 <787b0d920706072351s6917ad77oe0bf381a5d5817d0@mail.gmail.com>
Content-Type: text/plain
Date: Fri, 08 Jun 2007 15:31:14 -0700
Message-Id: <1181341874.14441.3.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Albert Cahalan <acahalan@gmail.com>, "Eric W. Biederman" <ebiederm@xmission.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Andrew,

Can you include this in -mm ?

Thanks,
Badari

shmid used to be stored as inode# for shared memory segments. Some of
the proc-ps tools use this from /proc/pid/maps.  Recent cleanups
to newseg() changed it.  This patch sets inode number back to shared 
memory id to fix breakage.

Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com>

Index: linux-2.6.22-rc4/ipc/shm.c
===================================================================
--- linux-2.6.22-rc4.orig/ipc/shm.c	2007-06-08 15:17:20.000000000 -0700
+++ linux-2.6.22-rc4/ipc/shm.c	2007-06-08 15:19:38.000000000 -0700
@@ -397,6 +397,11 @@ static int newseg (struct ipc_namespace 
 	shp->shm_nattch = 0;
 	shp->id = shm_buildid(ns, id, shp->shm_perm.seq);
 	shp->shm_file = file;
+	/*
+	 * shmid gets reported as "inode#" in /proc/pid/maps.
+	 * proc-ps tools use this. Changing this will break them.
+	 */
+	file->f_dentry->d_inode->i_ino = shp->id;
 
 	ns->shm_tot += numpages;
 	shm_unlock(shp);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

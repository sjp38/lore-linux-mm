Date: Thu, 22 Jun 2006 14:31:12 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060622213112.32391.816.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060622213102.32391.19996.sendpatchset@schroedinger.engr.sgi.com>
References: <20060622213102.32391.19996.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 2/4] Remove duplication of fget()
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: "Paul E. McKenney" <paulmck@us.ibm.com>, Jens Axboe <axboe@suse.de>, Dave Miller <davem@redhat.com>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

files rcu optimization: Remove duplicated fget from fget_light.

The code for fget is contained in fget_light. So call fget
instead.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17/fs/file_table.c
===================================================================
--- linux-2.6.17.orig/fs/file_table.c	2006-06-22 14:03:54.484771991 -0700
+++ linux-2.6.17/fs/file_table.c	2006-06-22 14:03:57.773630982 -0700
@@ -226,16 +226,9 @@ struct file fastcall *fget_light(unsigne
 	if (likely((atomic_read(&files->count) == 1))) {
 		file = fcheck_files(files, fd);
 	} else {
-		rcu_read_lock();
-		file = fcheck_files(files, fd);
-		if (file) {
-			if (atomic_inc_not_zero(&file->f_count))
-				*fput_needed = 1;
-			else
-				/* Didn't get the reference, someone's freed */
-				file = NULL;
-		}
-		rcu_read_unlock();
+		file = fget(fd);
+		if (file)
+			*fput_needed = 1;
 	}
 
 	return file;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

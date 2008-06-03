Message-Id: <20080603100940.716191845@amd.local0.net>
References: <20080603095956.781009952@amd.local0.net>
Date: Tue, 03 Jun 2008 20:00:16 +1000
From: npiggin@suse.de
Subject: [patch 20/21] fs: check for statfs overflow
Content-Disposition: inline; filename=fs-check-for-statfs-overflow.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, linux-mm@kvack.org, Jon Tollefson <kniht@linux.vnet.ibm.com>, kniht@us.ibm.com, andi@firstfloor.org, abh@cray.com, joachim.deguara@amd.com
List-ID: <linux-mm.kvack.org>

Adds a check for an overflow in the filesystem size so if someone is
checking with statfs() on a 16G hugetlbfs in a 32bit binary that it
will report back EOVERFLOW instead of a size of 0.

Acked-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Jon Tollefson <kniht@linux.vnet.ibm.com>
Signed-off-by: Nick Piggin <npiggin@suse.de>
---

 fs/compat.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)


Index: linux-2.6/fs/compat.c
===================================================================
--- linux-2.6.orig/fs/compat.c	2008-06-03 19:52:45.000000000 +1000
+++ linux-2.6/fs/compat.c	2008-06-03 19:57:08.000000000 +1000
@@ -197,8 +197,8 @@ static int put_compat_statfs(struct comp
 {
 	
 	if (sizeof ubuf->f_blocks == 4) {
-		if ((kbuf->f_blocks | kbuf->f_bfree | kbuf->f_bavail) &
-		    0xffffffff00000000ULL)
+		if ((kbuf->f_blocks | kbuf->f_bfree | kbuf->f_bavail |
+		     kbuf->f_bsize | kbuf->f_frsize) & 0xffffffff00000000ULL)
 			return -EOVERFLOW;
 		/* f_files and f_ffree may be -1; it's okay
 		 * to stuff that into 32 bits */
@@ -271,8 +271,8 @@ out:
 static int put_compat_statfs64(struct compat_statfs64 __user *ubuf, struct kstatfs *kbuf)
 {
 	if (sizeof ubuf->f_blocks == 4) {
-		if ((kbuf->f_blocks | kbuf->f_bfree | kbuf->f_bavail) &
-		    0xffffffff00000000ULL)
+		if ((kbuf->f_blocks | kbuf->f_bfree | kbuf->f_bavail |
+		     kbuf->f_bsize | kbuf->f_frsize) & 0xffffffff00000000ULL)
 			return -EOVERFLOW;
 		/* f_files and f_ffree may be -1; it's okay
 		 * to stuff that into 32 bits */
Index: linux-2.6/fs/open.c
===================================================================
--- linux-2.6.orig/fs/open.c	2008-06-03 19:52:45.000000000 +1000
+++ linux-2.6/fs/open.c	2008-06-03 19:57:08.000000000 +1000
@@ -63,7 +63,8 @@ static int vfs_statfs_native(struct dent
 		memcpy(buf, &st, sizeof(st));
 	else {
 		if (sizeof buf->f_blocks == 4) {
-			if ((st.f_blocks | st.f_bfree | st.f_bavail) &
+			if ((st.f_blocks | st.f_bfree | st.f_bavail |
+			     st.f_bsize | st.f_frsize) &
 			    0xffffffff00000000ULL)
 				return -EOVERFLOW;
 			/*

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

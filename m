Message-Id: <20080525143454.453947000@nick.local0.net>
References: <20080525142317.965503000@nick.local0.net>
Date: Mon, 26 May 2008 00:23:39 +1000
From: npiggin@suse.de
Subject: [patch 22/23] fs: check for statfs overflow
Content-Disposition: inline; filename=fs-check-for-statfs-overflow.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: kniht@us.ibm.com, andi@firstfloor.org, nacc@us.ibm.com, agl@us.ibm.com, abh@cray.com, joachim.deguara@amd.com, Jon Tollefson <kniht@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Adds a check for an overflow in the filesystem size so if someone is
checking with statfs() on a 16G hugetlbfs  in a 32bit binary that it
will report back EOVERFLOW instead of a size of 0.

Are other places that need a similar check?  I had tried a similar
check in put_compat_statfs64 too but it didn't seem to generate an
EOVERFLOW in my test case.

Signed-off-by: Jon Tollefson <kniht@linux.vnet.ibm.com>
Signed-off-by: Nick Piggin <npiggin@suse.de>
---

 fs/compat.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)


Index: linux-2.6/fs/compat.c
===================================================================
--- linux-2.6.orig/fs/compat.c
+++ linux-2.6/fs/compat.c
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

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

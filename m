Received: from midway.site ([71.117.233.155]) by xenotime.net for <linux-mm@kvack.org>; Tue, 26 Sep 2006 10:33:48 -0700
Date: Tue, 26 Sep 2006 10:35:04 -0700
From: Randy Dunlap <rdunlap@xenotime.net>
Subject: [RFC/PATCH mmap2: better determine overflow
Message-Id: <20060926103504.82bd9409.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Randy Dunlap <rdunlap@xenotime.net>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: hugh@veritas.com, akpm <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

mm/mmap.c::do_mmap_pgoff() checks for overflow like:

	/* offset overflow? */
	if ((pgoff + (len >> PAGE_SHIFT)) < pgoff)
               return -EOVERFLOW;

However, using pgoff (page indexes) to determine address range
overflow doesn't overflow.  Change to use byte offsets instead,
so that overflow can actually happen and be noticed.
Also return EOVERFLOW instead of ENOMEM when PAGE_ALIGN(len)
is 0.

Tested on i686 and x86_64.

Test program is at:  http://www.xenotime.net/linux/src/mmap-test.c

Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
---
 mm/mmap.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

--- linux-2618-work.orig/mm/mmap.c
+++ linux-2618-work/mm/mmap.c
@@ -923,13 +923,16 @@ unsigned long do_mmap_pgoff(struct file 
 
 	/* Careful about overflows.. */
 	len = PAGE_ALIGN(len);
-	if (!len || len > TASK_SIZE)
-		return -ENOMEM;
+	if (!len)
+		return -EOVERFLOW;
 
 	/* offset overflow? */
-	if ((pgoff + (len >> PAGE_SHIFT)) < pgoff)
+	if (((pgoff << PAGE_SHIFT) + len) < (pgoff << PAGE_SHIFT))
                return -EOVERFLOW;
 
+	if (len > TASK_SIZE)
+		return -ENOMEM;
+
 	/* Too many mappings? */
 	if (mm->map_count > sysctl_max_map_count)
 		return -ENOMEM;

---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

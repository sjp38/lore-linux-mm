Subject: PATCH: 
From: "Juan J. Quintela" <quintela@fi.udc.es>
Date: 12 Jul 2000 18:24:39 +0200
Message-ID: <yttpuoj8gfs.fsf@serpe.mitica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lkml <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org, linus@orzan.fi.udc.es
List-ID: <linux-mm.kvack.org>

Hi
        somebody pointed out that mm->rss is defined as an unsigned
        long, I think this patch is needed to do the desired effect.
        I have not founded other invalid uses of mm->rss.  Only that
        in someplaces it is tested against (mm->rss <= 0) instead of
        (mm->rss == 0).  I think that the last checks are harmless.

Later, Juan.

diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude base/mm/memory.c working/mm/memory.c
--- base/mm/memory.c	Mon May 15 21:00:33 2000
+++ working/mm/memory.c	Wed Jul 12 03:55:11 2000
@@ -373,12 +373,12 @@
 	spin_unlock(&mm->page_table_lock);
 	/*
 	 * Update rss for the mm_struct (not necessarily current->mm)
+	 * Notice that rss is an unsigned long.
 	 */
-	if (mm->rss > 0) {
+	if (mm->rss > freed)
 		mm->rss -= freed;
-		if (mm->rss < 0)
-			mm->rss = 0;
-	}
+	else
+		mm->rss = 0;
 }
 
 


-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

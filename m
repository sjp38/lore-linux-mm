Received: from alogconduit1ah.ccr.net (root@alogconduit1ag.ccr.net [208.130.159.7])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA12400
	for <linux-mm@kvack.org>; Sun, 23 May 1999 15:27:30 -0400
Subject: [PATCH] depricate ZMAGIC binaries
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 23 May 1999 13:41:36 -0500
Message-ID: <m1btfbsk67.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

The follow patch reads ZMAGIC binaries into anonymous memory,
instead of mapping them at weird offsets in the page cache.

It now also issues a warning when they are run.
This removes the need to support ZMAGIC binaries in the page cache.

Eric

diff -uNrX linux-ignore-files linux-2.3.3.eb1/fs/binfmt_aout.c linux-2.3.3.eb2/fs/binfmt_aout.c
--- linux-2.3.3.eb1/fs/binfmt_aout.c	Sun May 16 21:55:18 1999
+++ linux-2.3.3.eb2/fs/binfmt_aout.c	Tue May 18 01:12:47 1999
@@ -413,7 +413,14 @@
 			return fd;
 		file = fcheck(fd);
 
-		if (!file->f_op || !file->f_op->mmap) {
+		if ((fd_offset & ~PAGE_MASK) != 0) {
+			printk(KERN_WARNING 
+			       "fd_offset is not page aligned. Please convert program: %s\n",
+			       file->f_dentry->d_name.name
+			       );
+		}
+
+		if (!file->f_op || !file->f_op->mmap || ((fd_offset & ~PAGE_MASK) != 0)) {
 			sys_close(fd);
 			do_mmap(NULL, 0, ex.a_text+ex.a_data,
 				PROT_READ|PROT_WRITE|PROT_EXEC,
@@ -534,6 +541,24 @@
 
 	start_addr =  ex.a_entry & 0xfffff000;
 
+	if ((N_TXTOFF(ex) & ~PAGE_MASK) != 0) {
+		printk(KERN_WARNING 
+		       "N_TXTOFF is not page aligned. Please convert library: %s\n",
+		       file->f_dentry->d_name.name
+		       );
+		
+		do_mmap(NULL, start_addr & PAGE_MASK, ex.a_text + ex.a_data + ex.a_bss,
+			PROT_READ | PROT_WRITE | PROT_EXEC,
+			MAP_FIXED| MAP_PRIVATE, 0);
+		
+		read_exec(file->f_dentry, N_TXTOFF(ex),
+			  (char *)start_addr, ex.a_text + ex.a_data, 0);
+		flush_icache_range((unsigned long) start_addr,
+				   (unsigned long) start_addr + ex.a_text + ex.a_data);
+
+		retval = 0;
+		goto out_putf;
+	}
 	/* Now use mmap to map the library into memory. */
 	error = do_mmap(file, start_addr, ex.a_text + ex.a_data,
 			PROT_READ | PROT_WRITE | PROT_EXEC,
diff -uNrX linux-ignore-files linux-2.3.3.eb1/mm/filemap.c linux-2.3.3.eb2/mm/filemap.c
--- linux-2.3.3.eb1/mm/filemap.c	Tue May 18 01:11:52 1999
+++ linux-2.3.3.eb2/mm/filemap.c	Tue May 18 01:12:47 1999
@@ -1319,8 +1319,7 @@
 			return -EINVAL;
 	} else {
 		ops = &file_private_mmap;
-		if (inode->i_op && inode->i_op->bmap &&
-		    (vma->vm_offset & (inode->i_sb->s_blocksize - 1)))
+		if (vma->vm_offset & (PAGE_SIZE -1))
 			return -EINVAL;
 	}
 	if (!inode->i_sb || !S_ISREG(inode->i_mode))
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

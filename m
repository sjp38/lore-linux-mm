Received: from mail.ccr.net (ccr@alogconduit1af.ccr.net [208.130.159.6])
	by kvack.org (8.8.7/8.8.7) with ESMTP id BAA23523
	for <linux-mm@kvack.org>; Sun, 27 Dec 1998 01:33:16 -0500
Subject: RE: Large-File support of 32-bit Linux v0.01 available!
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 27 Dec 1998 00:49:38 -0600
Message-ID: <m167ay5bb1.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Matti Aarnio <matti.aarnio@sonera.fi>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

  Folks keep telling that
        1) "we need large file support on intel Linux"
        2) "it is too difficult to do efficiently, you must do
            lots of rework in kernel"
        3) "you will need new system calls, and new libraries"
  and
        4) nobody *doing* the thing

I started on it a while ago but I've be extremly short on free time.

The following is a patch you will need if you intend to make everything page
aligned in the page cache.  It removes the need for old that old a.out binaries
have for unaligned mappings, leaving only the page alinged QMAGIC
a.out binaries still in a position to do code sharing.  The rest
continue to work and just print anoying warnings. (Reminding me it's
time I upgrade some of my old slackware 2.2 software...)

I have some other logic mostly complete that keeps offset parameter in
the vm_area struct at 32 bits, and hopefully a greater chunck of the
page cache.

If I have the time I'll finish merging that with your start on the
system calls.

Eric


diff -uNrX linux-ignore-files linux-2.1.132.eb2/fs/binfmt_aout.c linux-2.1.132.eb3.make/fs/binfmt_aout.c
--- linux-2.1.132.eb2/fs/binfmt_aout.c	Fri Dec 25 16:42:47 1998
+++ linux-2.1.132.eb3.make/fs/binfmt_aout.c	Fri Dec 25 22:42:36 1998
@@ -409,7 +409,14 @@
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
@@ -530,6 +537,24 @@
 
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
diff -uNrX linux-ignore-files linux-2.1.132.eb2/mm/filemap.c linux-2.1.132.eb3.make/mm/filemap.c
--- linux-2.1.132.eb2/mm/filemap.c	Fri Dec 25 16:48:50 1998
+++ linux-2.1.132.eb3.make/mm/filemap.c	Fri Dec 25 23:04:10 1998
@@ -1350,7 +1350,7 @@
 			return -EINVAL;
 	} else {
 		ops = &file_private_mmap;
-		if (vma->vm_offset & (inode->i_sb->s_blocksize - 1))
+		if (vma->vm_offset & (PAGE_SIZE - 1))
 			return -EINVAL;
 	}
 	if (!inode->i_sb || !S_ISREG(inode->i_mode))

 
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org

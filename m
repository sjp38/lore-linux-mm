Received: from mail.ccr.net (ccr@alogconduit1ae.ccr.net [208.130.159.5])
	by kvack.org (8.8.7/8.8.7) with ESMTP id TAA16628
	for <linux-mm@kvack.org>; Tue, 9 Feb 1999 19:27:34 -0500
Subject: Re: [PATCH] Re: swapcache bug?
References: <Pine.LNX.3.95.990209082927.32602B-100000@penguin.transmeta.com>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 09 Feb 1999 18:28:04 -0600
In-Reply-To: Linus Torvalds's message of "Tue, 9 Feb 1999 08:32:52 -0800 (PST)"
Message-ID: <m13e4fxfu3.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, masp0008@stud.uni-sb.de, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>>>>> "LT" == Linus Torvalds <torvalds@transmeta.com> writes:

LT> On 9 Feb 1999, Eric W. Biederman wrote:
>> 
>> ???  With the latter OMAGIC format everthing is page aligned already.

LT> Yes.

LT> However, it's a question of pride too. I don't want to break "normal" user
LT> land applications (as opposed to things like "ifconfig" that are really
LT> very very special), unless I really have to.

You don't have to break programs, just have them use a little more memory.

The way we currently support shared ZMAGIC binaries is a real hack.
There are a lot of cases where it doesn't work. 2k+ ext2fs, and
network file systems.

And the code is very unobvious.

The filesytem code becomes much cleaner if we remove support for non
aligned mappings.

The following patch is all that it takes to remove the need to support
non-aligned mappings.  Everything still works we just use a little
more memory (if multiple copies of the program are running at once),
and complain.  

Avoiding this patch is not worth losing 3 bits of address space, and
code clarity.  

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
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

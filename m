Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA22853
	for <linux-mm@kvack.org>; Mon, 24 May 1999 11:46:36 -0400
Date: Mon, 24 May 1999 17:27:20 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] cache large files in the page cache
In-Reply-To: <m17lpzsi0h.fsf@flinx.ccr.net>
Message-ID: <Pine.LNX.4.05.9905241701300.2102-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 23 May 1999, Eric W. Biederman wrote:

>diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/drivers/sgi/char/graphics.c linux-2.3.3.eb5/drivers/sgi/char/graphics.c
>--- linux-2.3.3.eb4/drivers/sgi/char/graphics.c	Sun Oct 11 13:15:06 1998
>+++ linux-2.3.3.eb5/drivers/sgi/char/graphics.c	Sat May 22 17:16:53 1999
>@@ -237,12 +237,20 @@
> };
> 	
> int
>-sgi_graphics_mmap (struct inode *inode, struct file *file, struct vm_area_struct *vma)
>+sgi_graphics_mmap (struct inode *inode, struct file *file, struct vm_area_struct *vma,
>+		   loff_t offset)
> {
> 	uint size;
>+	unsigned long vm_offset;
>+	
>+	if (offset > PAGE_MAX_MEMORY_OFFSET) {
>+		return -EINVAL;
>+	}
>+	vm_offset = offset;
>+	vma->vm_index = vm_offset >> PAGE_SHIFT;
> 
> 	size = vma->vm_end - vma->vm_start;
>-	if (vma->vm_offset & ~PAGE_MASK)
>+	if (vm_offset & ~PAGE_MASK)
> 		return -ENXIO;
> 
> 	/* 1. Set our special graphic virtualizer  */
>@@ -252,7 +260,8 @@
> 	vma->vm_page_prot = PAGE_USERIO;
> 		
> 	/* final setup */
>-	vma->vm_dentry = dget (file->f_dentry);
>+	vma->vm_file = file;
>+	file->f_count++;
> 	return 0;

vm_file a and f_count should be just handled by do_mmap().

>@@ -365,8 +370,8 @@
> 	    > (unsigned long) current->rlim[RLIMIT_AS].rlim_cur)
> 		return -ENOMEM;
> 	vma->vm_start = address;
>-	vma->vm_offset -= grow;
>-	vma->vm_mm->total_vm += grow >> PAGE_SHIFT;
>+	vma->vm_index -= grow >> PAGE_SHIFT;
>+	vma->vm_mm->total_vm += grow;
				^^^^
grow should still be shifted right of PAGE_SHIFT I think.

I have not understood why PAGE_MAX_MEMORY_OFFSET & PAGE_MAX_FILE_OFFSET
are useful. We should check against too large offset or too high mmap in
the standard code, no? Maybe the offset limit is to forbid somebody to
create a too much large file even if the fs would permit? I am not sure if
it will be useful, at least if it's choosen at compile time and it's not a
sysctl.

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

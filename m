Date: Fri, 27 Dec 2002 23:47:44 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: shared pagetable benchmarking
In-Reply-To: <3E0D4B83.FEE220B8@digeo.com>
Message-ID: <Pine.LNX.4.44.0212272338040.4568-100000@home.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, Dave McCracken <dmccr@us.ibm.com>, Daniel Phillips <phillips@arcor.de>, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Fri, 27 Dec 2002, Andrew Morton wrote:
> >                 if (!file)
> >                         goto out;
> > +               if (prot & PROT_EXEC)
> > +                       flags |= MAP_POPULATE | MAP_NONBLOCK;
> 
> Yes, this could be used to prototype it, I think.
> 
> It doesn't work as-is, because remap_file_pages() requires a shared
> mapping.  Disabling that check results in a scrogged ld.so and a
> non-booting system.  remap_file_pages() plays games with the vma
> protection in ways which I do not understand.

Ahh.. Those file protection games are wrong for anything but the specific 
case of the sys_remap_file_pages() system call. The mmap() case should 
_not_ use that system call path at all, but should instead just call the 
populate function directly. Something like the appended patch.

CAREFUL! I've not checked all the details on this, but moving the
MAP_POPULATE check upwards should get rid of the problems with the vma
goign away etc, so it should make this at least closer to correct, and
makes all the extra work that sys_remap_file_pages() does totally
unnecessary, since we know the vma and ranges already.

This has not been compiled, much less tested. Consider a example ONLY.

		Linus

----
===== arch/i386/kernel/sys_i386.c 1.10 vs edited =====
--- 1.10/arch/i386/kernel/sys_i386.c	Sat Dec 21 08:24:45 2002
+++ edited/arch/i386/kernel/sys_i386.c	Fri Dec 27 19:08:30 2002
@@ -54,6 +54,8 @@
 		file = fget(fd);
 		if (!file)
 			goto out;
+		if (prot & PROT_EXEC)
+			flags |= MAP_POPULATE | MAP_NONBLOCK;
 	}
 
 	down_write(&current->mm->mmap_sem);
===== mm/mmap.c 1.58 vs edited =====
--- 1.58/mm/mmap.c	Sat Dec 14 09:42:45 2002
+++ edited/mm/mmap.c	Fri Dec 27 23:45:45 2002
@@ -576,6 +576,11 @@
 		error = file->f_op->mmap(file, vma);
 		if (error)
 			goto unmap_and_free_vma;
+
+		if (flags & MAP_POPULATE) {
+			if (vma->vm_ops && vma->vm_ops->populate)
+				vma->vm_ops->populate(vma, addr, len, prot, pgoff, flags & MAP_NONBLOCK);
+		}
 	} else if (vm_flags & VM_SHARED) {
 		error = shmem_zero_setup(vma);
 		if (error)
@@ -606,12 +611,6 @@
 	if (vm_flags & VM_LOCKED) {
 		mm->locked_vm += len >> PAGE_SHIFT;
 		make_pages_present(addr, addr + len);
-	}
-	if (flags & MAP_POPULATE) {
-		up_write(&mm->mmap_sem);
-		sys_remap_file_pages(addr, len, prot,
-					pgoff, flags & MAP_NONBLOCK);
-		down_write(&mm->mmap_sem);
 	}
 	return addr;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

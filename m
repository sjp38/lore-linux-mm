From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199910130125.SAA66579@google.engr.sgi.com>
Subject: Re: locking question: do_mmap(), do_munmap()
Date: Tue, 12 Oct 1999 18:25:42 -0700 (PDT)
In-Reply-To: <14338.25466.233239.59715@dukat.scot.redhat.com> from "Stephen C. Tweedie" at Oct 11, 99 11:23:54 pm
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: manfreds@colorfullife.com, viro@math.psu.edu, andrea@suse.de, linux-kernel@vger.rutgers.edu, mingo@chiara.csoma.elte.hu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> Hi,
> 
> On Mon, 11 Oct 1999 12:07:08 -0700 (PDT), kanoj@google.engr.sgi.com
> (Kanoj Sarcar) said:
> 
> >> What about something like a rw-semaphore which protects the vma list:
> >> vma-list modifiers [ie merge_segments(), insert_vm_struct() and
> >> do_munmap()] grab it exclusive, swapper grabs it "shared, starve
> >> exclusive".
> >> All other vma-list readers are protected by mm->mmap_sem.
> 
> It will deadlock.
> 

Not sure why you say that. Yes, I did see the nesting semdaphore grabbing
scenario that you posted, but I think you can prevent that from 
happening if you follow some rules. 

Here's a primitive patch showing the direction I am thinking of. I do not
have any problem with a spinning lock, but I coded this against 2.2.10,
where insert_vm_struct could go to sleep, hence I had to use sleeping
locks to protect the vma chain. Slight change is needed to vmscan.c
to use spinning locks.

Kanoj

This is a skeleton of the solution that prevents kswapd from walking
down a vma chain without protections. I am trying to get comments on
this approach before I try a full blown implementation.

The rules:
1. To modify the vmlist (add/delete), you must hold mmap_sem to 
guard against clones doing mmap/munmap/faults, (ie all vm system 
calls and faults), and from ptrace, swapin due to swap deletion
etc.
2. To modify the vmlist (add/delete), you must also hold
vmlist_modify_lock, to guard against page stealers scanning the
list.
3. To scan the vmlist, you must either 
	a. grab mmap_sem, which should be all cases except page stealer.
or
	b. grab vmlist_access_lock, only done by page stealer.
4. While holding the vmlist_modify_lock, you must be able to guarantee
that no code path will lead to page stealing.
5. You must be able to guarantee that while holding vmlist_modify_lock
or vmlist_access_lock of mm A, you will not try to get either lock
for mm B.

The assumptions:
1. No code path reachable thru insert_vm_struct and merge_segments
sleep for memory.


--- /usr/tmp/p_rdiff_a00368/vmscan.c	Tue Oct 12 17:58:50 1999
+++ mm/vmscan.c	Tue Oct 12 16:55:13 1999
@@ -295,6 +295,7 @@
 	/*
 	 * Find the proper vm-area
 	 */
+	vmlist_access_lock(mm);
 	vma = find_vma(mm, address);
 	if (vma) {
 		if (address < vma->vm_start)
@@ -302,8 +303,10 @@
 
 		for (;;) {
 			int result = swap_out_vma(vma, address, gfp_mask);
-			if (result)
+			if (result) {
+				vmlist_access_unlock(mm);
 				return result;
+			}
 			vma = vma->vm_next;
 			if (!vma)
 				break;
@@ -310,6 +313,7 @@
 			address = vma->vm_start;
 		}
 	}
+	vmlist_access_unlock(mm);
 
 	/* We didn't find anything for the process */
 	mm->swap_cnt = 0;
--- /usr/tmp/p_rdiff_a0036H/mlock.c	Tue Oct 12 17:59:06 1999
+++ mm/mlock.c	Tue Oct 12 16:35:25 1999
@@ -13,7 +13,9 @@
 
 static inline int mlock_fixup_all(struct vm_area_struct * vma, int newflags)
 {
+	vmlist_modify_lock(vma->vm_mm);
 	vma->vm_flags = newflags;
+	vmlist_modify_unlock(vma->vm_mm);
 	return 0;
 }
 
@@ -26,15 +28,17 @@
 	if (!n)
 		return -EAGAIN;
 	*n = *vma;
-	vma->vm_start = end;
 	n->vm_end = end;
-	vma->vm_offset += vma->vm_start - n->vm_start;
 	n->vm_flags = newflags;
 	if (n->vm_file)
 		get_file(n->vm_file);
 	if (n->vm_ops && n->vm_ops->open)
 		n->vm_ops->open(n);
+	vmlist_modify_lock(vma->vm_mm);
+	vma->vm_offset += end - vma->vm_start;
+	vma->vm_start = end;
 	insert_vm_struct(current->mm, n);
+	vmlist_modify_unlock(vma->vm_mm);
 	return 0;
 }
 
@@ -47,7 +51,6 @@
 	if (!n)
 		return -EAGAIN;
 	*n = *vma;
-	vma->vm_end = start;
 	n->vm_start = start;
 	n->vm_offset += n->vm_start - vma->vm_start;
 	n->vm_flags = newflags;
@@ -55,7 +58,10 @@
 		get_file(n->vm_file);
 	if (n->vm_ops && n->vm_ops->open)
 		n->vm_ops->open(n);
+	vmlist_modify_lock(vma->vm_mm);
+	vma->vm_end = start;
 	insert_vm_struct(current->mm, n);
+	vmlist_modify_unlock(vma->vm_mm);
 	return 0;
 }
 
@@ -75,10 +81,7 @@
 	*left = *vma;
 	*right = *vma;
 	left->vm_end = start;
-	vma->vm_start = start;
-	vma->vm_end = end;
 	right->vm_start = end;
-	vma->vm_offset += vma->vm_start - left->vm_start;
 	right->vm_offset += right->vm_start - left->vm_start;
 	vma->vm_flags = newflags;
 	if (vma->vm_file)
@@ -88,8 +91,14 @@
 		vma->vm_ops->open(left);
 		vma->vm_ops->open(right);
 	}
+	vmlist_modify_lock(vma->vm_mm);
+	vma->vm_offset += start - vma->vm_start;
+	vma->vm_start = start;
+	vma->vm_end = end;
+	vma->vm_flags = newflags;
 	insert_vm_struct(current->mm, left);
 	insert_vm_struct(current->mm, right);
+	vmlist_modify_unlock(vma->vm_mm);
 	return 0;
 }
 
@@ -168,7 +177,9 @@
 			break;
 		}
 	}
+	vmlist_modify_lock(current->mm);
 	merge_segments(current->mm, start, end);
+	vmlist_modify_unlock(current->mm);
 	return error;
 }
 
@@ -240,7 +251,9 @@
 		if (error)
 			break;
 	}
+	vmlist_modify_lock(current->mm);
 	merge_segments(current->mm, 0, TASK_SIZE);
+	vmlist_modify_unlock(current->mm);
 	return error;
 }
 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

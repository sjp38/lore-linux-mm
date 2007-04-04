Message-ID: <461357C4.4010403@yahoo.com.au>
Date: Wed, 04 Apr 2007 17:46:12 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: missing madvise functionality
References: <46128051.9000609@redhat.com>
In-Reply-To: <46128051.9000609@redhat.com>
Content-Type: multipart/mixed;
 boundary="------------040009020805000409080200"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ulrich Drepper <drepper@redhat.com>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Jakub Jelinek <jakub@redhat.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------040009020805000409080200
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Ulrich Drepper wrote:
> People might remember the thread about mysql not scaling and pointing
> the finger quite happily at glibc.  Well, the situation is not like that.
> 
> The problem is glibc has to work around kernel limitations.  If the
> malloc implementation detects that a large chunk of previously allocated
> memory is now free and unused it wants to return the memory to the
> system.  What we currently have to do is this:
> 
>   to free:      mmap(PROT_NONE) over the area
>   to reuse:     mprotect(PROT_READ|PROT_WRITE)
> 
> Yep, that's expensive, both operations need to get locks preventing
> other threads from doing the same.
> 
> Some people were quick to suggest that we simply avoid the freeing in
> many situations (that's what the patch submitted by Yanmin Zhang
> basically does).  That's no solution.  One of the very good properties
> of the current allocator is that it does not use much memory.

Does mmap(PROT_NONE) actually free the memory?


> A solution for this problem is a madvise() operation with the following
> property:
> 
>   - the content of the address range can be discarded
> 
>   - if an access to a page in the range happens in the future it must
>     succeed.  The old page content can be provided or a new, empty page
>     can be provided
> 
> That's it.  The current MADV_DONTNEED doesn't cut it because it zaps the
> pages, causing *all* future reuses to create page faults.  This is what
> I guess happens in the mysql test case where the pages where unused and
> freed but then almost immediately reused.  The page faults erased all
> the benefits of using one mprotect() call vs a pair of mmap()/mprotect()
> calls.

Two questions.

In the case of pages being unused then almost immediately reused, why is
it a bad solution to avoid freeing? Is it that you want to avoid
heuristics because in some cases they could fail and end up using memory?

Secondly, why is MADV_DONTNEED bad? How much more expensive is a pagefault
than a syscall? (including the cost of the TLB fill for the memory access
after the syscall, of course).

zapping the pages puts them on a nice LIFO cache hot list of pages that
can be quickly used when the next fault comes in, or used for any other
allocation in the kernel. Putting them on some sort of reclaim list seems
a bit pointless.

Oh, also: something like this patch would help out MADV_DONTNEED, as it
means it can run concurrently with page faults. I think the locking will
work (but needs forward porting).

-- 
SUSE Labs, Novell Inc.

--------------040009020805000409080200
Content-Type: text/plain;
 name="madv-mmap_sem.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="madv-mmap_sem.patch"

Index: linux-2.6/mm/madvise.c
===================================================================
--- linux-2.6.orig/mm/madvise.c
+++ linux-2.6/mm/madvise.c
@@ -12,6 +12,25 @@
 #include <linux/hugetlb.h>
 
 /*
+ * Any behaviour which results in changes to the vma->vm_flags needs to
+ * take mmap_sem for writing. Others, which simply traverse vmas, need
+ * to only take it for reading.
+ */
+static int madvise_need_mmap_write(int behavior)
+{
+	switch (behavior) {
+	case MADV_DOFORK:
+	case MADV_DONTFORK:
+	case MADV_NORMAL:
+	case MADV_SEQUENTIAL:
+	case MADV_RANDOM:
+		return 1;
+	default:
+		return 0;
+	}
+}
+
+/*
  * We can potentially split a vm area into separate
  * areas, each area with its own behavior.
  */
@@ -264,7 +283,10 @@ asmlinkage long sys_madvise(unsigned lon
 	int error = -EINVAL;
 	size_t len;
 
-	down_write(&current->mm->mmap_sem);
+	if (madvise_need_mmap_write(behavior))
+		down_write(&current->mm->mmap_sem);
+	else
+		down_read(&current->mm->mmap_sem);
 
 	if (start & ~PAGE_MASK)
 		goto out;
@@ -323,6 +345,10 @@ asmlinkage long sys_madvise(unsigned lon
 		vma = prev->vm_next;
 	}
 out:
-	up_write(&current->mm->mmap_sem);
+	if (madvise_need_mmap_write(behavior))
+		up_write(&current->mm->mmap_sem);
+	else
+		up_read(&current->mm->mmap_sem);
+
 	return error;
 }

--------------040009020805000409080200--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

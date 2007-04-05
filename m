Message-ID: <461479B8.9090203@yahoo.com.au>
Date: Thu, 05 Apr 2007 14:23:20 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: missing madvise functionality
References: <46128051.9000609@redhat.com> <461357C4.4010403@yahoo.com.au> <20070404082015.GG355@devserv.devel.redhat.com> <4613660C.5010108@yahoo.com.au>
In-Reply-To: <4613660C.5010108@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------010605090500070900080905"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jakub Jelinek <jakub@redhat.com>
Cc: Ulrich Drepper <drepper@redhat.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------010605090500070900080905
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Nick Piggin wrote:
> Jakub Jelinek wrote:
> 
>> On Wed, Apr 04, 2007 at 05:46:12PM +1000, Nick Piggin wrote:
>>
>>> Does mmap(PROT_NONE) actually free the memory?
>>
>>
>>
>> Yes.
>>         /* Clear old maps */
>>         error = -ENOMEM;
>> munmap_back:
>>         vma = find_vma_prepare(mm, addr, &prev, &rb_link, &rb_parent);
>>         if (vma && vma->vm_start < addr + len) {
>>                 if (do_munmap(mm, addr, len))
>>                         return -ENOMEM;
>>                 goto munmap_back;
>>         }
> 
> 
> Thanks, I overlooked the mmap vs mprotect detail. So how are the subsequent
> access faults avoided?

AFAIKS, the faults are not avoided. Not for single page allocations, not
for multi-page allocations.

So what glibc currently does to allocate, use, then deallocate a page is
this:
   mprotect(PROT_READ|PROT_WRITE) -> down_write(mmap_sem)
   touch page -> page fault -> down_read(mmap_sem)
   mmap(PROT_NONE) -> down_write(mmap_sem)

What it could be doing is:
   touch page -> page fault -> down_read(mmap_sem)
   madvise(MADV_DONTNEED) -> down_read(mmap_sem)

So after my previously posted patch (attached again) to only take down_read
in madvise where possible...

With 2 threads, the attached test.c ends up doing about 140,000 context
switches per second with just 2 threads/2CPUs, takes a little over 2
million faults, and about 80 seconds to complete, when running the
old_test() function (ie. mprotect,touch,mmap).

When running new_test() (ie. touch,madvise), context switches stay well
under 100, it takes slightly fewer faults, and it completes in about 8
seconds.

With 1 thread, new_test() actually completes in under half the time as
well (4.55 vs 9.88 seconds). This result won't have been altered by my
madvise patch, because the down_write fastpath is no slower than down_read.

Any comments?

-- 
SUSE Labs, Novell Inc.

--------------010605090500070900080905
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

--------------010605090500070900080905
Content-Type: text/x-csrc;
 name="test.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="test.c"

#include <stdlib.h>
#include <stdio.h>
#include <sys/mman.h>
#include <pthread.h>

#define NR_THREADS	1
#define ITERS	1000000
#define HEAPSIZE	(4*1024)

static void *old_thread(void *heap)
{
	int i;

	for (i = 0; i < ITERS; i++) {
		char *mem = heap;
		if (mprotect(heap, HEAPSIZE, PROT_READ|PROT_WRITE) == -1)
			perror("mprotect"), exit(1);
		*mem = i;
		if (mmap(heap, HEAPSIZE, PROT_NONE, MAP_PRIVATE|MAP_ANONYMOUS|MAP_FIXED, -1, 0) == MAP_FAILED)
			perror("mmap"), exit(1);
	}

	return NULL;
}

static void old_test(void)
{
	void *heap;
	pthread_t pt[NR_THREADS];
	int i;

	heap = mmap(NULL, NR_THREADS*HEAPSIZE, PROT_NONE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0);
	if (heap == MAP_FAILED)
		perror("mmap"), exit(1);

	for (i = 0; i < NR_THREADS; i++) {
		if (pthread_create(&pt[i], NULL, old_thread, heap + i*HEAPSIZE) == -1)
			perror("pthread_create"), exit(1);
	}
	for (i = 0; i < NR_THREADS; i++) {
		if (pthread_join(pt[i], NULL) == -1)
			perror("pthread_join"), exit(1);
	}

	if (munmap(heap, NR_THREADS*HEAPSIZE) == -1)
		perror("munmap"), exit(1);
}

static void *new_thread(void *heap)
{
	int i;

	for (i = 0; i < ITERS; i++) {
		char *mem = heap;
		*mem = i;
		if (madvise(heap, HEAPSIZE, MADV_DONTNEED) == -1)
			perror("madvise"), exit(1);
	}

	return NULL;
}

static void new_test(void)
{
	void *heap;
	pthread_t pt[NR_THREADS];
	int i;

	heap = mmap(NULL, HEAPSIZE, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0);
	if (heap == MAP_FAILED)
		perror("mmap"), exit(1);

	for (i = 0; i < NR_THREADS; i++) {
		if (pthread_create(&pt[i], NULL, new_thread, heap + i*HEAPSIZE) == -1)
			perror("pthread_create"), exit(1);
	}
	for (i = 0; i < NR_THREADS; i++) {
		if (pthread_join(pt[i], NULL) == -1)
			perror("pthread_join"), exit(1);
	}

	if (munmap(heap, HEAPSIZE) == -1)
		perror("munmap"), exit(1);
}

int main(void)
{
	old_test();

	exit(0);
}


--------------010605090500070900080905--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

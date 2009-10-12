Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 6EE2A6B004D
	for <linux-mm@kvack.org>; Mon, 12 Oct 2009 11:04:29 -0400 (EDT)
Date: Mon, 12 Oct 2009 16:04:08 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH] munmap() don't check sysctl_max_mapcount
In-Reply-To: <20091012184654.E4D0.A69D9226@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0910121512070.2943@sister.anvils>
References: <20091002180533.5F77.A69D9226@jp.fujitsu.com>
 <Pine.LNX.4.64.0910091007010.17240@sister.anvils> <20091012184654.E4D0.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 12 Oct 2009, KOSAKI Motohiro wrote:
> > 
> > If you change your patch so that do_munmap() cannot increase the final
> > number vmas beyond sysctl_max_map_count, that would seem reasonable.
> > But would that satisfy your testcase?  And does the testcase really
> > matter in practice?  It doesn't seem to have upset anyone before.
> 
> Very thank you for payed attention to my patch. Yes, this is real issue.
> my customer suffer from it.

That's a good reason for a fix; though nothing you say explains why
they're operating right at the sysctl_max_map_count limit (which is
likely to give them further surprises), and cannot raise that limit.

> 
> May I explain why you haven't seen this issue? this issue is architecture
> independent problem. however register stack architecture (e.g. ia64, sparc)
> dramatically increase the possibility of the heppen this issue.

Thanks for going to all this trouble; but I never doubted it could
happen, nor that some would be more likely to suffer than others.

> And, I doubt I haven't catch your mention. May I ask some question?
> Honestly I don't think max_map_count is important knob. it is strange
> mutant of limit of virtual address space in the process.
> At very long time ago (probably the stone age), linux doesn't have
> vma rb_tree handling, then many vma directly cause find_vma slow down.
> However current linux have good scalability. it can handle many vma issue.

I think there are probably several different reasons for the limit,
some perhaps buried in prehistory, yes, and others forgotten.

One reason is well-known to your colleague, KAMEZAWA-san:
the ELF core dump format only supports a ushort number of sections.

One reason will be to limit the amount of kernel memory which can
be pinned by a user program - why limit their ability to to lock down
user pages, if we let them run wild with kernel data structures?
The more important on 32-bit machines with more than 1GB of memory, as
the lowmem restriction comes to bite.  But I probably should not have
mentioned that, I fear you'll now go on a hunt for other places where
we impose no such limit, and embarrass me greatly with the result ;)

And one reason will be the long vma->vm_next searches: less of an
issue nowadays, yes, and preemptible if you have CONFIG_PREEMPT=y;
but still might be something of a problem.

> So, Why do you think max_mapcount sould be strictly keeped?

I don't believe it's the most serious limit we have, and I'm no
expert on its origins; but I do believe that if we profess to have
some limit, then we have to enforce it.  If we're going to allow
anybody to get around the limit, better just throw the limit away.

> 
> Honestly, I doubt nobody suffer from removing sysctl_max_mapcount.

I expect Kame to disagree with you on that.

> 
> And yes, stack unmapping have exceptional charactatics. the guard zone
> gurantee it never raise map_count. 
> So, I think the attached patch (0001-Don-t...) is the same as you talked about, right?

Yes, I've not tested but that looks right to me (I did have to think a
bit to realize that the case where the munmap spans more than one vma
is fine with the check you've added).  In the version below I've just
changed your code comment.

> I can accept it. I haven't test it on ia64. however, at least it works
> well on x86.
> 
> BUT, I still think kernel souldn't refuse any resource deallocation.
> otherwise, people discourage proper resource deallocation and encourage
> brutal intentional memory leak programming style. What do you think?

I think you're a little too trusting.  It's common enough that in order
to free one resource, we need just a little of another resource; and
it is frustrating when that other resource is tightly limited.  But if
somebody owes you 10000 yen, and asks to borrow just another 1000 yen
to make some arrangement to pay you back, then the next day asks to
borrow just another 1000 yen to enhance that arrangement, then....

That's what I'm asking to guard against here.   But if you're so
strongly against having that limit, please just get your customers
to raise it to INT_MAX: that should be enough to keep away from
its practical limitations, shouldn't it?


[PATCH] Don't make ENOMEM temporary mapcount exceeding in munmap()

From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On ia64, the following test program exit abnormally, because
glibc thread library called abort().

 ========================================================
 (gdb) bt
 #0  0xa000000000010620 in __kernel_syscall_via_break ()
 #1  0x20000000003208e0 in raise () from /lib/libc.so.6.1
 #2  0x2000000000324090 in abort () from /lib/libc.so.6.1
 #3  0x200000000027c3e0 in __deallocate_stack () from /lib/libpthread.so.0
 #4  0x200000000027f7c0 in start_thread () from /lib/libpthread.so.0
 #5  0x200000000047ef60 in __clone2 () from /lib/libc.so.6.1
 ========================================================

The fact is, glibc call munmap() when thread exitng time for freeing stack, and
it assume munlock() never fail. However, munmap() often make vma splitting
and it with many mapcount make -ENOMEM.

Oh well, that's crazy, because stack unmapping never increase mapcount.
The maxcount exceeding is only temporary. internal temporary exceeding
shouldn't make ENOMEM.

This patch does it.

 test_max_mapcount.c
 ==================================================================
  #include<stdio.h>
  #include<stdlib.h>
  #include<string.h>
  #include<pthread.h>
  #include<errno.h>
  #include<unistd.h>

  #define THREAD_NUM 30000
  #define MAL_SIZE (8*1024*1024)

 void *wait_thread(void *args)
 {
 	void *addr;

 	addr = malloc(MAL_SIZE);
 	sleep(10);

 	return NULL;
 }

 void *wait_thread2(void *args)
 {
 	sleep(60);

 	return NULL;
 }

 int main(int argc, char *argv[])
 {
 	int i;
 	pthread_t thread[THREAD_NUM], th;
 	int ret, count = 0;
 	pthread_attr_t attr;

 	ret = pthread_attr_init(&attr);
 	if(ret) {
 		perror("pthread_attr_init");
 	}

 	ret = pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
 	if(ret) {
 		perror("pthread_attr_setdetachstate");
 	}

 	for (i = 0; i < THREAD_NUM; i++) {
 		ret = pthread_create(&th, &attr, wait_thread, NULL);
 		if(ret) {
 			fprintf(stderr, "[%d] ", count);
 			perror("pthread_create");
 		} else {
 			printf("[%d] create OK.\n", count);
 		}
 		count++;

 		ret = pthread_create(&thread[i], &attr, wait_thread2, NULL);
 		if(ret) {
 			fprintf(stderr, "[%d] ", count);
 			perror("pthread_create");
 		} else {
 			printf("[%d] create OK.\n", count);
 		}
 		count++;
 	}

 	sleep(3600);
 	return 0;
 }
 ==================================================================

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---
 mm/mmap.c |   38 ++++++++++++++++++++++++++++++--------
 1 files changed, 30 insertions(+), 8 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 865830d..41ab576 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1830,10 +1830,10 @@ detach_vmas_to_be_unmapped(struct mm_struct *mm, struct vm_area_struct *vma,
 }
 
 /*
- * Split a vma into two pieces at address 'addr', a new vma is allocated
- * either for the first part or the tail.
+ * __split_vma() bypasses sysctl_max_map_count checking.  We use this on the
+ * munmap path where it doesn't make sense to fail.
  */
-int split_vma(struct mm_struct * mm, struct vm_area_struct * vma,
+static int __split_vma(struct mm_struct * mm, struct vm_area_struct * vma,
 	      unsigned long addr, int new_below)
 {
 	struct mempolicy *pol;
@@ -1843,9 +1843,6 @@ int split_vma(struct mm_struct * mm, struct vm_area_struct * vma,
 					~(huge_page_mask(hstate_vma(vma)))))
 		return -EINVAL;
 
-	if (mm->map_count >= sysctl_max_map_count)
-		return -ENOMEM;
-
 	new = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
 	if (!new)
 		return -ENOMEM;
@@ -1885,6 +1882,19 @@ int split_vma(struct mm_struct * mm, struct vm_area_struct * vma,
 	return 0;
 }
 
+/*
+ * Split a vma into two pieces at address 'addr', a new vma is allocated
+ * either for the first part or the tail.
+ */
+int split_vma(struct mm_struct * mm, struct vm_area_struct * vma,
+	      unsigned long addr, int new_below)
+{
+	if (mm->map_count >= sysctl_max_map_count)
+		return -ENOMEM;
+
+	return __split_vma(mm, vma, addr, new_below);
+}
+
 /* Munmap is split into 2 main parts -- this part which finds
  * what needs doing, and the areas themselves, which do the
  * work.  This now handles partial unmappings.
@@ -1920,7 +1930,17 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len)
 	 * places tmp vma above, and higher split_vma places tmp vma below.
 	 */
 	if (start > vma->vm_start) {
-		int error = split_vma(mm, vma, start, 0);
+		int error;
+
+		/*
+		 * Make sure that map_count on return from munmap() will
+		 * not exceed its limit; but let map_count go just above
+		 * its limit temporarily, to help free resources as expected.
+		 */
+		if (end < vma->vm_end && mm->map_count >= sysctl_max_map_count)
+			return -ENOMEM;
+
+		error = __split_vma(mm, vma, start, 0);
 		if (error)
 			return error;
 		prev = vma;
@@ -1929,7 +1949,7 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len)
 	/* Does it split the last one? */
 	last = find_vma(mm, end);
 	if (last && end > last->vm_start) {
-		int error = split_vma(mm, last, end, 1);
+		int error = __split_vma(mm, last, end, 1);
 		if (error)
 			return error;
 	}
-- 
1.6.2.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

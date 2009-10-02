Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2EEA76B004D
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 04:57:03 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9297Xql003272
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 2 Oct 2009 18:07:33 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 91EAA45DE4F
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 18:07:33 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E12D45DE4E
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 18:07:33 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 58A711DB803A
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 18:07:33 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id BDC3C1DB803F
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 18:07:29 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH] munmap() don't check sysctl_max_mapcount
Message-Id: <20091002180533.5F77.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Date: Fri,  2 Oct 2009 18:07:28 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

Hi everyone,

Is this good idea?


=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=46rom 0b9de3b65158847d376e2786840f932361d00e08 Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Fri, 18 Sep 2009 13:22:06 +0900
Subject: [PATCH] munmap() don't check sysctl_max_mapcount

On ia64, the following test program exit abnormally, because
glibc thread library called abort().

 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D
 (gdb) bt
 #0  0xa000000000010620 in __kernel_syscall_via_break ()
 #1  0x20000000003208e0 in raise () from /lib/libc.so.6.1
 #2  0x2000000000324090 in abort () from /lib/libc.so.6.1
 #3  0x200000000027c3e0 in __deallocate_stack () from /lib/libpthread.so.0
 #4  0x200000000027f7c0 in start_thread () from /lib/libpthread.so.0
 #5  0x200000000047ef60 in __clone2 () from /lib/libc.so.6.1
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D

The fact is, glibc call munmap() when thread exitng time for freeing stack,=
 and
it assume munlock() never fail. However, munmap() often make vma splitting
and it with many mapcount make -ENOMEM.

Oh well, stack unfreeing is not reasonable option. Also munlock() via free(=
)
shouldn't failed.

Thus, munmap() shoudn't check max-mapcount. This patch does it.

 test_max_mapcount.c
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
  #include<stdio.h>
  #include<stdlib.h>
  #include<string.h>
  #include<pthread.h>
  #include<errno.h>
  #include<unistd.h>
=20
  #define THREAD_NUM 30000
  #define MAL_SIZE (100*1024)
=20
 void *wait_thread(void *args)
 {
 	void *addr;
=20
 	addr =3D malloc(MAL_SIZE);
 	if(addr)
 		memset(addr, 1, MAL_SIZE);
 	sleep(1);
=20
 	return NULL;
 }
=20
 void *wait_thread2(void *args)
 {
 	sleep(60);
=20
 	return NULL;
 }
=20
 int main(int argc, char *argv[])
 {
 	int i;
 	pthread_t thread[THREAD_NUM], th;
 	int ret, count =3D 0;
 	pthread_attr_t attr;
=20
 	ret =3D pthread_attr_init(&attr);
 	if(ret) {
 		perror("pthread_attr_init");
 	}
=20
 	ret =3D pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
 	if(ret) {
 		perror("pthread_attr_setdetachstate");
 	}
=20
 	for (i =3D 0; i < THREAD_NUM; i++) {
 		ret =3D pthread_create(&th, &attr, wait_thread, NULL);
 		if(ret) {
 			fprintf(stderr, "[%d] ", count);
 			perror("pthread_create");
 		} else {
 			printf("[%d] create OK.\n", count);
 		}
 		count++;
=20
 		ret =3D pthread_create(&thread[i], &attr, wait_thread2, NULL);
 		if(ret) {
 			fprintf(stderr, "[%d] ", count);
 			perror("pthread_create");
 		} else {
 			printf("[%d] create OK.\n", count);
 		}
 		count++;
 	}
=20
 	sleep(3600);
 	return 0;
 }
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D



Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/mmap.c |   18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

Index: b/mm/mmap.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1832,7 +1832,7 @@ detach_vmas_to_be_unmapped(struct mm_str
  * Split a vma into two pieces at address 'addr', a new vma is allocated
  * either for the first part or the tail.
  */
-int split_vma(struct mm_struct * mm, struct vm_area_struct * vma,
+static int __split_vma(struct mm_struct * mm, struct vm_area_struct * vma,
 	      unsigned long addr, int new_below)
 {
 	struct mempolicy *pol;
@@ -1842,9 +1842,6 @@ int split_vma(struct mm_struct * mm, str
 					~(huge_page_mask(hstate_vma(vma)))))
 		return -EINVAL;
=20
-	if (mm->map_count >=3D sysctl_max_map_count)
-		return -ENOMEM;
-
 	new =3D kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
 	if (!new)
 		return -ENOMEM;
@@ -1884,6 +1881,15 @@ int split_vma(struct mm_struct * mm, str
 	return 0;
 }
=20
+int split_vma(struct mm_struct * mm, struct vm_area_struct * vma,
+	      unsigned long addr, int new_below)
+{
+	if (mm->map_count >=3D sysctl_max_map_count)
+		return -ENOMEM;
+
+	return __split_vma(mm, vma, addr, new_below);
+}
+
 /* Munmap is split into 2 main parts -- this part which finds
  * what needs doing, and the areas themselves, which do the
  * work.  This now handles partial unmappings.
@@ -1919,7 +1925,7 @@ int do_munmap(struct mm_struct *mm, unsi
 	 * places tmp vma above, and higher split_vma places tmp vma below.
 	 */
 	if (start > vma->vm_start) {
-		int error =3D split_vma(mm, vma, start, 0);
+		int error =3D __split_vma(mm, vma, start, 0);
 		if (error)
 			return error;
 		prev =3D vma;
@@ -1928,7 +1934,7 @@ int do_munmap(struct mm_struct *mm, unsi
 	/* Does it split the last one? */
 	last =3D find_vma(mm, end);
 	if (last && end > last->vm_start) {
-		int error =3D split_vma(mm, last, end, 1);
+		int error =3D __split_vma(mm, last, end, 1);
 		if (error)
 			return error;
 	}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

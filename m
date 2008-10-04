Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m94C44Js006237
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sat, 4 Oct 2008 21:04:05 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CCD452AC026
	for <linux-mm@kvack.org>; Sat,  4 Oct 2008 21:04:04 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (s8.gw.fujitsu.co.jp [10.0.50.98])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A36E412C045
	for <linux-mm@kvack.org>; Sat,  4 Oct 2008 21:04:04 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id 876351DB803A
	for <linux-mm@kvack.org>; Sat,  4 Oct 2008 21:04:04 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id 3201E1DB8038
	for <linux-mm@kvack.org>; Sat,  4 Oct 2008 21:04:04 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [RFC PATCH] Report the shmid backing a VMA in maps
In-Reply-To: <1223052415-18956-3-git-send-email-mel@csn.ul.ie>
References: <1223052415-18956-1-git-send-email-mel@csn.ul.ie> <1223052415-18956-3-git-send-email-mel@csn.ul.ie>
Message-Id: <20081004205650.CE47.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sat,  4 Oct 2008 21:04:03 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Adam Litke <agl@us.ibm.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Hi

I made another hugepage administrating helping patch.
So, I'd like to hear hugepage folks.

I tested this patch on mmotm 02/Oct + Mel's "Report the size of pages backing VMAs in /proc V3" series.


Thanks!


======================================================
Recently, Mel Gorman introduce attribute showing mechanism to /proc/{pid}/maps.
It is very powerful and useful feature.

In the other hand, huge page is often used via ipc shm, not mmap.
So, administrator often want to know relationship of memory region and shmid.

Then, To add shmid attribute in /proc/{pid}/maps is useful.


In addition, shmid information is not only useful for huge page, but also for normal shm.
Then, this patch works well on normal shm.

this patch depend on Mel's "Report the pagesize backing a VMA in /proc/pid/maps" patch.


example output of /proc/{pid}/maps
---------------------------------------------------------
00000000-00010000 r--p 00000000 00:00 0                                  
2000000000000000-2000000000040000 r-xp 00000000 fd:00 7372806            /lib/ld-2.5.so
2000000000040000-2000000000050000 rw-p 00030000 fd:00 7372806            /lib/ld-2.5.so
2000000000050000-2000000000060000 rw-p 2000000000050000 00:00 0          
2000000000060000-20000000000d0000 r-xp 00000000 fd:00 2334823            /usr/lib/libreadline.so.5.1
20000000000d0000-20000000000e0000 rw-p 00060000 fd:00 2334823            /usr/lib/libreadline.so.5.1
20000000000e0000-2000000000170000 r-xp 00000000 fd:00 2334751            /usr/lib/libncurses.so.5.5
2000000000170000-2000000000190000 rw-p 00080000 fd:00 2334751            /usr/lib/libncurses.so.5.5
2000000000190000-20000000001a0000 r-xp 00000000 fd:00 2337176            /usr/lib/libnuma.so.1
20000000001a0000-20000000001b0000 rw-p 00000000 fd:00 2337176            /usr/lib/libnuma.so.1
20000000001b0000-2000000000420000 r-xp 00000000 fd:00 7372813            /lib/libc-2.5.so
2000000000420000-2000000000430000 rw-p 00260000 fd:00 7372813            /lib/libc-2.5.so
2000000000430000-2000000000440000 rw-p 2000000000430000 00:00 0          
2000000000440000-2000000000450000 r-xp 00000000 fd:00 7372819            /lib/libdl-2.5.so
2000000000450000-2000000000460000 rw-p 00000000 fd:00 7372819            /lib/libdl-2.5.so
2000000000460000-20000000004d0000 rw-p 2000000000460000 00:00 0          
2000000000500000-2000000000900000 rw-s 00000000 00:09 0                  /SYSV00000000 (deleted) (shmid=0)
2000000000900000-2000000000d00000 rw-s 00000000 00:09 32769              /SYSV00000000 (deleted) (shmid=32769)
4000000000000000-4000000000030000 r-xp 00000000 fd:00 7536864            /home/kosaki/download/Memtoy-0.16/memtoy
6000000000000000-6000000000010000 rw-p 00020000 fd:00 7536864            /home/kosaki/download/Memtoy-0.16/memtoy
6000000000010000-6000000000040000 rw-p 6000000000010000 00:00 0          [heap]
6007ffffffc70000-6007ffffffc80000 rw-p 6007ffffffc70000 00:00 0          
600fffffffb10000-600fffffffc60000 rw-p 600fffffffea0000 00:00 0          [stack]
8000000000000000-8000000010000000 rw-s 00000000 00:0c 65538              /SYSV00000000 (deleted) (hpagesize=262144kB) (shmid=65538)
a000000000000000-a000000000020000 r-xp 00000000 00:00 0                  [vdso]
------------------------------------------------------------

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Mel Gorman <mel@csn.ul.ie>
---
 fs/proc/task_mmu.c  |   12 +++++++++---
 include/linux/shm.h |   10 ++++++++++
 ipc/shm.c           |   17 +++++++++++++++++
 3 files changed, 36 insertions(+), 3 deletions(-)

Index: b/fs/proc/task_mmu.c
===================================================================
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -254,9 +254,15 @@ static void show_map_vma(struct seq_file
 	 * Print additional attributes of the VMA of interest
 	 * - hugepage size if hugepage-backed
 	 */
-	if (showattributes && vma->vm_flags & VM_HUGETLB)
-		seq_printf(m, " (hpagesize=%lukB)",
-			vma_kernel_pagesize(vma) >> 10);
+	if (showattributes) {
+		if (vma->vm_flags & VM_HUGETLB)
+			seq_printf(m, " (hpagesize=%lukB)",
+				   vma_kernel_pagesize(vma) >> 10);
+		if (is_shm_vma(vma))
+			seq_printf(m, " (shmid=%d)",
+				   vma_shmid(vma));
+	}
+
 	seq_putc(m, '\n');
 }
 
Index: b/include/linux/shm.h
===================================================================
--- a/include/linux/shm.h
+++ b/include/linux/shm.h
@@ -106,6 +106,8 @@ struct shmid_kernel /* private to the ke
 #ifdef CONFIG_SYSVIPC
 long do_shmat(int shmid, char __user *shmaddr, int shmflg, unsigned long *addr);
 extern int is_file_shm_hugepages(struct file *file);
+int is_shm_vma(struct vm_area_struct *vma);
+int vma_shmid(struct vm_area_struct *vma);
 #else
 static inline long do_shmat(int shmid, char __user *shmaddr,
 				int shmflg, unsigned long *addr)
@@ -116,6 +118,14 @@ static inline int is_file_shm_hugepages(
 {
 	return 0;
 }
+static inline int is_shm_vma(struct vm_area_struct *vma)
+{
+	return 0;
+}
+int vma_shmid(struct vm_area_struct *vma)
+{
+	return -ENOENT;
+}
 #endif
 
 #endif /* __KERNEL__ */
Index: b/ipc/shm.c
===================================================================
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -1074,3 +1074,20 @@ static int sysvipc_shm_proc_show(struct 
 			  shp->shm_ctim);
 }
 #endif
+
+int is_shm_vma(struct vm_area_struct *vma)
+{
+	return !!(vma->vm_ops == &shm_vm_ops);
+}
+
+int vma_shmid(struct vm_area_struct *vma)
+{
+	struct shm_file_data *sfd;
+
+	if (!is_shm_vma(vma))
+		return -ENOENT;
+
+	sfd = (struct shm_file_data *)vma->vm_file->private_data;
+	return sfd->id;
+}
+


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

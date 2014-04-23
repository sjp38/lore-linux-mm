Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id E19766B0070
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 22:54:03 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id hz1so279211pad.7
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 19:54:03 -0700 (PDT)
Received: from g2t2354.austin.hp.com (g2t2354.austin.hp.com. [15.217.128.53])
        by mx.google.com with ESMTPS id fn10si22994018pad.197.2014.04.22.19.54.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 22 Apr 2014 19:54:02 -0700 (PDT)
Message-ID: <1398221636.6345.9.camel@buesod1.americas.hpqcorp.net>
Subject: [PATCH 5/4] ipc,shm: minor cleanups
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Tue, 22 Apr 2014 19:53:56 -0700
In-Reply-To: <1398090397-2397-1-git-send-email-manfred@colorfullife.com>
References: <1398090397-2397-1-git-send-email-manfred@colorfullife.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>
Cc: Davidlohr Bueso <davidlohr.bueso@hp.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, gthelen@google.com, aswin@hp.com, linux-mm@kvack.org

-  Breakup long function names/args.
-  Cleaup variable declaration.
-  s/current->mm/mm

Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
---
 ipc/shm.c | 40 +++++++++++++++++-----------------------
 1 file changed, 17 insertions(+), 23 deletions(-)

diff --git a/ipc/shm.c b/ipc/shm.c
index f000696..584d02e 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -480,15 +480,13 @@ static const struct vm_operations_struct shm_vm_ops = {
 static int newseg(struct ipc_namespace *ns, struct ipc_params *params)
 {
 	key_t key = params->key;
-	int shmflg = params->flg;
+	int id, error, shmflg = params->flg;
 	size_t size = params->u.size;
-	int error;
-	struct shmid_kernel *shp;
 	size_t numpages = (size + PAGE_SIZE - 1) >> PAGE_SHIFT;
-	struct file *file;
 	char name[13];
-	int id;
 	vm_flags_t acctflag = 0;
+	struct shmid_kernel *shp;
+	struct file *file;
 
 	if (size < SHMMIN || size > ns->shm_ctlmax)
 		return -EINVAL;
@@ -681,7 +679,8 @@ copy_shmid_from_user(struct shmid64_ds *out, void __user *buf, int version)
 	}
 }
 
-static inline unsigned long copy_shminfo_to_user(void __user *buf, struct shminfo64 *in, int version)
+static inline unsigned long copy_shminfo_to_user(void __user *buf,
+						 struct shminfo64 *in, int version)
 {
 	switch (version) {
 	case IPC_64:
@@ -711,8 +710,8 @@ static inline unsigned long copy_shminfo_to_user(void __user *buf, struct shminf
  * Calculate and add used RSS and swap pages of a shm.
  * Called with shm_ids.rwsem held as a reader
  */
-static void shm_add_rss_swap(struct shmid_kernel *shp,
-	unsigned long *rss_add, unsigned long *swp_add)
+static void shm_add_rss_swap(struct shmid_kernel *shp, unsigned long *rss_add,
+			     unsigned long *swp_add)
 {
 	struct inode *inode;
 
@@ -739,7 +738,7 @@ static void shm_add_rss_swap(struct shmid_kernel *shp,
  * Called with shm_ids.rwsem held as a reader
  */
 static void shm_get_stat(struct ipc_namespace *ns, unsigned long *rss,
-		unsigned long *swp)
+			 unsigned long *swp)
 {
 	int next_id;
 	int total, in_use;
@@ -1047,21 +1046,16 @@ out_unlock1:
 long do_shmat(int shmid, char __user *shmaddr, int shmflg, ulong *raddr,
 	      unsigned long shmlba)
 {
-	struct shmid_kernel *shp;
-	unsigned long addr;
-	unsigned long size;
+	unsigned long addr, size, flags, prot, populate = 0;
 	struct file *file;
-	int    err;
-	unsigned long flags;
-	unsigned long prot;
-	int acc_mode;
+	int acc_mode, err = -EINVAL;
 	struct ipc_namespace *ns;
 	struct shm_file_data *sfd;
+	struct shmid_kernel *shp;
 	struct path path;
 	fmode_t f_mode;
-	unsigned long populate = 0;
+	struct mm_struct *mm = current->mm;
 
-	err = -EINVAL;
 	if (shmid < 0)
 		goto out;
 	else if ((addr = (ulong)shmaddr)) {
@@ -1161,20 +1155,20 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg, ulong *raddr,
 	if (err)
 		goto out_fput;
 
-	down_write(&current->mm->mmap_sem);
+	down_write(&mm->mmap_sem);
 	if (addr && !(shmflg & SHM_REMAP)) {
 		err = -EINVAL;
 		if (addr + size < addr)
 			goto invalid;
 
-		if (find_vma_intersection(current->mm, addr, addr + size))
+		if (find_vma_intersection(mm, addr, addr + size))
 			goto invalid;
 		/*
 		 * If shm segment goes below stack, make sure there is some
 		 * space left for the stack to grow (at least 4 pages).
 		 */
-		if (addr < current->mm->start_stack &&
-		    addr > current->mm->start_stack - size - PAGE_SIZE * 5)
+		if (addr < mm->start_stack &&
+		    addr > mm->start_stack - size - PAGE_SIZE * 5)
 			goto invalid;
 	}
 
@@ -1184,7 +1178,7 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg, ulong *raddr,
 	if (IS_ERR_VALUE(addr))
 		err = (long)addr;
 invalid:
-	up_write(&current->mm->mmap_sem);
+	up_write(&mm->mmap_sem);
 	if (populate)
 		mm_populate(addr, populate);
 
-- 
1.8.1.4



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

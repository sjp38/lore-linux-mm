From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199910282204.PAA76687@google.engr.sgi.com>
Subject: [PATCH] kanoj-mm21-2.3.23 alow larger sizes to shmget()
Date: Thu, 28 Oct 1999 15:04:20 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@transmeta.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linus,

Per our previous discussion, this is the patch to change the shmget()
api to permit larger shm segments (now that larger user address spaces,
as well as large memory machines are possible).

Note that I have defined shmget() as
	shmget(key_t, size_t, int)
instead of as
	shmget(key_t, unsigned int, int)
or as
	shmget(key_t, unsigned long, int).

This is because the single unix spec sets down the first definition
(http://www.opengroup.org/onlinepubs/007908799/xsh/shmget.html).
This becomes interesting, because size_t is of different sizes on
different architectures, so the shmfs code has to do careful formatting.
(This logic is also probably needed in the ipcs command).

Let me know if the patch looks okay.

Thanks.

Kanoj

--- /usr/tmp/p_rdiff_a002SA/shm.h	Thu Oct 28 14:41:41 1999
+++ include/linux/shm.h	Wed Oct 27 11:05:49 1999
@@ -7,7 +7,7 @@
 
 struct shmid_ds {
 	struct ipc_perm		shm_perm;	/* operation perms */
-	int			shm_segsz;	/* size of segment (bytes) */
+	size_t			shm_segsz;	/* size of segment (bytes) */
 	__kernel_time_t		shm_atime;	/* last attach time */
 	__kernel_time_t		shm_dtime;	/* last detach time */
 	__kernel_time_t		shm_ctime;	/* last change time */
@@ -46,7 +46,7 @@
 #define SHM_INFO 	14
 
 struct	shminfo {
-	int shmmax;
+	size_t shmmax;
 	int shmmin;
 	int shmmni;
 	int shmseg;
@@ -68,7 +68,7 @@
 #define	SHM_DEST	01000	/* segment will be destroyed on last detach */
 #define SHM_LOCKED      02000   /* segment will not be swapped */
 
-asmlinkage long sys_shmget (key_t key, int size, int flag);
+asmlinkage long sys_shmget (key_t key, size_t size, int flag);
 asmlinkage long sys_shmat (int shmid, char *shmaddr, int shmflg, unsigned long *addr);
 asmlinkage long sys_shmdt (char *shmaddr);
 asmlinkage long sys_shmctl (int shmid, int cmd, struct shmid_ds *buf);
--- /usr/tmp/p_rdiff_a002SJ/shm.c	Thu Oct 28 14:41:55 1999
+++ ipc/shm.c	Thu Oct 28 13:35:44 1999
@@ -27,7 +27,7 @@
 
 extern int ipcperms (struct ipc_perm *ipcp, short shmflg);
 static int findkey (key_t key);
-static int newseg (key_t key, int shmflg, int size);
+static int newseg (key_t key, int shmflg, size_t size);
 static int shm_map (struct vm_area_struct *shmd);
 static void killseg (int id);
 static void shm_open (struct vm_area_struct *shmd);
@@ -104,7 +104,7 @@
 /*
  * allocate new shmid_kernel and pgtable. protected by shm_segs[id] = NOID.
  */
-static int newseg (key_t key, int shmflg, int size)
+static int newseg (key_t key, int shmflg, size_t size)
 {
 	struct shmid_kernel *shp;
 	int numpages = (size + PAGE_SIZE -1) >> PAGE_SHIFT;
@@ -168,9 +168,9 @@
 	return (unsigned int) shp->u.shm_perm.seq * SHMMNI + id;
 }
 
-int shmmax = SHMMAX;
+size_t shmmax = SHMMAX;
 
-asmlinkage long sys_shmget (key_t key, int size, int shmflg)
+asmlinkage long sys_shmget (key_t key, size_t size, int shmflg)
 {
 	struct shmid_kernel *shp;
 	int err, id = 0;
@@ -177,7 +177,7 @@
 
 	down(&current->mm->mmap_sem);
 	spin_lock(&shm_lock);
-	if (size < 0 || size > shmmax) {
+	if (size > shmmax) {
 		err = -EINVAL;
 	} else if (key == IPC_PRIVATE) {
 		err = newseg(key, shmflg, size);
@@ -494,7 +494,7 @@
 		err = -ENOMEM;
 		addr = 0;
 	again:
-		if (!(addr = get_unmapped_area(addr, shp->u.shm_segsz)))
+		if (!(addr = get_unmapped_area(addr, (unsigned long)shp->u.shm_segsz)))
 			goto out;
 		if(addr & (SHMLBA - 1)) {
 			addr = (addr + (SHMLBA - 1)) & ~(SHMLBA - 1);
@@ -520,7 +520,7 @@
 	if (addr < current->mm->start_stack &&
 	    addr > current->mm->start_stack - PAGE_SIZE*(shp->shm_npages + 4))
 		goto out;
-	if (!(shmflg & SHM_REMAP) && find_vma_intersection(current->mm, addr, addr + shp->u.shm_segsz))
+	if (!(shmflg & SHM_REMAP) && find_vma_intersection(current->mm, addr, addr + (unsigned long)shp->u.shm_segsz))
 		goto out;
 
 	err = -EACCES;
@@ -863,7 +863,15 @@
 	spin_lock(&shm_lock);
     	for(i = 0; i < SHMMNI; i++)
 		if(shm_segs[i] != IPC_UNUSED) {
-	    		len += sprintf(buffer + len, "%10d %10d  %4o %10d %5u %5u  %5d %5u %5u %5u %5u %10lu %10lu %10lu\n",
+#define SMALL_STRING "%10d %10d  %4o %10u %5u %5u  %5d %5u %5u %5u %5u %10lu %10lu %10lu\n"
+#define BIG_STRING   "%10d %10d  %4o %21u %5u %5u  %5d %5u %5u %5u %5u %10lu %10lu %10lu\n"
+			char *format;
+
+			if (sizeof(size_t) <= sizeof(int))
+				format = SMALL_STRING;
+			else
+				format = BIG_STRING;
+	    		len += sprintf(buffer + len, format,
 			shm_segs[i]->u.shm_perm.key,
 			shm_segs[i]->u.shm_perm.seq * SHMMNI + i,
 			shm_segs[i]->u.shm_perm.mode,
--- /usr/tmp/p_rdiff_a002SS/sysctl.c	Thu Oct 28 14:42:10 1999
+++ kernel/sysctl.c	Thu Oct 28 12:47:50 1999
@@ -49,7 +49,7 @@
 extern int sg_big_buff;
 #endif
 #ifdef CONFIG_SYSVIPC
-extern int shmmax;
+extern size_t shmmax;
 #endif
 
 #ifdef __sparc__
@@ -213,8 +213,8 @@
 	{KERN_RTSIGMAX, "rtsig-max", &max_queued_signals, sizeof(int),
 	 0644, NULL, &proc_dointvec},
 #ifdef CONFIG_SYSVIPC
-	{KERN_SHMMAX, "shmmax", &shmmax, sizeof (int),
-	 0644, NULL, &proc_dointvec},
+	{KERN_SHMMAX, "shmmax", &shmmax, sizeof (size_t),
+	 0644, NULL, &proc_doulongvec_minmax},
 #endif
 #ifdef CONFIG_MAGIC_SYSRQ
 	{KERN_SYSRQ, "sysrq", &sysrq_enabled, sizeof (int),
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

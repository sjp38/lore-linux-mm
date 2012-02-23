Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 8D8496B007E
	for <linux-mm@kvack.org>; Wed, 22 Feb 2012 23:03:15 -0500 (EST)
Received: by dadv6 with SMTP id v6so939490dad.14
        for <linux-mm@kvack.org>; Wed, 22 Feb 2012 20:03:14 -0800 (PST)
From: Siddhesh Poyarekar <siddhesh.poyarekar@gmail.com>
Subject: [PATCH] Mark thread stack correctly in proc/<pid>/maps
Date: Thu, 23 Feb 2012 09:33:31 +0530
Message-Id: <1329969811-3997-1-git-send-email-siddhesh.poyarekar@gmail.com>
In-Reply-To: <20120222150010.c784b29b.akpm@linux-foundation.org>
References: <20120222150010.c784b29b.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Jamie Lokier <jamie@shareable.org>, Mike Frysinger <vapier@gentoo.org>, Siddhesh Poyarekar <siddhesh.poyarekar@gmail.com>

Stack for a new thread is mapped by userspace code and passed via
sys_clone. This memory is currently seen as anonymous in
/proc/<pid>/maps, which makes it difficult to ascertain which mappings
are being used for thread stacks. This patch uses the individual task
stack pointers to determine which vmas are actually thread stacks.

For a multithreaded program like the following:

\#include <pthread.h>
void *thread_main(void *foo)
{
	while(1);
}

int main()
{
	pthread_t t;
	pthread_create(&t, NULL, thread_main, NULL);
	pthread_join(t, NULL);
}

proc/PID/maps looks like the following:

00400000-00401000 r-xp 00000000 fd:0a 3671804                            /home/siddhesh/a.out
00600000-00601000 rw-p 00000000 fd:0a 3671804                            /home/siddhesh/a.out
019ef000-01a10000 rw-p 00000000 00:00 0                                  [heap]
7f8a44491000-7f8a44492000 ---p 00000000 00:00 0
7f8a44492000-7f8a44c92000 rw-p 00000000 00:00 0
7f8a44c92000-7f8a44e3d000 r-xp 00000000 fd:00 2097482                    /lib64/libc-2.14.90.so
7f8a44e3d000-7f8a4503d000 ---p 001ab000 fd:00 2097482                    /lib64/libc-2.14.90.so
7f8a4503d000-7f8a45041000 r--p 001ab000 fd:00 2097482                    /lib64/libc-2.14.90.so
7f8a45041000-7f8a45043000 rw-p 001af000 fd:00 2097482                    /lib64/libc-2.14.90.so
7f8a45043000-7f8a45048000 rw-p 00000000 00:00 0
7f8a45048000-7f8a4505f000 r-xp 00000000 fd:00 2099938                    /lib64/libpthread-2.14.90.so
7f8a4505f000-7f8a4525e000 ---p 00017000 fd:00 2099938                    /lib64/libpthread-2.14.90.so
7f8a4525e000-7f8a4525f000 r--p 00016000 fd:00 2099938                    /lib64/libpthread-2.14.90.so
7f8a4525f000-7f8a45260000 rw-p 00017000 fd:00 2099938                    /lib64/libpthread-2.14.90.so
7f8a45260000-7f8a45264000 rw-p 00000000 00:00 0
7f8a45264000-7f8a45286000 r-xp 00000000 fd:00 2097348                    /lib64/ld-2.14.90.so
7f8a45457000-7f8a4545a000 rw-p 00000000 00:00 0
7f8a45484000-7f8a45485000 rw-p 00000000 00:00 0
7f8a45485000-7f8a45486000 r--p 00021000 fd:00 2097348                    /lib64/ld-2.14.90.so
7f8a45486000-7f8a45487000 rw-p 00022000 fd:00 2097348                    /lib64/ld-2.14.90.so
7f8a45487000-7f8a45488000 rw-p 00000000 00:00 0
7fff6273b000-7fff6275c000 rw-p 00000000 00:00 0                          [stack]
7fff627ff000-7fff62800000 r-xp 00000000 00:00 0                          [vdso]
ffffffffff600000-ffffffffff601000 r-xp 00000000 00:00 0                  [vsyscall]

Here, one could guess that 7f8a44492000-7f8a44c92000 is a stack since
the earlier vma that has no permissions (7f8a44e3d000-7f8a4503d000)
but that is not always a reliable way to find out which vma is a
thread stack. Also, /proc/PID/maps and /proc/PID/task/TID/maps
has the same content.

With this patch in place, /proc/PID/task/TID/maps are treated as 'maps
as the task would see it' and hence, only the vma that that task uses
as stack is marked as [stack]. All other 'stack' vmas are marked as
anonymous memory. /proc/PID/maps acts as a thread group level view,
where all stack vmas are marked.

So /proc/PID/maps will look like this:

00400000-00401000 r-xp 00000000 fd:0a 3671804                            /home/siddhesh/a.out
00600000-00601000 rw-p 00000000 fd:0a 3671804                            /home/siddhesh/a.out
019ef000-01a10000 rw-p 00000000 00:00 0                                  [heap]
7f8a44491000-7f8a44492000 ---p 00000000 00:00 0
7f8a44492000-7f8a44c92000 rw-p 00000000 00:00 0                          [stack]
7f8a44c92000-7f8a44e3d000 r-xp 00000000 fd:00 2097482                    /lib64/libc-2.14.90.so
7f8a44e3d000-7f8a4503d000 ---p 001ab000 fd:00 2097482                    /lib64/libc-2.14.90.so
7f8a4503d000-7f8a45041000 r--p 001ab000 fd:00 2097482                    /lib64/libc-2.14.90.so
7f8a45041000-7f8a45043000 rw-p 001af000 fd:00 2097482                    /lib64/libc-2.14.90.so
7f8a45043000-7f8a45048000 rw-p 00000000 00:00 0
7f8a45048000-7f8a4505f000 r-xp 00000000 fd:00 2099938                    /lib64/libpthread-2.14.90.so
7f8a4505f000-7f8a4525e000 ---p 00017000 fd:00 2099938                    /lib64/libpthread-2.14.90.so
7f8a4525e000-7f8a4525f000 r--p 00016000 fd:00 2099938                    /lib64/libpthread-2.14.90.so
7f8a4525f000-7f8a45260000 rw-p 00017000 fd:00 2099938                    /lib64/libpthread-2.14.90.so
7f8a45260000-7f8a45264000 rw-p 00000000 00:00 0
7f8a45264000-7f8a45286000 r-xp 00000000 fd:00 2097348                    /lib64/ld-2.14.90.so
7f8a45457000-7f8a4545a000 rw-p 00000000 00:00 0
7f8a45484000-7f8a45485000 rw-p 00000000 00:00 0
7f8a45485000-7f8a45486000 r--p 00021000 fd:00 2097348                    /lib64/ld-2.14.90.so
7f8a45486000-7f8a45487000 rw-p 00022000 fd:00 2097348                    /lib64/ld-2.14.90.so
7f8a45487000-7f8a45488000 rw-p 00000000 00:00 0
7fff6273b000-7fff6275c000 rw-p 00000000 00:00 0                          [stack]
7fff627ff000-7fff62800000 r-xp 00000000 00:00 0                          [vdso]
ffffffffff600000-ffffffffff601000 r-xp 00000000 00:00 0                  [vsyscall]

Thus marking all vmas that are used as stacks in the thread group. The
task level maps will however look like this:

00400000-00401000 r-xp 00000000 fd:0a 3671804                            /home/siddhesh/a.out
00600000-00601000 rw-p 00000000 fd:0a 3671804                            /home/siddhesh/a.out
019ef000-01a10000 rw-p 00000000 00:00 0                                  [heap]
7f8a44491000-7f8a44492000 ---p 00000000 00:00 0
7f8a44492000-7f8a44c92000 rw-p 00000000 00:00 0                          [stack]
7f8a44c92000-7f8a44e3d000 r-xp 00000000 fd:00 2097482                    /lib64/libc-2.14.90.so
7f8a44e3d000-7f8a4503d000 ---p 001ab000 fd:00 2097482                    /lib64/libc-2.14.90.so
7f8a4503d000-7f8a45041000 r--p 001ab000 fd:00 2097482                    /lib64/libc-2.14.90.so
7f8a45041000-7f8a45043000 rw-p 001af000 fd:00 2097482                    /lib64/libc-2.14.90.so
7f8a45043000-7f8a45048000 rw-p 00000000 00:00 0
7f8a45048000-7f8a4505f000 r-xp 00000000 fd:00 2099938                    /lib64/libpthread-2.14.90.so
7f8a4505f000-7f8a4525e000 ---p 00017000 fd:00 2099938                    /lib64/libpthread-2.14.90.so
7f8a4525e000-7f8a4525f000 r--p 00016000 fd:00 2099938                    /lib64/libpthread-2.14.90.so
7f8a4525f000-7f8a45260000 rw-p 00017000 fd:00 2099938                    /lib64/libpthread-2.14.90.so
7f8a45260000-7f8a45264000 rw-p 00000000 00:00 0
7f8a45264000-7f8a45286000 r-xp 00000000 fd:00 2097348                    /lib64/ld-2.14.90.so
7f8a45457000-7f8a4545a000 rw-p 00000000 00:00 0
7f8a45484000-7f8a45485000 rw-p 00000000 00:00 0
7f8a45485000-7f8a45486000 r--p 00021000 fd:00 2097348                    /lib64/ld-2.14.90.so
7f8a45486000-7f8a45487000 rw-p 00022000 fd:00 2097348                    /lib64/ld-2.14.90.so
7f8a45487000-7f8a45488000 rw-p 00000000 00:00 0
7fff6273b000-7fff6275c000 rw-p 00000000 00:00 0
7fff627ff000-7fff62800000 r-xp 00000000 00:00 0                          [vdso]
ffffffffff600000-ffffffffff601000 r-xp 00000000 00:00 0                  [vsyscall]

where only the vma that is being used as a stack by *that* task is
marked as [stack].

Analogous changes have been made to /proc/PID/smaps,
/proc/PID/numa_maps, /proc/PID/task/TID/smaps and
/proc/PID/task/TID/numa_maps. Relevant snippets from smaps and
numa_maps:

[siddhesh@localhost ~ ]$ pgrep a.out
1441
[siddhesh@localhost ~ ]$ cat /proc/1441/smaps | grep "\[stack\]"
7f8a44492000-7f8a44c92000 rw-p 00000000 00:00 0                          [stack]
7fff6273b000-7fff6275c000 rw-p 00000000 00:00 0                          [stack]
[siddhesh@localhost ~ ]$ cat /proc/1441/task/1442/smaps | grep "\[stack\]"
7f8a44492000-7f8a44c92000 rw-p 00000000 00:00 0                          [stack]
[siddhesh@localhost ~ ]$ cat /proc/1441/task/1441/smaps | grep "\[stack\]"
7fff6273b000-7fff6275c000 rw-p 00000000 00:00 0                          [stack]
[siddhesh@localhost ~ ]$ cat /proc/1441/numa_maps | grep "stack"
7f8a44492000 default stack anon=2 dirty=2 N0=2
7fff6273a000 default stack anon=3 dirty=3 N0=3
[siddhesh@localhost ~ ]$ cat /proc/1441/task/1442/numa_maps | grep "stack"
7f8a44492000 default stack anon=2 dirty=2 N0=2
[siddhesh@localhost ~ ]$ cat /proc/1441/task/1441/numa_maps | grep "stack"
7fff6273a000 default stack anon=3 dirty=3 N0=3

Signed-off-by: Siddhesh Poyarekar <siddhesh.poyarekar@gmail.com>
---
 Documentation/filesystems/proc.txt |   10 ++-
 fs/proc/base.c                     |   12 ++--
 fs/proc/internal.h                 |    9 ++-
 fs/proc/task_mmu.c                 |  139 ++++++++++++++++++++++++++++++------
 fs/proc/task_nommu.c               |   57 ++++++++++++---
 include/linux/mm.h                 |    9 +++
 mm/memory.c                        |   22 ++++++
 7 files changed, 214 insertions(+), 44 deletions(-)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index a76a26a..e0f9de3 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -290,7 +290,7 @@ Table 1-4: Contents of the stat files (as of 2.6.30-rc7)
   rsslim        current limit in bytes on the rss
   start_code    address above which program text can run
   end_code      address below which program text can run
-  start_stack   address of the start of the stack
+  start_stack   address of the start of the main process stack
   esp           current value of ESP
   eip           current value of EIP
   pending       bitmap of pending signals
@@ -356,12 +356,18 @@ The "pathname" shows the name associated file for this mapping.  If the mapping
 is not associated with a file:
 
  [heap]                   = the heap of the program
- [stack]                  = the stack of the main process
+ [stack]                  = the mapping is used as a stack by one
+                            of the threads of the process
  [vdso]                   = the "virtual dynamic shared object",
                             the kernel system call handler
 
  or if empty, the mapping is anonymous.
 
+The /proc/PID/task/TID/maps is a view of the virtual memory from the viewpoint
+of the individual tasks of a process. In this file you will see a mapping marked
+as [stack] only if that task sees it as a stack. This is a key difference from
+the content of /proc/PID/maps, where you will see all mappings that are being
+used as stack by all of those tasks.
 
 The /proc/PID/smaps is an extension based on maps, showing the memory
 consumption for each of the process's mappings. For each of mappings there
diff --git a/fs/proc/base.c b/fs/proc/base.c
index d4548dd..558660a 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -2990,9 +2990,9 @@ static const struct pid_entry tgid_base_stuff[] = {
 	INF("cmdline",    S_IRUGO, proc_pid_cmdline),
 	ONE("stat",       S_IRUGO, proc_tgid_stat),
 	ONE("statm",      S_IRUGO, proc_pid_statm),
-	REG("maps",       S_IRUGO, proc_maps_operations),
+	REG("maps",       S_IRUGO, proc_pid_maps_operations),
 #ifdef CONFIG_NUMA
-	REG("numa_maps",  S_IRUGO, proc_numa_maps_operations),
+	REG("numa_maps",  S_IRUGO, proc_pid_numa_maps_operations),
 #endif
 	REG("mem",        S_IRUSR|S_IWUSR, proc_mem_operations),
 	LNK("cwd",        proc_cwd_link),
@@ -3003,7 +3003,7 @@ static const struct pid_entry tgid_base_stuff[] = {
 	REG("mountstats", S_IRUSR, proc_mountstats_operations),
 #ifdef CONFIG_PROC_PAGE_MONITOR
 	REG("clear_refs", S_IWUSR, proc_clear_refs_operations),
-	REG("smaps",      S_IRUGO, proc_smaps_operations),
+	REG("smaps",      S_IRUGO, proc_pid_smaps_operations),
 	REG("pagemap",    S_IRUGO, proc_pagemap_operations),
 #endif
 #ifdef CONFIG_SECURITY
@@ -3349,9 +3349,9 @@ static const struct pid_entry tid_base_stuff[] = {
 	INF("cmdline",   S_IRUGO, proc_pid_cmdline),
 	ONE("stat",      S_IRUGO, proc_tid_stat),
 	ONE("statm",     S_IRUGO, proc_pid_statm),
-	REG("maps",      S_IRUGO, proc_maps_operations),
+	REG("maps",      S_IRUGO, proc_tid_maps_operations),
 #ifdef CONFIG_NUMA
-	REG("numa_maps", S_IRUGO, proc_numa_maps_operations),
+	REG("numa_maps", S_IRUGO, proc_tid_numa_maps_operations),
 #endif
 	REG("mem",       S_IRUSR|S_IWUSR, proc_mem_operations),
 	LNK("cwd",       proc_cwd_link),
@@ -3361,7 +3361,7 @@ static const struct pid_entry tid_base_stuff[] = {
 	REG("mountinfo",  S_IRUGO, proc_mountinfo_operations),
 #ifdef CONFIG_PROC_PAGE_MONITOR
 	REG("clear_refs", S_IWUSR, proc_clear_refs_operations),
-	REG("smaps",     S_IRUGO, proc_smaps_operations),
+	REG("smaps",     S_IRUGO, proc_tid_smaps_operations),
 	REG("pagemap",    S_IRUGO, proc_pagemap_operations),
 #endif
 #ifdef CONFIG_SECURITY
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index 2925775..c44efe1 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -53,9 +53,12 @@ extern int proc_pid_statm(struct seq_file *m, struct pid_namespace *ns,
 				struct pid *pid, struct task_struct *task);
 extern loff_t mem_lseek(struct file *file, loff_t offset, int orig);
 
-extern const struct file_operations proc_maps_operations;
-extern const struct file_operations proc_numa_maps_operations;
-extern const struct file_operations proc_smaps_operations;
+extern const struct file_operations proc_pid_maps_operations;
+extern const struct file_operations proc_tid_maps_operations;
+extern const struct file_operations proc_pid_numa_maps_operations;
+extern const struct file_operations proc_tid_numa_maps_operations;
+extern const struct file_operations proc_pid_smaps_operations;
+extern const struct file_operations proc_tid_smaps_operations;
 extern const struct file_operations proc_clear_refs_operations;
 extern const struct file_operations proc_pagemap_operations;
 extern const struct file_operations proc_net_operations;
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 7dcd2a2..3e166f5 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -209,10 +209,12 @@ static int do_maps_open(struct inode *inode, struct file *file,
 	return ret;
 }
 
-static void show_map_vma(struct seq_file *m, struct vm_area_struct *vma)
+static void show_map_vma(struct seq_file *m, struct vm_area_struct *vma, int is_pid)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	struct file *file = vma->vm_file;
+	struct proc_maps_private *priv = m->private;
+	struct task_struct *task = priv->task;
 	vm_flags_t flags = vma->vm_flags;
 	unsigned long ino = 0;
 	unsigned long long pgoff = 0;
@@ -259,8 +261,7 @@ static void show_map_vma(struct seq_file *m, struct vm_area_struct *vma)
 				if (vma->vm_start <= mm->brk &&
 						vma->vm_end >= mm->start_brk) {
 					name = "[heap]";
-				} else if (vma->vm_start <= mm->start_stack &&
-					   vma->vm_end >= mm->start_stack) {
+				} else if (vm_is_stack(task, vma, is_pid)) {
 					name = "[stack]";
 				}
 			} else {
@@ -275,13 +276,13 @@ static void show_map_vma(struct seq_file *m, struct vm_area_struct *vma)
 	seq_putc(m, '\n');
 }
 
-static int show_map(struct seq_file *m, void *v)
+static int show_map(struct seq_file *m, void *v, int is_pid)
 {
 	struct vm_area_struct *vma = v;
 	struct proc_maps_private *priv = m->private;
 	struct task_struct *task = priv->task;
 
-	show_map_vma(m, vma);
+	show_map_vma(m, vma, is_pid);
 
 	if (m->count < m->size)  /* vma is copied successfully */
 		m->version = (vma != get_gate_vma(task->mm))
@@ -289,20 +290,49 @@ static int show_map(struct seq_file *m, void *v)
 	return 0;
 }
 
+static int show_pid_map(struct seq_file *m, void *v)
+{
+	return show_map(m, v, 1);
+}
+
+static int show_tid_map(struct seq_file *m, void *v)
+{
+	return show_map(m, v, 0);
+}
+
 static const struct seq_operations proc_pid_maps_op = {
 	.start	= m_start,
 	.next	= m_next,
 	.stop	= m_stop,
-	.show	= show_map
+	.show	= show_pid_map
 };
 
-static int maps_open(struct inode *inode, struct file *file)
+static const struct seq_operations proc_tid_maps_op = {
+	.start	= m_start,
+	.next	= m_next,
+	.stop	= m_stop,
+	.show	= show_tid_map
+};
+
+static int pid_maps_open(struct inode *inode, struct file *file)
 {
 	return do_maps_open(inode, file, &proc_pid_maps_op);
 }
 
-const struct file_operations proc_maps_operations = {
-	.open		= maps_open,
+static int tid_maps_open(struct inode *inode, struct file *file)
+{
+	return do_maps_open(inode, file, &proc_tid_maps_op);
+}
+
+const struct file_operations proc_pid_maps_operations = {
+	.open		= pid_maps_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release_private,
+};
+
+const struct file_operations proc_tid_maps_operations = {
+	.open		= tid_maps_open,
 	.read		= seq_read,
 	.llseek		= seq_lseek,
 	.release	= seq_release_private,
@@ -422,7 +452,7 @@ static int smaps_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 	return 0;
 }
 
-static int show_smap(struct seq_file *m, void *v)
+static int show_smap(struct seq_file *m, void *v, int is_pid)
 {
 	struct proc_maps_private *priv = m->private;
 	struct task_struct *task = priv->task;
@@ -440,7 +470,7 @@ static int show_smap(struct seq_file *m, void *v)
 	if (vma->vm_mm && !is_vm_hugetlb_page(vma))
 		walk_page_range(vma->vm_start, vma->vm_end, &smaps_walk);
 
-	show_map_vma(m, vma);
+	show_map_vma(m, vma, is_pid);
 
 	seq_printf(m,
 		   "Size:           %8lu kB\n"
@@ -479,20 +509,49 @@ static int show_smap(struct seq_file *m, void *v)
 	return 0;
 }
 
+static int show_pid_smap(struct seq_file *m, void *v)
+{
+	return show_smap(m, v, 1);
+}
+
+static int show_tid_smap(struct seq_file *m, void *v)
+{
+	return show_smap(m, v, 0);
+}
+
 static const struct seq_operations proc_pid_smaps_op = {
 	.start	= m_start,
 	.next	= m_next,
 	.stop	= m_stop,
-	.show	= show_smap
+	.show	= show_pid_smap
+};
+
+static const struct seq_operations proc_tid_smaps_op = {
+	.start	= m_start,
+	.next	= m_next,
+	.stop	= m_stop,
+	.show	= show_tid_smap
 };
 
-static int smaps_open(struct inode *inode, struct file *file)
+static int pid_smaps_open(struct inode *inode, struct file *file)
 {
 	return do_maps_open(inode, file, &proc_pid_smaps_op);
 }
 
-const struct file_operations proc_smaps_operations = {
-	.open		= smaps_open,
+static int tid_smaps_open(struct inode *inode, struct file *file)
+{
+	return do_maps_open(inode, file, &proc_tid_smaps_op);
+}
+
+const struct file_operations proc_pid_smaps_operations = {
+	.open		= pid_smaps_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release_private,
+};
+
+const struct file_operations proc_tid_smaps_operations = {
+	.open		= tid_smaps_open,
 	.read		= seq_read,
 	.llseek		= seq_lseek,
 	.release	= seq_release_private,
@@ -1002,7 +1061,7 @@ static int gather_hugetbl_stats(pte_t *pte, unsigned long hmask,
 /*
  * Display pages allocated per node and memory policy via /proc.
  */
-static int show_numa_map(struct seq_file *m, void *v)
+static int show_numa_map(struct seq_file *m, void *v, int is_pid)
 {
 	struct numa_maps_private *numa_priv = m->private;
 	struct proc_maps_private *proc_priv = &numa_priv->proc_maps;
@@ -1039,8 +1098,7 @@ static int show_numa_map(struct seq_file *m, void *v)
 		seq_path(m, &file->f_path, "\n\t= ");
 	} else if (vma->vm_start <= mm->brk && vma->vm_end >= mm->start_brk) {
 		seq_printf(m, " heap");
-	} else if (vma->vm_start <= mm->start_stack &&
-			vma->vm_end >= mm->start_stack) {
+	} else if (vm_is_stack(proc_priv->task, vma, is_pid)) {
 		seq_printf(m, " stack");
 	}
 
@@ -1084,21 +1142,39 @@ out:
 	return 0;
 }
 
+static int show_pid_numa_map(struct seq_file *m, void *v)
+{
+	return show_numa_map(m, v, 1);
+}
+
+static int show_tid_numa_map(struct seq_file *m, void *v)
+{
+	return show_numa_map(m, v, 0);
+}
+
 static const struct seq_operations proc_pid_numa_maps_op = {
         .start  = m_start,
         .next   = m_next,
         .stop   = m_stop,
-        .show   = show_numa_map,
+        .show   = show_pid_numa_map,
 };
 
-static int numa_maps_open(struct inode *inode, struct file *file)
+static const struct seq_operations proc_tid_numa_maps_op = {
+        .start  = m_start,
+        .next   = m_next,
+        .stop   = m_stop,
+        .show   = show_tid_numa_map,
+};
+
+static int numa_maps_open(struct inode *inode, struct file *file,
+			  const struct seq_operations *ops)
 {
 	struct numa_maps_private *priv;
 	int ret = -ENOMEM;
 	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
 	if (priv) {
 		priv->proc_maps.pid = proc_pid(inode);
-		ret = seq_open(file, &proc_pid_numa_maps_op);
+		ret = seq_open(file, ops);
 		if (!ret) {
 			struct seq_file *m = file->private_data;
 			m->private = priv;
@@ -1109,8 +1185,25 @@ static int numa_maps_open(struct inode *inode, struct file *file)
 	return ret;
 }
 
-const struct file_operations proc_numa_maps_operations = {
-	.open		= numa_maps_open,
+static int pid_numa_maps_open(struct inode *inode, struct file *file)
+{
+	return numa_maps_open(inode, file, &proc_pid_numa_maps_op);
+}
+
+static int tid_numa_maps_open(struct inode *inode, struct file *file)
+{
+	return numa_maps_open(inode, file, &proc_tid_numa_maps_op);
+}
+
+const struct file_operations proc_pid_numa_maps_operations = {
+	.open		= pid_numa_maps_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release_private,
+};
+
+const struct file_operations proc_tid_numa_maps_operations = {
+	.open		= tid_numa_maps_open,
 	.read		= seq_read,
 	.llseek		= seq_lseek,
 	.release	= seq_release_private,
diff --git a/fs/proc/task_nommu.c b/fs/proc/task_nommu.c
index 980de54..bdfff69 100644
--- a/fs/proc/task_nommu.c
+++ b/fs/proc/task_nommu.c
@@ -134,9 +134,11 @@ static void pad_len_spaces(struct seq_file *m, int len)
 /*
  * display a single VMA to a sequenced file
  */
-static int nommu_vma_show(struct seq_file *m, struct vm_area_struct *vma)
+static int nommu_vma_show(struct seq_file *m, struct vm_area_struct *vma,
+			  int is_pid)
 {
 	struct mm_struct *mm = vma->vm_mm;
+	struct proc_maps_private *priv = m->private;
 	unsigned long ino = 0;
 	struct file *file;
 	dev_t dev = 0;
@@ -168,8 +170,7 @@ static int nommu_vma_show(struct seq_file *m, struct vm_area_struct *vma)
 		pad_len_spaces(m, len);
 		seq_path(m, &file->f_path, "");
 	} else if (mm) {
-		if (vma->vm_start <= mm->start_stack &&
-			vma->vm_end >= mm->start_stack) {
+		if (vm_is_stack(priv->task, vma, is_pid))
 			pad_len_spaces(m, len);
 			seq_puts(m, "[stack]");
 		}
@@ -182,11 +183,22 @@ static int nommu_vma_show(struct seq_file *m, struct vm_area_struct *vma)
 /*
  * display mapping lines for a particular process's /proc/pid/maps
  */
-static int show_map(struct seq_file *m, void *_p)
+static int show_map(struct seq_file *m, void *_p, int is_pid)
 {
 	struct rb_node *p = _p;
 
-	return nommu_vma_show(m, rb_entry(p, struct vm_area_struct, vm_rb));
+	return nommu_vma_show(m, rb_entry(p, struct vm_area_struct, vm_rb),
+			      is_pid);
+}
+
+static int show_pid_map(struct seq_file *m, void *_p)
+{
+	return show_map(m, _p, 1);
+}
+
+static int show_tid_map(struct seq_file *m, void *_p)
+{
+	return show_map(m, _p, 0);
 }
 
 static void *m_start(struct seq_file *m, loff_t *pos)
@@ -240,10 +252,18 @@ static const struct seq_operations proc_pid_maps_ops = {
 	.start	= m_start,
 	.next	= m_next,
 	.stop	= m_stop,
-	.show	= show_map
+	.show	= show_pid_map
+};
+
+static const struct seq_operations proc_tid_maps_ops = {
+	.start	= m_start,
+	.next	= m_next,
+	.stop	= m_stop,
+	.show	= show_tid_map
 };
 
-static int maps_open(struct inode *inode, struct file *file)
+static int maps_open(struct inode *inode, struct file *file,
+		     const struct seq_operations *ops)
 {
 	struct proc_maps_private *priv;
 	int ret = -ENOMEM;
@@ -251,7 +271,7 @@ static int maps_open(struct inode *inode, struct file *file)
 	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
 	if (priv) {
 		priv->pid = proc_pid(inode);
-		ret = seq_open(file, &proc_pid_maps_ops);
+		ret = seq_open(file, ops);
 		if (!ret) {
 			struct seq_file *m = file->private_data;
 			m->private = priv;
@@ -262,8 +282,25 @@ static int maps_open(struct inode *inode, struct file *file)
 	return ret;
 }
 
-const struct file_operations proc_maps_operations = {
-	.open		= maps_open,
+static int pid_maps_open(struct inode *inode, struct file *file)
+{
+	return maps_open(inode, file, &proc_pid_maps_ops);
+}
+
+static int tid_maps_open(struct inode *inode, struct file *file)
+{
+	return maps_open(inode, file, &proc_tid_maps_ops);
+}
+
+const struct file_operations proc_pid_maps_operations = {
+	.open		= pid_maps_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release_private,
+};
+
+const struct file_operations proc_tid_maps_operations = {
+	.open		= tid_maps_open,
 	.read		= seq_read,
 	.llseek		= seq_lseek,
 	.release	= seq_release_private,
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 17b27cd..b0fc583 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1040,6 +1040,15 @@ static inline int stack_guard_page_end(struct vm_area_struct *vma,
 		!vma_growsup(vma->vm_next, addr);
 }
 
+/* Check if the vma is being used as a stack by this task */
+static inline int vm_is_stack_for_task(struct task_struct *t,
+				       struct vm_area_struct *vma)
+{
+	return (vma->vm_start <= KSTK_ESP(t) && vma->vm_end >= KSTK_ESP(t));
+}
+
+extern int vm_is_stack(struct task_struct *task, struct vm_area_struct *vma, int in_group);
+
 extern unsigned long move_page_tables(struct vm_area_struct *vma,
 		unsigned long old_addr, struct vm_area_struct *new_vma,
 		unsigned long new_addr, unsigned long len);
diff --git a/mm/memory.c b/mm/memory.c
index fa2f04e..601a920 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3909,6 +3909,28 @@ void print_vma_addr(char *prefix, unsigned long ip)
 	up_read(&current->mm->mmap_sem);
 }
 
+/*
+ * Check if the vma is being used as a stack.
+ * If is_group is non-zero, check in the entire thread group or else
+ * just check in the current task.
+ */
+int vm_is_stack(struct task_struct *task,
+			      struct vm_area_struct *vma, int in_group)
+{
+	if (vm_is_stack_for_task(task, vma))
+		return 1;
+
+	if (in_group) {
+		struct task_struct *t = task;
+		while_each_thread(task, t) {
+			if (vm_is_stack_for_task(t, vma))
+				return 1;
+		}
+	}
+
+	return 0;
+}
+
 #ifdef CONFIG_PROVE_LOCKING
 void might_fault(void)
 {
-- 
1.7.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

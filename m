Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 67D7E6B004D
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 23:24:05 -0500 (EST)
Received: by yhoo22 with SMTP id o22so3409655yho.14
        for <linux-mm@kvack.org>; Mon, 20 Feb 2012 20:24:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1328972596-4142-1-git-send-email-siddhesh.poyarekar@gmail.com>
References: <4F32B776.6070007@gmail.com>
	<1328972596-4142-1-git-send-email-siddhesh.poyarekar@gmail.com>
Date: Tue, 21 Feb 2012 09:54:04 +0530
Message-ID: <CAAHN_R1Ho-JNLSKXM_3uU8nTpFHr87ujUEoFJChjZyk4iBYzjA@mail.gmail.com>
Subject: [RESEND][PATCH] Mark thread stack correctly in proc/<pid>/maps
From: Siddhesh Poyarekar <siddhesh.poyarekar@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Jamie Lokier <jamie@shareable.org>, Mike Frysinger <vapier@gentoo.org>

Hi,

Resending patch.

Regards,
Siddhesh


---------- Forwarded message ----------
From: Siddhesh Poyarekar <siddhesh.poyarekar@gmail.com>
Date: Sat, Feb 11, 2012 at 8:33 PM
Subject: [PATCH] Mark thread stack correctly in proc/<pid>/maps
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Viro
<viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Jamie Lokier
<jamie@shareable.org>, vapier@gentoo.org, Siddhesh Poyarekar
<siddhesh.poyarekar@gmail.com>


Stack for a new thread is mapped by userspace code and passed via
sys_clone. This memory is currently seen as anonymous in
/proc/<pid>/maps, which makes it difficult to ascertain which mappings
are being used for thread stacks. This patch uses the individual task
stack pointers to determine which vmas are actually thread stacks.

The display for maps, smaps and numa_maps is now different at the
thread group (/proc/PID/maps) and thread (/proc/PID/task/TID/maps)
levels. The idea is to give the mapping as the individual tasks see it
in /proc/PID/task/TID/maps and then give an overview of the entire mm
as it were, in /proc/PID/maps.

At the thread group level, all vmas that are used as stacks are marked
as such. At the thread level however, only the stack that the task in
question uses is marked as such and all others (including the main
stack) are marked as anonymous memory.

Signed-off-by: Siddhesh Poyarekar <siddhesh.poyarekar@gmail.com>
---
=A0Documentation/filesystems/proc.txt | =A0 10 ++-
=A0fs/proc/base.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 12 ++--
=A0fs/proc/internal.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A09 ++-
=A0fs/proc/task_mmu.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0139 ++++++++++++=
++++++++++++++++++------
=A0fs/proc/task_nommu.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 57 ++++++++++++--=
-
=A0include/linux/mm.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A09 +++
=A0mm/memory.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 22 ++++=
++
=A07 files changed, 214 insertions(+), 44 deletions(-)

diff --git a/Documentation/filesystems/proc.txt
b/Documentation/filesystems/proc.txt
index a76a26a..e0f9de3 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -290,7 +290,7 @@ Table 1-4: Contents of the stat files (as of 2.6.30-rc7=
)
=A0 rsslim =A0 =A0 =A0 =A0current limit in bytes on the rss
=A0 start_code =A0 =A0address above which program text can run
=A0 end_code =A0 =A0 =A0address below which program text can run
- =A0start_stack =A0 address of the start of the stack
+ =A0start_stack =A0 address of the start of the main process stack
=A0 esp =A0 =A0 =A0 =A0 =A0 current value of ESP
=A0 eip =A0 =A0 =A0 =A0 =A0 current value of EIP
=A0 pending =A0 =A0 =A0 bitmap of pending signals
@@ -356,12 +356,18 @@ The "pathname" shows the name associated file
for this mapping. =A0If the mapping
=A0is not associated with a file:

=A0[heap] =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D the heap of the program
- [stack] =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=3D the stack of the main proc=
ess
+ [stack] =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=3D the mapping is used as a s=
tack by one
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0of the threads of =
the process
=A0[vdso] =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D the "virtual dynamic shar=
ed object",
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 the kernel system c=
all handler

=A0or if empty, the mapping is anonymous.

+The /proc/PID/task/TID/maps is a view of the virtual memory from the viewp=
oint
+of the individual tasks of a process. In this file you will see a
mapping marked
+as [stack] only if that task sees it as a stack. This is a key difference =
from
+the content of /proc/PID/maps, where you will see all mappings that are be=
ing
+used as stack by all of those tasks.

=A0The /proc/PID/smaps is an extension based on maps, showing the memory
=A0consumption for each of the process's mappings. For each of mappings the=
re
diff --git a/fs/proc/base.c b/fs/proc/base.c
index d4548dd..558660a 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -2990,9 +2990,9 @@ static const struct pid_entry tgid_base_stuff[] =3D {
=A0 =A0 =A0 =A0INF("cmdline", =A0 =A0S_IRUGO, proc_pid_cmdline),
=A0 =A0 =A0 =A0ONE("stat", =A0 =A0 =A0 S_IRUGO, proc_tgid_stat),
=A0 =A0 =A0 =A0ONE("statm", =A0 =A0 =A0S_IRUGO, proc_pid_statm),
- =A0 =A0 =A0 REG("maps", =A0 =A0 =A0 S_IRUGO, proc_maps_operations),
+ =A0 =A0 =A0 REG("maps", =A0 =A0 =A0 S_IRUGO, proc_pid_maps_operations),
=A0#ifdef CONFIG_NUMA
- =A0 =A0 =A0 REG("numa_maps", =A0S_IRUGO, proc_numa_maps_operations),
+ =A0 =A0 =A0 REG("numa_maps", =A0S_IRUGO, proc_pid_numa_maps_operations),
=A0#endif
=A0 =A0 =A0 =A0REG("mem", =A0 =A0 =A0 =A0S_IRUSR|S_IWUSR, proc_mem_operatio=
ns),
=A0 =A0 =A0 =A0LNK("cwd", =A0 =A0 =A0 =A0proc_cwd_link),
@@ -3003,7 +3003,7 @@ static const struct pid_entry tgid_base_stuff[] =3D {
=A0 =A0 =A0 =A0REG("mountstats", S_IRUSR, proc_mountstats_operations),
=A0#ifdef CONFIG_PROC_PAGE_MONITOR
=A0 =A0 =A0 =A0REG("clear_refs", S_IWUSR, proc_clear_refs_operations),
- =A0 =A0 =A0 REG("smaps", =A0 =A0 =A0S_IRUGO, proc_smaps_operations),
+ =A0 =A0 =A0 REG("smaps", =A0 =A0 =A0S_IRUGO, proc_pid_smaps_operations),
=A0 =A0 =A0 =A0REG("pagemap", =A0 =A0S_IRUGO, proc_pagemap_operations),
=A0#endif
=A0#ifdef CONFIG_SECURITY
@@ -3349,9 +3349,9 @@ static const struct pid_entry tid_base_stuff[] =3D {
=A0 =A0 =A0 =A0INF("cmdline", =A0 S_IRUGO, proc_pid_cmdline),
=A0 =A0 =A0 =A0ONE("stat", =A0 =A0 =A0S_IRUGO, proc_tid_stat),
=A0 =A0 =A0 =A0ONE("statm", =A0 =A0 S_IRUGO, proc_pid_statm),
- =A0 =A0 =A0 REG("maps", =A0 =A0 =A0S_IRUGO, proc_maps_operations),
+ =A0 =A0 =A0 REG("maps", =A0 =A0 =A0S_IRUGO, proc_tid_maps_operations),
=A0#ifdef CONFIG_NUMA
- =A0 =A0 =A0 REG("numa_maps", S_IRUGO, proc_numa_maps_operations),
+ =A0 =A0 =A0 REG("numa_maps", S_IRUGO, proc_tid_numa_maps_operations),
=A0#endif
=A0 =A0 =A0 =A0REG("mem", =A0 =A0 =A0 S_IRUSR|S_IWUSR, proc_mem_operations)=
,
=A0 =A0 =A0 =A0LNK("cwd", =A0 =A0 =A0 proc_cwd_link),
@@ -3361,7 +3361,7 @@ static const struct pid_entry tid_base_stuff[] =3D {
=A0 =A0 =A0 =A0REG("mountinfo", =A0S_IRUGO, proc_mountinfo_operations),
=A0#ifdef CONFIG_PROC_PAGE_MONITOR
=A0 =A0 =A0 =A0REG("clear_refs", S_IWUSR, proc_clear_refs_operations),
- =A0 =A0 =A0 REG("smaps", =A0 =A0 S_IRUGO, proc_smaps_operations),
+ =A0 =A0 =A0 REG("smaps", =A0 =A0 S_IRUGO, proc_tid_smaps_operations),
=A0 =A0 =A0 =A0REG("pagemap", =A0 =A0S_IRUGO, proc_pagemap_operations),
=A0#endif
=A0#ifdef CONFIG_SECURITY
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index 2925775..c44efe1 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -53,9 +53,12 @@ extern int proc_pid_statm(struct seq_file *m,
struct pid_namespace *ns,
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct pid *=
pid, struct task_struct *task);
=A0extern loff_t mem_lseek(struct file *file, loff_t offset, int orig);

-extern const struct file_operations proc_maps_operations;
-extern const struct file_operations proc_numa_maps_operations;
-extern const struct file_operations proc_smaps_operations;
+extern const struct file_operations proc_pid_maps_operations;
+extern const struct file_operations proc_tid_maps_operations;
+extern const struct file_operations proc_pid_numa_maps_operations;
+extern const struct file_operations proc_tid_numa_maps_operations;
+extern const struct file_operations proc_pid_smaps_operations;
+extern const struct file_operations proc_tid_smaps_operations;
=A0extern const struct file_operations proc_clear_refs_operations;
=A0extern const struct file_operations proc_pagemap_operations;
=A0extern const struct file_operations proc_net_operations;
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 7dcd2a2..3e166f5 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -209,10 +209,12 @@ static int do_maps_open(struct inode *inode,
struct file *file,
=A0 =A0 =A0 =A0return ret;
=A0}

-static void show_map_vma(struct seq_file *m, struct vm_area_struct *vma)
+static void show_map_vma(struct seq_file *m, struct vm_area_struct
*vma, int is_pid)
=A0{
=A0 =A0 =A0 =A0struct mm_struct *mm =3D vma->vm_mm;
=A0 =A0 =A0 =A0struct file *file =3D vma->vm_file;
+ =A0 =A0 =A0 struct proc_maps_private *priv =3D m->private;
+ =A0 =A0 =A0 struct task_struct *task =3D priv->task;
=A0 =A0 =A0 =A0vm_flags_t flags =3D vma->vm_flags;
=A0 =A0 =A0 =A0unsigned long ino =3D 0;
=A0 =A0 =A0 =A0unsigned long long pgoff =3D 0;
@@ -259,8 +261,7 @@ static void show_map_vma(struct seq_file *m,
struct vm_area_struct *vma)
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (vma->vm_=
start <=3D mm->brk &&
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0vma->vm_end >=3D mm->start_brk) {
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0name =3D "[heap]";
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else if (vm=
a->vm_start <=3D mm->start_stack &&
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0vma->vm_end >=3D mm->start_stack) {
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else if (vm=
_is_stack(task, vma, is_pid)) {
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0name =3D "[stack]";
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else {
@@ -275,13 +276,13 @@ static void show_map_vma(struct seq_file *m,
struct vm_area_struct *vma)
=A0 =A0 =A0 =A0seq_putc(m, '\n');
=A0}

-static int show_map(struct seq_file *m, void *v)
+static int show_map(struct seq_file *m, void *v, int is_pid)
=A0{
=A0 =A0 =A0 =A0struct vm_area_struct *vma =3D v;
=A0 =A0 =A0 =A0struct proc_maps_private *priv =3D m->private;
=A0 =A0 =A0 =A0struct task_struct *task =3D priv->task;

- =A0 =A0 =A0 show_map_vma(m, vma);
+ =A0 =A0 =A0 show_map_vma(m, vma, is_pid);

=A0 =A0 =A0 =A0if (m->count < m->size) =A0/* vma is copied successfully */
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0m->version =3D (vma !=3D get_gate_vma(task->=
mm))
@@ -289,20 +290,49 @@ static int show_map(struct seq_file *m, void *v)
=A0 =A0 =A0 =A0return 0;
=A0}

+static int show_pid_map(struct seq_file *m, void *v)
+{
+ =A0 =A0 =A0 return show_map(m, v, 1);
+}
+
+static int show_tid_map(struct seq_file *m, void *v)
+{
+ =A0 =A0 =A0 return show_map(m, v, 0);
+}
+
=A0static const struct seq_operations proc_pid_maps_op =3D {
=A0 =A0 =A0 =A0.start =A0=3D m_start,
=A0 =A0 =A0 =A0.next =A0 =3D m_next,
=A0 =A0 =A0 =A0.stop =A0 =3D m_stop,
- =A0 =A0 =A0 .show =A0 =3D show_map
+ =A0 =A0 =A0 .show =A0 =3D show_pid_map
=A0};

-static int maps_open(struct inode *inode, struct file *file)
+static const struct seq_operations proc_tid_maps_op =3D {
+ =A0 =A0 =A0 .start =A0=3D m_start,
+ =A0 =A0 =A0 .next =A0 =3D m_next,
+ =A0 =A0 =A0 .stop =A0 =3D m_stop,
+ =A0 =A0 =A0 .show =A0 =3D show_tid_map
+};
+
+static int pid_maps_open(struct inode *inode, struct file *file)
=A0{
=A0 =A0 =A0 =A0return do_maps_open(inode, file, &proc_pid_maps_op);
=A0}

-const struct file_operations proc_maps_operations =3D {
- =A0 =A0 =A0 .open =A0 =A0 =A0 =A0 =A0 =3D maps_open,
+static int tid_maps_open(struct inode *inode, struct file *file)
+{
+ =A0 =A0 =A0 return do_maps_open(inode, file, &proc_tid_maps_op);
+}
+
+const struct file_operations proc_pid_maps_operations =3D {
+ =A0 =A0 =A0 .open =A0 =A0 =A0 =A0 =A0 =3D pid_maps_open,
+ =A0 =A0 =A0 .read =A0 =A0 =A0 =A0 =A0 =3D seq_read,
+ =A0 =A0 =A0 .llseek =A0 =A0 =A0 =A0 =3D seq_lseek,
+ =A0 =A0 =A0 .release =A0 =A0 =A0 =A0=3D seq_release_private,
+};
+
+const struct file_operations proc_tid_maps_operations =3D {
+ =A0 =A0 =A0 .open =A0 =A0 =A0 =A0 =A0 =3D tid_maps_open,
=A0 =A0 =A0 =A0.read =A0 =A0 =A0 =A0 =A0 =3D seq_read,
=A0 =A0 =A0 =A0.llseek =A0 =A0 =A0 =A0 =3D seq_lseek,
=A0 =A0 =A0 =A0.release =A0 =A0 =A0 =A0=3D seq_release_private,
@@ -422,7 +452,7 @@ static int smaps_pte_range(pmd_t *pmd, unsigned
long addr, unsigned long end,
=A0 =A0 =A0 =A0return 0;
=A0}

-static int show_smap(struct seq_file *m, void *v)
+static int show_smap(struct seq_file *m, void *v, int is_pid)
=A0{
=A0 =A0 =A0 =A0struct proc_maps_private *priv =3D m->private;
=A0 =A0 =A0 =A0struct task_struct *task =3D priv->task;
@@ -440,7 +470,7 @@ static int show_smap(struct seq_file *m, void *v)
=A0 =A0 =A0 =A0if (vma->vm_mm && !is_vm_hugetlb_page(vma))
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0walk_page_range(vma->vm_start, vma->vm_end, =
&smaps_walk);

- =A0 =A0 =A0 show_map_vma(m, vma);
+ =A0 =A0 =A0 show_map_vma(m, vma, is_pid);

=A0 =A0 =A0 =A0seq_printf(m,
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "Size: =A0 =A0 =A0 =A0 =A0 %8lu kB\n"
@@ -479,20 +509,49 @@ static int show_smap(struct seq_file *m, void *v)
=A0 =A0 =A0 =A0return 0;
=A0}

+static int show_pid_smap(struct seq_file *m, void *v)
+{
+ =A0 =A0 =A0 return show_smap(m, v, 1);
+}
+
+static int show_tid_smap(struct seq_file *m, void *v)
+{
+ =A0 =A0 =A0 return show_smap(m, v, 0);
+}
+
=A0static const struct seq_operations proc_pid_smaps_op =3D {
=A0 =A0 =A0 =A0.start =A0=3D m_start,
=A0 =A0 =A0 =A0.next =A0 =3D m_next,
=A0 =A0 =A0 =A0.stop =A0 =3D m_stop,
- =A0 =A0 =A0 .show =A0 =3D show_smap
+ =A0 =A0 =A0 .show =A0 =3D show_pid_smap
+};
+
+static const struct seq_operations proc_tid_smaps_op =3D {
+ =A0 =A0 =A0 .start =A0=3D m_start,
+ =A0 =A0 =A0 .next =A0 =3D m_next,
+ =A0 =A0 =A0 .stop =A0 =3D m_stop,
+ =A0 =A0 =A0 .show =A0 =3D show_tid_smap
=A0};

-static int smaps_open(struct inode *inode, struct file *file)
+static int pid_smaps_open(struct inode *inode, struct file *file)
=A0{
=A0 =A0 =A0 =A0return do_maps_open(inode, file, &proc_pid_smaps_op);
=A0}

-const struct file_operations proc_smaps_operations =3D {
- =A0 =A0 =A0 .open =A0 =A0 =A0 =A0 =A0 =3D smaps_open,
+static int tid_smaps_open(struct inode *inode, struct file *file)
+{
+ =A0 =A0 =A0 return do_maps_open(inode, file, &proc_tid_smaps_op);
+}
+
+const struct file_operations proc_pid_smaps_operations =3D {
+ =A0 =A0 =A0 .open =A0 =A0 =A0 =A0 =A0 =3D pid_smaps_open,
+ =A0 =A0 =A0 .read =A0 =A0 =A0 =A0 =A0 =3D seq_read,
+ =A0 =A0 =A0 .llseek =A0 =A0 =A0 =A0 =3D seq_lseek,
+ =A0 =A0 =A0 .release =A0 =A0 =A0 =A0=3D seq_release_private,
+};
+
+const struct file_operations proc_tid_smaps_operations =3D {
+ =A0 =A0 =A0 .open =A0 =A0 =A0 =A0 =A0 =3D tid_smaps_open,
=A0 =A0 =A0 =A0.read =A0 =A0 =A0 =A0 =A0 =3D seq_read,
=A0 =A0 =A0 =A0.llseek =A0 =A0 =A0 =A0 =3D seq_lseek,
=A0 =A0 =A0 =A0.release =A0 =A0 =A0 =A0=3D seq_release_private,
@@ -1002,7 +1061,7 @@ static int gather_hugetbl_stats(pte_t *pte,
unsigned long hmask,
=A0/*
=A0* Display pages allocated per node and memory policy via /proc.
=A0*/
-static int show_numa_map(struct seq_file *m, void *v)
+static int show_numa_map(struct seq_file *m, void *v, int is_pid)
=A0{
=A0 =A0 =A0 =A0struct numa_maps_private *numa_priv =3D m->private;
=A0 =A0 =A0 =A0struct proc_maps_private *proc_priv =3D &numa_priv->proc_map=
s;
@@ -1039,8 +1098,7 @@ static int show_numa_map(struct seq_file *m, void *v)
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0seq_path(m, &file->f_path, "\n\t=3D ");
=A0 =A0 =A0 =A0} else if (vma->vm_start <=3D mm->brk && vma->vm_end >=3D mm=
->start_brk) {
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0seq_printf(m, " heap");
- =A0 =A0 =A0 } else if (vma->vm_start <=3D mm->start_stack &&
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vma->vm_end >=3D mm->start_st=
ack) {
+ =A0 =A0 =A0 } else if (vm_is_stack(proc_priv->task, vma, is_pid)) {
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0seq_printf(m, " stack");
=A0 =A0 =A0 =A0}

@@ -1084,21 +1142,39 @@ out:
=A0 =A0 =A0 =A0return 0;
=A0}

+static int show_pid_numa_map(struct seq_file *m, void *v)
+{
+ =A0 =A0 =A0 return show_numa_map(m, v, 1);
+}
+
+static int show_tid_numa_map(struct seq_file *m, void *v)
+{
+ =A0 =A0 =A0 return show_numa_map(m, v, 0);
+}
+
=A0static const struct seq_operations proc_pid_numa_maps_op =3D {
=A0 =A0 =A0 =A0 .start =A0=3D m_start,
=A0 =A0 =A0 =A0 .next =A0 =3D m_next,
=A0 =A0 =A0 =A0 .stop =A0 =3D m_stop,
- =A0 =A0 =A0 =A0.show =A0 =3D show_numa_map,
+ =A0 =A0 =A0 =A0.show =A0 =3D show_pid_numa_map,
=A0};

-static int numa_maps_open(struct inode *inode, struct file *file)
+static const struct seq_operations proc_tid_numa_maps_op =3D {
+ =A0 =A0 =A0 =A0.start =A0=3D m_start,
+ =A0 =A0 =A0 =A0.next =A0 =3D m_next,
+ =A0 =A0 =A0 =A0.stop =A0 =3D m_stop,
+ =A0 =A0 =A0 =A0.show =A0 =3D show_tid_numa_map,
+};
+
+static int numa_maps_open(struct inode *inode, struct file *file,
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 const struct seq_operatio=
ns *ops)
=A0{
=A0 =A0 =A0 =A0struct numa_maps_private *priv;
=A0 =A0 =A0 =A0int ret =3D -ENOMEM;
=A0 =A0 =A0 =A0priv =3D kzalloc(sizeof(*priv), GFP_KERNEL);
=A0 =A0 =A0 =A0if (priv) {
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0priv->proc_maps.pid =3D proc_pid(inode);
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D seq_open(file, &proc_pid_numa_maps_op=
);
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D seq_open(file, ops);
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!ret) {
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct seq_file *m =3D file-=
>private_data;
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0m->private =3D priv;
@@ -1109,8 +1185,25 @@ static int numa_maps_open(struct inode *inode,
struct file *file)
=A0 =A0 =A0 =A0return ret;
=A0}

-const struct file_operations proc_numa_maps_operations =3D {
- =A0 =A0 =A0 .open =A0 =A0 =A0 =A0 =A0 =3D numa_maps_open,
+static int pid_numa_maps_open(struct inode *inode, struct file *file)
+{
+ =A0 =A0 =A0 return numa_maps_open(inode, file, &proc_pid_numa_maps_op);
+}
+
+static int tid_numa_maps_open(struct inode *inode, struct file *file)
+{
+ =A0 =A0 =A0 return numa_maps_open(inode, file, &proc_tid_numa_maps_op);
+}
+
+const struct file_operations proc_pid_numa_maps_operations =3D {
+ =A0 =A0 =A0 .open =A0 =A0 =A0 =A0 =A0 =3D pid_numa_maps_open,
+ =A0 =A0 =A0 .read =A0 =A0 =A0 =A0 =A0 =3D seq_read,
+ =A0 =A0 =A0 .llseek =A0 =A0 =A0 =A0 =3D seq_lseek,
+ =A0 =A0 =A0 .release =A0 =A0 =A0 =A0=3D seq_release_private,
+};
+
+const struct file_operations proc_tid_numa_maps_operations =3D {
+ =A0 =A0 =A0 .open =A0 =A0 =A0 =A0 =A0 =3D tid_numa_maps_open,
=A0 =A0 =A0 =A0.read =A0 =A0 =A0 =A0 =A0 =3D seq_read,
=A0 =A0 =A0 =A0.llseek =A0 =A0 =A0 =A0 =3D seq_lseek,
=A0 =A0 =A0 =A0.release =A0 =A0 =A0 =A0=3D seq_release_private,
diff --git a/fs/proc/task_nommu.c b/fs/proc/task_nommu.c
index 980de54..bdfff69 100644
--- a/fs/proc/task_nommu.c
+++ b/fs/proc/task_nommu.c
@@ -134,9 +134,11 @@ static void pad_len_spaces(struct seq_file *m, int len=
)
=A0/*
=A0* display a single VMA to a sequenced file
=A0*/
-static int nommu_vma_show(struct seq_file *m, struct vm_area_struct *vma)
+static int nommu_vma_show(struct seq_file *m, struct vm_area_struct *vma,
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int is_pid)
=A0{
=A0 =A0 =A0 =A0struct mm_struct *mm =3D vma->vm_mm;
+ =A0 =A0 =A0 struct proc_maps_private *priv =3D m->private;
=A0 =A0 =A0 =A0unsigned long ino =3D 0;
=A0 =A0 =A0 =A0struct file *file;
=A0 =A0 =A0 =A0dev_t dev =3D 0;
@@ -168,8 +170,7 @@ static int nommu_vma_show(struct seq_file *m,
struct vm_area_struct *vma)
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pad_len_spaces(m, len);
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0seq_path(m, &file->f_path, "");
=A0 =A0 =A0 =A0} else if (mm) {
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (vma->vm_start <=3D mm->start_stack &&
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vma->vm_end >=3D mm->start_st=
ack) {
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (vm_is_stack(priv->task, vma, is_pid))
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pad_len_spaces(m, len);
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0seq_puts(m, "[stack]");
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
@@ -182,11 +183,22 @@ static int nommu_vma_show(struct seq_file *m,
struct vm_area_struct *vma)
=A0/*
=A0* display mapping lines for a particular process's /proc/pid/maps
=A0*/
-static int show_map(struct seq_file *m, void *_p)
+static int show_map(struct seq_file *m, void *_p, int is_pid)
=A0{
=A0 =A0 =A0 =A0struct rb_node *p =3D _p;

- =A0 =A0 =A0 return nommu_vma_show(m, rb_entry(p, struct vm_area_struct, v=
m_rb));
+ =A0 =A0 =A0 return nommu_vma_show(m, rb_entry(p, struct vm_area_struct, v=
m_rb),
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 is_pid);
+}
+
+static int show_pid_map(struct seq_file *m, void *_p)
+{
+ =A0 =A0 =A0 return show_map(m, _p, 1);
+}
+
+static int show_tid_map(struct seq_file *m, void *_p)
+{
+ =A0 =A0 =A0 return show_map(m, _p, 0);
=A0}

=A0static void *m_start(struct seq_file *m, loff_t *pos)
@@ -240,10 +252,18 @@ static const struct seq_operations proc_pid_maps_ops =
=3D {
=A0 =A0 =A0 =A0.start =A0=3D m_start,
=A0 =A0 =A0 =A0.next =A0 =3D m_next,
=A0 =A0 =A0 =A0.stop =A0 =3D m_stop,
- =A0 =A0 =A0 .show =A0 =3D show_map
+ =A0 =A0 =A0 .show =A0 =3D show_pid_map
+};
+
+static const struct seq_operations proc_tid_maps_ops =3D {
+ =A0 =A0 =A0 .start =A0=3D m_start,
+ =A0 =A0 =A0 .next =A0 =3D m_next,
+ =A0 =A0 =A0 .stop =A0 =3D m_stop,
+ =A0 =A0 =A0 .show =A0 =3D show_tid_map
=A0};

-static int maps_open(struct inode *inode, struct file *file)
+static int maps_open(struct inode *inode, struct file *file,
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0const struct seq_operations *ops)
=A0{
=A0 =A0 =A0 =A0struct proc_maps_private *priv;
=A0 =A0 =A0 =A0int ret =3D -ENOMEM;
@@ -251,7 +271,7 @@ static int maps_open(struct inode *inode, struct file *=
file)
=A0 =A0 =A0 =A0priv =3D kzalloc(sizeof(*priv), GFP_KERNEL);
=A0 =A0 =A0 =A0if (priv) {
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0priv->pid =3D proc_pid(inode);
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D seq_open(file, &proc_pid_maps_ops);
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D seq_open(file, ops);
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!ret) {
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct seq_file *m =3D file-=
>private_data;
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0m->private =3D priv;
@@ -262,8 +282,25 @@ static int maps_open(struct inode *inode, struct
file *file)
=A0 =A0 =A0 =A0return ret;
=A0}

-const struct file_operations proc_maps_operations =3D {
- =A0 =A0 =A0 .open =A0 =A0 =A0 =A0 =A0 =3D maps_open,
+static int pid_maps_open(struct inode *inode, struct file *file)
+{
+ =A0 =A0 =A0 return maps_open(inode, file, &proc_pid_maps_ops);
+}
+
+static int tid_maps_open(struct inode *inode, struct file *file)
+{
+ =A0 =A0 =A0 return maps_open(inode, file, &proc_tid_maps_ops);
+}
+
+const struct file_operations proc_pid_maps_operations =3D {
+ =A0 =A0 =A0 .open =A0 =A0 =A0 =A0 =A0 =3D pid_maps_open,
+ =A0 =A0 =A0 .read =A0 =A0 =A0 =A0 =A0 =3D seq_read,
+ =A0 =A0 =A0 .llseek =A0 =A0 =A0 =A0 =3D seq_lseek,
+ =A0 =A0 =A0 .release =A0 =A0 =A0 =A0=3D seq_release_private,
+};
+
+const struct file_operations proc_tid_maps_operations =3D {
+ =A0 =A0 =A0 .open =A0 =A0 =A0 =A0 =A0 =3D tid_maps_open,
=A0 =A0 =A0 =A0.read =A0 =A0 =A0 =A0 =A0 =3D seq_read,
=A0 =A0 =A0 =A0.llseek =A0 =A0 =A0 =A0 =3D seq_lseek,
=A0 =A0 =A0 =A0.release =A0 =A0 =A0 =A0=3D seq_release_private,
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 17b27cd..b0fc583 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1040,6 +1040,15 @@ static inline int stack_guard_page_end(struct
vm_area_struct *vma,
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0!vma_growsup(vma->vm_next, addr);
=A0}

+/* Check if the vma is being used as a stack by this task */
+static inline int vm_is_stack_for_task(struct task_struct *t,
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0struct vm_area_struct *vma)
+{
+ =A0 =A0 =A0 return (vma->vm_start <=3D KSTK_ESP(t) && vma->vm_end >=3D KS=
TK_ESP(t));
+}
+
+extern int vm_is_stack(struct task_struct *task, struct
vm_area_struct *vma, int in_group);
+
=A0extern unsigned long move_page_tables(struct vm_area_struct *vma,
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long old_addr, struct vm_area_struc=
t *new_vma,
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long new_addr, unsigned long len);
diff --git a/mm/memory.c b/mm/memory.c
index fa2f04e..601a920 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3909,6 +3909,28 @@ void print_vma_addr(char *prefix, unsigned long ip)
=A0 =A0 =A0 =A0up_read(&current->mm->mmap_sem);
=A0}

+/*
+ * Check if the vma is being used as a stack.
+ * If is_group is non-zero, check in the entire thread group or else
+ * just check in the current task.
+ */
+int vm_is_stack(struct task_struct *task,
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct vm_area_st=
ruct *vma, int in_group)
+{
+ =A0 =A0 =A0 if (vm_is_stack_for_task(task, vma))
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
+
+ =A0 =A0 =A0 if (in_group) {
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct task_struct *t =3D task;
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 while_each_thread(task, t) {
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (vm_is_stack_for_task(t, v=
ma))
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
+ =A0 =A0 =A0 }
+
+ =A0 =A0 =A0 return 0;
+}
+
=A0#ifdef CONFIG_PROVE_LOCKING
=A0void might_fault(void)
=A0{
--
1.7.7.4



--=20
Siddhesh Poyarekar
http://siddhesh.in

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

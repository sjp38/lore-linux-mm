Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 64D956B01F2
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 01:06:56 -0400 (EDT)
From: Nikanth Karthikesan <knikanth@suse.de>
Subject: [PATCH] Export mlock information via smaps
Date: Tue, 17 Aug 2010 10:39:31 +0530
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Message-Id: <201008171039.31070.knikanth@suse.de>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Currently there is no way to find whether a process has locked its pages in
memory or not. And which of the memory regions are locked in memory.

Add a new field to perms field 'l' to export this information. The informat=
ion
exported via maps file is not changed.

Signed-off-by: Nikanth Karthikesan <knikanth@suse.de>

=2D--

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems=
/proc.txt
index a6aca87..c6a9694 100644
=2D-- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -374,13 +374,18 @@ Swap:                  0 kB
 KernelPageSize:        4 kB
 MMUPageSize:           4 kB
=20
=2DThe first  of these lines shows  the same information  as is displayed f=
or the
=2Dmapping in /proc/PID/maps.  The remaining lines show  the size of the ma=
pping,
=2Dthe amount of the mapping that is currently resident in RAM, the "propor=
tional
=2Dset size=E2=80=9D (divide each shared page by the number of processes sh=
aring it), the
=2Dnumber of clean and dirty shared pages in the mapping, and the number of=
 clean
=2Dand dirty private pages in the mapping.  The "Referenced" indicates the =
amount
=2Dof memory currently marked as referenced or accessed.
+The first of these lines shows the same information as is displayed for the
+mapping in /proc/PID/maps, except for "perms", which includes an additional
+field to denote whether a mapping is locked in memory or not.
+
+ l =3D locked
+
+The remaining lines show  the size of the mapping, the amount of the mappi=
ng
+that is currently resident in RAM, the "proportional set size=E2=80=9D (di=
vide each
+shared page by the number of processes sharing it), the number of clean and
+dirty shared pages in the mapping, and the number of clean and dirty priva=
te
+pages in the mapping.  The "Referenced" indicates the amount of memory cur=
rently
+marked as referenced or accessed.
=20
 This file is only present if the CONFIG_MMU kernel configuration option is
 enabled.
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index aea1d3f..5f8f344 100644
=2D-- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -203,7 +203,8 @@ static int do_maps_open(struct inode *inode, struct fil=
e *file,
 	return ret;
 }
=20
=2Dstatic void show_map_vma(struct seq_file *m, struct vm_area_struct *vma)
+static void show_map_vma(struct seq_file *m, struct vm_area_struct *vma,
+							int show_lock)
 {
 	struct mm_struct *mm =3D vma->vm_mm;
 	struct file *file =3D vma->vm_file;
@@ -220,13 +221,14 @@ static void show_map_vma(struct seq_file *m, struct v=
m_area_struct *vma)
 		pgoff =3D ((loff_t)vma->vm_pgoff) << PAGE_SHIFT;
 	}
=20
=2D	seq_printf(m, "%08lx-%08lx %c%c%c%c %08llx %02x:%02x %lu %n",
+	seq_printf(m, "%08lx-%08lx %c%c%c%c%s %08llx %02x:%02x %lu %n",
 			vma->vm_start,
 			vma->vm_end,
 			flags & VM_READ ? 'r' : '-',
 			flags & VM_WRITE ? 'w' : '-',
 			flags & VM_EXEC ? 'x' : '-',
 			flags & VM_MAYSHARE ? 's' : 'p',
+			show_lock ? (flags & VM_LOCKED ? "l" : "-") : "",
 			pgoff,
 			MAJOR(dev), MINOR(dev), ino, &len);
=20
@@ -266,7 +268,7 @@ static int show_map(struct seq_file *m, void *v)
 	struct proc_maps_private *priv =3D m->private;
 	struct task_struct *task =3D priv->task;
=20
=2D	show_map_vma(m, vma);
+	show_map_vma(m, vma, 0);
=20
 	if (m->count < m->size)  /* vma is copied successfully */
 		m->version =3D (vma !=3D get_gate_vma(task))? vma->vm_start: 0;
@@ -392,7 +394,7 @@ static int show_smap(struct seq_file *m, void *v)
 	if (vma->vm_mm && !is_vm_hugetlb_page(vma))
 		walk_page_range(vma->vm_start, vma->vm_end, &smaps_walk);
=20
=2D	show_map_vma(m, vma);
+	show_map_vma(m, vma, 1);
=20
 	seq_printf(m,
 		   "Size:           %8lu kB\n"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

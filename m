Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 3C3CC6B13F0
	for <linux-mm@kvack.org>; Thu,  2 Feb 2012 01:24:17 -0500 (EST)
Received: by ghrr18 with SMTP id r18so1272497ghr.14
        for <linux-mm@kvack.org>; Wed, 01 Feb 2012 22:24:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1326776095-2629-1-git-send-email-siddhesh.poyarekar@gmail.com>
References: <20120116163106.GC7180@jl-vm1.vm.bytemark.co.uk>
	<1326776095-2629-1-git-send-email-siddhesh.poyarekar@gmail.com>
Date: Thu, 2 Feb 2012 11:54:16 +0530
Message-ID: <CAAHN_R2g9zaujw30+zLf91AGDHNqE6HDc8Z4yJbrzgJcJYFkXg@mail.gmail.com>
Subject: [RESEND][PATCH] Mark thread stack correctly in proc/<pid>/maps
From: Siddhesh Poyarekar <siddhesh.poyarekar@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jamie Lokier <jamie@shareable.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-man@vger.kernel.org, Siddhesh Poyarekar <siddhesh.poyarekar@gmail.com>

Hi,

Resending since I did not get any feedback on the second take of the patch.

Thanks,
Siddhesh


---------- Forwarded message ----------
From: Siddhesh Poyarekar <siddhesh.poyarekar@gmail.com>
Date: Tue, Jan 17, 2012 at 10:24 AM
Subject: [PATCH] Mark thread stack correctly in proc/<pid>/maps
To: Jamie Lokier <jamie@shareable.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Viro
<viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Michael
Kerrisk <mtk.manpages@gmail.com>, linux-man@vger.kernel.org, Siddhesh
Poyarekar <siddhesh.poyarekar@gmail.com>


[Take 2]

Memory mmaped by glibc for a thread stack currently shows up as a simple
anonymous map, which makes it difficult to differentiate between memory
usage of the thread on stack and other dynamic allocation. Since glibc
already uses MAP_STACK to request this mapping, the attached patch
uses this flag to add additional VM_STACK_FLAGS to the resulting vma
so that the mapping is treated as a stack and not any regular
anonymous mapping. Also, one may use vm_flags to decide if a vma is a
stack.

This patch also changes the maps output to annotate stack guards for
both the process stack as well as the thread stacks. Thus is born the
[stack guard] annotation, which should be exactly a page long for the
process stack and can be longer than a page (configurable in
userspace) for POSIX compliant thread stacks. A thread stack guard is
simply page(s) with PROT_NONE.

If accepted, this should also reflect in the man page for mmap since
MAP_STACK will no longer be a noop.

Signed-off-by: Siddhesh Poyarekar <siddhesh.poyarekar@gmail.com>
---
=A0fs/proc/task_mmu.c | =A0 41 ++++++++++++++++++++++++++++++++++++-----
=A0include/linux/mm.h | =A0 19 +++++++++++++++++--
=A0mm/mmap.c =A0 =A0 =A0 =A0 =A0| =A0 =A03 +++
=A03 files changed, 56 insertions(+), 7 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index e418c5a..650330c 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -227,13 +227,42 @@ static void show_map_vma(struct seq_file *m,
struct vm_area_struct *vma)
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pgoff =3D ((loff_t)vma->vm_pgoff) << PAGE_SH=
IFT;
=A0 =A0 =A0 =A0}

- =A0 =A0 =A0 /* We don't show the stack guard page in /proc/maps */
+ =A0 =A0 =A0 /*
+ =A0 =A0 =A0 =A0* Mark the process stack guard, which is just one page at =
the
+ =A0 =A0 =A0 =A0* beginning of the stack within the stack vma.
+ =A0 =A0 =A0 =A0*/
=A0 =A0 =A0 =A0start =3D vma->vm_start;
- =A0 =A0 =A0 if (stack_guard_page_start(vma, start))
+ =A0 =A0 =A0 if (stack_guard_page_start(vma, start)) {
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 seq_printf(m, "%08lx-%08lx %c%c%c%c %08llx %0=
2x:%02x %lu %n",
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 start,
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 start + PAGE_=
SIZE,
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 flags & VM_RE=
AD ? 'r' : '-',
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 flags & VM_WR=
ITE ? 'w' : '-',
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 flags & VM_EX=
EC ? 'x' : '-',
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 flags & VM_MA=
YSHARE ? 's' : 'p',
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgoff,
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 MAJOR(dev), M=
INOR(dev), ino, &len);
+
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 pad_len_spaces(m, len);
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 seq_puts(m, "[stack guard]\n");
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0start +=3D PAGE_SIZE;
+ =A0 =A0 =A0 }
=A0 =A0 =A0 =A0end =3D vma->vm_end;
- =A0 =A0 =A0 if (stack_guard_page_end(vma, end))
+ =A0 =A0 =A0 if (stack_guard_page_end(vma, end)) {
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 seq_printf(m, "%08lx-%08lx %c%c%c%c %08llx %0=
2x:%02x %lu %n",
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 end - PAGE_SI=
ZE,
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 end,
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 flags & VM_RE=
AD ? 'r' : '-',
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 flags & VM_WR=
ITE ? 'w' : '-',
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 flags & VM_EX=
EC ? 'x' : '-',
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 flags & VM_MA=
YSHARE ? 's' : 'p',
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgoff,
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 MAJOR(dev), M=
INOR(dev), ino, &len);
+
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 pad_len_spaces(m, len);
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 seq_puts(m, "[stack guard]\n");
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0end -=3D PAGE_SIZE;
+ =A0 =A0 =A0 }

=A0 =A0 =A0 =A0seq_printf(m, "%08lx-%08lx %c%c%c%c %08llx %02x:%02x %lu %n"=
,
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0start,
@@ -259,8 +288,10 @@ static void show_map_vma(struct seq_file *m,
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
a_is_stack(vma) &&
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0vma_is_guard(vma)) {
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 name =3D "[stack guard]";
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else if (vm=
a_is_stack(vma)) {
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0name =3D "[stack]";
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else {
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 17b27cd..4e57753 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1018,12 +1018,26 @@ static inline int vma_growsdown(struct
vm_area_struct *vma, unsigned long addr)
=A0 =A0 =A0 =A0return vma && (vma->vm_end =3D=3D addr) && (vma->vm_flags & =
VM_GROWSDOWN);
=A0}

+static inline int vma_is_stack(struct vm_area_struct *vma)
+{
+ =A0 =A0 =A0 return vma && (vma->vm_flags & (VM_GROWSUP | VM_GROWSDOWN));
+}
+
+/*
+ * Check guard set by userspace (PROT_NONE)
+ */
+static inline int vma_is_guard(struct vm_area_struct *vma)
+{
+ =A0 =A0 =A0 return (vma->vm_flags & (VM_READ | VM_WRITE | VM_EXEC |
VM_SHARED)) =3D=3D 0;
+}
+
=A0static inline int stack_guard_page_start(struct vm_area_struct *vma,
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 unsigned long addr)
=A0{
=A0 =A0 =A0 =A0return (vma->vm_flags & VM_GROWSDOWN) &&
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(vma->vm_start =3D=3D addr) &&
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 !vma_growsdown(vma->vm_prev, addr);
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 !vma_growsdown(vma->vm_prev, addr) &&
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 !vma_is_guard(vma);
=A0}

=A0/* Is the vma a continuation of the stack vma below it? */
@@ -1037,7 +1051,8 @@ static inline int stack_guard_page_end(struct
vm_area_struct *vma,
=A0{
=A0 =A0 =A0 =A0return (vma->vm_flags & VM_GROWSUP) &&
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(vma->vm_end =3D=3D addr) &&
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 !vma_growsup(vma->vm_next, addr);
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 !vma_growsup(vma->vm_next, addr) &&
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 !vma_is_guard(vma);
=A0}

=A0extern unsigned long move_page_tables(struct vm_area_struct *vma,
diff --git a/mm/mmap.c b/mm/mmap.c
index 3f758c7..2f9f540 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -992,6 +992,9 @@ unsigned long do_mmap_pgoff(struct file *file,
unsigned long addr,
=A0 =A0 =A0 =A0vm_flags =3D calc_vm_prot_bits(prot) | calc_vm_flag_bits(fla=
gs) |
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mm->def_flags | VM_MAYREAD |=
 VM_MAYWRITE | VM_MAYEXEC;

+ =A0 =A0 =A0 if (flags & MAP_STACK)
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 vm_flags |=3D VM_STACK_FLAGS;
+
=A0 =A0 =A0 =A0if (flags & MAP_LOCKED)
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!can_do_mlock())
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EPERM;
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

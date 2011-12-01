Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E1D226B0070
	for <linux-mm@kvack.org>; Thu,  1 Dec 2011 08:21:39 -0500 (EST)
Message-ID: <1322745659.4699.17.camel@twins>
Subject: Re: [PATCH v7 3.2-rc2 3/30] uprobes: register/unregister probes.
From: Peter Zijlstra <peterz@infradead.org>
Date: Thu, 01 Dec 2011 14:20:59 +0100
In-Reply-To: <20111118110713.10512.9461.sendpatchset@srdronam.in.ibm.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
	 <20111118110713.10512.9461.sendpatchset@srdronam.in.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>

On Fri, 2011-11-18 at 16:37 +0530, Srikar Dronamraju wrote:
> +static int __register_uprobe(struct inode *inode, loff_t offset,
> +                               struct uprobe *uprobe)
> +{
> +       struct list_head try_list;
> +       struct vm_area_struct *vma;
> +       struct address_space *mapping;
> +       struct vma_info *vi, *tmpvi;
> +       struct mm_struct *mm;
> +       loff_t vaddr;
> +       int ret =3D 0;
> +
> +       mapping =3D inode->i_mapping;
> +       INIT_LIST_HEAD(&try_list);
> +       while ((vi =3D find_next_vma_info(&try_list, offset,
> +                                               mapping, true)) !=3D NULL=
) {
> +               if (IS_ERR(vi)) {
> +                       ret =3D -ENOMEM;
> +                       break;
> +               }
> +               mm =3D vi->mm;
> +               down_read(&mm->mmap_sem);
> +               vma =3D find_vma(mm, (unsigned long)vi->vaddr);
> +               if (!vma || !valid_vma(vma, true)) {
> +                       list_del(&vi->probe_list);
> +                       kfree(vi);
> +                       up_read(&mm->mmap_sem);
> +                       mmput(mm);
> +                       continue;
> +               }
> +               vaddr =3D vma->vm_start + offset;
> +               vaddr -=3D vma->vm_pgoff << PAGE_SHIFT;
> +               if (vma->vm_file->f_mapping->host !=3D inode ||
> +                                               vaddr !=3D vi->vaddr) {
> +                       list_del(&vi->probe_list);
> +                       kfree(vi);
> +                       up_read(&mm->mmap_sem);
> +                       mmput(mm);
> +                       continue;
> +               }
> +               ret =3D install_breakpoint(mm);
> +               up_read(&mm->mmap_sem);
> +               mmput(mm);
> +               if (ret && ret =3D=3D -EEXIST)
> +                       ret =3D 0;
> +               if (!ret)
> +                       break;
> +       }
> +       list_for_each_entry_safe(vi, tmpvi, &try_list, probe_list) {
> +               list_del(&vi->probe_list);
> +               kfree(vi);
> +       }
> +       return ret;
> +}
> +
> +static void __unregister_uprobe(struct inode *inode, loff_t offset,
> +                                               struct uprobe *uprobe)
> +{
> +       struct list_head try_list;
> +       struct address_space *mapping;
> +       struct vma_info *vi, *tmpvi;
> +       struct vm_area_struct *vma;
> +       struct mm_struct *mm;
> +       loff_t vaddr;
> +
> +       mapping =3D inode->i_mapping;
> +       INIT_LIST_HEAD(&try_list);
> +       while ((vi =3D find_next_vma_info(&try_list, offset,
> +                                               mapping, false)) !=3D NUL=
L) {
> +               if (IS_ERR(vi))
> +                       break;
> +               mm =3D vi->mm;
> +               down_read(&mm->mmap_sem);
> +               vma =3D find_vma(mm, (unsigned long)vi->vaddr);
> +               if (!vma || !valid_vma(vma, false)) {
> +                       list_del(&vi->probe_list);
> +                       kfree(vi);
> +                       up_read(&mm->mmap_sem);
> +                       mmput(mm);
> +                       continue;
> +               }
> +               vaddr =3D vma->vm_start + offset;
> +               vaddr -=3D vma->vm_pgoff << PAGE_SHIFT;
> +               if (vma->vm_file->f_mapping->host !=3D inode ||
> +                                               vaddr !=3D vi->vaddr) {
> +                       list_del(&vi->probe_list);
> +                       kfree(vi);
> +                       up_read(&mm->mmap_sem);
> +                       mmput(mm);
> +                       continue;
> +               }
> +               remove_breakpoint(mm);
> +               up_read(&mm->mmap_sem);
> +               mmput(mm);
> +       }
> +
> +       list_for_each_entry_safe(vi, tmpvi, &try_list, probe_list) {
> +               list_del(&vi->probe_list);
> +               kfree(vi);
> +       }
> +       delete_uprobe(uprobe);
> +}=20

I already mentioned on IRC that there's a lot of duplication here and
how to 'solve that'...

Something like the below, it lost the delete_uprobe() bit, and it adds a
few XXX marks where we have to deal with -ENOMEM. Also its not been near
a compiler.

---
 kernel/uprobes.c |   78 ++++++++++++++------------------------------------=
---
 1 files changed, 21 insertions(+), 57 deletions(-)

diff --git a/kernel/uprobes.c b/kernel/uprobes.c
index 2493191..c57284a 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -622,7 +622,7 @@ static int install_breakpoint(struct mm_struct *mm, str=
uct uprobe *uprobe,
 }
=20
 static void remove_breakpoint(struct mm_struct *mm, struct uprobe *uprobe,
-							loff_t vaddr)
+			      struct vm_area_struct *vma, loff_t vaddr)
 {
 	if (!set_orig_insn(mm, uprobe, (unsigned long)vaddr, true))
 		atomic_dec(&mm->mm_uprobes_count);
@@ -713,8 +713,10 @@ static struct vma_info *find_next_vma_info(struct list=
_head *head,
 	return retvi;
 }
=20
-static int __register_uprobe(struct inode *inode, loff_t offset,
-				struct uprobe *uprobe)
+typedef int (*vma_func_t)(struct mm_struct *mm, struct uprobe *uprobe,
+			  struct vm_area_struct *vma, unsigned long addr);
+
+static int __for_each_vma(struct uprobe *uprobe, vma_func_t func)
 {
 	struct list_head try_list;
 	struct vm_area_struct *vma;
@@ -724,12 +726,12 @@ static int __register_uprobe(struct inode *inode, lof=
f_t offset,
 	loff_t vaddr;
 	int ret =3D 0;
=20
-	mapping =3D inode->i_mapping;
+	mapping =3D uprobe->inode->i_mapping;
 	INIT_LIST_HEAD(&try_list);
-	while ((vi =3D find_next_vma_info(&try_list, offset,
+	while ((vi =3D find_next_vma_info(&try_list, uprobe->offset,
 						mapping, true)) !=3D NULL) {
 		if (IS_ERR(vi)) {
-			ret =3D -ENOMEM;
+			ret =3D PTR_ERR(vi);
 			break;
 		}
 		mm =3D vi->mm;
@@ -742,9 +744,9 @@ static int __register_uprobe(struct inode *inode, loff_=
t offset,
 			mmput(mm);
 			continue;
 		}
-		vaddr =3D vma->vm_start + offset;
+		vaddr =3D vma->vm_start + uprobe->offset;
 		vaddr -=3D vma->vm_pgoff << PAGE_SHIFT;
-		if (vma->vm_file->f_mapping->host !=3D inode ||
+		if (vma->vm_file->f_mapping->host !=3D uprobe->inode ||
 						vaddr !=3D vi->vaddr) {
 			list_del(&vi->probe_list);
 			kfree(vi);
@@ -752,12 +754,12 @@ static int __register_uprobe(struct inode *inode, lof=
f_t offset,
 			mmput(mm);
 			continue;
 		}
-		ret =3D install_breakpoint(mm, uprobe, vma, vi->vaddr);
+		ret =3D func(mm, uprobe, vma, vi->vaddr);
 		up_read(&mm->mmap_sem);
 		mmput(mm);
 		if (ret && ret =3D=3D -EEXIST)
 			ret =3D 0;
-		if (!ret)
+		if (ret)
 			break;
 	}
 	list_for_each_entry_safe(vi, tmpvi, &try_list, probe_list) {
@@ -767,52 +769,14 @@ static int __register_uprobe(struct inode *inode, lof=
f_t offset,
 	return ret;
 }
=20
-static void __unregister_uprobe(struct inode *inode, loff_t offset,
-						struct uprobe *uprobe)
+static int __register_uprobe(struct uprobe *uprobe)
 {
-	struct list_head try_list;
-	struct address_space *mapping;
-	struct vma_info *vi, *tmpvi;
-	struct vm_area_struct *vma;
-	struct mm_struct *mm;
-	loff_t vaddr;
-
-	mapping =3D inode->i_mapping;
-	INIT_LIST_HEAD(&try_list);
-	while ((vi =3D find_next_vma_info(&try_list, offset,
-						mapping, false)) !=3D NULL) {
-		if (IS_ERR(vi))
-			break;
-		mm =3D vi->mm;
-		down_read(&mm->mmap_sem);
-		vma =3D find_vma(mm, (unsigned long)vi->vaddr);
-		if (!vma || !valid_vma(vma, false)) {
-			list_del(&vi->probe_list);
-			kfree(vi);
-			up_read(&mm->mmap_sem);
-			mmput(mm);
-			continue;
-		}
-		vaddr =3D vma->vm_start + offset;
-		vaddr -=3D vma->vm_pgoff << PAGE_SHIFT;
-		if (vma->vm_file->f_mapping->host !=3D inode ||
-						vaddr !=3D vi->vaddr) {
-			list_del(&vi->probe_list);
-			kfree(vi);
-			up_read(&mm->mmap_sem);
-			mmput(mm);
-			continue;
-		}
-		remove_breakpoint(mm, uprobe, vi->vaddr);
-		up_read(&mm->mmap_sem);
-		mmput(mm);
-	}
+	return __for_each_vma(uprobe, install_breakpoint);
+}
=20
-	list_for_each_entry_safe(vi, tmpvi, &try_list, probe_list) {
-		list_del(&vi->probe_list);
-		kfree(vi);
-	}
-	delete_uprobe(uprobe);
+static int __unregister_uprobe(struct uprobe *uprobe)
+{
+	return __for_each_vma(uprobe, remove_breakpoint);
 }
=20
 /*
@@ -852,10 +816,10 @@ int register_uprobe(struct inode *inode, loff_t offse=
t,
 	mutex_lock(uprobes_hash(inode));
 	uprobe =3D alloc_uprobe(inode, offset);
 	if (uprobe && !add_consumer(uprobe, consumer)) {
-		ret =3D __register_uprobe(inode, offset, uprobe);
+		ret =3D __register_uprobe(uprobe);
 		if (ret) {
 			uprobe->consumers =3D NULL;
-			__unregister_uprobe(inode, offset, uprobe);
+			__unregister_uprobe(uprobe); // -ENOMEM
 		} else
 			uprobe->flags |=3D UPROBES_RUN_HANDLER;
 	}
@@ -894,7 +858,7 @@ void unregister_uprobe(struct inode *inode, loff_t offs=
et,
 	}
=20
 	if (!uprobe->consumers) {
-		__unregister_uprobe(inode, offset, uprobe);
+		__unregister_uprobe(uprobe); // XXX -ENOMEM
 		uprobe->flags &=3D ~UPROBES_RUN_HANDLER;
 	}
 	mutex_unlock(uprobes_hash(inode));

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

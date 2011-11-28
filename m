Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C98916B006E
	for <linux-mm@kvack.org>; Mon, 28 Nov 2011 10:30:19 -0500 (EST)
Message-ID: <1322494194.2921.147.camel@twins>
Subject: Re: [PATCH v7 3.2-rc2 3/30] uprobes: register/unregister probes.
From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 28 Nov 2011 16:29:54 +0100
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

So what kind of half-assed state are we left in if we try an unregister
under memory pressure and how do we deal with that?

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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

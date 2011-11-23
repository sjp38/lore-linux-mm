Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E20126B00E3
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 11:09:25 -0500 (EST)
Message-ID: <1322064540.14799.78.camel@twins>
Subject: Re: [PATCH v7 3.2-rc2 3/30] uprobes: register/unregister probes.
From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 23 Nov 2011 17:09:00 +0100
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

Shouldn't that read:
		if (ret)
			break;

So that we bail when there's a real error instead of no error?

> +       }
> +       list_for_each_entry_safe(vi, tmpvi, &try_list, probe_list) {
> +               list_del(&vi->probe_list);
> +               kfree(vi);
> +       }
> +       return ret;
> +}=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 04CA86B004F
	for <linux-mm@kvack.org>; Wed,  4 Jan 2012 11:52:15 -0500 (EST)
Message-ID: <1325695916.2697.5.camel@twins>
Subject: Re: [PATCH v8 3.2.0-rc5 1/9] uprobes: Install and remove
 breakpoints.
From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 04 Jan 2012 17:51:56 +0100
In-Reply-To: <20111216122808.2085.76986.sendpatchset@srdronam.in.ibm.com>
References: <20111216122756.2085.95791.sendpatchset@srdronam.in.ibm.com>
	 <20111216122808.2085.76986.sendpatchset@srdronam.in.ibm.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Rothwell <sfr@canb.auug.org.au>

On Fri, 2011-12-16 at 17:58 +0530, Srikar Dronamraju wrote:
> +static int register_for_each_vma(struct uprobe *uprobe, bool is_register=
)
> +{
> +       struct list_head try_list;
> +       struct vm_area_struct *vma;
> +       struct address_space *mapping;
> +       struct vma_info *vi, *tmpvi;
> +       struct mm_struct *mm;
> +       loff_t vaddr;
> +       int ret =3D 0;
> +
> +       mapping =3D uprobe->inode->i_mapping;
> +       INIT_LIST_HEAD(&try_list);
> +       while ((vi =3D find_next_vma_info(&try_list, uprobe->offset,
> +                                       mapping, is_register)) !=3D NULL)=
 {
> +               if (IS_ERR(vi)) {
> +                       ret =3D PTR_ERR(vi);
> +                       break;
> +               }
> +               mm =3D vi->mm;
> +               down_read(&mm->mmap_sem);
> +               vma =3D find_vma(mm, (unsigned long)vi->vaddr);
> +               if (!vma || !valid_vma(vma, is_register)) {
> +                       list_del(&vi->probe_list);
> +                       kfree(vi);
> +                       up_read(&mm->mmap_sem);
> +                       mmput(mm);
> +                       continue;
> +               }
> +               vaddr =3D vma_address(vma, uprobe->offset);
> +               if (vma->vm_file->f_mapping->host !=3D uprobe->inode ||
> +                                               vaddr !=3D vi->vaddr) {
> +                       list_del(&vi->probe_list);
> +                       kfree(vi);
> +                       up_read(&mm->mmap_sem);
> +                       mmput(mm);
> +                       continue;
> +               }
> +
> +               if (is_register)
> +                       ret =3D install_breakpoint(mm, uprobe, vma, vi->v=
addr);
> +               else
> +                       remove_breakpoint(mm, uprobe, vi->vaddr);
> +
> +               up_read(&mm->mmap_sem);
> +               mmput(mm);
> +               if (is_register) {
> +                       if (ret && ret =3D=3D -EEXIST)
> +                               ret =3D 0;
> +                       if (ret)
> +                               break;
> +               }

Since you init ret :=3D 0 and remove_breakpoint doesn't change it, this
conditional on is_register is superfluous.

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

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 48A149000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 07:38:09 -0400 (EDT)
Subject: Re: [PATCH v5 3.1.0-rc4-tip 4/26]   uprobes: Define hooks for
 mmap/munmap.
From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 27 Sep 2011 13:37:15 +0200
In-Reply-To: <20110926154414.GB13535@linux.vnet.ibm.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
	 <20110920120040.25326.63549.sendpatchset@srdronam.in.ibm.com>
	 <1317045191.1763.22.camel@twins>
	 <20110926154414.GB13535@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1317123435.15383.33.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, 2011-09-26 at 21:14 +0530, Srikar Dronamraju wrote:
>=20
> > > +
> > > +/*
> > > + * Called from mmap_region.
> > > + * called with mm->mmap_sem acquired.
> > > + *
> > > + * Return -ve no if we fail to insert probes and we cannot
> > > + * bail-out.
> > > + * Return 0 otherwise. i.e :
> > > + * - successful insertion of probes
> > > + * - (or) no possible probes to be inserted.
> > > + * - (or) insertion of probes failed but we can bail-out.
> > > + */
> > > +int mmap_uprobe(struct vm_area_struct *vma)
> > > +{
> > > +   struct list_head tmp_list;
> > > +   struct uprobe *uprobe, *u;
> > > +   struct inode *inode;
> > > +   int ret =3D 0;
> > > +
> > > +   if (!valid_vma(vma))
> > > +           return ret;     /* Bail-out */
> > > +
> > > +   inode =3D igrab(vma->vm_file->f_mapping->host);
> > > +   if (!inode)
> > > +           return ret;
> > > +
> > > +   INIT_LIST_HEAD(&tmp_list);
> > > +   mutex_lock(&uprobes_mmap_mutex);
> > > +   build_probe_list(inode, &tmp_list);
> > > +   list_for_each_entry_safe(uprobe, u, &tmp_list, pending_list) {
> > > +           loff_t vaddr;
> > > +
> > > +           list_del(&uprobe->pending_list);
> > > +           if (!ret && uprobe->consumers) {
> > > +                   vaddr =3D vma->vm_start + uprobe->offset;
> > > +                   vaddr -=3D vma->vm_pgoff << PAGE_SHIFT;
> > > +                   if (vaddr < vma->vm_start || vaddr >=3D vma->vm_e=
nd)
> > > +                           continue;
> > > +                   ret =3D install_breakpoint(vma->vm_mm, uprobe);
> > > +
> > > +                   if (ret && (ret =3D=3D -ESRCH || ret =3D=3D -EEXI=
ST))
> > > +                           ret =3D 0;
> > > +           }
> > > +           put_uprobe(uprobe);
> > > +   }
> > > +
> > > +   mutex_unlock(&uprobes_mmap_mutex);
> > > +   iput(inode);
> > > +   return ret;
> > > +}
> > > +
> > > +static void dec_mm_uprobes_count(struct vm_area_struct *vma,
> > > +           struct inode *inode)
> > > +{
> > > +   struct uprobe *uprobe;
> > > +   struct rb_node *n;
> > > +   unsigned long flags;
> > > +
> > > +   n =3D uprobes_tree.rb_node;
> > > +   spin_lock_irqsave(&uprobes_treelock, flags);
> > > +   uprobe =3D __find_uprobe(inode, 0, &n);
> > > +
> > > +   /*
> > > +    * If indeed there is a probe for the inode and with offset zero,
> > > +    * then lets release its reference. (ref got thro __find_uprobe)
> > > +    */
> > > +   if (uprobe)
> > > +           put_uprobe(uprobe);
> > > +   for (; n; n =3D rb_next(n)) {
> > > +           loff_t vaddr;
> > > +
> > > +           uprobe =3D rb_entry(n, struct uprobe, rb_node);
> > > +           if (uprobe->inode !=3D inode)
> > > +                   break;
> > > +           vaddr =3D vma->vm_start + uprobe->offset;
> > > +           vaddr -=3D vma->vm_pgoff << PAGE_SHIFT;
> > > +           if (vaddr < vma->vm_start || vaddr >=3D vma->vm_end)
> > > +                   continue;
> > > +           atomic_dec(&vma->vm_mm->mm_uprobes_count);
> > > +   }
> > > +   spin_unlock_irqrestore(&uprobes_treelock, flags);
> > > +}
> > > +
> > > +/*
> > > + * Called in context of a munmap of a vma.
> > > + */
> > > +void munmap_uprobe(struct vm_area_struct *vma)
> > > +{
> > > +   struct inode *inode;
> > > +
> > > +   if (!valid_vma(vma))
> > > +           return;         /* Bail-out */
> > > +
> > > +   if (!atomic_read(&vma->vm_mm->mm_uprobes_count))
> > > +           return;
> > > +
> > > +   inode =3D igrab(vma->vm_file->f_mapping->host);
> > > +   if (!inode)
> > > +           return;
> > > +
> > > +   dec_mm_uprobes_count(vma, inode);
> > > +   iput(inode);
> > > +   return;
> > > +}
> >=20
> > One has to wonder why mmap_uprobe() can be one function but
> > munmap_uprobe() cannot.
> >=20
>=20
> I didnt understand this comment, Can you please elaborate?
> mmap_uprobe uses build_probe_list and munmap_uprobe uses
> dec_mm_uprobes_count.=20

Ah, I missed build_probe_list(), but I didn't see a reason for the
existence of dec_mm_uprobe_count(), the name doesn't make sense and the
content is 'small' enough to just put in munmap_uprobe.

To me it looks similar to the list iteration you have in mmap_uprobe(),
you didn't split that out into another function either.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

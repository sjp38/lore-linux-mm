Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 209159000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 09:24:20 -0400 (EDT)
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p8RC3IjW024038
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 08:03:18 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8RDOIlg171022
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 09:24:18 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8RDO74n032715
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 09:24:09 -0400
Date: Tue, 27 Sep 2011 18:38:50 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 3.1.0-rc4-tip 4/26]   uprobes: Define hooks for
 mmap/munmap.
Message-ID: <20110927130850.GD3685@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
 <20110920120040.25326.63549.sendpatchset@srdronam.in.ibm.com>
 <1317045191.1763.22.camel@twins>
 <20110926154414.GB13535@linux.vnet.ibm.com>
 <1317123435.15383.33.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1317123435.15383.33.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

* Peter Zijlstra <peterz@infradead.org> [2011-09-27 13:37:15]:

> On Mon, 2011-09-26 at 21:14 +0530, Srikar Dronamraju wrote:
> > 
> > > > +
> > > > +/*
> > > > + * Called from mmap_region.
> > > > + * called with mm->mmap_sem acquired.
> > > > + *
> > > > + * Return -ve no if we fail to insert probes and we cannot
> > > > + * bail-out.
> > > > + * Return 0 otherwise. i.e :
> > > > + * - successful insertion of probes
> > > > + * - (or) no possible probes to be inserted.
> > > > + * - (or) insertion of probes failed but we can bail-out.
> > > > + */
> > > > +int mmap_uprobe(struct vm_area_struct *vma)
> > > > +{
> > > > +   struct list_head tmp_list;
> > > > +   struct uprobe *uprobe, *u;
> > > > +   struct inode *inode;
> > > > +   int ret = 0;
> > > > +
> > > > +   if (!valid_vma(vma))
> > > > +           return ret;     /* Bail-out */
> > > > +
> > > > +   inode = igrab(vma->vm_file->f_mapping->host);
> > > > +   if (!inode)
> > > > +           return ret;
> > > > +
> > > > +   INIT_LIST_HEAD(&tmp_list);
> > > > +   mutex_lock(&uprobes_mmap_mutex);
> > > > +   build_probe_list(inode, &tmp_list);
> > > > +   list_for_each_entry_safe(uprobe, u, &tmp_list, pending_list) {
> > > > +           loff_t vaddr;
> > > > +
> > > > +           list_del(&uprobe->pending_list);
> > > > +           if (!ret && uprobe->consumers) {
> > > > +                   vaddr = vma->vm_start + uprobe->offset;
> > > > +                   vaddr -= vma->vm_pgoff << PAGE_SHIFT;
> > > > +                   if (vaddr < vma->vm_start || vaddr >= vma->vm_end)
> > > > +                           continue;
> > > > +                   ret = install_breakpoint(vma->vm_mm, uprobe);
> > > > +
> > > > +                   if (ret && (ret == -ESRCH || ret == -EEXIST))
> > > > +                           ret = 0;
> > > > +           }
> > > > +           put_uprobe(uprobe);
> > > > +   }
> > > > +
> > > > +   mutex_unlock(&uprobes_mmap_mutex);
> > > > +   iput(inode);
> > > > +   return ret;
> > > > +}
> > > > +
> > > > +static void dec_mm_uprobes_count(struct vm_area_struct *vma,
> > > > +           struct inode *inode)
> > > > +{
> > > > +   struct uprobe *uprobe;
> > > > +   struct rb_node *n;
> > > > +   unsigned long flags;
> > > > +
> > > > +   n = uprobes_tree.rb_node;
> > > > +   spin_lock_irqsave(&uprobes_treelock, flags);
> > > > +   uprobe = __find_uprobe(inode, 0, &n);
> > > > +
> > > > +   /*
> > > > +    * If indeed there is a probe for the inode and with offset zero,
> > > > +    * then lets release its reference. (ref got thro __find_uprobe)
> > > > +    */
> > > > +   if (uprobe)
> > > > +           put_uprobe(uprobe);
> > > > +   for (; n; n = rb_next(n)) {
> > > > +           loff_t vaddr;
> > > > +
> > > > +           uprobe = rb_entry(n, struct uprobe, rb_node);
> > > > +           if (uprobe->inode != inode)
> > > > +                   break;
> > > > +           vaddr = vma->vm_start + uprobe->offset;
> > > > +           vaddr -= vma->vm_pgoff << PAGE_SHIFT;
> > > > +           if (vaddr < vma->vm_start || vaddr >= vma->vm_end)
> > > > +                   continue;
> > > > +           atomic_dec(&vma->vm_mm->mm_uprobes_count);
> > > > +   }
> > > > +   spin_unlock_irqrestore(&uprobes_treelock, flags);
> > > > +}
> > > > +
> > > > +/*
> > > > + * Called in context of a munmap of a vma.
> > > > + */
> > > > +void munmap_uprobe(struct vm_area_struct *vma)
> > > > +{
> > > > +   struct inode *inode;
> > > > +
> > > > +   if (!valid_vma(vma))
> > > > +           return;         /* Bail-out */
> > > > +
> > > > +   if (!atomic_read(&vma->vm_mm->mm_uprobes_count))
> > > > +           return;
> > > > +
> > > > +   inode = igrab(vma->vm_file->f_mapping->host);
> > > > +   if (!inode)
> > > > +           return;
> > > > +
> > > > +   dec_mm_uprobes_count(vma, inode);
> > > > +   iput(inode);
> > > > +   return;
> > > > +}
> > > 
> > > One has to wonder why mmap_uprobe() can be one function but
> > > munmap_uprobe() cannot.
> > > 
> > 
> > I didnt understand this comment, Can you please elaborate?
> > mmap_uprobe uses build_probe_list and munmap_uprobe uses
> > dec_mm_uprobes_count. 
> 
> Ah, I missed build_probe_list(), but I didn't see a reason for the
> existence of dec_mm_uprobe_count(), the name doesn't make sense and the
> content is 'small' enough to just put in munmap_uprobe.
> 
> To me it looks similar to the list iteration you have in mmap_uprobe(),
> you didn't split that out into another function either.

Hmm, For me whats done in dec_mm_uprobe_count() is similar to whats
done in build_probe_list(), just that build_probe_list does a atomic_inc
+ list_add while dec_mm_uprobe_count() does a atomic_dec.

When I kept dec_mm_uprobe_count() inside munmap_uprobe(), I found most
of the code nested too deep. Hence carved it out as a separate function.

I open to suggestions for dec_mm_uprobe_count()

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D03B56B0012
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 01:48:25 -0400 (EDT)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p5G5OBgZ014092
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 01:24:11 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5G5mN1g166052
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 01:48:23 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5G5mIDg005985
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 01:48:23 -0400
Date: Thu, 16 Jun 2011 11:10:22 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 3.0-rc2-tip 4/22]  4: Uprobes: register/unregister
 probes.
Message-ID: <20110616054022.GJ4952@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
 <20110607125900.28590.16071.sendpatchset@localhost6.localdomain6>
 <1307660604.2497.1769.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1307660604.2497.1769.camel@laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Oleg Nesterov <oleg@redhat.com>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

* Peter Zijlstra <peterz@infradead.org> [2011-06-10 01:03:24]:

> On Tue, 2011-06-07 at 18:29 +0530, Srikar Dronamraju wrote:
> > +       vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, 0, 0) {
> > +               loff_t vaddr;
> > +               struct task_struct *tsk;
> > +
> > +               if (!atomic_inc_not_zero(&vma->vm_mm->mm_users))
> > +                       continue;
> > +
> > +               mm = vma->vm_mm;
> > +               if (!valid_vma(vma)) {
> > +                       mmput(mm);
> > +                       continue;
> > +               }
> > +
> > +               vaddr = vma->vm_start + offset;
> > +               vaddr -= vma->vm_pgoff << PAGE_SHIFT;
> > +               if (vaddr < vma->vm_start || vaddr > vma->vm_end) {
> > +                       /* Not in this vma */
> > +                       mmput(mm);
> > +                       continue;
> > +               }
> > +               tsk = get_mm_owner(mm);
> > +               if (tsk && vaddr > TASK_SIZE_OF(tsk)) {
> > +                       /*
> > +                        * We cannot have a virtual address that is
> > +                        * greater than TASK_SIZE_OF(tsk)
> > +                        */
> > +                       put_task_struct(tsk);
> > +                       mmput(mm);
> > +                       continue;
> > +               }
> > +               put_task_struct(tsk);
> > +               mm->uprobes_vaddr = (unsigned long) vaddr;
> > +               list_add(&mm->uprobes_list, &try_list);
> > +       } 
> 
> This still falls flat on its face when there's multiple maps of the same
> text in one mm.
> 

To address this we will use a uprobe_info structure.

struct uprobe_info {
        unsigned long uprobes_vaddr;
        struct mm_struct *mm;
        struct list_head uprobes_list;
};

and remove the uprobes_list and uprobes_vaddr entries from mm structure.

the uprobe_info structures will be created in the vma_prio_tree_foreach
loop as and when required. Since we now have i_mmap_mutex, allocating this
uprobe_info structure as when required should be okay.

Agree?

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

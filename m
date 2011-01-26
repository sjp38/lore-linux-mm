Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 076076B0092
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 04:10:26 -0500 (EST)
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e32.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p0Q90F9u028483
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 02:00:15 -0700
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0Q9ALBO100990
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 02:10:21 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0Q9AJ59005743
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 02:10:21 -0700
Date: Wed, 26 Jan 2011 14:33:46 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [RFC] [PATCH 2.6.37-rc5-tip 8/20]  8: uprobes: mmap and fork
 hooks.
Message-ID: <20110126090346.GH19725@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20101216095714.23751.52601.sendpatchset@localhost6.localdomain6>
 <20101216095848.23751.73144.sendpatchset@localhost6.localdomain6>
 <1295957739.28776.717.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1295957739.28776.717.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Frederic Weisbecker <fweisbec@gmail.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

> On Thu, 2010-12-16 at 15:28 +0530, Srikar Dronamraju wrote:
> > +void uprobe_mmap(struct vm_area_struct *vma)
> > +{
> > +       struct list_head tmp_list;
> > +       struct uprobe *uprobe, *u;
> > +       struct mm_struct *mm;
> > +       struct inode *inode;
> > +
> > +       if (!valid_vma(vma))
> > +               return;
> > +
> > +       INIT_LIST_HEAD(&tmp_list);
> > +
> > +       /*
> > +        * The vma was just allocated and this routine gets called
> > +        * while holding write lock for mmap_sem.  Function called
> > +        * in context of a thread that has a reference to mm.
> > +        * Hence no need to take a reference to mm
> > +        */
> > +       mm = vma->vm_mm;
> > +       up_write(&mm->mmap_sem);
> 
> Are you very very sure its a good thing to simply drop the mmap_sem
> here? Also, why?
> 

I actually dont like to release the write_lock and then reacquire it.
write_opcode, which is called thro install_uprobe, i.e to insert the
actual breakpoint instruction takes a read lock on the mmap_sem.
Hence uprobe_mmap gets called in context with write lock on mmap_sem
held, I had to release it before calling install_uprobe.

Another solution, I thought of was to pass a context to write_opcode to
say that map-sem is already acquired by us. But I am not sure that
idea is good enuf. 

> > +       mutex_lock(&uprobes_mutex);
> > +
> > +       inode = vma->vm_file->f_mapping->host;
> 
> Since you just dropped the mmap_sem, what's keeping that vma from going
> away?
> 

How about dropping the mmap_sem after add_to_temp_list and cachng the
vma->vm_start value before calling add_to_temp_list?

Or if you have better ideas, then that would be great.

> > +       add_to_temp_list(vma, inode, &tmp_list);
> > +
> > +       list_for_each_entry_safe(uprobe, u, &tmp_list, pending_list) {
> > +               mm->uprobes_vaddr = vma->vm_start + uprobe->offset;
> > +               install_uprobe(mm, uprobe);
> > +               list_del(&uprobe->pending_list);
> > +       }
> > +       mutex_unlock(&uprobes_mutex);
> > +       down_write(&mm->mmap_sem);
> > +} 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

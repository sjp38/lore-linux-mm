Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A4A8C6B0092
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 03:02:34 -0500 (EST)
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e9.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p0Q7brG2006240
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 02:37:55 -0500
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 900E24DE8043
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 02:59:00 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0Q82VI4389938
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 03:02:31 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0Q82Umh014000
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 06:02:31 -0200
Date: Wed, 26 Jan 2011 13:25:58 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [RFC] [PATCH 2.6.37-rc5-tip 5/20]  5: Uprobes:
 register/unregister probes.
Message-ID: <20110126075558.GB19725@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20101216095714.23751.52601.sendpatchset@localhost6.localdomain6>
 <20101216095817.23751.76989.sendpatchset@localhost6.localdomain6>
 <1295957744.28776.722.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1295957744.28776.722.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Frederic Weisbecker <fweisbec@gmail.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

> > +
> > +               list_add(&mm->uprobes_list, &tmp_list);
> > +               mm->uprobes_vaddr = vma->vm_start + offset;
> > +       }
> > +       spin_unlock(&mapping->i_mmap_lock);
> 
> Both this and unregister are racy, what is to say:
>  - the vma didn't get removed from the mm
>  - no new matching vma got added
> 

register_uprobe, unregister_uprobe, uprobe_mmap are all synchronized by
uprobes_mutex. So I dont see one unregister_uprobe getting thro when
another register_uprobe is working with a vma.

If I am missing something elementary, please explain a bit more.

> > +       if (list_empty(&tmp_list)) {
> > +               ret = 0;
> > +               goto consumers_add;
> > +       }
> > +       list_for_each_entry_safe(mm, tmpmm, &tmp_list, uprobes_list) {
> > +               if (!install_uprobe(mm, uprobe))
> > +                       ret = 0;
> > +               list_del(&mm->uprobes_list);
> > +               mmput(mm);
> > +       }
> > +
> > +consumers_add:
> > +       add_consumer(uprobe, consumer);
> > +       mutex_unlock(&uprobes_mutex);
> > +       put_uprobe(uprobe);
> > +       return ret;
> > +}
> > + 

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 55F8F9000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 09:00:26 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p8RCjUCS015321
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 08:45:30 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8RD0MW5183954
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 09:00:22 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8RD0KcB011876
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 10:00:21 -0300
Date: Tue, 27 Sep 2011 18:15:00 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 3.1.0-rc4-tip 18/26]   uprobes: slot allocation.
Message-ID: <20110927124500.GA3685@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
 <20110920120335.25326.50673.sendpatchset@srdronam.in.ibm.com>
 <1317125932.15383.49.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1317125932.15383.49.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

* Peter Zijlstra <peterz@infradead.org> [2011-09-27 14:18:52]:

> On Tue, 2011-09-20 at 17:33 +0530, Srikar Dronamraju wrote:
> > +static struct uprobes_xol_area *xol_alloc_area(void)
> > +{
> > +       struct uprobes_xol_area *area = NULL;
> > +
> > +       area = kzalloc(sizeof(*area), GFP_KERNEL);
> > +       if (unlikely(!area))
> > +               return NULL;
> > +
> > +       area->bitmap = kzalloc(BITS_TO_LONGS(UINSNS_PER_PAGE) * sizeof(long),
> > +                                                               GFP_KERNEL);
> > +
> > +       if (!area->bitmap)
> > +               goto fail;
> > +
> > +       init_waitqueue_head(&area->wq);
> > +       spin_lock_init(&area->slot_lock);
> > +       if (!xol_add_vma(area) && !current->mm->uprobes_xol_area) {
> 
> So what happens if xol_add_vma() succeeds, but we find
> ->uprobes_xol_area set?
> 
> > +               task_lock(current);
> > +               if (!current->mm->uprobes_xol_area) {
> 
> Having to re-test it under this lock seems to suggest it could.
> 
> > +                       current->mm->uprobes_xol_area = area;
> > +                       task_unlock(current);
> > +                       return area;
> 
> This function would be so much easier to read if the success case (this
> here I presume) would not be nested 2 deep.
> 
> > +               }
> > +               task_unlock(current);
> > +       }
> 
> at which point you could end up with two extra vmas? Because there's no
> freeing of the result of xol_add_vma().
> 

Agree, we need to unmap the vma in that case.

> > +fail:
> > +       kfree(area->bitmap);
> > +       kfree(area);
> > +       return current->mm->uprobes_xol_area;
> > +} 

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

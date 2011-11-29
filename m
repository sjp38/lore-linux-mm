Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A30106B0055
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 02:49:59 -0500 (EST)
Received: from /spool/local
	by e6.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Tue, 29 Nov 2011 02:49:53 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAT7nn3c334716
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 02:49:49 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAT7nlUT018065
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 05:49:49 -0200
Date: Tue, 29 Nov 2011 13:18:07 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v7 3.2-rc2 3/30] uprobes: register/unregister probes.
Message-ID: <20111129074807.GA13445@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
 <20111118110713.10512.9461.sendpatchset@srdronam.in.ibm.com>
 <1322494194.2921.147.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1322494194.2921.147.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>

* Peter Zijlstra <peterz@infradead.org> [2011-11-28 16:29:54]:

> On Fri, 2011-11-18 at 16:37 +0530, Srikar Dronamraju wrote:
> > +static void __unregister_uprobe(struct inode *inode, loff_t offset,
> > +                                               struct uprobe *uprobe)
> > +{
> > +       struct list_head try_list;
> > +       struct address_space *mapping;
> > +       struct vma_info *vi, *tmpvi;
> > +       struct vm_area_struct *vma;
> > +       struct mm_struct *mm;
> > +       loff_t vaddr;
> > +
> > +       mapping = inode->i_mapping;
> > +       INIT_LIST_HEAD(&try_list);
> > +       while ((vi = find_next_vma_info(&try_list, offset,
> > +                                               mapping, false)) != NULL) {
> > +               if (IS_ERR(vi))
> > +                       break;
> 
> So what kind of half-assed state are we left in if we try an unregister
> under memory pressure and how do we deal with that?
> 

Agree, Even I had this concern and wanted to see if there are ways to
deal with this.

- One approach would be pass extra GFG flags while we do allocations
  atleast in the unregister_uprobe.

Drawback of this approach: if the system is already under memory
pressure we shouldnt exert more pressure by asking it to repeat.

- The other approach would be to cache these temporary objects while we
  insert probes. i.e keep these metadata around.

I am sure you wouldnt want to add additional metadata.

- Third approach would be to have a completion/worker routine kick in if
  unregister_uprobe fails due to memory allocations.

This looks better than the rest.

Do you have any other approaches that we could try?

-- 
thanks and regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

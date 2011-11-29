Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 700F76B004D
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 03:35:13 -0500 (EST)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Tue, 29 Nov 2011 01:35:12 -0700
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAT8Z804095822
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 01:35:08 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAT8Z5LR017941
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 01:35:07 -0700
Date: Tue, 29 Nov 2011 14:03:22 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v7 3.2-rc2 4/30] uprobes: Define hooks for mmap/munmap.
Message-ID: <20111129083322.GD13445@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
 <20111118110723.10512.66282.sendpatchset@srdronam.in.ibm.com>
 <1322071812.14799.87.camel@twins>
 <20111124134742.GH28065@linux.vnet.ibm.com>
 <1322492384.2921.143.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1322492384.2921.143.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>, tulasidhard@gmail.com

> > > > +                       ret = install_breakpoint(vma->vm_mm, uprobe);
> > > > +                       if (ret == -EEXIST) {
> > > > +                               atomic_inc(&vma->vm_mm->mm_uprobes_count);
> > > > +                               ret = 0;
> > > > +                       } 
> > > 
> > > Aren't you double counting that probe position here? The one that raced
> > > you to inserting it will also have incremented that counter, no?
> > > 
> > 
> > No we arent.
> > Because register_uprobe can never race with mmap_uprobe and register
> > before mmap_uprobe registers .(Once we start mmap_region,
> > register_uprobe waits for the read_lock of mmap_sem.)
> > 
> > And we badly need this for mmap_uprobe case.  Because when we do mremap,
> > or vma_adjust(), we do a munmap_uprobe() followed by mmap_uprobe() which
> > would have decremented the count but not removed it. So when we do a
> > mmap_uprobe, we need to increment the count. 
> 
> Ok, so I didn't parse that properly last time around.. but it still
> doesn't make sense, why would munmap_uprobe() decrement the count but
> not uninstall the probe?
> 
> install_breakpoint() returning -EEXIST on two different conditions
> doesn't help either.
> 
> So what I think you're doing is that you're optimizing the unmap case
> since the memory is going to be thrown out fixing up the instruction is
> a waste of time, but this leads to the asymmetry observed above. But you

Yes, we are optimizing the unmap case, because we expect the memory to
be thrown out.

> fail to mention this in both the changelog or a comment near that
> -EEXIST branch in mmap_uprobe.
> 
> Worse, you don't explain how the other -EEXIST (!consumers) thing
> interacts here, and I just gave up trying to figure that out since it
> made my head hurt.
> 

install_breakpoints cannot have !consumers to be true when called from
register_uprobe. (Since unregister_uprobe() which does the removal of
consumer cannot race with register_uprobe().)

Now lets consider mmap_uprobe() being called from vm_adjust(), the
preceding unmap_uprobe() has already decremented the count but left the
count intact.

if consumers is NULL, unregister_uprobes() has kicked already in, so
there is no point in inserting the probe, Hence we return EEXIST. The
following unregister_uprobe() (or the munmap_uprobe() which might race
before unregister_uprobe) is also going to decrement the count.  So we
have a case where the same breakpoint is accounted as removed twice. To
offset this, we pretend as if the breakpoint is around by incrementing
the count.

Would it help if I add an extra check in mmap_uprobe?

int mmap_uprobe(...) {
....
	       ret = install_breakpoint(vma->vm_mm, uprobe);
	       if (ret == -EEXIST) {
			if (!read_opcode(vma->vm_mm, vaddr, &opcode) &&
					(opcode == UPROBES_BKPT_INSN))
			       atomic_inc(&vma->vm_mm->mm_uprobes_count);
		       ret = 0;
	       } 
....
}


The extra read_opcode check will tell us if the breakpoint is still
around and then only increment the count. (As in it will distinguish if
the mmap_uprobe is from vm_adjust).

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

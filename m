Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id AC5516B004D
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 11:25:32 -0500 (EST)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Tue, 29 Nov 2011 09:25:31 -0700
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pATGOjlC092860
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 09:24:46 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pATGOdFh006884
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 09:24:45 -0700
Date: Tue, 29 Nov 2011 21:52:37 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v7 3.2-rc2 4/30] uprobes: Define hooks for mmap/munmap.
Message-ID: <20111129162237.GA18380@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
 <20111118110723.10512.66282.sendpatchset@srdronam.in.ibm.com>
 <1322071812.14799.87.camel@twins>
 <20111124134742.GH28065@linux.vnet.ibm.com>
 <1322492384.2921.143.camel@twins>
 <20111129083322.GD13445@linux.vnet.ibm.com>
 <1322567326.2921.226.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1322567326.2921.226.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>, tulasidhard@gmail.com

The rules that I am using are: 

mmap_uprobe() increments the count if 
	- it successfully adds a breakpoint.
	- it not add a breakpoint, but sees that there is a underlying
	  breakpoint (via a read_opcode call).

munmap_uprobe() decrements the count if 
	- it sees a underlying breakpoint,  (via  a read_opcode call)
	- Subsequent unregister_uprobe wouldnt find the breakpoint
	  unless a mmap_uprobe kicks in, since the old vma would be
	  dropped just after munmap_uprobe.

register_uprobe increments the count if:
	- it successfully adds a breakpoint.

unregister_uprobe decrements the count if:
	- it sees a underlying breakpoint and removes successfully. 
			(via a read_opcode call)
	- Subsequent munmap_uprobe wouldnt find the breakpoint
	  since there is no underlying breakpoint after the
	  breakpoint removal.

> > 
> > if consumers is NULL, unregister_uprobes() has kicked already in, so
> > there is no point in inserting the probe, Hence we return EEXIST. The
> > following unregister_uprobe() (or the munmap_uprobe() which might race
> > before unregister_uprobe) is also going to decrement the count.  So we
> > have a case where the same breakpoint is accounted as removed twice. To
> > offset this, we pretend as if the breakpoint is around by incrementing
> > the count.
> 
> There's 2 main cases, 
> 	A) vma_adjust() vs unregister_uprobe() and 
> 	B) mmap() vs unregister_uprobe().
> 
> The result of A should be -1 reference in total, since we're removing
> the one probe. 

If the breakpoint was never there, then a value of 0 should also be
correct.  See case A3a and A3b.

> The result of B should be 0 since we're removing the
> probe and we shouldn't be installing new ones.
> 
> A1)
> 	vma_adjust()
> 	  munmap_uprobe()
> 				unregister_uprobe()
> 	  mmap_uprobe()
> 				  delete_uprobe()
> 
> 
> 	munmap will to -1, mmap will do +1, __unregister_uprobe() which is
> serialized against vma_adjust() will do -1 on either the old or new vma,
> resulting in a grand total of: -1+1-1=-1, OK

Right.

> 
> A2) breakpoint is in old, not in new, again two cases:
> 
> A2a) __unregister_uprobe() sees old

So  unregister_uprobe is called on the vma before vma_adjust.

> 
> 	munmap -1, __unregister_uprobe -1, mmap 0: -2 FAIL
> 

So munmap wouldnt decrement because, munmap_uprobe checks to see if the
breakpoint is still around before it increments.

unregister unlike munmap removes the breakpoint too.

> A2b) __unregister_uprobe() sees new
> 

So the order would be munmap(), mmap() and unregister_uprobe()

> 	munmap -1, __unregister_uprobe 0, mmap 0: -1 OK

Right, Since the old vma is gone, the new vma doesnt have the
breakpoint.

> 
> A3) breakpoint is in new, not in old, again two cases:
> 

> A3a) __unregister_uprobe() sees old
> 
So  unregister_uprobe is called on the vma before vma_adjust.

> 	munmap 0, __unregister_uprobe 0, mmap: 1: 1 FAIL


If mmap_uprobe() increments it would mean that breakpoint was already
there. (-EEXIST + read_opcode); since there was no breakpoint, it will
not increment..

0 is the correct value here, Not -1. because there was no probe inserted
or removed.

> 
> A3b) __unregister_uprobe() seed new
So the order would be munmap(), mmap() and unregister_uprobe()
> 
> 	munmap 0, __unregister_uprobe -1, mmap: 1: 0 FAIL
> 

If mmap_uprobe() increments it would mean that breakpoint was already
there.  __unregister_uprobe will decrement.  Since we added a new probe
and deleted it, the value 0 is correct here.

> B1)
> 				unregister_uprobe()
> 	mmap()
> 	  mmap_uprobe()
> 				  __unregister_uprobe()
> 				  delete_uprobe()
> 
> 	mmap +1, __unregister_uprobe() -1: 0 OK
> 
> B2)
> 				unregister_uprobe()
> 	mmap()
> 				  __unregister_uprobe()
> 	  mmap_uprobe()
> 				  delete_uprobe()
> 
> 	mmap +1, __unregister_uprobe() 0: +1 FAIL

I think you meant __unregister_uprobe happened before mmap_uprobe.

If mmap_uprobe() increments it would mean that breakpoint was already
there. (-EEXIST + read_opcode); since there was no breakpoint, it will
not increment..
> 
> 
> > Would it help if I add an extra check in mmap_uprobe?
> > 
> > int mmap_uprobe(...) {
> > ....
> > 	       ret = install_breakpoint(vma->vm_mm, uprobe);
> > 	       if (ret == -EEXIST) {
> > 			if (!read_opcode(vma->vm_mm, vaddr, &opcode) &&
> > 					(opcode == UPROBES_BKPT_INSN))
> > 			       atomic_inc(&vma->vm_mm->mm_uprobes_count);
> > 		       ret = 0;
> > 	       } 
> > ....
> > }
> 
> > The extra read_opcode check will tell us if the breakpoint is still
> > around and then only increment the count. (As in it will distinguish if
> > the mmap_uprobe is from vm_adjust).
> 
> No, I don't see that fixing A2a for example.

This check should help A3a and B2 cases.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

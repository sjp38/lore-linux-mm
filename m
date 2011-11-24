Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 488536B0096
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 09:26:16 -0500 (EST)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Thu, 24 Nov 2011 09:26:14 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAOEQAwb326360
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 09:26:10 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAOEQ7bP026570
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 09:26:09 -0500
Date: Thu, 24 Nov 2011 19:55:07 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v7 3.2-rc2 4/30] uprobes: Define hooks for mmap/munmap.
Message-ID: <20111124142507.GI28065@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
 <20111118110723.10512.66282.sendpatchset@srdronam.in.ibm.com>
 <1322071812.14799.87.camel@twins>
 <20111124134742.GH28065@linux.vnet.ibm.com>
 <1322144017.2921.57.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1322144017.2921.57.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>, tulasidhard@gmail.com

* Peter Zijlstra <peterz@infradead.org> [2011-11-24 15:13:37]:

> On Thu, 2011-11-24 at 19:17 +0530, Srikar Dronamraju wrote:
> > * Peter Zijlstra <peterz@infradead.org> [2011-11-23 19:10:12]:
> > 
> > > On Fri, 2011-11-18 at 16:37 +0530, Srikar Dronamraju wrote:
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
> 
> Still doesn't make any sense. Since you don't increment on success, one
> has to assume install_breakpoint() will cause an increment. Therefore,
> when we encounter -EEXIST we'll already have accounted for this
> mm,inode,offset combination.
> 

In the success case, install_breakpoint itself does the increment.
We cant allow install_breakpoint to increment in EEXIST case always
because doing that in register_uprobe context would increment which is
wrong.

> But I'll have another look at it, maybe I'm missing something
> obvious :-)
> 
> > And we badly need this for mmap_uprobe case.  Because when we do mremap,
> > or vma_adjust(), we do a munmap_uprobe() followed by mmap_uprobe() which
> > would have decremented the count but not removed it. So when we do a
> > mmap_uprobe, we need to increment the count. 
> 
> Well I see why the count needs to be correct, that's not the issue.

Okay .. 

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

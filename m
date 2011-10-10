Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4D6B36B002C
	for <linux-mm@kvack.org>; Mon, 10 Oct 2011 08:49:38 -0400 (EDT)
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e36.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p9ACgbkE020390
	for <linux-mm@kvack.org>; Mon, 10 Oct 2011 06:42:37 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p9ACnUii154664
	for <linux-mm@kvack.org>; Mon, 10 Oct 2011 06:49:30 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p9ACnSKx023502
	for <linux-mm@kvack.org>; Mon, 10 Oct 2011 06:49:30 -0600
Date: Mon, 10 Oct 2011 18:01:02 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 3.1.0-rc4-tip 4/26]   uprobes: Define hooks for
 mmap/munmap.
Message-ID: <20111010123102.GC16268@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
 <20110920120040.25326.63549.sendpatchset@srdronam.in.ibm.com>
 <20111003133710.GA28118@redhat.com>
 <20111006110531.GE17591@linux.vnet.ibm.com>
 <20111007173623.GC32319@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20111007173623.GC32319@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

> > >
> > > So. We are adding the new mapping, we should find all breakpoints this
> > > file has in the start/end range.
> > >
> > > We are holding ->mmap_sem... this seems enough to protect against the
> > > races with register/unregister. Except, what if __register_uprobe()
> > > fails? In this case __unregister_uprobe() does delete_uprobe() at the
> > > very end. What if mmap mmap_uprobe() is called right before delete_?
> > >
> >
> > Because consumers would be NULL before _unregister_uprobe kicks in, we
> > shouldnt have a problem here.
> 
> Hmm. But it is not NULL.
> 
> Once again, I didn't mean unregister_uprobe(). I meant register_uprobe().
> In this case, if __register_uprobe() fails, we are doing __unregister
> but uprobe->consumer != NULL.

Oh Okay, I missed setting uprobe->consumer = NULL once __register_uprobe
fails.
I shall go ahead and set uprobe->consumer = NULL; (the other option is
calling del_consumer() but I dont see a need for calling this.) just
before calling __unregister_uprobe() if and only if __register_uprobe
fails.

> 
> Just suppose that the caller of register_uprobe() gets a (long) preemption
> right before __unregister_uprobe()->delete_uprobe(). What if mmap() is
> called at this time?
> 
> > Am I missing something?
> 
> May be you, may be me. Please recheck ;)

Rechecked and found the issue. Thanks.

> 
> > I think this would be taken care of if we move the munmap_uprobe() hook
> > from unmap_vmas to unlink_file_vma().
> 
> Probably yes, we should rely on prio_tree locking/changes.
> 
> > The other thing that I need to investigate a bit more is if I have
> > handle all cases of mremap correctly.
> 
> Yes. May be mmap_uprobe() should be "closer" to vma_prio_tree_add/insert
> too, but I am not sure.

Okay, that seems like a good idea.

> 
> Oleg.
> 

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

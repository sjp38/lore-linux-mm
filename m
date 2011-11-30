Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 060C66B004D
	for <linux-mm@kvack.org>; Wed, 30 Nov 2011 00:33:04 -0500 (EST)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Tue, 29 Nov 2011 22:33:02 -0700
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAU5WgXK117848
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 22:32:42 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAU5WaY0016192
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 22:32:41 -0700
Date: Wed, 30 Nov 2011 11:00:44 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v7 3.2-rc2 4/30] uprobes: Define hooks for mmap/munmap.
Message-ID: <20111130053007.GA21514@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
 <20111118110723.10512.66282.sendpatchset@srdronam.in.ibm.com>
 <1322071812.14799.87.camel@twins>
 <20111124134742.GH28065@linux.vnet.ibm.com>
 <1322492384.2921.143.camel@twins>
 <20111129083322.GD13445@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20111129083322.GD13445@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>, tulasidhard@gmail.com

> 
> int mmap_uprobe(...) {
> ....
> 	       ret = install_breakpoint(vma->vm_mm, uprobe);
> 	       if (ret == -EEXIST) {
> 			if (!read_opcode(vma->vm_mm, vaddr, &opcode) &&
> 					(opcode == UPROBES_BKPT_INSN))
> 			       atomic_inc(&vma->vm_mm->mm_uprobes_count);
> 		       ret = 0;
> 	       } 
> ....
> }
> 

Infact the check for EEXIST and read_opcode in mmap_uprobe() is needed
for another reason too.

Lets say while unregister_uprobe was around, a thread thats being
probed, just forked a child and the child called mmap_uprobe.

Now mmap_uprobe might find that the breakpoint is already inserted
since the pages are shared with the parent. But before
unregister_uprobe can come around and cleanup, the child can run and hit
the breakpoint. Since the breakpoint count is 0 for the child, we dont
expect the child to have hit a breakpoint placed by uprobes, and the
child gets a SIGTRAP.

With this check for read_opcode on EEXIST from install_breakpoint, we
will know that there is a valid breakpoint underneath and increment
the count. So on a breakpoint hit, the uprobes notifier does the right
thing.

If the unregister_uprobe() had already cleanup the breakpoint in the
parent, the child's copy would also be clean so read_opcode wont find
the breakpoint and hence we wont increment the breakpoint.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

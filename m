Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D2B346B0055
	for <linux-mm@kvack.org>; Wed, 30 Nov 2011 00:52:53 -0500 (EST)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Tue, 29 Nov 2011 22:52:52 -0700
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAU5qoY5091340
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 22:52:50 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAU5qm1Z019127
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 22:52:50 -0700
Date: Wed, 30 Nov 2011 11:20:56 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v7 3.2-rc2 4/30] uprobes: Define hooks for mmap/munmap.
Message-ID: <20111130055056.GB18380@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
 <20111118110723.10512.66282.sendpatchset@srdronam.in.ibm.com>
 <1322071812.14799.87.camel@twins>
 <20111124134742.GH28065@linux.vnet.ibm.com>
 <1322492384.2921.143.camel@twins>
 <20111129083322.GD13445@linux.vnet.ibm.com>
 <1322567326.2921.226.camel@twins>
 <1322579127.2921.240.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1322579127.2921.240.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>, tulasidhard@gmail.com

> 
> There's more cases, I forgot the details of how the prio_tree stuff
> works, so please consider if its possible to also have:
> 
>   __unregister_uprobe() will observe neither old nor new
> 
> This could happen if we first munmap, __unregister_uprobe() will iterate
> past where mmap() will insert the new vma, mmap will insert the new vma,
> and __unregister_uprobe() will now not observe it.
> 

- When we iterate thro __unregister_uprobe(), we always walk from the
  root of the prio tree and not depend on the last found node. So
  __unregister_uprobe able to iterate thro the rmap without finding the
  old or the new vma would mean that the exclusive mmap_sem was dropped
  for atleast a brief period and munmap/mmap are disjoint.

Here munmap_uprobe would have reduced the count followed by the pages
being cleared.
__unregister_uprobe maintains the status quo.
mmap_uprobe would load a new set of pages without any breakpoint, since
there are no consumers, and no underlying breakpoints, it also maintains
the status quo.

> and
> 
>   __unregister_uprobe() will observe both old _and_ new
> 
> This latter could happen by favourably interleaving the prio_tree
> iteration with the munmap and mmap operations, so that we first observe
> the old vma, do the munmap, do the mmap, and then have the
> find_next_vma_info() thing find the new vma.

If __unregister_uprobe() can observe both old _and_ new, then it means
mmap has occurred. So its correct that probes are removed from
the old and new. The munmap_uprobe of the old vma wouldnt see the
breakpoint (via read_opcode) so wont decrement the count. If the
munmap_uprobe had seen the breakpoint before unregister_uprobe, then
unregister_uprobe cant decrement the count.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

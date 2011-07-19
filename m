Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 0E22E6B004A
	for <linux-mm@kvack.org>; Tue, 19 Jul 2011 03:05:42 -0400 (EDT)
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e2.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p6J6iQsu009130
	for <linux-mm@kvack.org>; Tue, 19 Jul 2011 02:44:26 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p6J75YKx113220
	for <linux-mm@kvack.org>; Tue, 19 Jul 2011 03:05:34 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p6J75WxZ026378
	for <linux-mm@kvack.org>; Tue, 19 Jul 2011 03:05:34 -0400
Date: Tue, 19 Jul 2011 12:23:50 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 3.0-rc2-tip 7/22]  7: uprobes: mmap and fork hooks.
Message-ID: <20110719065350.GB1210@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110617090504.GN4952@linux.vnet.ibm.com>
 <1308303665.2355.11.camel@twins>
 <1308662243.26237.144.camel@twins>
 <20110622143906.GF16471@linux.vnet.ibm.com>
 <20110624020659.GA24776@linux.vnet.ibm.com>
 <1308901324.27849.7.camel@twins>
 <20110627064502.GB24776@linux.vnet.ibm.com>
 <1309165071.6701.4.camel@twins>
 <20110718092055.GA1210@linux.vnet.ibm.com>
 <1310999476.13765.107.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1310999476.13765.107.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

* Peter Zijlstra <peterz@infradead.org> [2011-07-18 16:31:16]:

> On Mon, 2011-07-18 at 14:50 +0530, Srikar Dronamraju wrote:
> >  *  - Introduce uprobes_list and uprobes_vaddr in vm_area_struct.
> >  *    uprobes_list is a node in the temp list of vmas while
> >  *    registering/unregistering uprobes. uprobes_vaddr caches the vaddr to
> >  *    insert/remove the breakpoint.
> >  *
> >  *  - Introduce srcu to synchronize vma deletion with walking the list of
> >  *    vma in register/unregister_uprobe.
> 
> I don't think you can sell this, that'll make munmap() horridly slow.

Okay, 

How about using a counter and a wq in each vma.
Based on the counter, I can wait in the munmap() and since this is per
vma, this should be faster than srcu.

Counter would be incremented when we do a vma-rmap walk. 
decremented when after insertion/deletion.
read in munmap().

> 
> >  *  - Introduce uprobes_mmap_mutex to synchronize uprobe deletion and
> >  *    mmap_uprobe(). 
> 
> Yes, that'll work I think.

Here another possibility is to have a per uprobe mutex, that way we
would not have to serialize mmap_uprobe. But this optimization can be
done later too.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

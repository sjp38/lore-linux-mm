Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0253F6B0082
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 05:07:39 -0400 (EDT)
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e39.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p5D8rJMP024475
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 02:53:19 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5D97VGb334298
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 03:07:31 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5D37Txi022775
	for <linux-mm@kvack.org>; Sun, 12 Jun 2011 21:07:31 -0600
Date: Mon, 13 Jun 2011 14:29:55 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 3.0-rc2-tip 2/22]  2: uprobes: Breakground page
 replacement.
Message-ID: <20110613085955.GD27130@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
 <20110607125835.28590.25476.sendpatchset@localhost6.localdomain6>
 <1307660609.2497.1773.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1307660609.2497.1773.camel@laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, LKML <linux-kernel@vger.kernel.org>

* Peter Zijlstra <peterz@infradead.org> [2011-06-10 01:03:29]:

> On Tue, 2011-06-07 at 18:28 +0530, Srikar Dronamraju wrote:
> > +       vaddr_old = kmap_atomic(old_page, KM_USER0);
> > +       vaddr_new = kmap_atomic(new_page, KM_USER1);
> > +
> > +       memcpy(vaddr_new, vaddr_old, PAGE_SIZE);
> > +       /* poke the new insn in, ASSUMES we don't cross page boundary */
> > +       addr = vaddr;
> > +       vaddr &= ~PAGE_MASK;
> > +       memcpy(vaddr_new + vaddr, &opcode, uprobe_opcode_sz);
> > +
> > +       kunmap_atomic(vaddr_new);
> > +       kunmap_atomic(vaddr_old); 
> 
> 
> > +       vaddr_new = kmap_atomic(page, KM_USER0);
> > +       vaddr &= ~PAGE_MASK;
> > +       memcpy(opcode, vaddr_new + vaddr, uprobe_opcode_sz);
> > +       kunmap_atomic(vaddr_new);
> > 


> 
> Both sequences in resp {write,read}_opcode() assume the opcode doesn't
> cross page boundaries but don't in fact have any assertions validating
> this assumption.
> 

read_opcode and write_opcode reads/writes just one breakpoint instruction
I had the below note just above the write_opcode definition.

/*
 * NOTE:
 * Expect the breakpoint instruction to be the smallest size instruction for
 * the architecture. If an arch has variable length instruction and the
 * breakpoint instruction is not of the smallest length instruction
 * supported by that architecture then we need to modify read_opcode /
 * write_opcode accordingly. This would never be a problem for archs that
 * have fixed length instructions.
 */

Do we have archs which have a breakpoint instruction which isnt of the
smallest instruction size for that arch. If we do have can we change the
write_opcode/read_opcode while we support that architecture?

-- 
Thanks and Regards
Srikar
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

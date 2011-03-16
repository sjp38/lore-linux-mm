Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5EE8B8D0039
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 01:04:29 -0400 (EDT)
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e6.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p2G4eABf029721
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 00:40:10 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id BF3B238C8038
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 01:04:23 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2G54REC330660
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 01:04:27 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2G54PMI021536
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 01:04:26 -0400
Date: Wed, 16 Mar 2011 10:28:20 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 2.6.38-rc8-tip 11/20] 11: uprobes: slot allocation
 for uprobes
Message-ID: <20110316045820.GF24254@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
 <20110314133610.27435.93666.sendpatchset@localhost6.localdomain6>
 <20110315131020.36477a1c@bike.lwn.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20110315131020.36477a1c@bike.lwn.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

* Jonathan Corbet <corbet@lwn.net> [2011-03-15 13:10:20]:

> Just a couple of minor notes while I was looking at this code...
> 
> > +static struct uprobes_xol_area *xol_alloc_area(void)
> > +{
> > +	struct uprobes_xol_area *area = NULL;
> > +
> > +	area = kzalloc(sizeof(*area), GFP_USER);
> > +	if (unlikely(!area))
> > +		return NULL;
> > +
> > +	area->bitmap = kzalloc(BITS_TO_LONGS(UINSNS_PER_PAGE) * sizeof(long),
> > +								GFP_USER);
> 
> Why GFP_USER?  That causes extra allocation limits to be enforced.  Given
> that in part 14 you have:

Okay, Will use GFP_KERNEL. 
We used GFP_USER because we thought its going to represent part of
process address space; 

> 
> +/* Prepare to single-step probed instruction out of line. */
> +static int pre_ssout(struct uprobe *uprobe, struct pt_regs *regs,
> +				unsigned long vaddr)
> +{
> +	xol_get_insn_slot(uprobe, vaddr);
> +	BUG_ON(!current->utask->xol_vaddr);
> 
> It seems to me that you really don't want those allocations to fail.
> 
> back to xol_alloc_area():
> 
> > +	if (!area->bitmap)
> > +		goto fail;
> > +
> > +	spin_lock_init(&area->slot_lock);
> > +	if (!xol_add_vma(area) && !current->mm->uprobes_xol_area) {
> > +		task_lock(current);
> > +		if (!current->mm->uprobes_xol_area) {
> > +			current->mm->uprobes_xol_area = area;
> > +			task_unlock(current);
> > +			return area;
> > +		}
> > +		task_unlock(current);
> > +	}
> > +
> > +fail:
> > +	if (area) {
> > +		if (area->bitmap)
> > +			kfree(area->bitmap);
> > +		kfree(area);
> > +	}
> 
> You've already checked area against NULL, and kfree() can handle null
> pointers, so both of those tests are unneeded.

Okay, 

> 
> > +	return current->mm->uprobes_xol_area;
> > +}
> 
> jon

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

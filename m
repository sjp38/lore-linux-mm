Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id CB9CB8D0039
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 15:10:24 -0400 (EDT)
Date: Tue, 15 Mar 2011 13:10:20 -0600
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH v2 2.6.38-rc8-tip 11/20] 11: uprobes: slot allocation
 for uprobes
Message-ID: <20110315131020.36477a1c@bike.lwn.net>
In-Reply-To: <20110314133610.27435.93666.sendpatchset@localhost6.localdomain6>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
	<20110314133610.27435.93666.sendpatchset@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

Just a couple of minor notes while I was looking at this code...

> +static struct uprobes_xol_area *xol_alloc_area(void)
> +{
> +	struct uprobes_xol_area *area = NULL;
> +
> +	area = kzalloc(sizeof(*area), GFP_USER);
> +	if (unlikely(!area))
> +		return NULL;
> +
> +	area->bitmap = kzalloc(BITS_TO_LONGS(UINSNS_PER_PAGE) * sizeof(long),
> +								GFP_USER);

Why GFP_USER?  That causes extra allocation limits to be enforced.  Given
that in part 14 you have:

+/* Prepare to single-step probed instruction out of line. */
+static int pre_ssout(struct uprobe *uprobe, struct pt_regs *regs,
+				unsigned long vaddr)
+{
+	xol_get_insn_slot(uprobe, vaddr);
+	BUG_ON(!current->utask->xol_vaddr);

It seems to me that you really don't want those allocations to fail.

back to xol_alloc_area():

> +	if (!area->bitmap)
> +		goto fail;
> +
> +	spin_lock_init(&area->slot_lock);
> +	if (!xol_add_vma(area) && !current->mm->uprobes_xol_area) {
> +		task_lock(current);
> +		if (!current->mm->uprobes_xol_area) {
> +			current->mm->uprobes_xol_area = area;
> +			task_unlock(current);
> +			return area;
> +		}
> +		task_unlock(current);
> +	}
> +
> +fail:
> +	if (area) {
> +		if (area->bitmap)
> +			kfree(area->bitmap);
> +		kfree(area);
> +	}

You've already checked area against NULL, and kfree() can handle null
pointers, so both of those tests are unneeded.

> +	return current->mm->uprobes_xol_area;
> +}

jon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

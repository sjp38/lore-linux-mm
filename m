Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C13306B002F
	for <linux-mm@kvack.org>; Fri,  7 Oct 2011 14:41:52 -0400 (EDT)
Date: Fri, 7 Oct 2011 20:37:40 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v5 3.1.0-rc4-tip 18/26]   uprobes: slot allocation.
Message-ID: <20111007183740.GC1655@redhat.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com> <20110920120335.25326.50673.sendpatchset@srdronam.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110920120335.25326.50673.sendpatchset@srdronam.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On 09/20, Srikar Dronamraju wrote:
>
> - * valid_vma: Verify if the specified vma is an executable vma
> + * valid_vma: Verify if the specified vma is an executable vma,
> + * but not an XOL vma.
>   *	- Return 1 if the specified virtual address is in an
> - *	  executable vma.
> + *	  executable vma, but not in an XOL vma.
>   */
>  static bool valid_vma(struct vm_area_struct *vma)
>  {
> +	struct uprobes_xol_area *area = vma->vm_mm->uprobes_xol_area;
> +
>  	if (!vma->vm_file)
>  		return false;
>
> +	if (area && (area->vaddr == vma->vm_start))
> +			return false;

Could you explain why do we need this "but not an XOL vma" check?
xol_vma->vm_file is always NULL, no?

> +static struct uprobes_xol_area *xol_alloc_area(void)
> +{
> +	struct uprobes_xol_area *area = NULL;
> +
> +	area = kzalloc(sizeof(*area), GFP_KERNEL);
> +	if (unlikely(!area))
> +		return NULL;
> +
> +	area->bitmap = kzalloc(BITS_TO_LONGS(UINSNS_PER_PAGE) * sizeof(long),
> +								GFP_KERNEL);
> +
> +	if (!area->bitmap)
> +		goto fail;
> +
> +	init_waitqueue_head(&area->wq);
> +	spin_lock_init(&area->slot_lock);
> +	if (!xol_add_vma(area) && !current->mm->uprobes_xol_area) {
> +		task_lock(current);
> +		if (!current->mm->uprobes_xol_area) {
> +			current->mm->uprobes_xol_area = area;
> +			task_unlock(current);
> +			return area;
> +		}
> +		task_unlock(current);

But you can't rely on task_lock(), you can race with another thread
with the same ->mm. I guess you need mmap_sem or xchg().

>  static int pre_ssout(struct uprobe *uprobe, struct pt_regs *regs,
>  				unsigned long vaddr)
>  {
> -	/* TODO: Yet to be implemented */
> +	if (xol_get_insn_slot(uprobe, vaddr) && !pre_xol(uprobe, regs)) {
> +		set_instruction_pointer(regs, current->utask->xol_vaddr);

set_instruction_pointer() looks unneded, pre_xol() has already changed
regs->ip.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

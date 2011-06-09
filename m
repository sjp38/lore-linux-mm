Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1BF2C900118
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 18:59:54 -0400 (EDT)
Received: from j77219.upc-j.chello.nl ([24.132.77.219] helo=dyad.programming.kicks-ass.net)
	by casper.infradead.org with esmtpsa (Exim 4.76 #1 (Red Hat Linux))
	id 1QUoCd-00067R-17
	for linux-mm@kvack.org; Thu, 09 Jun 2011 22:59:51 +0000
Subject: Re: [PATCH v4 3.0-rc2-tip 4/22]  4: Uprobes: register/unregister
 probes.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20110607125900.28590.16071.sendpatchset@localhost6.localdomain6>
References: 
	 <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
	 <20110607125900.28590.16071.sendpatchset@localhost6.localdomain6>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 10 Jun 2011 01:03:24 +0200
Message-ID: <1307660604.2497.1769.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 2011-06-07 at 18:29 +0530, Srikar Dronamraju wrote:
> +       vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, 0, 0) {
> +               loff_t vaddr;
> +               struct task_struct *tsk;
> +
> +               if (!atomic_inc_not_zero(&vma->vm_mm->mm_users))
> +                       continue;
> +
> +               mm = vma->vm_mm;
> +               if (!valid_vma(vma)) {
> +                       mmput(mm);
> +                       continue;
> +               }
> +
> +               vaddr = vma->vm_start + offset;
> +               vaddr -= vma->vm_pgoff << PAGE_SHIFT;
> +               if (vaddr < vma->vm_start || vaddr > vma->vm_end) {
> +                       /* Not in this vma */
> +                       mmput(mm);
> +                       continue;
> +               }
> +               tsk = get_mm_owner(mm);
> +               if (tsk && vaddr > TASK_SIZE_OF(tsk)) {
> +                       /*
> +                        * We cannot have a virtual address that is
> +                        * greater than TASK_SIZE_OF(tsk)
> +                        */
> +                       put_task_struct(tsk);
> +                       mmput(mm);
> +                       continue;
> +               }
> +               put_task_struct(tsk);
> +               mm->uprobes_vaddr = (unsigned long) vaddr;
> +               list_add(&mm->uprobes_list, &try_list);
> +       } 

This still falls flat on its face when there's multiple maps of the same
text in one mm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

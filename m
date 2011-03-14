Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 38F678D003E
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 11:39:01 -0400 (EDT)
Subject: Re: [PATCH v2 2.6.38-rc8-tip 3/20]  3: uprobes: Breakground page
 replacement.
From: Steven Rostedt <rostedt@goodmis.org>
In-Reply-To: <20110314133433.27435.49566.sendpatchset@localhost6.localdomain6>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
	 <20110314133433.27435.49566.sendpatchset@localhost6.localdomain6>
Content-Type: text/plain; charset="ISO-8859-15"
Date: Mon, 14 Mar 2011 11:38:57 -0400
Message-ID: <1300117137.9910.110.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Mon, 2011-03-14 at 19:04 +0530, Srikar Dronamraju wrote:
> +/*
> + * Called with tsk->mm->mmap_sem held (either for read or write and
> + * with a reference to tsk->mm.
> + */
> +static int write_opcode(struct task_struct *tsk, struct uprobe * uprobe,
> +                       unsigned long vaddr, uprobe_opcode_t opcode)
> +{
> +       struct page *old_page, *new_page;
> +       void *vaddr_old, *vaddr_new;
> +       struct vm_area_struct *vma;
> +       spinlock_t *ptl;
> +       pte_t *orig_pte;
> +       unsigned long addr;
> +       int ret = -EINVAL;
> +
> +       /* Read the page with vaddr into memory */
> +       ret = get_user_pages(tsk, tsk->mm, vaddr, 1, 1, 1, &old_page, &vma);
> +       if (ret <= 0)
> +               return -EINVAL;
> +       ret = -EINVAL;
> +
> +       /*
> +        * check if the page we are interested is read-only mapped
> +        * Since we are interested in text pages, Our pages of interest
> +        * should be mapped read-only.
> +        */
> +       if ((vma->vm_flags & (VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)) ==
> +                                               (VM_READ|VM_EXEC))
> +               goto put_out;
> + 

I'm confused by the above comment and code. You state we are only
interested text pages mapped read-only, but then if the page is mapped
read/exec we exit out? It is fine if it is anything but READ/EXEC.

I'm also curious to why we can't modify text code that is also mapped as
read/write.

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

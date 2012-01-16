Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id C83BF6B004F
	for <linux-mm@kvack.org>; Mon, 16 Jan 2012 03:35:18 -0500 (EST)
Date: Mon, 16 Jan 2012 09:34:42 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH v9 3.2 0/9] Uprobes patchset with perf probe support
Message-ID: <20120116083442.GA23622@elte.hu>
References: <20120110114821.17610.9188.sendpatchset@srdronam.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120110114821.17610.9188.sendpatchset@srdronam.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Rothwell <sfr@canb.auug.org.au>


* Srikar Dronamraju <srikar@linux.vnet.ibm.com> wrote:

> This patchset implements Uprobes which enables you to 
> dynamically probe any routine in a user space application and 
> collect information non-disruptively.

Did all review feedback get addressed in your latest tree?

If yes then it would be nice to hear the opinion of Andrew about 
this bit:

>  mm/mmap.c                               |   33 +-

The relevant portion of the patch is:

> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -30,6 +30,7 @@
>  #include <linux/perf_event.h>
>  #include <linux/audit.h>
>  #include <linux/khugepaged.h>
> +#include <linux/uprobes.h>
>  
>  #include <asm/uaccess.h>
>  #include <asm/cacheflush.h>
> @@ -616,6 +617,13 @@ again:			remove_next = 1 + (end > next->vm_end);
>  	if (mapping)
>  		mutex_unlock(&mapping->i_mmap_mutex);
>  
> +	if (root) {
> +		mmap_uprobe(vma);
> +
> +		if (adjust_next)
> +			mmap_uprobe(next);
> +	}
> +
>  	if (remove_next) {
>  		if (file) {
>  			fput(file);
> @@ -637,6 +645,8 @@ again:			remove_next = 1 + (end > next->vm_end);
>  			goto again;
>  		}
>  	}
> +	if (insert && file)
> +		mmap_uprobe(insert);
>  
>  	validate_mm(mm);
>  
> @@ -1329,6 +1339,11 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
>  			mm->locked_vm += (len >> PAGE_SHIFT);
>  	} else if ((flags & MAP_POPULATE) && !(flags & MAP_NONBLOCK))
>  		make_pages_present(addr, addr + len);
> +
> +	if (file && mmap_uprobe(vma))
> +		/* matching probes but cannot insert */
> +		goto unmap_and_free_vma;
> +
>  	return addr;
>  
>  unmap_and_free_vma:
> @@ -2305,6 +2320,10 @@ int insert_vm_struct(struct mm_struct * mm, struct vm_area_struct * vma)
>  	if ((vma->vm_flags & VM_ACCOUNT) &&
>  	     security_vm_enough_memory_mm(mm, vma_pages(vma)))
>  		return -ENOMEM;
> +
> +	if (vma->vm_file && mmap_uprobe(vma))
> +		return -EINVAL;
> +
>  	vma_link(mm, vma, prev, rb_link, rb_parent);
>  	return 0;
>  }
> @@ -2356,6 +2375,10 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
>  			new_vma->vm_pgoff = pgoff;
>  			if (new_vma->vm_file) {
>  				get_file(new_vma->vm_file);
> +
> +				if (mmap_uprobe(new_vma))
> +					goto out_free_mempol;
> +
>  				if (vma->vm_flags & VM_EXECUTABLE)
>  					added_exe_file_vma(mm);
>  			}

it's named mmap_uprobe(), which makes it rather single-purpose. 
The uprobes code wants to track vma life-time so that it can 
manage uprobes breakpoints installed here, correct?

We already have some other vma tracking goodies in perf itself 
(see perf_event_mmap() et al) - would it make sense to merge the 
two vma instrumentation facilities and not burden mm/ with two 
separate sets of callbacks?

If all such issues are resolved then i guess we could queue up 
uprobes in -tip, conditional on it remaining sufficiently 
regression-, problem- and NAK-free.

Also, it would be nice to hear Arnaldo's opinion about the 
tools/perf/ bits.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

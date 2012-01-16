Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id AF5FA6B004F
	for <linux-mm@kvack.org>; Mon, 16 Jan 2012 06:28:04 -0500 (EST)
Date: Mon, 16 Jan 2012 11:28:02 +0000
From: Jamie Lokier <jamie@shareable.org>
Subject: Re: [PATCH] Mark thread stack correctly in proc/<pid>/maps
Message-ID: <20120116112802.GB7180@jl-vm1.vm.bytemark.co.uk>
References: <1326544511-6547-1-git-send-email-siddhesh.poyarekar@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1326544511-6547-1-git-send-email-siddhesh.poyarekar@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Siddhesh Poyarekar <siddhesh.poyarekar@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-man@vger.kernel.org

Siddhesh Poyarekar wrote:
> Memory mmaped by glibc for a thread stack currently shows up as a simple
> anonymous map, which makes it difficult to differentiate between memory
> usage of the thread on stack and other dynamic allocation. Since glibc
> already uses MAP_STACK to request this mapping, the attached patch
> uses this flag to add additional VM_STACK_FLAGS to the resulting vma
> so that the mapping is treated as a stack and not any regular
> anonymous mapping. Also, one may use vm_flags to decide if a vma is a
> stack.

I think this is fine.

> There is an additional complication with posix threads where the stack
> guard for a thread stack may be larger than a page, unlike the case
> for process stack where the stack guard is a page long. glibc
> implements these guards by calling mprotect on the beginning page(s)
> to remove all permissions. I have used this to remove vmas that have
> the thread stack guard, from the /proc/maps output.

> -	/* We don't show the stack guard page in /proc/maps */
> +	/* We don't show the stack guard pages in /proc/maps */
> +	if (thread_stack_guard(vma))
> +		return;
> +
>  	start = vma->vm_start;
>  	if (stack_guard_page_start(vma, start))
>  		start += PAGE_SIZE;

Hmm, I see why you did this.  The current code already hides one guard
page, which is already dubious for programs that do things like read
/proc/pid/maps to decide if MAP_FIXED would be not clobber an existing
mapping.  At least those programs _could_ know about the stack guard
page address

I wonder if it's a potential security hole: You've just allowed
programs to use two MAP_GROWSUP/DOWN|PROT_NONE to hide vmas from the
user.  Sure, the memory isn't accessible, but it can still store data
and be ephemerally made visible using mprotect() then hidden again.

I would prefer a label like "[stack guard]" or just "[guard]",
both for the thread stacks and the process stack.

With a label like "[guard]" it needn't be limited to stacks; heap
guard pages used by some programs would also be labelled.

> +static inline int vma_is_stack(struct vm_area_struct *vma)
> +{
> +	return vma && (vma->vm_flags & (VM_GROWSUP | VM_GROWSDOWN));
> +}
> +
> +/*
> + * POSIX thread stack guards may be more than a page long and access to it
> + * should return an error (possibly a SIGSEGV). The glibc implementation does
> + * an mprotect(..., ..., PROT_NONE), so our guard vma has no permissions.
> + */
> +static inline int thread_stack_guard(struct vm_area_struct *vma)

Is there a reason the names aren't consistent - i.e. not vma_is_stack_guard()?

> +{
> +	return vma_is_stack(vma) &&
> +		((vma->vm_flags & (VM_READ | VM_WRITE | VM_EXEC | VM_MAYSHARE)) == 0) &&
> +		vma_is_stack((vma->vm_flags & VM_GROWSDOWN)?vma->vm_next:vma->vm_prev);
> +}
> +

That doesn't check if ->vm_next/prev is adjacent in address space.

You can't assume the program is using Glibc, or that MAP_STACK
mappings are all from Glibc, or that they are in the pattern you expect.

How about simply calling it vma_is_guard(), return 1 if it's PROT_NONE
without checking vma_is_stack() or ->vm_next/prev, and annotate the
maps output like this:

   is_stack              => "[stack]"
   is_guard & is_stack   => "[stack guard]"
   is_guard & !is_stack  => "[guard]"

What do you think?

-- Jamie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B1FC98D003B
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 19:50:46 -0400 (EDT)
Date: Mon, 11 Apr 2011 16:50:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Check we have the right vma in __access_remote_vm()
Message-Id: <20110411165035.5a303647.akpm@linux-foundation.org>
In-Reply-To: <10e5cbf67c850b6ae511979bdbad1761236ad9b0.1302247435.git.michael@ellerman.id.au>
References: <10e5cbf67c850b6ae511979bdbad1761236ad9b0.1302247435.git.michael@ellerman.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <michael@ellerman.id.au>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, walken@google.com, aarcange@redhat.com, riel@redhat.com, linuxppc-dev@ozlabs.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Fri,  8 Apr 2011 17:24:01 +1000 (EST)
Michael Ellerman <michael@ellerman.id.au> wrote:

> In __access_remote_vm() we need to check that we have found the right
> vma, not the following vma, before we try to access it. Otherwise we
> might call the vma's access routine with an address which does not
> fall inside the vma.
> 

hm, mysteries.  Does this patch fix any known problem in any known
kernel, or was the problem discovered by inspection, or what?

> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 9da8cab..ce999ca 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3678,7 +3678,7 @@ static int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
>  			 */
>  #ifdef CONFIG_HAVE_IOREMAP_PROT
>  			vma = find_vma(mm, addr);
> -			if (!vma)
> +			if (!vma || vma->vm_start > addr)
>  				break;
>  			if (vma->vm_ops && vma->vm_ops->access)
>  				ret = vma->vm_ops->access(vma, addr, buf,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

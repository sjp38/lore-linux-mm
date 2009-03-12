Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 206376B005C
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 07:38:33 -0400 (EDT)
Received: by fxm26 with SMTP id 26so363730fxm.38
        for <linux-mm@kvack.org>; Thu, 12 Mar 2009 04:38:31 -0700 (PDT)
Date: Thu, 12 Mar 2009 14:45:33 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] acquire mmap semaphore in pagemap_read.
Message-ID: <20090312114533.GA2407@x200.localdomain>
References: <20090312113308.6fe18a93@skybase>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090312113308.6fe18a93@skybase>
Sender: owner-linux-mm@kvack.org
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 12, 2009 at 11:33:08AM +0100, Martin Schwidefsky wrote:
> --- linux-2.6/fs/proc/task_mmu.c
> +++ linux-2.6-patched/fs/proc/task_mmu.c
> @@ -716,7 +716,9 @@ static ssize_t pagemap_read(struct file 
>  	 * user buffer is tracked in "pm", and the walk
>  	 * will stop when we hit the end of the buffer.
>  	 */
> +	down_read(&mm->mmap_sem);
>  	ret = walk_page_range(start_vaddr, end_vaddr, &pagemap_walk);
> +	up_read(&mm->mmap_sem);

This will introduce "put_user under mmap_sem" which is deadlockable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

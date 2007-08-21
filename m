Date: Tue, 21 Aug 2007 16:26:20 -0500
From: Matt Mackall <mpm@selenic.com>
Subject: Re: [RFC][PATCH 4/9] pagemap: remove open-coded sizeof(unsigned long)
Message-ID: <20070821212620.GJ30556@waste.org>
References: <20070821204248.0F506A29@kernel> <20070821204251.67EF9E06@kernel>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070821204251.67EF9E06@kernel>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 21, 2007 at 01:42:51PM -0700, Dave Hansen wrote:
> 
> I think the code gets easier to read when we give symbolic names
> to some of the operations we're performing.  I was sure we needed
> this when I saw the header being built like this:
> 
> 	...
> 	buf[2] = sizeof(unsigned long)
> 	buf[3] = sizeof(unsigned long)
> 
> I really couldn't remember what either field did ;(
> 
> Signed-off-by: Dave Hansen <haveblue@us.ibm.com>

Comment still rendered obsolete by previous patch. Otherwise:

Acked-by: Matt Mackall <mpm@selenic.com>

> ---
> 
>  lxc-dave/fs/proc/task_mmu.c |   12 +++++++-----
>  1 file changed, 7 insertions(+), 5 deletions(-)
> 
> diff -puN fs/proc/task_mmu.c~pagemap-use-ENTRY_SIZE fs/proc/task_mmu.c
> --- lxc/fs/proc/task_mmu.c~pagemap-use-ENTRY_SIZE	2007-08-21 13:30:51.000000000 -0700
> +++ lxc-dave/fs/proc/task_mmu.c	2007-08-21 13:30:51.000000000 -0700
> @@ -508,14 +508,16 @@ struct pagemapread {
>  	unsigned long __user *out;
>  };
>  
> +#define PM_ENTRY_BYTES sizeof(unsigned long)
> +
>  static int add_to_pagemap(unsigned long addr, unsigned long pfn,
>  			  struct pagemapread *pm)
>  {
>  	__put_user(pfn, pm->out);
>  	pm->out++;
> -	pm->pos += sizeof(unsigned long);
> -	pm->count -= sizeof(unsigned long);
>  	pm->next = addr + PAGE_SIZE;
> +	pm->pos += PM_ENTRY_BYTES;
> +	pm->count -= PM_ENTRY_BYTES;
>  	return 0;
>  }
>  
> @@ -601,13 +603,13 @@ static ssize_t pagemap_read(struct file 
>  		goto out;
>  
>  	ret = -EIO;
> -	svpfn = src / sizeof(unsigned long);
> +	svpfn = src / PM_ENTRY_BYTES;
>  	addr = PAGE_SIZE * svpfn;
> -	if (svpfn * sizeof(unsigned long) != src)
> +	if (svpfn * PM_ENTRY_BYTES != src)
>  		goto out;
>  	evpfn = min((src + count) / sizeof(unsigned long) - 1,
>  		    ((~0UL) >> PAGE_SHIFT) + 1);
> -	count = (evpfn - svpfn) * sizeof(unsigned long);
> +	count = (evpfn - svpfn) * PM_ENTRY_BYTES;
>  	end = PAGE_SIZE * evpfn;
>  	//printk("src %ld svpfn %d evpfn %d count %d\n", src, svpfn, evpfn, count);
>  
> _

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

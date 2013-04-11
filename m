Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 8261D6B0006
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 03:14:27 -0400 (EDT)
Date: Thu, 11 Apr 2013 03:14:21 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1365664461-7zv87ja0-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <51662D64.3000409@hitachi.com>
References: <51662D64.3000409@hitachi.com>
Subject: Re: [RFC Patch 1/2] mm: Add a parameter to force a kernel panic when
 memory error occurs on dirty cache
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mitsuhiro Tanino <mitsuhiro.tanino.gm@hitachi.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

# You can run checkpatch.pl to find coding style violation.

On Thu, Apr 11, 2013 at 12:26:28PM +0900, Mitsuhiro Tanino wrote:
> This patch introduces a sysctl interface,
> vm.memory_failure_dirty_panic, to provide selectable actions
> when a memory error is detected on dirty page cache.

Using another value of sysctl_memory_failure_recovery looks to me
better than adding a new interface, because this interface is not
orthogonal to sysctl_memory_failure_recovery
(if sysctl_memory_failure_recovery == 0, vm.memory_failure_dirty_panic
is meaningless.)

> 
> 
> Signed-off-by: Mitsuhiro Tanino <mitsuhiro.tanino.gm@hitachi.com>
> ---
> 
> diff --git a/a/Documentation/sysctl/vm.txt b/b/Documentation/sysctl/vm.txt
> index 078701f..7dad994 100644
> --- a/a/Documentation/sysctl/vm.txt
> +++ b/b/Documentation/sysctl/vm.txt
> @@ -34,6 +34,7 @@ Currently, these files are in /proc/sys/vm:
>  - legacy_va_layout
>  - lowmem_reserve_ratio
>  - max_map_count
> +- memory_failure_dirty_panic
>  - memory_failure_early_kill
>  - memory_failure_recovery
>  - min_free_kbytes
> @@ -306,6 +307,29 @@ The default value is 65536.
>  
>  =============================================================
>  
> +memory_failure_dirty_panic:
> +
> +Control whether a system continues to operate or not when uncorrected
> +recoverable memory error (typically a 2bit error in a memory module)
> +is detected in the background by hardware and a page type is a dirty
> +page cache.
> +
> +When uncorrected recoverable memory error occurs on a dirty page
> +cache, the kernel truncates the page because a system crashes if
> +the kernel touches the corrupted page. However, this page truncation
> +causes data lost problem because the dirty page cache does not write
> +back to a disk. As a result, if the dirty cache belongs a file,
> +the file is not renewed and remains old data.
> +
> +0: Keep a system running. Note a dirty page is truncated and data
> +of dirty page is lost.
> +
> +1: Force the kernel panic.
> +
> +The default value is 0.
> +
> +=============================================================
> +
>  memory_failure_early_kill:
>  
>  Control how to kill processes when uncorrected memory error (typically
> diff --git a/a/include/linux/mm.h b/b/include/linux/mm.h
> index 66e2f7c..0025882 100644
> --- a/a/include/linux/mm.h
> +++ b/b/include/linux/mm.h
> @@ -1718,6 +1718,7 @@ enum mf_flags {
>  extern int memory_failure(unsigned long pfn, int trapno, int flags);
>  extern void memory_failure_queue(unsigned long pfn, int trapno, int flags);
>  extern int unpoison_memory(unsigned long pfn);
> +extern int sysctl_memory_failure_dirty_panic;
>  extern int sysctl_memory_failure_early_kill;
>  extern int sysctl_memory_failure_recovery;
>  extern void shake_page(struct page *p, int access);
> diff --git a/a/kernel/sysctl.c b/b/kernel/sysctl.c
> index c88878d..452dd80 100644
> --- a/a/kernel/sysctl.c
> +++ b/b/kernel/sysctl.c
> @@ -1412,6 +1412,15 @@ static struct ctl_table vm_table[] = {
>  		.extra1		= &zero,
>  		.extra2		= &one,
>  	},
> +	{
> +		.procname	= "memory_failure_dirty_panic",
> +		.data		= &sysctl_memory_failure_dirty_panic,
> +		.maxlen		= sizeof(sysctl_memory_failure_dirty_panic),
> +		.mode		= 0644,
> +		.proc_handler	= proc_dointvec_minmax,
> +		.extra1		= &zero,
> +		.extra2		= &one,
> +	},
>  #endif
>  	{ }
>  };
> diff --git a/a/mm/memory-failure.c b/b/mm/memory-failure.c
> index c6e4dd3..6d3c0ed 100644
> --- a/a/mm/memory-failure.c
> +++ b/b/mm/memory-failure.c
> @@ -57,6 +57,8 @@
>  #include <linux/kfifo.h>
>  #include "internal.h"
>  
> +int sysctl_memory_failure_dirty_panic __read_mostly = 0;
> +
>  int sysctl_memory_failure_early_kill __read_mostly = 0;
>  
>  int sysctl_memory_failure_recovery __read_mostly = 1;
> @@ -618,8 +620,16 @@ static int me_pagecache_dirty(struct page *p, unsigned long pfn)
>  	struct address_space *mapping = page_mapping(p);
>  
>  	SetPageError(p);
> -	/* TBD: print more information about the file. */
>  	if (mapping) {
> +		/* Print more information about the file. */
> +		if (mapping->host != NULL && S_ISREG(mapping->host->i_mode))
> +			pr_info("MCE %#lx: File was corrupted: Dev:%s Inode:%lu Offset:%lu\n",
> +				page_to_pfn(p), mapping->host->i_sb->s_id,
> +				mapping->host->i_ino, page_index(p));
> +		else
> +			pr_info("MCE %#lx: A dirty page cache was corrupted.\n",
> +				page_to_pfn(p));
> +
>  		/*
>  		 * IO error will be reported by write(), fsync(), etc.
>  		 * who check the mapping.
> @@ -657,6 +667,19 @@ static int me_pagecache_dirty(struct page *p, unsigned long pfn)
>  		mapping_set_error(mapping, EIO);
>  	}
>  
> +	/* Force a kernel panic instantly because a dirty page cache is
> +	   truncated and this leads data corruption problem when
> +	   application processes old data.
> +	*/
> +	if (sysctl_memory_failure_dirty_panic) {
> +		if (mapping != NULL && mapping->host != NULL)
> +			panic("MCE %#lx: Force a panic because a dirty page cache was corrupted: File type:0x%x\n",
> +				page_to_pfn(p), mapping->host->i_mode);
> +		else
> +			panic("MCE %#lx: Force a panic because a dirty page cache was corrupted.\n",
> +				page_to_pfn(p));
> +	}
> +
>  	return me_pagecache_clean(p, pfn);
>  }

I think that adding sysctl parameter and printing out file information
should be done in separate patches.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

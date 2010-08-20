Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 3F5FE6B0205
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 20:25:36 -0400 (EDT)
Date: Thu, 19 Aug 2010 17:25:02 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Export mlock information via smaps
Message-Id: <20100819172502.42a0d493.akpm@linux-foundation.org>
In-Reply-To: <201008181219.51915.knikanth@suse.de>
References: <201008171039.31070.knikanth@suse.de>
	<201008181023.41378.knikanth@suse.de>
	<20100818055253.GA28417@balbir.in.ibm.com>
	<201008181219.51915.knikanth@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nikanth Karthikesan <knikanth@suse.de>
Cc: balbir@linux.vnet.ibm.com, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 18 Aug 2010 12:19:51 +0530
Nikanth Karthikesan <knikanth@suse.de> wrote:

> Currently there is no way to find whether a process has locked its pages in
> memory or not. And which of the memory regions are locked in memory.
> 
> Add a new field "Locked" to export this information via smaps file.
> 
> Signed-off-by: Nikanth Karthikesan <knikanth@suse.de>
> 
> ---
> 
> diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
> index a6aca87..17b0ae0 100644
> --- a/Documentation/filesystems/proc.txt
> +++ b/Documentation/filesystems/proc.txt
> @@ -373,6 +373,7 @@ Referenced:          892 kB
>  Swap:                  0 kB
>  KernelPageSize:        4 kB
>  MMUPageSize:           4 kB
> +Locked:              374 kB
>  
>  The first  of these lines shows  the same information  as is displayed for the
>  mapping in /proc/PID/maps.  The remaining lines show  the size of the mapping,
> @@ -397,6 +398,8 @@ To clear the bits for the file mapped pages associated with the process
>      > echo 3 > /proc/PID/clear_refs
>  Any other value written to /proc/PID/clear_refs will have no effect.
>  
> +The "Locked" indicates whether the mapping is locked in memory or not.
> +
>  
>  1.2 Kernel data
>  ---------------
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index aea1d3f..58e586c 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -405,7 +405,8 @@ static int show_smap(struct seq_file *m, void *v)
>  		   "Referenced:     %8lu kB\n"
>  		   "Swap:           %8lu kB\n"
>  		   "KernelPageSize: %8lu kB\n"
> -		   "MMUPageSize:    %8lu kB\n",
> +		   "MMUPageSize:    %8lu kB\n"
> +		   "Locked:         %8lu kB\n",
>  		   (vma->vm_end - vma->vm_start) >> 10,
>  		   mss.resident >> 10,
>  		   (unsigned long)(mss.pss >> (10 + PSS_SHIFT)),
> @@ -416,7 +417,9 @@ static int show_smap(struct seq_file *m, void *v)
>  		   mss.referenced >> 10,
>  		   mss.swap >> 10,
>  		   vma_kernel_pagesize(vma) >> 10,
> -		   vma_mmu_pagesize(vma) >> 10);
> +		   vma_mmu_pagesize(vma) >> 10,
> +		   (vma->vm_flags & VM_LOCKED) ?
> +			(unsigned long)(mss.pss >> (10 + PSS_SHIFT)) : 0);

What was the rationale for duplicating the Pss value here, rather than
say Rss or whatever?  Really, the value is just a boolean due to kernel
internal details but we should try to put something sensible and
meaningful in there if it isn't just "1" or "0".  As it stands, people
will look at the /proc/pid/smaps output, then at proc.txt and will come
away all confused.

btw, we forgot to document Pss (of all things!) in
Documentation/filesystems/proc.txt.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

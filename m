Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D55656B01F1
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 01:53:00 -0400 (EDT)
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e33.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o7I5m9Tq017363
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 23:48:09 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o7I5qwor149290
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 23:52:58 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o7I5qwtl001623
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 23:52:58 -0600
Date: Wed, 18 Aug 2010 11:22:53 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH] Export mlock information via smaps
Message-ID: <20100818055253.GA28417@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <201008171039.31070.knikanth@suse.de>
 <1282062336.10679.226.camel@calx>
 <201008181023.41378.knikanth@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <201008181023.41378.knikanth@suse.de>
Sender: owner-linux-mm@kvack.org
To: Nikanth Karthikesan <knikanth@suse.de>
Cc: Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Nikanth Karthikesan <knikanth@suse.de> [2010-08-18 10:23:41]:

> On Tuesday 17 August 2010 21:55:36 Matt Mackall wrote:
> > On Tue, 2010-08-17 at 10:39 +0530, Nikanth Karthikesan wrote:
> > > Currently there is no way to find whether a process has locked its pages
> > > in memory or not. And which of the memory regions are locked in memory.
> > >
> > > Add a new field to perms field 'l' to export this information. The
> > > information exported via maps file is not changed.
> > 
> > I'm worried that your new 'l' flag will fatally surprise some naive
> > parser of this file.
> > 
> 
> So how to proceed? Create another "ssmaps" file or something? :) Or is the
> following patch any better? Even the "Yes"/"No" could be changed to "0 kB" or
> "x kB", if it would make it better.
> 
> Thanks
> Nikanth
> 
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
> index a6aca87..6eafd26 100644
> --- a/Documentation/filesystems/proc.txt
> +++ b/Documentation/filesystems/proc.txt
> @@ -373,6 +373,7 @@ Referenced:          892 kB
>  Swap:                  0 kB
>  KernelPageSize:        4 kB
>  MMUPageSize:           4 kB
> +Locked:         No
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
> index aea1d3f..7bafbcf 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -405,7 +405,8 @@ static int show_smap(struct seq_file *m, void *v)
>  		   "Referenced:     %8lu kB\n"
>  		   "Swap:           %8lu kB\n"
>  		   "KernelPageSize: %8lu kB\n"
> -		   "MMUPageSize:    %8lu kB\n",
> +		   "MMUPageSize:    %8lu kB\n"
> +		   "Locked:         %s\n",
>  		   (vma->vm_end - vma->vm_start) >> 10,
>  		   mss.resident >> 10,
>  		   (unsigned long)(mss.pss >> (10 + PSS_SHIFT)),
> @@ -416,7 +417,8 @@ static int show_smap(struct seq_file *m, void *v)
>  		   mss.referenced >> 10,
>  		   mss.swap >> 10,
>  		   vma_kernel_pagesize(vma) >> 10,
> -		   vma_mmu_pagesize(vma) >> 10);
> +		   vma_mmu_pagesize(vma) >> 10,
> +		   (vma->vm_flags & VM_LOCKED) ? "Yes" : "No");
>

Why not show the Locked as kB as well? I know that the entire VMA is
locked, but ideally if we can show mss.pss as locked, one can write
a simple script to accumulate locked memory for the process. NOTE:
One could choose RSS or PSS, but I'd prefer PSS (even though the
value is not stable across the system) since it is more accurate
representation of the truly locked memory. 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

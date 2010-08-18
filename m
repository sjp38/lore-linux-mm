Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 5FB856B01F1
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 11:13:15 -0400 (EDT)
Date: Wed, 18 Aug 2010 23:12:36 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] Export mlock information via smaps
Message-ID: <20100818151236.GB9431@localhost>
References: <201008171039.31070.knikanth@suse.de>
 <201008181023.41378.knikanth@suse.de>
 <20100818055253.GA28417@balbir.in.ibm.com>
 <201008181219.51915.knikanth@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201008181219.51915.knikanth@suse.de>
Sender: owner-linux-mm@kvack.org
To: Nikanth Karthikesan <knikanth@suse.de>
Cc: balbir@linux.vnet.ibm.com, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 18, 2010 at 12:19:51PM +0530, Nikanth Karthikesan wrote:
> On Wednesday 18 August 2010 11:22:53 Balbir Singh wrote:
> > * Nikanth Karthikesan <knikanth@suse.de> [2010-08-18 10:23:41]:
> > > On Tuesday 17 August 2010 21:55:36 Matt Mackall wrote:
> > > > On Tue, 2010-08-17 at 10:39 +0530, Nikanth Karthikesan wrote:
> > > > > Currently there is no way to find whether a process has locked its
> > > > > pages in memory or not. And which of the memory regions are locked in
> > > > > memory.
> > > > >
> > > > > Add a new field to perms field 'l' to export this information. The
> > > > > information exported via maps file is not changed.
> > > >
> > > > I'm worried that your new 'l' flag will fatally surprise some naive
> > > > parser of this file.
> > >
> > > So how to proceed? Create another "ssmaps" file or something? :) Or is
> > > the following patch any better? Even the "Yes"/"No" could be changed to
> > > "0 kB" or "x kB", if it would make it better.
> > >
> > > Thanks
> > > Nikanth
> > >
> > > Currently there is no way to find whether a process has locked its pages
> > > in memory or not. And which of the memory regions are locked in memory.
> > >
> > > Add a new field "Locked" to export this information via smaps file.
> > >
> > > Signed-off-by: Nikanth Karthikesan <knikanth@suse.de>
> > >
> > > ---
> > >
> > > diff --git a/Documentation/filesystems/proc.txt
> > > b/Documentation/filesystems/proc.txt index a6aca87..6eafd26 100644
> > > --- a/Documentation/filesystems/proc.txt
> > > +++ b/Documentation/filesystems/proc.txt
> > > @@ -373,6 +373,7 @@ Referenced:          892 kB
> > >  Swap:                  0 kB
> > >  KernelPageSize:        4 kB
> > >  MMUPageSize:           4 kB
> > > +Locked:         No
> > >
> > >  The first  of these lines shows  the same information  as is displayed
> > > for the mapping in /proc/PID/maps.  The remaining lines show  the size of
> > > the mapping, @@ -397,6 +398,8 @@ To clear the bits for the file mapped
> > > pages associated with the process
> > >
> > >      > echo 3 > /proc/PID/clear_refs
> > >
> > >  Any other value written to /proc/PID/clear_refs will have no effect.
> > >
> > > +The "Locked" indicates whether the mapping is locked in memory or not.
> > > +
> > >
> > >  1.2 Kernel data
> > >  ---------------
> > > diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> > > index aea1d3f..7bafbcf 100644
> > > --- a/fs/proc/task_mmu.c
> > > +++ b/fs/proc/task_mmu.c
> > > @@ -405,7 +405,8 @@ static int show_smap(struct seq_file *m, void *v)
> > >  		   "Referenced:     %8lu kB\n"
> > >  		   "Swap:           %8lu kB\n"
> > >  		   "KernelPageSize: %8lu kB\n"
> > > -		   "MMUPageSize:    %8lu kB\n",
> > > +		   "MMUPageSize:    %8lu kB\n"
> > > +		   "Locked:         %s\n",
> > >  		   (vma->vm_end - vma->vm_start) >> 10,
> > >  		   mss.resident >> 10,
> > >  		   (unsigned long)(mss.pss >> (10 + PSS_SHIFT)),
> > > @@ -416,7 +417,8 @@ static int show_smap(struct seq_file *m, void *v)
> > >  		   mss.referenced >> 10,
> > >  		   mss.swap >> 10,
> > >  		   vma_kernel_pagesize(vma) >> 10,
> > > -		   vma_mmu_pagesize(vma) >> 10);
> > > +		   vma_mmu_pagesize(vma) >> 10,
> > > +		   (vma->vm_flags & VM_LOCKED) ? "Yes" : "No");
> > 
> > Why not show the Locked as kB as well? I know that the entire VMA is
> > locked, but ideally if we can show mss.pss as locked, one can write
> > a simple script to accumulate locked memory for the process. NOTE:
> > One could choose RSS or PSS, but I'd prefer PSS (even though the
> > value is not stable across the system) since it is more accurate
> > representation of the truly locked memory.
> > 
> 
> Agreed. Attached patch does this, i.e, uses PSS as amount of locked memory.

Maybe it's only me, but I as an end user instinctively take "Locked"
as the plain number of locked pages. How about renaming to "PSSLocked"
to avoid such misconceptions?

Otherwise

Acked-by: Wu Fengguang <fengguang.wu@intel.com>

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

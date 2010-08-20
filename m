Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id DC90E6B02EB
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 17:57:11 -0400 (EDT)
Subject: Re: [PATCH] Export mlock information via smaps
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20100819172502.42a0d493.akpm@linux-foundation.org>
References: <201008171039.31070.knikanth@suse.de>
	 <201008181023.41378.knikanth@suse.de>
	 <20100818055253.GA28417@balbir.in.ibm.com>
	 <201008181219.51915.knikanth@suse.de>
	 <20100819172502.42a0d493.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 20 Aug 2010 16:57:06 -0500
Message-ID: <1282341426.10679.715.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nikanth Karthikesan <knikanth@suse.de>, balbir@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2010-08-19 at 17:25 -0700, Andrew Morton wrote:
> On Wed, 18 Aug 2010 12:19:51 +0530
> Nikanth Karthikesan <knikanth@suse.de> wrote:
> 
> > Currently there is no way to find whether a process has locked its pages in
> > memory or not. And which of the memory regions are locked in memory.
> > 
> > Add a new field "Locked" to export this information via smaps file.
> > 
> > Signed-off-by: Nikanth Karthikesan <knikanth@suse.de>
> > 
> > ---
> > 
> > diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
> > index a6aca87..17b0ae0 100644
> > --- a/Documentation/filesystems/proc.txt
> > +++ b/Documentation/filesystems/proc.txt
> > @@ -373,6 +373,7 @@ Referenced:          892 kB
> >  Swap:                  0 kB
> >  KernelPageSize:        4 kB
> >  MMUPageSize:           4 kB
> > +Locked:              374 kB
> >  
> >  The first  of these lines shows  the same information  as is displayed for the
> >  mapping in /proc/PID/maps.  The remaining lines show  the size of the mapping,
> > @@ -397,6 +398,8 @@ To clear the bits for the file mapped pages associated with the process
> >      > echo 3 > /proc/PID/clear_refs
> >  Any other value written to /proc/PID/clear_refs will have no effect.
> >  
> > +The "Locked" indicates whether the mapping is locked in memory or not.
> > +
> >  
> >  1.2 Kernel data
> >  ---------------
> > diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> > index aea1d3f..58e586c 100644
> > --- a/fs/proc/task_mmu.c
> > +++ b/fs/proc/task_mmu.c
> > @@ -405,7 +405,8 @@ static int show_smap(struct seq_file *m, void *v)
> >  		   "Referenced:     %8lu kB\n"
> >  		   "Swap:           %8lu kB\n"
> >  		   "KernelPageSize: %8lu kB\n"
> > -		   "MMUPageSize:    %8lu kB\n",
> > +		   "MMUPageSize:    %8lu kB\n"
> > +		   "Locked:         %8lu kB\n",
> >  		   (vma->vm_end - vma->vm_start) >> 10,
> >  		   mss.resident >> 10,
> >  		   (unsigned long)(mss.pss >> (10 + PSS_SHIFT)),
> > @@ -416,7 +417,9 @@ static int show_smap(struct seq_file *m, void *v)
> >  		   mss.referenced >> 10,
> >  		   mss.swap >> 10,
> >  		   vma_kernel_pagesize(vma) >> 10,
> > -		   vma_mmu_pagesize(vma) >> 10);
> > +		   vma_mmu_pagesize(vma) >> 10,
> > +		   (vma->vm_flags & VM_LOCKED) ?
> > +			(unsigned long)(mss.pss >> (10 + PSS_SHIFT)) : 0);
> 
> What was the rationale for duplicating the Pss value here, rather than
> say Rss or whatever?  Really, the value is just a boolean due to kernel
> internal details but we should try to put something sensible and
> meaningful in there if it isn't just "1" or "0".  As it stands, people
> will look at the /proc/pid/smaps output, then at proc.txt and will come
> away all confused.

I think RSS is perhaps a better answer here.

> btw, we forgot to document Pss (of all things!) in
> Documentation/filesystems/proc.txt.

There is something there, but it's nearly useless. How about something
like this:

Improve smaps field documentation

Signed-off-by: Matt Mackall <mpm@selenic.com>

diff -r ef46bace13e0 Documentation/filesystems/proc.txt
--- a/Documentation/filesystems/proc.txt	Wed Aug 18 15:45:23 2010 -0700
+++ b/Documentation/filesystems/proc.txt	Fri Aug 20 16:55:09 2010 -0500
@@ -374,13 +374,14 @@
 KernelPageSize:        4 kB
 MMUPageSize:           4 kB
 
-The first  of these lines shows  the same information  as is displayed for the
-mapping in /proc/PID/maps.  The remaining lines show  the size of the mapping,
-the amount of the mapping that is currently resident in RAM, the "proportional
-set sizea?? (divide each shared page by the number of processes sharing it), the
-number of clean and dirty shared pages in the mapping, and the number of clean
-and dirty private pages in the mapping.  The "Referenced" indicates the amount
-of memory currently marked as referenced or accessed.
+The first of these lines shows the same information as is displayed
+for the mapping in /proc/PID/maps. The remaining lines show the size
+of the mapping (size), the amount of the mapping that is currently
+resident in RAM (RSS), the process' proportional share of this mapping
+(PSS), the number of clean and dirty shared pages in the mapping, and
+the number of clean and dirty private pages in the mapping. The
+"Referenced" indicates the amount of memory currently marked as
+referenced or accessed.
 
 This file is only present if the CONFIG_MMU kernel configuration option is
 enabled.


-- 
Mathematics is the supreme nostalgia of our time.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

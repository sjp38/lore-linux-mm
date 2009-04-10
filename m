Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6A7705F0001
	for <linux-mm@kvack.org>; Thu,  9 Apr 2009 23:32:34 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n3A3VaFB019751
	for <linux-mm@kvack.org>; Thu, 9 Apr 2009 21:31:36 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3A3X31M184706
	for <linux-mm@kvack.org>; Thu, 9 Apr 2009 21:33:03 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3A3X2tk031824
	for <linux-mm@kvack.org>; Thu, 9 Apr 2009 21:33:02 -0600
Date: Thu, 9 Apr 2009 20:33:01 -0700
From: Matt Helsley <matthltc@us.ibm.com>
Subject: Re: [PATCH 02/30] Remove struct mm_struct::exe_file et al
Message-ID: <20090410033301.GA29496@us.ibm.com>
References: <20090410023312.GC27788@x200.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090410023312.GC27788@x200.localdomain>
Sender: owner-linux-mm@kvack.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: akpm@linux-foundation.org, containers@lists.linux-foundation.org, xemul@parallels.com, linux-kernel@vger.kernel.org, dave@linux.vnet.ibm.com, hch@infradead.org, mingo@elte.hu, torvalds@linux-foundation.org, David Howells <dhowells@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 10, 2009 at 06:33:12AM +0400, Alexey Dobriyan wrote:
> Commit 925d1c401fa6cfd0df5d2e37da8981494ccdec07 aka "procfs task exe symlink".
> introduced struct mm_struct::exe_file and struct
> mm_struct::num_exe_file_vmas.
> 
> The rationale is weak: unifying MMU and no-MMU version of /proc/*/exe code.
> For this a) struct mm_struct becomes bigger, b) mmap/munmap/exit become slower,

Again -- no numbers to tell us how significant the performance savings are.
Until I see numbers it seems to me you're making a mountain of a molehill here
so I guess I can do the same.

With this patch any task can briefly hold any mmap semaphore it wants by doing
readlink on /proc/*/exe. In contrast, exe_file avoids the need to hold mmap_sem 
when doing a readlink on /proc/*/exe. As far as I am aware mmap_sem is
a notoriously bad semaphore to hold for any duration and hence anything that
avoids using it would be helpful.

> c) patch adds more code than removes in fact.
> 
> After commit 8feae13110d60cc6287afabc2887366b0eb226c2 aka
> "NOMMU: Make VMAs per MM as for MMU-mode linux" no-MMU kernels also
> maintain list of VMAs in ->mmap, so we can switch back for MMU version
> of /proc/*/exe.
> 
> This also helps C/R, no need to save and restore ->exe_file and to count
> additional references.

Checkpointing exe_file is easy -- it can be done just like any other file
reference the task holds. No extra reference counting code is necessary.
num_exe_file_vmas need not be saved so long as exe_file is set prior to creating
the VMAs.

It looks to me like you've fixed the bugs from the previous version that David
Howells nacked. He is missing from the Cc list so I've added him.

> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> ---
> 
>  fs/exec.c                |    2 
>  fs/proc/base.c           |  105 +++++++++++++----------------------------------
>  include/linux/mm.h       |   12 -----
>  include/linux/mm_types.h |    6 --
>  include/linux/proc_fs.h  |   20 --------
>  kernel/fork.c            |    3 -
>  mm/mmap.c                |   22 +--------
>  mm/nommu.c               |   16 -------
>  8 files changed, 36 insertions(+), 150 deletions(-)

Granted, the reduction in code certainly looks nice. IMHO this is your
only strong argument for the patch.

Cheers,
	-Matt Helsley

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

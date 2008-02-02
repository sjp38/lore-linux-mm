Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m12LIL8W003831
	for <linux-mm@kvack.org>; Sat, 2 Feb 2008 16:18:21 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m12LHxZD216510
	for <linux-mm@kvack.org>; Sat, 2 Feb 2008 16:18:21 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m12LHwfo027922
	for <linux-mm@kvack.org>; Sat, 2 Feb 2008 16:17:59 -0500
Subject: Re: [PATCH] sys_remap_file_pages: fix ->vm_file accounting
From: Matt Helsley <matthltc@us.ibm.com>
In-Reply-To: <20080130172646.GA2355@tv-sign.ru>
References: <20080130142014.GA2164@tv-sign.ru>
	 <1201712101.31222.22.camel@tucsk.pomaz.szeredi.hu>
	 <20080130172646.GA2355@tv-sign.ru>
Content-Type: text/plain
Date: Sat, 02 Feb 2008 13:17:45 -0800
Message-Id: <1201987065.9062.6.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Oleg Nesterov <oleg@tv-sign.ru>
Cc: Miklos Szeredi <mszeredi@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, William Lee Irwin III <wli@holomorphy.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, stable@kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-01-30 at 20:26 +0300, Oleg Nesterov wrote:
> On 01/30, Miklos Szeredi wrote:
> > 
> > On Wed, 2008-01-30 at 17:20 +0300, Oleg Nesterov wrote:
> > > Fix ->vm_file accounting, mmap_region() may do do_munmap().
> > 
> > There's a small problem with the patch: the vma itself is freed at
> > unmap, so the fput(vma->vm_file) may crash.  Here's an updated patch.
> 
> Ah, indeed, thanks!
> 
> 
> Offtopic. I noticed this problem while looking at this patch:
> 
> 	http://marc.info/?l=linux-mm-commits&m=120141116911711
> 
> So this (the old vma could be removed before we create the new mapping)
> means that the patch above has another problem: if we are remapping the
> whole VM_EXECUTABLE vma, removed_exe_file_vma() can clear ->exe_file
> while it shouldn't (Matt Helsley cc'ed).
> 
> Oleg.

	Looking at sys_remap_file_pages() it appears that the shared flag must
be set in order to remap. Executable mappings are always MAP_PRIVATE and
hence lack the shared flag so that any modifications to those areas
don't get written back to the executable. I don't think userspace can
change this flag -- even using plain mremap. So, unless there's a way to
change that flag, I don't think there's anything related to
VM_EXECUTABLE vmas that needs to be done here.

Cc'ing linux-mm.

Cheers,
	-Matt Helsley

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

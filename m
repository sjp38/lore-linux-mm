Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B51056B003D
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 12:22:43 -0400 (EDT)
Subject: Re: [PATCH] acquire mmap semaphore in pagemap_read.
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20090317130410.7dd8daa5@skybase>
References: <20090312113308.6fe18a93@skybase>
	 <20090312114533.GA2407@x200.localdomain> <20090312125410.25400d18@skybase>
	 <1236871414.3213.50.camel@calx> <20090312165451.1a7ef22f@skybase>
	 <20090317130410.7dd8daa5@skybase>
Content-Type: text/plain
Date: Tue, 17 Mar 2009 11:21:41 -0500
Message-Id: <1237306901.3213.251.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Alexey Dobriyan <adobriyan@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Gerald Schaefer <gerald.schaefer@de.ibm.com>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, 2009-03-17 at 13:04 +0100, Martin Schwidefsky wrote:
> On Thu, 12 Mar 2009 16:54:51 +0100
> Martin Schwidefsky <schwidefsky@de.ibm.com> wrote:
> 
> > On Thu, 12 Mar 2009 10:23:34 -0500
> > Matt Mackall <mpm@selenic.com> wrote:
> > 
> > > Well it means we may have to reintroduce the very annoying double
> > > buffering from various earlier implementations. But let's leave this
> > > discussion until after we've figured out what to do about the walker
> > > code.
> > 
> > About the walker code. I've realized that there is another way to fix
> > this. The TASK_SIZE definition is currently used for two things: 1) as
> > a maximum mappable address, 2) the size of the address space for a
> > process. And there lies a problem: while a process is using a reduced
> > page table 1) and 2) differ. If I make TASK_SIZE give you the current
> > size of the address space then it is not possible to mmap an object
> > beyond 4TB and the page table upgrade never happens. If I make
> > TASK_SIZE return the maximum mappable address the page table walker
> > breaks. The solution could be to introduce MAX_TASK_SIZE and use that
> > in the mmap code to find out what can be mapped.
>  
> I got around the TASK_SIZE checks with arch code only. In total I'll
> need two fixes, one that makes TASK_SIZE to reflect the size of the
> current address space and another one to get the page table upgrades
> working again. I'll push these patches via git390 as no common code
> changes are required.

Thanks, Martin.

> Which leaves the mmap_sem issue as the only problem left.

Yeah, this one needs more thought. I'd really rather not go back to
double-buffering here as it was much more complicated, not to mention
slow.

-- 
http://selenic.com : development and support for Mercurial and Linux


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

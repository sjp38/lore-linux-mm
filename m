Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 8130C6B004F
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 11:24:58 -0400 (EDT)
Subject: Re: [PATCH] acquire mmap semaphore in pagemap_read.
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20090312125410.25400d18@skybase>
References: <20090312113308.6fe18a93@skybase>
	 <20090312114533.GA2407@x200.localdomain>  <20090312125410.25400d18@skybase>
Content-Type: text/plain
Date: Thu, 12 Mar 2009 10:23:34 -0500
Message-Id: <1236871414.3213.50.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Alexey Dobriyan <adobriyan@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Gerald Schaefer <gerald.schaefer@de.ibm.com>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, 2009-03-12 at 12:54 +0100, Martin Schwidefsky wrote:
> On Thu, 12 Mar 2009 14:45:33 +0300
> Alexey Dobriyan <adobriyan@gmail.com> wrote:
> 
> > On Thu, Mar 12, 2009 at 11:33:08AM +0100, Martin Schwidefsky wrote:
> > > --- linux-2.6/fs/proc/task_mmu.c
> > > +++ linux-2.6-patched/fs/proc/task_mmu.c
> > > @@ -716,7 +716,9 @@ static ssize_t pagemap_read(struct file 
> > >  	 * user buffer is tracked in "pm", and the walk
> > >  	 * will stop when we hit the end of the buffer.
> > >  	 */
> > > +	down_read(&mm->mmap_sem);
> > >  	ret = walk_page_range(start_vaddr, end_vaddr, &pagemap_walk);
> > > +	up_read(&mm->mmap_sem);
> > 
> > This will introduce "put_user under mmap_sem" which is deadlockable.
> 
> Hmm, interesting. In this case the pagemap interface is fundamentally broken.

Well it means we may have to reintroduce the very annoying double
buffering from various earlier implementations. But let's leave this
discussion until after we've figured out what to do about the walker
code.

-- 
http://selenic.com : development and support for Mercurial and Linux


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

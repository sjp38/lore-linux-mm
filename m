Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0F5706B004F
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 07:57:33 -0400 (EDT)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.14.3/8.13.8) with ESMTP id n2CBvUs4089964
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 11:57:31 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2CBvUeL4321434
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 12:57:30 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2CBvThI003724
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 12:57:30 +0100
Date: Thu, 12 Mar 2009 12:54:10 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH] acquire mmap semaphore in pagemap_read.
Message-ID: <20090312125410.25400d18@skybase>
In-Reply-To: <20090312114533.GA2407@x200.localdomain>
References: <20090312113308.6fe18a93@skybase>
	<20090312114533.GA2407@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, 12 Mar 2009 14:45:33 +0300
Alexey Dobriyan <adobriyan@gmail.com> wrote:

> On Thu, Mar 12, 2009 at 11:33:08AM +0100, Martin Schwidefsky wrote:
> > --- linux-2.6/fs/proc/task_mmu.c
> > +++ linux-2.6-patched/fs/proc/task_mmu.c
> > @@ -716,7 +716,9 @@ static ssize_t pagemap_read(struct file 
> >  	 * user buffer is tracked in "pm", and the walk
> >  	 * will stop when we hit the end of the buffer.
> >  	 */
> > +	down_read(&mm->mmap_sem);
> >  	ret = walk_page_range(start_vaddr, end_vaddr, &pagemap_walk);
> > +	up_read(&mm->mmap_sem);
> 
> This will introduce "put_user under mmap_sem" which is deadlockable.

Hmm, interesting. In this case the pagemap interface is fundamentally broken.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

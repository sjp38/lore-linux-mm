Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 161FE5F0001
	for <linux-mm@kvack.org>; Fri, 10 Apr 2009 03:30:54 -0400 (EDT)
Date: Fri, 10 Apr 2009 15:30:42 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH][1/2]page_fault retry with NOPAGE_RETRY
Message-ID: <20090410073042.GB21149@localhost>
References: <604427e00904081302m7b29c538u7781cd8f4dd576f2@mail.gmail.com> <20090409230205.310c68a7.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090409230205.310c68a7.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ying Han <yinghan@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Mike Waychison <mikew@google.com>, Rohit Seth <rohitseth@google.com>, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "H. Peter Anvin" <hpa@zytor.com>, =?utf-8?B?VMO2csO2aw==?= Edwin <edwintorok@gmail.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Fri, Apr 10, 2009 at 02:02:05PM +0800, Andrew Morton wrote:
[snip]
> >  	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))
> >  		return ret;
> > 
> > @@ -2611,8 +2618,10 @@ static int do_linear_fault(struct mm_struct *mm, struct
> >  {
> >  	pgoff_t pgoff = (((address & PAGE_MASK)
> >  			- vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
> > -	unsigned int flags = (write_access ? FAULT_FLAG_WRITE : 0);
> > +	int write = write_access & ~FAULT_FLAG_RETRY;
> > +	unsigned int flags = (write ? FAULT_FLAG_WRITE : 0);
> > 
> > +	flags |= (write_access & FAULT_FLAG_RETRY);
> 
> gee, I'm lost.

So did me.

> Can we please redo this as:
> 
> 
> 	int write;
> 	unsigned int flags;
> 
> 	/*
> 	 * Big fat comment explaining the next three lines goes here
> 	 */

Basically it's doing a
        (is_write_access  | FAULT_FLAG_RETRY) =>
        (FAULT_FLAG_WRITE | FAULT_FLAG_RETRY)
by extracting the bool part:
> 	write = write_access & ~FAULT_FLAG_RETRY;
convert bool to a bit flag:
> 	unsigned int flags = (write ? FAULT_FLAG_WRITE : 0);
and restore the FAULT_FLAG_RETRY:
> 	flags |= (write_access & FAULT_FLAG_RETRY);

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

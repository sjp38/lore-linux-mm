Date: Fri, 8 Dec 2006 15:52:00 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bugme-new] [Bug 7645] New: Kernel BUG at mm/memory.c:1124
Message-Id: <20061208155200.0e2794a1.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0612072101120.27573@blonde.wat.veritas.com>
References: <200612070355.kB73tGf4021820@fire-2.osdl.org>
	<20061206201246.be7fb860.akpm@osdl.org>
	<4577A36B.6090803@cern.ch>
	<20061206230338.b0bf2b9e.akpm@osdl.org>
	<45782B32.6040401@cern.ch>
	<Pine.LNX.4.64.0612072101120.27573@blonde.wat.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Ramiro Voicu <Ramiro.Voicu@cern.ch>, linux-mm@kvack.org, bugme-daemon@bugzilla.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 7 Dec 2006 21:22:57 +0000 (GMT)
Hugh Dickins <hugh@veritas.com> wrote:

> On Thu, 7 Dec 2006, Ramiro Voicu wrote:
> > Andrew Morton wrote:
> > > On Thu, 07 Dec 2006 06:15:23 +0100
> > > Ramiro Voicu <Ramiro.Voicu@cern.ch> wrote:
> > >>
> > >> Dec  7 06:12:11 xxxx kernel: [  319.720340] pte_val: 629025
> > > 
> > > hm.  A valid, read-only, accessed user page with a sane-looking pfn.
> > > And this is repeatable, on two different machines.
> > > 
> > > I don't know what to do, sorry.  A bisection-search would have a good
> > > chance of finding the bug, but that would be pretty painful.  It looks like
> > > you were able to hit the bug after five minutes uptime, which helps.  Is it
> > > always that easy to hit?
> > 
> > It depends ... It can take days or minutes until it happens. The program
> > is a simple FTP-like using multiple TCP Streams, implemented with Java NIO.
> 
> Interesting.  I think you needn't bother with that bisection.  I can't
> say why this started happening to you only with recent releases (timings
> changed somehow I guess): it looks like reading /dev/zero has been using
> zeromap_page_range unsafely for years.
> 
> First it zaps existing ptes, then it inserts the zero page ptes - but
> only while holding mmap_sem for read: could be racing against another
> thread doing the same, or against ordinary faulting.  Now, it may well
> be that the program is buggy to be racing against itself in this way
> (which would fit with why this hasn't been observed before - buggy
> programs are exceedingly rare, aren't they ;-?) but of course it
> shouldn't trigger a kernel BUG (or leak, which preceded the BUG).
> 
> Please try the simple patch below: I expect it to fix your problem.
> Whether it's the right patch, I'm not quite sure: we do commonly use
> zap_page_range and zeromap_page_range with mmap_sem held for write,
> but perhaps we'd want to avoid such serialization in this case?
> 
> Hugh
> 
> --- 2.6.19/drivers/char/mem.c	2006-11-29 21:57:37.000000000 +0000
> +++ linux/drivers/char/mem.c	2006-12-07 20:21:46.000000000 +0000
> @@ -631,7 +631,7 @@ static inline size_t read_zero_pagealign
>  
>  	mm = current->mm;
>  	/* Oops, this was forgotten before. -ben */
> -	down_read(&mm->mmap_sem);
> +	down_write(&mm->mmap_sem);
>  
>  	/* For private mappings, just map in zero pages. */
>  	for (vma = find_vma(mm, addr); vma; vma = vma->vm_next) {
> @@ -655,7 +655,7 @@ static inline size_t read_zero_pagealign
>  			goto out_up;
>  	}
>  
> -	up_read(&mm->mmap_sem);
> +	up_write(&mm->mmap_sem);
>  	
>  	/* The shared case is hard. Let's do the conventional zeroing. */ 
>  	do {
> @@ -669,7 +669,7 @@ static inline size_t read_zero_pagealign
>  
>  	return size;
>  out_up:
> -	up_read(&mm->mmap_sem);
> +	up_write(&mm->mmap_sem);
>  	return size;
>  }
>  

Ramiro, have you had a chance to test this yet?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

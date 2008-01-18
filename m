Received: by wa-out-1112.google.com with SMTP id m33so1925339wag.8
        for <linux-mm@kvack.org>; Fri, 18 Jan 2008 13:03:04 -0800 (PST)
Message-ID: <4df4ef0c0801181303o6656832g8b63d2a119a86a9c@mail.gmail.com>
Date: Sat, 19 Jan 2008 00:03:04 +0300
From: "Anton Salikhmetov" <salikhmetov@gmail.com>
Subject: Re: [PATCH -v6 2/2] Updating ctime and mtime for memory-mapped files
In-Reply-To: <alpine.LFD.1.00.0801181214440.2957@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <12006091182260-git-send-email-salikhmetov@gmail.com>
	 <alpine.LFD.1.00.0801180949040.2957@woody.linux-foundation.org>
	 <E1JFvgx-0000zz-2C@pomaz-ex.szeredi.hu>
	 <alpine.LFD.1.00.0801181033580.2957@woody.linux-foundation.org>
	 <E1JFwOz-00019k-Uo@pomaz-ex.szeredi.hu>
	 <alpine.LFD.1.00.0801181106340.2957@woody.linux-foundation.org>
	 <E1JFwnQ-0001FB-2c@pomaz-ex.szeredi.hu>
	 <alpine.LFD.1.00.0801181127000.2957@woody.linux-foundation.org>
	 <4df4ef0c0801181158s3f783beaqead3d7049d4d3fa7@mail.gmail.com>
	 <alpine.LFD.1.00.0801181214440.2957@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Miklos Szeredi <miklos@szeredi.hu>, peterz@infradead.org, linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, akpm@linux-foundation.org, protasnb@gmail.com, r.e.wolff@bitwizard.nl, hidave.darkstar@gmail.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>

2008/1/18, Linus Torvalds <torvalds@linux-foundation.org>:
>
>
> On Fri, 18 Jan 2008, Anton Salikhmetov wrote:
> >
> > The current solution doesn't hit the performance at all when compared to
> > the competitor POSIX-compliant systems. It is faster and does even more
> > than the POSIX standard requires.
>
> Your current patches have two problems:
>  - they are simply unnecessarily invasive for a relatively simple issue
>  - all versions I've looked at closer are buggy too
>
> Example:
>
>         +               if (pte_dirty(*pte) && pte_write(*pte))
>         +                       *pte = pte_wrprotect(*pte);
>
> Uhhuh. Looks simple enough. Except it does a non-atomic pte access while
> other CPU's may be accessing it and updating it from their hw page table
> walkers. What will happen? Who knows? I can see lost access bits at a
> minimum.
>
> IOW, this isn't simple code. It's code that it is simple to screw up. In
> this case, you really need to use ptep_set_wrprotect(), for example.

Before using pte_wrprotect() the vma_wrprotect() routine uses the
pte_offset_map_lock() macro to get the PTE and to acquire the ptl
spinlock. Why did you say that this code was not SMP-safe? It should
be atomic, I think.


>
> So why not do it in many fewer lines with that simpler vma->dirty flag?

Neither the dirty flag you suggest, nor the AS_MCTIME flag I've
introduced in my previous solutions solve the following problem:

- mmap()
- a write reference
- msync() with MS_ASYNC
- a write reference
- msync() with MS_ASYNC

The POSIX standard requires the ctime and mtime stamps to be updated
not later than at the second call to msync() with the MS_ASYNC flag.

Some other POSIX-compliant operating system such as HP-UX and FreeBSD
satisfy this POSIX requirement. Linux does not.

>
>                 Linus
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

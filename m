Subject: Re: [PATCH 1/2] Massive code cleanup of sys_msync()
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20080115111018.1e27a229.randy.dunlap@oracle.com>
References: <12004129652397-git-send-email-salikhmetov@gmail.com>
	 <12004129734126-git-send-email-salikhmetov@gmail.com>
	 <20080115175705.GA21557@infradead.org>
	 <4df4ef0c0801151102l4d72b6b5j702e21beb1ebe459@mail.gmail.com>
	 <20080115111018.1e27a229.randy.dunlap@oracle.com>
Content-Type: text/plain
Date: Tue, 15 Jan 2008 14:46:57 -0600
Message-Id: <1200430017.19146.61.camel@cinder.waste.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: Anton Salikhmetov <salikhmetov@gmail.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, torvalds@linux-foundation.org, a.p.zijlstra@chello.nl, akpm@linux-foundation.org, protasnb@gmail.com, miklos@szeredi.hu
List-ID: <linux-mm.kvack.org>

On Tue, 2008-01-15 at 11:10 -0800, Randy Dunlap wrote:
> On Tue, 15 Jan 2008 22:02:54 +0300 Anton Salikhmetov wrote:
> 
> > 2008/1/15, Christoph Hellwig <hch@infradead.org>:
> > > On Tue, Jan 15, 2008 at 07:02:44PM +0300, Anton Salikhmetov wrote:
> 
> > > > @@ -33,71 +34,65 @@ asmlinkage long sys_msync(unsigned long start, size_t len, int flags)
> > > >       unsigned long end;
> > > >       struct mm_struct *mm = current->mm;
> > > >       struct vm_area_struct *vma;
> > > > -     int unmapped_error = 0;
> > > > -     int error = -EINVAL;
> > > > +     int error = 0, unmapped_error = 0;
> > > >
> > > >       if (flags & ~(MS_ASYNC | MS_INVALIDATE | MS_SYNC))
> > > > -             goto out;
> > > > +             return -EINVAL;
> > > >       if (start & ~PAGE_MASK)
> > > > -             goto out;
> > > > +             return -EINVAL;
> > >
> > > The goto out for a simple return style is used quite commonly in kernel
> > > code to have a single return statement which makes code maintaince, e.g.
> > > adding locks or allocations simpler.  Not sure that getting rid of it
> > > makes a lot of sense.
> > 
> > Sorry, I can't agree. That's what is written in the CodingStyle document:
> > 
> > The goto statement comes in handy when a function exits from multiple
> > locations and some common work such as cleanup has to be done.
> 
> CodingStyle does not try to cover Everything.  Nor do we want it to.
> 
> At any rate, there is a desire for functions to have a single point
> of return, regardless of the amount of cleanup to be done, so I agree
> with Christoph's comments.

When we're not cleaning up resources, the main advantage of having a
single point of return is that you can trace backwards from the return
point through the function's logic. But that advantage flies right out
the window when you use gotos. You still have to figure out how you got
to the return statement by tracing back and looking at all the possible
gotos. And the "goto out" style adds bulk and non-negligible complexity
when we've got to search back for what the last explicitly set value of
"ret" or "error" or whatever the function in question is using was.
Sometimes people get this wrong ("retval is already -EINVAL, so I don't
need to explicitly set it"), and create bugs.

So I think if we're not actually going to use "structured
programming" (no gotos) or "stack cleanup" styles, the single return
point style is more trouble than it's worth.

A lesser advantage of the single return point is that you can set a
breakpoint or put a printk at the end of a function. But I don't think
that's much justification.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

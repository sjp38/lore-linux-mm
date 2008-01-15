Received: by wa-out-1112.google.com with SMTP id m33so4639984wag.8
        for <linux-mm@kvack.org>; Tue, 15 Jan 2008 11:26:55 -0800 (PST)
Message-ID: <4df4ef0c0801151126p5dfdbc13ga9862c995890c33c@mail.gmail.com>
Date: Tue, 15 Jan 2008 22:26:55 +0300
From: "Anton Salikhmetov" <salikhmetov@gmail.com>
Subject: Re: [PATCH 1/2] Massive code cleanup of sys_msync()
In-Reply-To: <20080115111018.1e27a229.randy.dunlap@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <12004129652397-git-send-email-salikhmetov@gmail.com>
	 <12004129734126-git-send-email-salikhmetov@gmail.com>
	 <20080115175705.GA21557@infradead.org>
	 <4df4ef0c0801151102l4d72b6b5j702e21beb1ebe459@mail.gmail.com>
	 <20080115111018.1e27a229.randy.dunlap@oracle.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, torvalds@linux-foundation.org, a.p.zijlstra@chello.nl, akpm@linux-foundation.org, protasnb@gmail.com, miklos@szeredi.hu
List-ID: <linux-mm.kvack.org>

2008/1/15, Randy Dunlap <randy.dunlap@oracle.com>:
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

Should I replace "return -EINVAL;" statement with the following?

{
    error = -EINVAL;
    goto out;
}

>
>
> > The second part of requirement does not hold true for the sys_msync() routine.
> >
> > >
> > > > +             file = vma->vm_file;
> > > > +             if ((flags & MS_SYNC) && file && (vma->vm_flags & VM_SHARED)) {
> > >
> > > Given that file is assigned just above it would be more readable to test
> > > it first.
> >
> > The second part of my solution changes this code, anyway.
> >
> > >
> > > > +                     if (error)
> > > > +                             return error;
> > >
> > > This should be an goto out, returns out of the middle of the function
> > > make reading and maintaining the code not so nice.
> >
> > Sorry, I don't think so. No "common cleanup" is needed here.
>
>
> ---
> ~Randy
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

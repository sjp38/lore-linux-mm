Received: by wa-out-1112.google.com with SMTP id m33so3806491wag.8
        for <linux-mm@kvack.org>; Mon, 14 Jan 2008 03:56:33 -0800 (PST)
Message-ID: <4df4ef0c0801140356x2bf11e33oc8969d65ad5641a6@mail.gmail.com>
Date: Mon, 14 Jan 2008 14:56:33 +0300
From: "Anton Salikhmetov" <salikhmetov@gmail.com>
Subject: Re: [PATCH 1/2] massive code cleanup of sys_msync()
In-Reply-To: <E1JEMsg-00079n-FK@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <12001991991217-git-send-email-salikhmetov@gmail.com>
	 <12001992013606-git-send-email-salikhmetov@gmail.com>
	 <E1JEMsg-00079n-FK@pomaz-ex.szeredi.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, torvalds@linux-foundation.org, a.p.zijlstra@chello.nl, akpm@linux-foundation.org, protasnb@gmail.com
List-ID: <linux-mm.kvack.org>

2008/1/14, Miklos Szeredi <miklos@szeredi.hu>:
> > Substantial code cleanup of the sys_msync() function:
> >
> > 1) using the PAGE_ALIGN() macro instead of "manual" alignment;
> > 2) improved readability of the loop traversing the process memory regions.
>
> Thanks for doing this.  See comments below.
>
> > Signed-off-by: Anton Salikhmetov <salikhmetov@gmail.com>
> > ---
> >  mm/msync.c |   78 +++++++++++++++++++++++++++---------------------------------
> >  1 files changed, 35 insertions(+), 43 deletions(-)
> >
> > diff --git a/mm/msync.c b/mm/msync.c
> > index 144a757..ff654c9 100644
> > --- a/mm/msync.c
> > +++ b/mm/msync.c
> > @@ -1,24 +1,25 @@
> >  /*
> >   *   linux/mm/msync.c
> >   *
> > + * The msync() system call.
> >   * Copyright (C) 1994-1999  Linus Torvalds
> > + *
> > + * Substantial code cleanup.
> > + * Copyright (C) 2008 Anton Salikhmetov <salikhmetov@gmail.com>
> >   */
> >
> > -/*
> > - * The msync() system call.
> > - */
> > +#include <linux/file.h>
> >  #include <linux/fs.h>
> >  #include <linux/mm.h>
> >  #include <linux/mman.h>
> > -#include <linux/file.h>
> > -#include <linux/syscalls.h>
> >  #include <linux/sched.h>
> > +#include <linux/syscalls.h>
> >
> >  /*
> >   * MS_SYNC syncs the entire file - including mappings.
> >   *
> >   * MS_ASYNC does not start I/O (it used to, up to 2.5.67).
> > - * Nor does it marks the relevant pages dirty (it used to up to 2.6.17).
> > + * Nor does it mark the relevant pages dirty (it used to up to 2.6.17).
> >   * Now it doesn't do anything, since dirty pages are properly tracked.
> >   *
> >   * The application may now run fsync() to
> > @@ -33,71 +34,62 @@ asmlinkage long sys_msync(unsigned long start, size_t len, int flags)
> >       unsigned long end;
> >       struct mm_struct *mm = current->mm;
> >       struct vm_area_struct *vma;
> > -     int unmapped_error = 0;
> > -     int error = -EINVAL;
> > +     int error = 0, unmapped_error = 0;
> >
> >       if (flags & ~(MS_ASYNC | MS_INVALIDATE | MS_SYNC))
> > -             goto out;
> > +             return -EINVAL;
> >       if (start & ~PAGE_MASK)
> > -             goto out;
> > +             return -EINVAL;
> >       if ((flags & MS_ASYNC) && (flags & MS_SYNC))
> > -             goto out;
> > -     error = -ENOMEM;
> > -     len = (len + ~PAGE_MASK) & PAGE_MASK;
> > +             return -EINVAL;
> > +
> > +     len = PAGE_ALIGN(len);
> >       end = start + len;
> >       if (end < start)
> > -             goto out;
> > -     error = 0;
> > +             return -ENOMEM;
> >       if (end == start)
> > -             goto out;
> > +             return 0;
> > +
> >       /*
> >        * If the interval [start,end) covers some unmapped address ranges,
> >        * just ignore them, but return -ENOMEM at the end.
> >        */
> >       down_read(&mm->mmap_sem);
> >       vma = find_vma(mm, start);
> > -     for (;;) {
> > +     do {
> >               struct file *file;
> >
> > -             /* Still start < end. */
> > -             error = -ENOMEM;
> > -             if (!vma)
> > -                     goto out_unlock;
> > -             /* Here start < vma->vm_end. */
> > +             if (!vma) {
> > +                     error = -ENOMEM;
> > +                     break;
> > +             }
> >               if (start < vma->vm_start) {
> >                       start = vma->vm_start;
> > -                     if (start >= end)
> > -                             goto out_unlock;
> > +                     if (start >= end) {
> > +                             error = -ENOMEM;
> > +                             break;
> > +                     }
> >                       unmapped_error = -ENOMEM;
> >               }
> > -             /* Here vma->vm_start <= start < vma->vm_end. */
> > -             if ((flags & MS_INVALIDATE) &&
> > -                             (vma->vm_flags & VM_LOCKED)) {
> > +             if ((flags & MS_INVALIDATE) && (vma->vm_flags & VM_LOCKED)) {
> >                       error = -EBUSY;
> > -                     goto out_unlock;
> > +                     break;
> >               }
> >               file = vma->vm_file;
> > -             start = vma->vm_end;
> > -             if ((flags & MS_SYNC) && file &&
> > -                             (vma->vm_flags & VM_SHARED)) {
> > +             if ((flags & MS_SYNC) && file && (vma->vm_flags & VM_SHARED)) {
> >                       get_file(file);
> >                       up_read(&mm->mmap_sem);
> >                       error = do_fsync(file, 0);
> >                       fput(file);
> > -                     if (error || start >= end)
> > -                             goto out;
> > +                     if (error)
> > +                             return error;
> >                       down_read(&mm->mmap_sem);
> > -                     vma = find_vma(mm, start);
>
> Where did this line go?  It's needed because after releasing and
> reacquiring the mmap sem, the old vma may have gone away.
>
> I suggest, that when doing such a massive cleanup, that you split it
> up even further into easily understandable pieces, so such bugs cannot
> creep in.

Thanks for your review. I overlooked this problem. I'll redo my cleanup soon.

>
> > -             } else {
> > -                     if (start >= end) {
> > -                             error = 0;
> > -                             goto out_unlock;
> > -                     }
> > -                     vma = vma->vm_next;
> >               }
> > -     }
> > -out_unlock:
> > +
> > +             start = vma->vm_end;
> > +             vma = vma->vm_next;
> > +     } while (start < end);
> >       up_read(&mm->mmap_sem);
> > -out:
> > +
> >       return error ? : unmapped_error;
> >  }
> > --
> > 1.4.4.4
>
> Miklos
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

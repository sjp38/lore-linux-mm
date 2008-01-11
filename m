Received: by wa-out-1112.google.com with SMTP id m33so2067497wag.8
        for <linux-mm@kvack.org>; Fri, 11 Jan 2008 11:29:35 -0800 (PST)
Message-ID: <4df4ef0c0801111129v67a4578fl523a08e6860a3c8@mail.gmail.com>
Date: Fri, 11 Jan 2008 22:29:35 +0300
From: "Anton Salikhmetov" <salikhmetov@gmail.com>
Subject: Re: [PATCH 2/2][RFC][BUG] msync: updating ctime and mtime at syncing
In-Reply-To: <4787BB89.4010609@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <1200006638.19293.42.camel@codedot>
	 <1200012249.20379.2.camel@codedot> <4787BB89.4010609@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Staubach <staubach@redhat.com>
Cc: linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, Valdis.Kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, jesper.juhl@gmail.com
List-ID: <linux-mm.kvack.org>

2008/1/11, Peter Staubach <staubach@redhat.com>:
> Anton Salikhmetov wrote:
> > From: Anton Salikhmetov <salikhmetov@gmail.com>
> >
> > The patch contains changes for updating the ctime and mtime fields for memory mapped files:
> >
> > 1) adding a new flag triggering update of the inode data;
> > 2) implementing a helper function for checking that flag and updating ctime and mtime;
> > 3) updating time stamps for mapped files in sys_msync() and do_fsync().
> >
> >
>
> What happens if the application does not issue either an msync
> or an fsync call, but either just munmap's the region or just
> keeps on manipulating it?  It appears to me that the file times
> will never be updated in these cases.
>
> It seems to me that the file times should be updated eventually,
> and perhaps even regularly if the file is being constantly
> updated via the mmap'd region.

Indeed, FreeBSD, for example, implements updating ctime and mtime
in exactly the way you described. Many people I've spoken with do
interpret the POSIX requirement the same way as you do.

I had thoroughly investigated the possibility of implementing
the feature you are talking about, and came to the conclusion
that it would lead to quite massive changes and would require
a very complicated work with locks. At least, within
the current kernel design for the memory management.
So, I believe that the "auto-updating" feature should be
implemented later and outside of the bug #2645.

Finally, my solution puts the Linux kernel much closer to
the POSIX standard (the msync() and fsync() requirements), anyway.
And the changes which my patch contains, to the best of my knowledge,
do not intersect with the possible implementation of
the "auto-updating" feature.

I'm planning on adding the "auto-updating" feature in
the nearest future, but it looks like a separate project to me.

>
>     Thanx...
>
>        ps
>
> > Signed-off-by: Anton Salikhmetov <salikhmetov@gmail.com>
> >
> > ---
> >
> > diff --git a/fs/buffer.c b/fs/buffer.c
> > index 7249e01..09adf7e 100644
> > --- a/fs/buffer.c
> > +++ b/fs/buffer.c
> > @@ -719,6 +719,7 @@ static int __set_page_dirty(struct page *page,
> >       }
> >       write_unlock_irq(&mapping->tree_lock);
> >       __mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
> > +     set_bit(AS_MCTIME, &mapping->flags);
> >
> >       return 1;
> >  }
> > diff --git a/fs/inode.c b/fs/inode.c
> > index ed35383..c5b954e 100644
> > --- a/fs/inode.c
> > +++ b/fs/inode.c
> > @@ -22,6 +22,7 @@
> >  #include <linux/bootmem.h>
> >  #include <linux/inotify.h>
> >  #include <linux/mount.h>
> > +#include <linux/file.h>
> >
> >  /*
> >   * This is needed for the following functions:
> > @@ -1282,6 +1283,18 @@ void file_update_time(struct file *file)
> >
> >  EXPORT_SYMBOL(file_update_time);
> >
> > +/*
> > + * Update the ctime and mtime stamps after checking if they are to be updated.
> > + */
> > +void mapped_file_update_time(struct file *file)
> > +{
> > +     if (test_and_clear_bit(AS_MCTIME, &file->f_mapping->flags)) {
> > +             get_file(file);
> > +             file_update_time(file);
> > +             fput(file);
> > +     }
> > +}
> > +
> >  int inode_needs_sync(struct inode *inode)
> >  {
> >       if (IS_SYNC(inode))
> > diff --git a/fs/sync.c b/fs/sync.c
> > index 7cd005e..df57507 100644
> > --- a/fs/sync.c
> > +++ b/fs/sync.c
> > @@ -87,6 +87,8 @@ long do_fsync(struct file *file, int datasync)
> >               goto out;
> >       }
> >
> > +     mapped_file_update_time(file);
> > +
> >       ret = filemap_fdatawrite(mapping);
> >
> >       /*
> > diff --git a/include/linux/fs.h b/include/linux/fs.h
> > index b3ec4a4..0b05118 100644
> > --- a/include/linux/fs.h
> > +++ b/include/linux/fs.h
> > @@ -1978,6 +1978,7 @@ extern int inode_change_ok(struct inode *, struct iattr *);
> >  extern int __must_check inode_setattr(struct inode *, struct iattr *);
> >
> >  extern void file_update_time(struct file *file);
> > +extern void mapped_file_update_time(struct file *file);
> >
> >  static inline ino_t parent_ino(struct dentry *dentry)
> >  {
> > diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> > index db8a410..bf0f9e7 100644
> > --- a/include/linux/pagemap.h
> > +++ b/include/linux/pagemap.h
> > @@ -17,8 +17,9 @@
> >   * Bits in mapping->flags.  The lower __GFP_BITS_SHIFT bits are the page
> >   * allocation mode flags.
> >   */
> > -#define      AS_EIO          (__GFP_BITS_SHIFT + 0)  /* IO error on async write */
> > +#define AS_EIO               (__GFP_BITS_SHIFT + 0)  /* IO error on async write */
> >  #define AS_ENOSPC    (__GFP_BITS_SHIFT + 1)  /* ENOSPC on async write */
> > +#define AS_MCTIME    (__GFP_BITS_SHIFT + 2)  /* mtime and ctime to update */
> >
> >  static inline void mapping_set_error(struct address_space *mapping, int error)
> >  {
> > diff --git a/mm/msync.c b/mm/msync.c
> > index e788f7b..9d0a8f9 100644
> > --- a/mm/msync.c
> > +++ b/mm/msync.c
> > @@ -5,6 +5,7 @@
> >   * Copyright (C) 1994-1999  Linus Torvalds
> >   *
> >   * Substantial code cleanup.
> > + * Updating the ctime and mtime stamps for memory mapped files.
> >   * Copyright (C) 2008 Anton Salikhmetov <salikhmetov@gmail.com>
> >   */
> >
> > @@ -22,6 +23,10 @@
> >   * Nor does it mark the relevant pages dirty (it used to up to 2.6.17).
> >   * Now it doesn't do anything, since dirty pages are properly tracked.
> >   *
> > + * The msync() system call updates the ctime and mtime fields for
> > + * the mapped file when called with the MS_SYNC or MS_ASYNC flags
> > + * according to the POSIX standard.
> > + *
> >   * The application may now run fsync() to
> >   * write out the dirty pages and wait on the writeout and check the result.
> >   * Or the application may run fadvise(FADV_DONTNEED) against the fd to start
> > @@ -74,14 +79,17 @@ asmlinkage long sys_msync(unsigned long start, size_t len, int flags)
> >                       break;
> >               }
> >               file = vma->vm_file;
> > -             if ((flags & MS_SYNC) && file && (vma->vm_flags & VM_SHARED)) {
> > -                     get_file(file);
> > -                     up_read(&mm->mmap_sem);
> > -                     error = do_fsync(file, 0);
> > -                     fput(file);
> > -                     if (error)
> > -                             return error;
> > -                     down_read(&mm->mmap_sem);
> > +             if (file && (vma->vm_flags & VM_SHARED)) {
> > +                     mapped_file_update_time(file);
> > +                     if (flags & MS_SYNC) {
> > +                             get_file(file);
> > +                             up_read(&mm->mmap_sem);
> > +                             error = do_fsync(file, 0);
> > +                             fput(file);
> > +                             if (error)
> > +                                     return error;
> > +                             down_read(&mm->mmap_sem);
> > +                     }
> >               }
> >
> >               start = vma->vm_end;
> > diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> > index d55cfca..a85df0b 100644
> > --- a/mm/page-writeback.c
> > +++ b/mm/page-writeback.c
> > @@ -1025,6 +1025,7 @@ int __set_page_dirty_nobuffers(struct page *page)
> >               if (mapping->host) {
> >                       /* !PageAnon && !swapper_space */
> >                       __mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
> > +                     set_bit(AS_MCTIME, &mapping->flags);
> >               }
> >               return 1;
> >       }
> >
> >
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

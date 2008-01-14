Received: by wa-out-1112.google.com with SMTP id m33so3817879wag.8
        for <linux-mm@kvack.org>; Mon, 14 Jan 2008 04:22:27 -0800 (PST)
Message-ID: <4df4ef0c0801140422l1980d507v1884ad8d8e8bf6d3@mail.gmail.com>
Date: Mon, 14 Jan 2008 15:22:26 +0300
From: "Anton Salikhmetov" <salikhmetov@gmail.com>
Subject: Re: [PATCH 2/2] updating ctime and mtime at syncing
In-Reply-To: <E1JENAv-0007CM-T9@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <12001991991217-git-send-email-salikhmetov@gmail.com>
	 <12001992023392-git-send-email-salikhmetov@gmail.com>
	 <E1JENAv-0007CM-T9@pomaz-ex.szeredi.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, torvalds@linux-foundation.org, a.p.zijlstra@chello.nl, akpm@linux-foundation.org, protasnb@gmail.com
List-ID: <linux-mm.kvack.org>

2008/1/14, Miklos Szeredi <miklos@szeredi.hu>:
> > http://bugzilla.kernel.org/show_bug.cgi?id=2645
> >
> > Changes for updating the ctime and mtime fields for memory-mapped files:
> >
> > 1) new flag triggering update of the inode data;
> > 2) new function to update ctime and mtime for block device files;
> > 3) new helper function to update ctime and mtime when needed;
> > 4) updating time stamps for mapped files in sys_msync() and do_fsync();
> > 5) implementing the feature of auto-updating ctime and mtime.
>
> How exactly is this done?
>
> Is this catering for this case:
>
>  1 page is dirtied through mapping
>  2 app calls msync(MS_ASYNC)
>  3 page is written again through mapping
>  4 app calls msync(MS_ASYNC)
>  5 ...
>  6 page is written back
>
> What happens at 4?  Do we care about this one at all?

The POSIX standard requires updating the file times every time when msync()
is called with MS_ASYNC. I.e. the time stamps should be updated even
when no physical synchronization is being done immediately.

At least, this is how I undestand the standard. Please tell me if I am wrong.

>
> More comments inline.
>
> > Signed-off-by: Anton Salikhmetov <salikhmetov@gmail.com>
> > ---
> >  fs/buffer.c             |    1 +
> >  fs/fs-writeback.c       |    2 ++
> >  fs/inode.c              |   42 +++++++++++++++++++++++++++++++++++-------
> >  fs/sync.c               |    2 ++
> >  include/linux/fs.h      |    9 ++++++++-
> >  include/linux/pagemap.h |    3 ++-
> >  mm/msync.c              |   24 ++++++++++++++++--------
> >  mm/page-writeback.c     |    1 +
> >  8 files changed, 67 insertions(+), 17 deletions(-)
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
> > diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> > index 0fca820..c25ebd5 100644
> > --- a/fs/fs-writeback.c
> > +++ b/fs/fs-writeback.c
> > @@ -243,6 +243,8 @@ __sync_single_inode(struct inode *inode, struct writeback_control *wbc)
> >
> >       spin_unlock(&inode_lock);
> >
> > +     mapping_update_time(mapping);
> > +
> >       ret = do_writepages(mapping, wbc);
> >
> >       /* Don't write the inode if only I_DIRTY_PAGES was set */
> > diff --git a/fs/inode.c b/fs/inode.c
> > index ed35383..c02bfab 100644
> > --- a/fs/inode.c
> > +++ b/fs/inode.c
> > @@ -1243,8 +1243,8 @@ void touch_atime(struct vfsmount *mnt, struct dentry *dentry)
> >  EXPORT_SYMBOL(touch_atime);
> >
> >  /**
> > - *   file_update_time        -       update mtime and ctime time
> > - *   @file: file accessed
> > + *   inode_update_time       -       update mtime and ctime time
> > + *   @inode: inode accessed
> >   *
> >   *   Update the mtime and ctime members of an inode and mark the inode
> >   *   for writeback.  Note that this function is meant exclusively for
> > @@ -1253,10 +1253,8 @@ EXPORT_SYMBOL(touch_atime);
> >   *   S_NOCTIME inode flag, e.g. for network filesystem where these
> >   *   timestamps are handled by the server.
> >   */
> > -
> > -void file_update_time(struct file *file)
> > +void inode_update_time(struct inode *inode)
> >  {
> > -     struct inode *inode = file->f_path.dentry->d_inode;
> >       struct timespec now;
> >       int sync_it = 0;
> >
> > @@ -1279,8 +1277,39 @@ void file_update_time(struct file *file)
> >       if (sync_it)
> >               mark_inode_dirty_sync(inode);
> >  }
> > +EXPORT_SYMBOL(inode_update_time);
> > +
> > +/*
> > + * Update the ctime and mtime stamps for memory-mapped block device files.
> > + */
> > +static void bd_inode_update_time(struct inode *inode)
> > +{
> > +     struct block_device *bdev = inode->i_bdev;
> > +     struct list_head *p;
> > +
> > +     if (bdev == NULL)
> > +             return;
> > +
> > +     mutex_lock(&bdev->bd_mutex);
> > +     list_for_each(p, &bdev->bd_inodes) {
> > +             inode = list_entry(p, struct inode, i_devices);
> > +             inode_update_time(inode);
> > +     }
> > +     mutex_unlock(&bdev->bd_mutex);
> > +}
>
> Umm, why not just call with file->f_dentry->d_inode, so that you don't
> need to do this ugly search for the physical inode?  The file pointer
> is available in both msync and fsync.

I'm not sure if I undestood your question. I see two possible
interpretations for this
question, and I'm answering both.

The intention was to make the data changes in the block device data visible to
all device files associated with the block device. Hence the search,
because the time
stamps for all such device files should be updated as well.

Not only the sys_msync() and do_fsync() routines call the helper function
mapping_update_time(). Not all call sites of the helper function have the file
pointer available. Therefore, I pass the mapping pointer to the helper function
in order to make this function adequate for all situations.

>
> > -EXPORT_SYMBOL(file_update_time);
> > +/*
> > + * Update the ctime and mtime stamps after checking if they are to be updated.
> > + */
> > +void mapping_update_time(struct address_space *mapping)
> > +{
> > +     if (test_and_clear_bit(AS_MCTIME, &mapping->flags)) {
> > +             if (S_ISBLK(mapping->host->i_mode))
> > +                     bd_inode_update_time(mapping->host);
> > +             else
> > +                     inode_update_time(mapping->host);
> > +     }
> > +}
> >
> >  int inode_needs_sync(struct inode *inode)
> >  {
> > @@ -1290,7 +1319,6 @@ int inode_needs_sync(struct inode *inode)
> >               return 1;
> >       return 0;
> >  }
> > -
> >  EXPORT_SYMBOL(inode_needs_sync);
> >
> >  int inode_wait(void *word)
> > diff --git a/fs/sync.c b/fs/sync.c
> > index 7cd005e..5561464 100644
> > --- a/fs/sync.c
> > +++ b/fs/sync.c
> > @@ -87,6 +87,8 @@ long do_fsync(struct file *file, int datasync)
> >               goto out;
> >       }
> >
> > +     mapping_update_time(mapping);
> > +
> >       ret = filemap_fdatawrite(mapping);
> >
> >       /*
> > diff --git a/include/linux/fs.h b/include/linux/fs.h
> > index b3ec4a4..1dccd4b 100644
> > --- a/include/linux/fs.h
> > +++ b/include/linux/fs.h
> > @@ -1977,7 +1977,14 @@ extern int buffer_migrate_page(struct address_space *,
> >  extern int inode_change_ok(struct inode *, struct iattr *);
> >  extern int __must_check inode_setattr(struct inode *, struct iattr *);
> >
> > -extern void file_update_time(struct file *file);
> > +extern void inode_update_time(struct inode *);
> > +
> > +static inline void file_update_time(struct file *file)
> > +{
> > +     inode_update_time(file->f_path.dentry->d_inode);
> > +}
> > +
> > +extern void mapping_update_time(struct address_space *);
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
> > index ff654c9..07dc8fc 100644
> > --- a/mm/msync.c
> > +++ b/mm/msync.c
> > @@ -5,6 +5,7 @@
> >   * Copyright (C) 1994-1999  Linus Torvalds
> >   *
> >   * Substantial code cleanup.
> > + * Updating the ctime and mtime stamps for memory-mapped files.
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
> > @@ -76,14 +81,17 @@ asmlinkage long sys_msync(unsigned long start, size_t len, int flags)
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
> > +                     mapping_update_time(file->f_mapping);
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
> > --
> > 1.4.4.4
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0F8F46B0069
	for <linux-mm@kvack.org>; Wed,  2 Nov 2011 11:02:07 -0400 (EDT)
Date: Wed, 2 Nov 2011 16:02:00 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm: Improve cmtime update on shared writable mmaps
Message-ID: <20111102150200.GC31575@quack.suse.cz>
References: <CALCETrWoZeFpznU5Nv=+PvL9QRkTnS4atiGXx0jqZP_E3TJPqw@mail.gmail.com>
 <6e365cb75f3318ab45d7145aededcc55b8ededa3.1319844715.git.luto@amacapital.net>
 <20111101225342.GG18701@quack.suse.cz>
 <CALCETrW3ZZ=474cXY0HH1=fHTwKJUo--ufPfD1WLpGRC4_CPrw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CALCETrW3ZZ=474cXY0HH1=fHTwKJUo--ufPfD1WLpGRC4_CPrw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Jan Kara <jack@suse.cz>, Andreas Dilger <adilger@dilger.ca>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org

On Tue 01-11-11 16:02:24, Andy Lutomirski wrote:
> On Tue, Nov 1, 2011 at 3:53 PM, Jan Kara <jack@suse.cz> wrote:
> > On Fri 28-10-11 16:39:25, Andy Lutomirski wrote:
> >> We used to update a file's time on do_wp_page.  This caused latency
> >> whenever file_update_time would sleep (this happens on ext4).  It is
> >> also, IMO, less than ideal: any copy, backup, or 'make' run taken
> >> after do_wp_page but before an mmap user finished writing would see
> >> the new timestamp but the old contents.
> >>
> >> With this patch, cmtime is updated after a page is written.  When the
> >> mm code transfers the dirty bit from a pte to the associated struct
> >> page, it also sets a new page flag indicating that the page was
> >> modified directly from userspace.  The inode's time is then updated in
> >> clear_page_dirty_for_io.
> >>
> >> We can't update cmtime in all contexts in which ptes are unmapped:
> >> various reclaim paths can unmap ptes from GFP_NOFS paths.
> >>
> >> Signed-off-by: Andy Lutomirski <luto@amacapital.net>
> >> ---
> >>
> >> I'm not thrilled about using a page flag for this, but I haven't
> >> spotted a better way.  Updating the time in writepage would touch
> >> a lot of files and would interact oddly with write.
> >  I see two problems with this patch:
> > 1) Using a page flags is really a no-go. We are rather short on page flags
> > so using them for such minor thing is a real wastage. Moreover it should be
> > rather easy to just use an inode flag instead.
> 
> Am I allowed to set inode flags without holding any locks?
  That's a good question. Locking of i_flags was always kind of unclear to
me. They are certainly read without any locks and in the couple of places
where setting can actually race VFS uses i_mutex for serialization which is
kind of overkill (and unusable from page fault due to locking constraints).
Probably using atomic bitops for setting i_flags would be needed.

> > 2) You cannot call inode_update_time_writable() from
> > clear_page_dirty_for_io() because that is called under a page lock and thus
> > would create lock inversion problems.
> 
> Hmm.  Isn't it permitted to at least read from an fs while holding the
> page lock?  I thought that the page lock was held for the entire
> duration of a read and at the beginning of writeback.
  You are right that page lock is held during the whole ->readpage() call.
But that does not mean any reading can be done while page lock is held...
Page lock is also held during the ->writepage() call but that is one of
reasons why several filesystems ignore that callback and use ->writepages()
callback which allows them to do some fs internal locking before taking the
page lock.

> I can push this down to the ->writepage implementations or to the
> clear_page_dirty_for_io callers, but that will result in a bigger
> patch.
  Yes, I think this might be a way to go. Actually using
block_write_full_page() callback for updating times might somewhat reduce
number of filesystems that need to be modified...

								Honza

> >>  fs/inode.c                 |   51 ++++++++++++++++++++++++++++++-------------
> >>  include/linux/fs.h         |    1 +
> >>  include/linux/page-flags.h |    5 ++++
> >>  mm/page-writeback.c        |   19 +++++++++++++---
> >>  mm/rmap.c                  |   18 +++++++++++++-
> >>  5 files changed, 72 insertions(+), 22 deletions(-)
> >>
> >> diff --git a/fs/inode.c b/fs/inode.c
> >> index ec79246..ee93a25 100644
> >> --- a/fs/inode.c
> >> +++ b/fs/inode.c
> >> @@ -1461,21 +1461,8 @@ void touch_atime(struct vfsmount *mnt, struct dentry *dentry)
> >>  }
> >>  EXPORT_SYMBOL(touch_atime);
> >>
> >> -/**
> >> - *   file_update_time        -       update mtime and ctime time
> >> - *   @file: file accessed
> >> - *
> >> - *   Update the mtime and ctime members of an inode and mark the inode
> >> - *   for writeback.  Note that this function is meant exclusively for
> >> - *   usage in the file write path of filesystems, and filesystems may
> >> - *   choose to explicitly ignore update via this function with the
> >> - *   S_NOCMTIME inode flag, e.g. for network filesystem where these
> >> - *   timestamps are handled by the server.
> >> - */
> >> -
> >> -void file_update_time(struct file *file)
> >> +static void do_inode_update_time(struct file *file, struct inode *inode)
> >>  {
> >> -     struct inode *inode = file->f_path.dentry->d_inode;
> >>       struct timespec now;
> >>       enum { S_MTIME = 1, S_CTIME = 2, S_VERSION = 4 } sync_it = 0;
> >>
> >> @@ -1497,7 +1484,7 @@ void file_update_time(struct file *file)
> >>               return;
> >>
> >>       /* Finally allowed to write? Takes lock. */
> >> -     if (mnt_want_write_file(file))
> >> +     if (file && mnt_want_write_file(file))
> >>               return;
> >>
> >>       /* Only change inode inside the lock region */
> >> @@ -1508,10 +1495,42 @@ void file_update_time(struct file *file)
> >>       if (sync_it & S_MTIME)
> >>               inode->i_mtime = now;
> >>       mark_inode_dirty_sync(inode);
> >> -     mnt_drop_write(file->f_path.mnt);
> >> +
> >> +     if (file)
> >> +             mnt_drop_write(file->f_path.mnt);
> >> +}
> >> +
> >> +/**
> >> + *   file_update_time        -       update mtime and ctime time
> >> + *   @file: file accessed
> >> + *
> >> + *   Update the mtime and ctime members of an inode and mark the inode
> >> + *   for writeback.  Note that this function is meant exclusively for
> >> + *   usage in the file write path of filesystems, and filesystems may
> >> + *   choose to explicitly ignore update via this function with the
> >> + *   S_NOCMTIME inode flag, e.g. for network filesystem where these
> >> + *   timestamps are handled by the server.
> >> + */
> >> +
> >> +void file_update_time(struct file *file)
> >> +{
> >> +     do_inode_update_time(file, file->f_path.dentry->d_inode);
> >>  }
> >>  EXPORT_SYMBOL(file_update_time);
> >>
> >> +/**
> >> + *   inode_update_time_writable      -       update mtime and ctime
> >> + *   @inode: inode accessed
> >> + *
> >> + *   Same as file_update_time, except that the caller is responsible
> >> + *   for checking that the mount is writable.
> >> + */
> >> +
> >> +void inode_update_time_writable(struct inode *inode)
> >> +{
> >> +     do_inode_update_time(0, inode);
> >> +}
> >> +
> >>  int inode_needs_sync(struct inode *inode)
> >>  {
> >>       if (IS_SYNC(inode))
> >> diff --git a/include/linux/fs.h b/include/linux/fs.h
> >> index 277f497..9e28927 100644
> >> --- a/include/linux/fs.h
> >> +++ b/include/linux/fs.h
> >> @@ -2553,6 +2553,7 @@ extern int inode_newsize_ok(const struct inode *, loff_t offset);
> >>  extern void setattr_copy(struct inode *inode, const struct iattr *attr);
> >>
> >>  extern void file_update_time(struct file *file);
> >> +extern void inode_update_time_writable(struct inode *inode);
> >>
> >>  extern int generic_show_options(struct seq_file *m, struct vfsmount *mnt);
> >>  extern void save_mount_options(struct super_block *sb, char *options);
> >> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> >> index e90a673..4eed012 100644
> >> --- a/include/linux/page-flags.h
> >> +++ b/include/linux/page-flags.h
> >> @@ -107,6 +107,7 @@ enum pageflags {
> >>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
> >>       PG_compound_lock,
> >>  #endif
> >> +     PG_update_cmtime,       /* Dirtied via writable mapping. */
> >>       __NR_PAGEFLAGS,
> >>
> >>       /* Filesystems */
> >> @@ -273,6 +274,10 @@ PAGEFLAG_FALSE(HWPoison)
> >>  #define __PG_HWPOISON 0
> >>  #endif
> >>
> >> +/* Whoever clears PG_update_cmtime must update the cmtime. */
> >> +SETPAGEFLAG(UpdateCMTime, update_cmtime)
> >> +TESTCLEARFLAG(UpdateCMTime, update_cmtime)
> >> +
> >>  u64 stable_page_flags(struct page *page);
> >>
> >>  static inline int PageUptodate(struct page *page)
> >> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> >> index 0e309cd..41c48ea 100644
> >> --- a/mm/page-writeback.c
> >> +++ b/mm/page-writeback.c
> >> @@ -1460,7 +1460,8 @@ EXPORT_SYMBOL(set_page_dirty_lock);
> >>
> >>  /*
> >>   * Clear a page's dirty flag, while caring for dirty memory accounting.
> >> - * Returns true if the page was previously dirty.
> >> + * Returns true if the page was previously dirty.  Also updates inode time
> >> + * if necessary.
> >>   *
> >>   * This is for preparing to put the page under writeout.  We leave the page
> >>   * tagged as dirty in the radix tree so that a concurrent write-for-sync
> >> @@ -1474,6 +1475,7 @@ EXPORT_SYMBOL(set_page_dirty_lock);
> >>   */
> >>  int clear_page_dirty_for_io(struct page *page)
> >>  {
> >> +     int ret;
> >>       struct address_space *mapping = page_mapping(page);
> >>
> >>       BUG_ON(!PageLocked(page));
> >> @@ -1520,11 +1522,20 @@ int clear_page_dirty_for_io(struct page *page)
> >>                       dec_zone_page_state(page, NR_FILE_DIRTY);
> >>                       dec_bdi_stat(mapping->backing_dev_info,
> >>                                       BDI_RECLAIMABLE);
> >> -                     return 1;
> >> +                     ret = 1;
> >> +                     goto out;
> >>               }
> >> -             return 0;
> >> +             ret = 0;
> >> +             goto out;
> >>       }
> >> -     return TestClearPageDirty(page);
> >> +     ret = TestClearPageDirty(page);
> >> +
> >> +out:
> >> +     /* We know that the inode (if any) is on a writable mount. */
> >> +     if (mapping && mapping->host && TestClearPageUpdateCMTime(page))
> >> +             inode_update_time_writable(mapping->host);
> >> +
> >> +     return ret;
> >>  }
> >>  EXPORT_SYMBOL(clear_page_dirty_for_io);
> >>
> >> diff --git a/mm/rmap.c b/mm/rmap.c
> >> index 8005080..2ee595d 100644
> >> --- a/mm/rmap.c
> >> +++ b/mm/rmap.c
> >> @@ -937,6 +937,16 @@ int page_mkclean(struct page *page)
> >>               struct address_space *mapping = page_mapping(page);
> >>               if (mapping) {
> >>                       ret = page_mkclean_file(mapping, page);
> >> +
> >> +                     /*
> >> +                      * If dirtied via shared writable mapping, cmtime
> >> +                      * needs to be updated.  If dirtied only through
> >> +                      * write(), etc, then the writer already updated
> >> +                      * cmtime.
> >> +                      */
> >> +                     if (ret)
> >> +                             SetPageUpdateCMTime(page);
> >> +
> >>                       if (page_test_and_clear_dirty(page_to_pfn(page), 1))
> >>                               ret = 1;
> >>               }
> >> @@ -1203,8 +1213,10 @@ int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
> >>       pteval = ptep_clear_flush_notify(vma, address, pte);
> >>
> >>       /* Move the dirty bit to the physical page now the pte is gone. */
> >> -     if (pte_dirty(pteval))
> >> +     if (pte_dirty(pteval)) {
> >> +             SetPageUpdateCMTime(page);
> >>               set_page_dirty(page);
> >> +     }
> >>
> >>       /* Update high watermark before we lower rss */
> >>       update_hiwater_rss(mm);
> >> @@ -1388,8 +1400,10 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
> >>                       set_pte_at(mm, address, pte, pgoff_to_pte(page->index));
> >>
> >>               /* Move the dirty bit to the physical page now the pte is gone. */
> >> -             if (pte_dirty(pteval))
> >> +             if (pte_dirty(pteval)) {
> >> +                     SetPageUpdateCMTime(page);
> >>                       set_page_dirty(page);
> >> +             }
> >>
> >>               page_remove_rmap(page);
> >>               page_cache_release(page);
> >> --
> >> 1.7.6.4
> >>
> > --
> > Jan Kara <jack@suse.cz>
> > SUSE Labs, CR
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

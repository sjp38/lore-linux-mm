Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 9CD736B014E
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 11:15:08 -0400 (EDT)
Date: Thu, 13 Sep 2012 11:15:03 -0400 (EDT)
From: =?ISO-8859-15?Q?Luk=E1=A8_Czerner?= <lczerner@redhat.com>
Subject: Re: [PATCH 07/15 v2] ext4: Take i_mutex before punching hole
In-Reply-To: <CAOiN93kKVxYeS5f0_nR3RpdX7sv+EJNA-T4jq7amFS5LQGqfnw@mail.gmail.com>
Message-ID: <alpine.LFD.2.00.1209131113450.15781@dhcp-196-88.bos.redhat.com>
References: <1346451711-1931-1-git-send-email-lczerner@redhat.com> <1346451711-1931-8-git-send-email-lczerner@redhat.com> <CAOiN93kKVxYeS5f0_nR3RpdX7sv+EJNA-T4jq7amFS5LQGqfnw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ashish Sangwan <ashishsangwan2@gmail.com>
Cc: Lukas Czerner <lczerner@redhat.com>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, tytso@mit.edu, hughd@google.com, linux-mm@kvack.org

On Mon, 10 Sep 2012, Ashish Sangwan wrote:

> Date: Mon, 10 Sep 2012 17:30:53 +0530
> From: Ashish Sangwan <ashishsangwan2@gmail.com>
> To: Lukas Czerner <lczerner@redhat.com>
> Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, tytso@mit.edu,
>     hughd@google.com, linux-mm@kvack.org
> Subject: Re: [PATCH 07/15 v2] ext4: Take i_mutex before punching hole
> 
> On Sat, Sep 1, 2012 at 3:51 AM, Lukas Czerner <lczerner@redhat.com> wrote:
> > Currently the allocation might happen in the punched range after the
> > truncation and before the releasing the space of the range. This would
> > lead to blocks being unallocated under the mapped buffer heads resulting
> > in nasty bugs.
> >
> > With this commit we take i_mutex before going to do anything in the
> > ext4_ext_punch_hole() preventing any write to happen while the hole
> > punching is in progress. This will also allow us to ditch the writeout
> > of dirty pages withing the range.
> >
> > This commit was based on code provided by Zheng Liu, thanks!
> >
> > Signed-off-by: Lukas Czerner <lczerner@redhat.com>
> > ---
> >  fs/ext4/extents.c |   26 ++++++++++----------------
> >  1 files changed, 10 insertions(+), 16 deletions(-)
> >
> > diff --git a/fs/ext4/extents.c b/fs/ext4/extents.c
> > index aabbb3f..f920383 100644
> > --- a/fs/ext4/extents.c
> > +++ b/fs/ext4/extents.c
> > @@ -4769,9 +4769,11 @@ int ext4_ext_punch_hole(struct file *file, loff_t offset, loff_t length)
> >         loff_t first_page_offset, last_page_offset;
> >         int credits, err = 0;
> >
> > +       mutex_lock(&inode->i_mutex);
> > +
> >         /* No need to punch hole beyond i_size */
> >         if (offset >= inode->i_size)
> > -               return 0;
> > +               goto out1;
> >
> >         /*
> >          * If the hole extends beyond i_size, set the hole
> > @@ -4789,18 +4791,6 @@ int ext4_ext_punch_hole(struct file *file, loff_t offset, loff_t length)
> >         first_page_offset = first_page << PAGE_CACHE_SHIFT;
> >         last_page_offset = last_page << PAGE_CACHE_SHIFT;
> >
> > -       /*
> > -        * Write out all dirty pages to avoid race conditions
> > -        * Then release them.
> > -        */
> > -       if (mapping->nrpages && mapping_tagged(mapping, PAGECACHE_TAG_DIRTY)) {
> > -               err = filemap_write_and_wait_range(mapping,
> > -                       offset, offset + length - 1);
> > -
> > -               if (err)
> > -                       return err;
> > -       }
> > -
> 
> Removing above code will cause a problem in case the file has all its
> data in memory and nothing has been committed on disk. If punch hole
> is issued for such a file, as there are no extents present, EIO would
> be returned from ext4_ext_rm_leaf. So, even though blocks would be
> removed from memory, the end result will be error EIO.
> 
> >         /* Now release the pages */
> >         if (last_page_offset > first_page_offset) {
> >                 truncate_pagecache_range(inode, first_page_offset,
> 
> To avoid this, you can add a check after the call to truncate_pagecache_range.
> if(!inode->i_blocks)
>   return 0;

Thanks for pointing this out. However Dimitry has better fix for
this with some additional changes so I am dropping this particular
patch.

(see "ext4: punch_hole should wait for DIO writers")

Thanks!
-Lukas

> 
> > @@ -4812,12 +4802,14 @@ int ext4_ext_punch_hole(struct file *file, loff_t offset, loff_t length)
> >
> >         credits = ext4_writepage_trans_blocks(inode);
> >         handle = ext4_journal_start(inode, credits);
> > -       if (IS_ERR(handle))
> > -               return PTR_ERR(handle);
> > +       if (IS_ERR(handle)) {
> > +               err = PTR_ERR(handle);
> > +               goto out1;
> > +       }
> >
> >         err = ext4_orphan_add(handle, inode);
> >         if (err)
> > -               goto out;
> > +               goto out1;
> >
> >         /*
> >          * Now we need to zero out the non-page-aligned data in the
> > @@ -4907,6 +4899,8 @@ out:
> >         inode->i_mtime = inode->i_ctime = ext4_current_time(inode);
> >         ext4_mark_inode_dirty(handle, inode);
> >         ext4_journal_stop(handle);
> > +out1:
> > +       mutex_unlock(&inode->i_mutex);
> >         return err;
> >  }
> >  int ext4_fiemap(struct inode *inode, struct fiemap_extent_info *fieinfo,
> > --
> > 1.7.7.6
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-ext4" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

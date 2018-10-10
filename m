Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0F5F26B0007
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 11:51:04 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id p73-v6so5325378qkp.2
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 08:51:04 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id d23-v6si1466948qte.191.2018.10.10.08.51.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 08:51:02 -0700 (PDT)
Date: Wed, 10 Oct 2018 08:50:55 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH 14/25] vfs: make remap_file_range functions take and
 return bytes completed
Message-ID: <20181010155055.GS28243@magnolia>
References: <153913023835.32295.13962696655740190941.stgit@magnolia>
 <153913040858.32295.9474188640729118153.stgit@magnolia>
 <CAOQ4uxg0=EJp1WJXmUeHT05yF1txRKKhPHVTWeG+rdtRD5FfHA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOQ4uxg0=EJp1WJXmUeHT05yF1txRKKhPHVTWeG+rdtRD5FfHA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Amir Goldstein <amir73il@gmail.com>
Cc: Dave Chinner <david@fromorbit.com>, Eric Sandeen <sandeen@redhat.com>, Linux NFS Mailing List <linux-nfs@vger.kernel.org>, linux-cifs@vger.kernel.org, overlayfs <linux-unionfs@vger.kernel.org>, linux-xfs <linux-xfs@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Btrfs <linux-btrfs@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, ocfs2-devel@oss.oracle.com

On Wed, Oct 10, 2018 at 09:47:00AM +0300, Amir Goldstein wrote:
> On Wed, Oct 10, 2018 at 3:14 AM Darrick J. Wong <darrick.wong@oracle.com> wrote:
> >
> > From: Darrick J. Wong <darrick.wong@oracle.com>
> >
> > Change the remap_file_range functions to take a number of bytes to
> > operate upon and return the number of bytes they operated on.  This is a
> > requirement for allowing fs implementations to return short clone/dedupe
> > results to the user, which will enable us to obey resource limits in a
> > graceful manner.
> >
> > A subsequent patch will enable copy_file_range to signal to the
> > ->clone_file_range implementation that it can handle a short length,
> > which will be returned in the function's return value.  Neither clone
> > ioctl can take advantage of this, alas.
> >
> > Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> > ---
> [...]
> > @@ -141,8 +142,8 @@ static int ovl_copy_up_data(struct path *old, struct path *new, loff_t len)
> >         }
> >
> >         /* Try to use clone_file_range to clone up within the same fs */
> > -       error = do_clone_file_range(old_file, 0, new_file, 0, len);
> > -       if (!error)
> > +       cloned = do_clone_file_range(old_file, 0, new_file, 0, len);
> > +       if (cloned == len)
> >                 goto out;
> >         /* Couldn't clone, so now we try to copy the data */
> >         error = 0;
> 
> This error = 0 not needed anymore, but not a big deal...

Fixed.

> > diff --git a/fs/overlayfs/file.c b/fs/overlayfs/file.c
> > index 693bd0620a81..c8c890c22898 100644
> > --- a/fs/overlayfs/file.c
> > +++ b/fs/overlayfs/file.c
> > @@ -434,14 +434,14 @@ enum ovl_copyop {
> >         OVL_DEDUPE,
> >  };
> >
> > -static ssize_t ovl_copyfile(struct file *file_in, loff_t pos_in,
> > +static loff_t ovl_copyfile(struct file *file_in, loff_t pos_in,
> >                             struct file *file_out, loff_t pos_out,
> > -                           u64 len, unsigned int flags, enum ovl_copyop op)
> > +                           loff_t len, unsigned int flags, enum ovl_copyop op)
> >  {
> >         struct inode *inode_out = file_inode(file_out);
> >         struct fd real_in, real_out;
> >         const struct cred *old_cred;
> > -       ssize_t ret;
> > +       loff_t ret;
> >
> >         ret = ovl_real_fdget(file_out, &real_out);
> >         if (ret)
> > @@ -489,9 +489,9 @@ static ssize_t ovl_copy_file_range(struct file *file_in, loff_t pos_in,
> >                             OVL_COPY);
> >  }
> >
> > -static int ovl_remap_file_range(struct file *file_in, loff_t pos_in,
> > -                               struct file *file_out, loff_t pos_out,
> > -                               u64 len, unsigned int flags)
> > +static loff_t ovl_remap_file_range(struct file *file_in, loff_t pos_in,
> > +                                  struct file *file_out, loff_t pos_out,
> > +                                  loff_t len, unsigned int flags)
> >  {
> >         enum ovl_copyop op;
> >
> > diff --git a/fs/read_write.c b/fs/read_write.c
> > index 917934770b08..f43b0620afd4 100644
> > --- a/fs/read_write.c
> > +++ b/fs/read_write.c
> > @@ -1589,10 +1589,13 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
> >          * more efficient if both clone and copy are supported (e.g. NFS).
> >          */
> >         if (file_in->f_op->remap_file_range) {
> > -               ret = file_in->f_op->remap_file_range(file_in, pos_in,
> > -                               file_out, pos_out, len, 0);
> > -               if (ret == 0) {
> > -                       ret = len;
> > +               s64 cloned;
> 
> loff_t?

Fixed.

> > +
> > +               cloned = file_in->f_op->remap_file_range(file_in, pos_in,
> > +                               file_out, pos_out,
> > +                               min_t(loff_t, MAX_RW_COUNT, len), 0);
> > +               if (cloned >= 0) {
> > +                       ret = cloned;
> >                         goto done;
> >                 }
> >         }
> 
> Commit message wasn't clear enough on the behavior of copy_file_range()
> before and after the patch IMO. Maybe it would be better to pospone this
> semantic change to the RFR_SHORTEN patch and keep if (cloned == len)
> in this patch?

There shouldn't be any behavior change here -- all implementations
return a negative error code or the length that was passed in.  I'll
clarify that in the commit message.

--D

> Thanks,
> Amir.

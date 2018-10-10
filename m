Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 311686B0003
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 13:01:44 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id c4-v6so4227716plz.20
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 10:01:44 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id o32-v6si11503300pld.284.2018.10.10.10.01.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 10:01:43 -0700 (PDT)
Date: Wed, 10 Oct 2018 10:01:37 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH 06/25] vfs: strengthen checking of file range inputs to
 generic_remap_checks
Message-ID: <20181010170137.GA24824@magnolia>
References: <153913023835.32295.13962696655740190941.stgit@magnolia>
 <153913028015.32295.15993665528948323051.stgit@magnolia>
 <CAOQ4uxjZ1JuT3Ga1kTDF9boeYF5pafDmsnzWxVNPWcTpESchgw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOQ4uxjZ1JuT3Ga1kTDF9boeYF5pafDmsnzWxVNPWcTpESchgw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Amir Goldstein <amir73il@gmail.com>
Cc: Dave Chinner <david@fromorbit.com>, Eric Sandeen <sandeen@redhat.com>, Linux NFS Mailing List <linux-nfs@vger.kernel.org>, linux-cifs@vger.kernel.org, overlayfs <linux-unionfs@vger.kernel.org>, linux-xfs <linux-xfs@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Btrfs <linux-btrfs@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, ocfs2-devel@oss.oracle.com

On Wed, Oct 10, 2018 at 08:23:27AM +0300, Amir Goldstein wrote:
> On Wed, Oct 10, 2018 at 3:11 AM Darrick J. Wong <darrick.wong@oracle.com> wrote:
> >
> > From: Darrick J. Wong <darrick.wong@oracle.com>
> >
> > File range remapping, if allowed to run past the destination file's EOF,
> > is an optimization on a regular file write.  Regular file writes that
> > extend the file length are subject to various constraints which are not
> > checked by range cloning.
> >
> > This is a correctness problem because we're never allowed to touch
> > ranges that the page cache can't support (s_maxbytes); we're not
> > supposed to deal with large offsets (MAX_NON_LFS) if O_LARGEFILE isn't
> > set; and we must obey resource limits (RLIMIT_FSIZE).
> >
> > Therefore, add these checks to the new generic_remap_checks function so
> > that we curtail unexpected behavior.
> >
> > Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> > ---
> >  mm/filemap.c |   39 +++++++++++++++++++++++++++++++++++++++
> >  1 file changed, 39 insertions(+)
> >
> >
> > diff --git a/mm/filemap.c b/mm/filemap.c
> > index 14041a8468ba..59056bd9c58a 100644
> > --- a/mm/filemap.c
> > +++ b/mm/filemap.c
> > @@ -2974,6 +2974,27 @@ inline ssize_t generic_write_checks(struct kiocb *iocb, struct iov_iter *from)
> >  }
> >  EXPORT_SYMBOL(generic_write_checks);
> >
> > +static int
> > +generic_remap_check_limits(struct file *file, loff_t pos, uint64_t *count)
> > +{
> > +       struct inode *inode = file->f_mapping->host;
> > +
> > +       /* Don't exceed the LFS limits. */
> > +       if (unlikely(pos + *count > MAX_NON_LFS &&
> > +                               !(file->f_flags & O_LARGEFILE))) {
> > +               if (pos >= MAX_NON_LFS)
> > +                       return -EFBIG;
> > +               *count = min(*count, MAX_NON_LFS - (uint64_t)pos);
> > +       }
> > +
> > +       /* Don't operate on ranges the page cache doesn't support. */
> > +       if (unlikely(pos >= inode->i_sb->s_maxbytes))
> > +               return -EFBIG;
> > +
> > +       *count = min(*count, inode->i_sb->s_maxbytes - (uint64_t)pos);
> > +       return 0;
> > +}
> > +
> 
> Sorry. I haven't explained myself properly last time.
> What I meant is that it hurts my eyes to see generic_write_checks() and
> generic_remap_check_limits() which from the line of (limit != RLIM_INFINITY)
> are exactly the same thing. Yes, generic_remap_check_limits() uses
> iov_iter_truncate(), but that's a minor semantic change - it can be easily
> resolved by creating a dummy iter in generic_remap_checks() instead of
> passing int *count.

Making a fake kiocb and iterator seem like a terribly fragile idea.

How about I make the common helper take a pos and *count, and
generic_write_checks can translate that into iov_iter_truncate?

> You could say that this is nit picking, but the very reason this patch
> set exists
> it because clone/dedup implementation did not use the same range checks
> of write to begin with, so it just seems wrong to diverge them at this point.
> 
> So to be clear, I suggest that generic_write_checks() should use your
> generic_remap_check_limits() helper.
> If you disagree and others can live with this minor duplication, fine by me.

Nah, I think I misunderstood you the first time, sorry about that.

--D

> Thanks,
> Amir.

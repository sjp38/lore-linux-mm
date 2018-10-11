Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id CED746B0279
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 12:04:23 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id b27-v6so8396134pfm.15
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 09:04:23 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id 129-v6si28018404pgj.283.2018.10.11.09.04.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Oct 2018 09:04:22 -0700 (PDT)
Date: Thu, 11 Oct 2018 09:04:11 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH 17/25] vfs: enable remap callers that can handle short
 operations
Message-ID: <20181011160411.GA28243@magnolia>
References: <153923113649.5546.9840926895953408273.stgit@magnolia>
 <153923126628.5546.3484461137192547927.stgit@magnolia>
 <CAOQ4uxgbTf0Po3stK4YZWqYPWTmwfqsSLGwV4p4be6gBrdLP+g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOQ4uxgbTf0Po3stK4YZWqYPWTmwfqsSLGwV4p4be6gBrdLP+g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Amir Goldstein <amir73il@gmail.com>
Cc: Dave Chinner <david@fromorbit.com>, Eric Sandeen <sandeen@redhat.com>, Linux NFS Mailing List <linux-nfs@vger.kernel.org>, linux-cifs@vger.kernel.org, overlayfs <linux-unionfs@vger.kernel.org>, linux-xfs <linux-xfs@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Btrfs <linux-btrfs@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, ocfs2-devel@oss.oracle.com

On Thu, Oct 11, 2018 at 08:15:42AM +0300, Amir Goldstein wrote:
> On Thu, Oct 11, 2018 at 7:14 AM Darrick J. Wong <darrick.wong@oracle.com> wrote:
> >
> > From: Darrick J. Wong <darrick.wong@oracle.com>
> >
> > Plumb in a remap flag that enables the filesystem remap handler to
> > shorten remapping requests for callers that can handle it.  Now
> > copy_file_range can report partial success (in case we run up against
> > alignment problems, resource limits, etc.).
> >
> > Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> > Reviewed-by: Amir Goldstein <amir73il@gmail.com>
> > ---
> >  fs/read_write.c    |   15 +++++++++------
> >  include/linux/fs.h |    7 +++++--
> >  mm/filemap.c       |   16 ++++++++++++----
> >  3 files changed, 26 insertions(+), 12 deletions(-)
> >
> >
> > diff --git a/fs/read_write.c b/fs/read_write.c
> > index 6ec908f9a69b..3713893b7e38 100644
> > --- a/fs/read_write.c
> > +++ b/fs/read_write.c
> > @@ -1593,7 +1593,8 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
> >
> >                 cloned = file_in->f_op->remap_file_range(file_in, pos_in,
> >                                 file_out, pos_out,
> > -                               min_t(loff_t, MAX_RW_COUNT, len), 0);
> > +                               min_t(loff_t, MAX_RW_COUNT, len),
> > +                               RFR_CAN_SHORTEN);
> >                 if (cloned > 0) {
> >                         ret = cloned;
> >                         goto done;
> > @@ -1804,16 +1805,18 @@ int generic_remap_file_range_prep(struct file *file_in, loff_t pos_in,
> >                  * If the user is attempting to remap a partial EOF block and
> >                  * it's inside the destination EOF then reject it.
> >                  *
> > -                * We don't support shortening requests, so we can only reject
> > -                * them.
> > +                * If possible, shorten the request instead of rejecting it.
> >                  */
> >                 if (is_dedupe)
> >                         ret = -EBADE;
> >                 else if (pos_out + *len < i_size_read(inode_out))
> >                         ret = -EINVAL;
> >
> > -               if (ret)
> > -                       return ret;
> > +               if (ret) {
> > +                       if (!(remap_flags & RFR_CAN_SHORTEN))
> > +                               return ret;
> > +                       *len &= ~blkmask;
> > +               }
> >         }
> >
> >         return 1;
> > @@ -2112,7 +2115,7 @@ int vfs_dedupe_file_range(struct file *file, struct file_dedupe_range *same)
> >
> >                 deduped = vfs_dedupe_file_range_one(file, off, dst_file,
> >                                                     info->dest_offset, len,
> > -                                                   0);
> > +                                                   RFR_CAN_SHORTEN);
> 
> You did not update WARN_ON_ONCE in vfs_dedupe_file_range_one()
> to allow this flag and did not mention dedupe in commit message.
> Was that change intentional in this patch?
> 
> After RFR_SHORT_DEDUPE patch the end result in fine.

Heh, oops, sorry about that.  I'll reissue the patch with the two
corrections.

--D

> Thanks,
> Amir.

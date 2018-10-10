Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6863A6B026B
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 12:29:56 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 14-v6so5045639pfk.22
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 09:29:56 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id g3-v6si24697426pgj.74.2018.10.10.09.29.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 09:29:55 -0700 (PDT)
Date: Wed, 10 Oct 2018 09:29:48 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH 17/25] vfs: make remapping to source file eof more
 explicit
Message-ID: <20181010162948.GT28243@magnolia>
References: <153913023835.32295.13962696655740190941.stgit@magnolia>
 <153913043746.32295.17463515265798256890.stgit@magnolia>
 <CAOQ4uxivwLR5assf0VwHdp5p06Er4w7urB637Z3wiQ1eZoT9tQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOQ4uxivwLR5assf0VwHdp5p06Er4w7urB637Z3wiQ1eZoT9tQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Amir Goldstein <amir73il@gmail.com>
Cc: Dave Chinner <david@fromorbit.com>, Eric Sandeen <sandeen@redhat.com>, Linux NFS Mailing List <linux-nfs@vger.kernel.org>, linux-cifs@vger.kernel.org, overlayfs <linux-unionfs@vger.kernel.org>, linux-xfs <linux-xfs@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Btrfs <linux-btrfs@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, ocfs2-devel@oss.oracle.com

On Wed, Oct 10, 2018 at 03:29:06PM +0300, Amir Goldstein wrote:
> On Wed, Oct 10, 2018 at 3:14 AM Darrick J. Wong <darrick.wong@oracle.com> wrote:
> >
> > From: Darrick J. Wong <darrick.wong@oracle.com>
> >
> > Create a RFR_TO_SRC_EOF flag to explicitly declare that the caller wants
> > the remap implementation to remap to the end of the source file, once
> > the files are locked.
> >
> > Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> > ---
> >  fs/ioctl.c         |    3 ++-
> >  fs/nfsd/vfs.c      |    3 ++-
> >  fs/read_write.c    |   13 +++++++------
> >  include/linux/fs.h |    2 ++
> >  4 files changed, 13 insertions(+), 8 deletions(-)
> >
> >
> > diff --git a/fs/ioctl.c b/fs/ioctl.c
> > index 505275ec5596..7fec997abd2f 100644
> > --- a/fs/ioctl.c
> > +++ b/fs/ioctl.c
> > @@ -224,6 +224,7 @@ static long ioctl_file_clone(struct file *dst_file, unsigned long srcfd,
> >  {
> >         struct fd src_file = fdget(srcfd);
> >         loff_t cloned;
> > +       unsigned int flags = olen == 0 ? RFR_TO_SRC_EOF : 0;
> >         int ret;
> >
> >         if (!src_file.file)
> > @@ -232,7 +233,7 @@ static long ioctl_file_clone(struct file *dst_file, unsigned long srcfd,
> >         if (src_file.file->f_path.mnt != dst_file->f_path.mnt)
> >                 goto fdput;
> >         cloned = vfs_clone_file_range(src_file.file, off, dst_file, destoff,
> > -                                     olen, 0);
> > +                                     olen, flags);
> >         if (cloned < 0)
> >                 ret = cloned;
> >         else if (olen && cloned != olen)
> > diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> > index 726fc5b2b27a..d1f2ae08adf6 100644
> > --- a/fs/nfsd/vfs.c
> > +++ b/fs/nfsd/vfs.c
> > @@ -542,8 +542,9 @@ __be32 nfsd4_clone_file_range(struct file *src, u64 src_pos, struct file *dst,
> >                 u64 dst_pos, u64 count)
> >  {
> >         loff_t cloned;
> > +       unsigned int flags = count == 0 ? RFR_TO_SRC_EOF : 0;
> >
> > -       cloned = vfs_clone_file_range(src, src_pos, dst, dst_pos, count, 0);
> > +       cloned = vfs_clone_file_range(src, src_pos, dst, dst_pos, count, flags);
> >         if (count && cloned != count)
> >                 cloned = -EINVAL;
> >         return nfserrno(cloned < 0 ? cloned : 0);
> > diff --git a/fs/read_write.c b/fs/read_write.c
> > index 479eb810c8e6..a628fd9a47cf 100644
> > --- a/fs/read_write.c
> > +++ b/fs/read_write.c
> > @@ -1748,11 +1748,12 @@ int generic_remap_file_range_prep(struct file *file_in, loff_t pos_in,
> >
> >         isize = i_size_read(inode_in);
> >
> > -       /* Zero length dedupe exits immediately; reflink goes to EOF. */
> > -       if (*len == 0) {
> > -               if (is_dedupe || pos_in == isize)
> > -                       return 0;
> > -               if (pos_in > isize)
> > +       /*
> > +        * If the caller asked to go all the way to the end of the source file,
> > +        * set *len now that we have the file locked.
> > +        */
> > +       if (remap_flags & RFR_TO_SRC_EOF) {
> > +               if (pos_in >= isize)
> >                         return -EINVAL;
> >                 *len = isize - pos_in;
> >         }
> > @@ -1828,7 +1829,7 @@ loff_t do_clone_file_range(struct file *file_in, loff_t pos_in,
> >         struct inode *inode_out = file_inode(file_out);
> >         loff_t ret;
> >
> > -       WARN_ON_ONCE(remap_flags);
> > +       WARN_ON_ONCE(remap_flags & ~(RFR_TO_SRC_EOF));
> >
> >         if (S_ISDIR(inode_in->i_mode) || S_ISDIR(inode_out->i_mode))
> >                 return -EISDIR;
> > diff --git a/include/linux/fs.h b/include/linux/fs.h
> > index 5c1bf1c35bc6..9f90dcd4df3b 100644
> > --- a/include/linux/fs.h
> > +++ b/include/linux/fs.h
> > @@ -1725,8 +1725,10 @@ struct block_device_operations;
> >   * These flags control the behavior of the remap_file_range function pointer.
> >   *
> >   * RFR_IDENTICAL_DATA: only remap if contents identical (i.e. deduplicate)
> 
> <bikeshedding> not that I care so much, but is there any reason you chose
> to use _IDENTICAL_ vs. _SAME_? The latter is shorter and already engraved
> in the dedup uapi. </bikeshedding>

I picked 'identical' because it seemed (to me anyway) to hint that yes
we do memcmp the contents.  Some people I've met seem to use 'same' to
describe the much looser statement that hash(a) == hash(b), e.g.

  "We use crc32c to find out if the blocks are the same and then we of
   course do a byte by byte comparison to find out if they're really the
   same."

No, you're using crc32c to find block-match candidates and then memcmp
to decide if they're really identical. :)

Anyway, I suppose we already use 'same' elsewhere in the kernel to
describe this, so I should reduce the cognitive dissonance and use that
too.  Fixed.

> > + * RFR_TO_SRC_EOF: remap to the end of the source file
> >   */
> >  #define RFR_IDENTICAL_DATA     (1 << 0)
> > +#define RFR_TO_SRC_EOF         (1 << 1)
> >
> 
> So what is the best way to make sure that all filesystems can
> properly handle this flag? and the RFR_CAN_SHORTEN flag?
> 
> The way that your patches took is to not check for invalid flags
> at all in filesystems, but I don't think that is a viable option.

The RFR flags are internal APIs, so we don't need to be quite as strict
as fiemap does...

> Another way would be to individually add those flags to invalid
> flags check in all relevant filesystems.
> 
> Another way would be to follow a pattern similar to
> fiemap_check_flags(), except in case filesystem does not declare
> to support the RFR_ "advisory" flags, it will not fail the operation
> 
> Comparing to FIEMAP_ flags, no filesystem would have needed to declare
> support for FIEMAP_FLAG_SYNC, because vfs dealt with it anyway
> before calling into the filesystem. So de-facto, any filesystem supports
> FIEMAP_FLAG_SYNC without doing anything, but it is still worth passing
> the flag into filesystem in case it matter (it does for overlayfs).

...but I think you have a good point that we could help filesystem
writers distinguish between advisory flags that are taken care of by the
VFS but passed to the fs for full disclosure; and mandatory flags that
the fs for which the fs must advertise support.

IOWs,

int remap_check_flags(unsigned int remap_flags, unsigned int supported_flags)
{
	/* VFS already took care of these */
	remap_flags &= ~(RFR_TO_EOF | RFR_CAN_SHORTEN);

	if (remap_flags & ~supported_flags) {
		WARN_ONCE(1, "Internal API misuse at %pS", __return_address);
		return -EINVAL;
	}

	return 0;
}

> I am not sure if giving fiemap_check_flags() as an example for sorting
> out VFS API flags is a good idea, because I completely don't understand
> what is going on in ext4_fiemap(). Why do FIEMAP_FLAG_CACHE and
> the case of  !EXT4_INODE_EXTENTS bypass fiemap_check_flags()?

generic_block_fiemap calls fiemap_check_flags.

> Is there a rational behind all this or just plain old API bit rot?
> If bit rot, then perhaps the fiemap_check_flags() wasn't a good enough
> coding pattern?

Hooooo... I don't even want to get into what FIEMAP_FLAG_CACHE does in
ext4.

--D

> Thanks,
> Amir.

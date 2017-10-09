Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B448E6B025E
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 18:50:29 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id d28so9772658pfe.2
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 15:50:29 -0700 (PDT)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id d6si7113473pgn.192.2017.10.09.15.50.27
        for <linux-mm@kvack.org>;
        Mon, 09 Oct 2017 15:50:28 -0700 (PDT)
Date: Tue, 10 Oct 2017 09:50:25 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v7 06/12] xfs: wire up MAP_DIRECT
Message-ID: <20171009225025.GT3666@dastard>
References: <150732931273.22363.8436792888326501071.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150732934955.22363.14950885120988262779.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20171009034030.GH3666@dastard>
 <CAPcyv4i6WBxfVJ0yqWbuW2kiJ-wpi+iYRPk=Kykqt3U5Rrw7MA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4i6WBxfVJ0yqWbuW2kiJ-wpi+iYRPk=Kykqt3U5Rrw7MA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-xfs@vger.kernel.org, Jan Kara <jack@suse.cz>, Arnd Bergmann <arnd@arndb.de>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-rdma@vger.kernel.org, Linux API <linux-api@vger.kernel.org>, Christoph Hellwig <hch@lst.de>, "J. Bruce Fields" <bfields@fieldses.org>, Linux MM <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Jeff Layton <jlayton@poochiereds.net>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Mon, Oct 09, 2017 at 10:08:40AM -0700, Dan Williams wrote:
> On Sun, Oct 8, 2017 at 8:40 PM, Dave Chinner <david@fromorbit.com> wrote:
> >>
> >>  /*
> >>   * Clear the specified ranges to zero through either the pagecache or DAX.
> >> @@ -1008,6 +1018,26 @@ xfs_file_llseek(
> >>       return vfs_setpos(file, offset, inode->i_sb->s_maxbytes);
> >>  }
> >>
> >> +static int
> >> +xfs_vma_checks(
> >> +     struct vm_area_struct   *vma,
> >> +     struct inode            *inode)
> >
> > Exactly what are we checking for - function name doesn't tell me,
> > and there's no comments, either?
> 
> Ok, I'll improve this.
> 
> >
> >> +{
> >> +     if (!is_xfs_map_direct(vma))
> >> +             return 0;
> >> +
> >> +     if (!is_map_direct_valid(vma->vm_private_data))
> >> +             return VM_FAULT_SIGBUS;
> >> +
> >> +     if (xfs_is_reflink_inode(XFS_I(inode)))
> >> +             return VM_FAULT_SIGBUS;
> >> +
> >> +     if (!IS_DAX(inode))
> >> +             return VM_FAULT_SIGBUS;
> >
> > And how do we get is_xfs_map_direct() set to true if we don't have a
> > DAX inode or the inode has shared extents?
> 
> So, this was my way of trying to satisfy the request you made here:
> 
>     https://lkml.org/lkml/2017/8/11/876
> 
> i.e. allow MAP_DIRECT on non-dax files to enable a use case of
> freezing the block-map to examine which file extents are linked. If
> you don't want to use MAP_DIRECT for this, we can move these checks to
> mmap time.

Ok, but I don't want to use mmap to deal with this, nor do I care
whether DAX is in use or not. So I don't think this is really
necessary for MAP_DIRECT.


> >> +xfs_file_mmap_validate(
> >> +     struct file             *filp,
> >> +     struct vm_area_struct   *vma,
> >> +     unsigned long           map_flags,
> >> +     int                     fd)
> >> +{
> >> +     struct inode            *inode = file_inode(filp);
> >> +     struct xfs_inode        *ip = XFS_I(inode);
> >> +     struct map_direct_state *mds;
> >> +
> >> +     if (map_flags & ~(XFS_MAP_SUPPORTED))
> >> +             return -EOPNOTSUPP;
> >> +
> >> +     if ((map_flags & MAP_DIRECT) == 0)
> >> +             return xfs_file_mmap(filp, vma);
> >> +
> >> +     file_accessed(filp);
> >> +     vma->vm_ops = &xfs_file_vm_direct_ops;
> >> +     if (IS_DAX(inode))
> >> +             vma->vm_flags |= VM_MIXEDMAP | VM_HUGEPAGE;
> >
> > And if it isn't a DAX inode? what is MAP_DIRECT supposed to do then?
> 
> In the non-DAX case it just takes the FL_LAYOUT file lease... although
> we could also just have an fcntl for that purpose. The use case of
> just freezing the block map does not need a mapping.

RIght, so I think we should just add a fcntl for the non-DAX case I
have in mind, and not complicate the MAP_DIRECT implementation right
now.  We can alsways extend the scope of MAP_DIRECT in future if we
actually need to do so.

> >> +     mds = map_direct_register(fd, vma);
> >> +     if (IS_ERR(mds))
> >> +             return PTR_ERR(mds);
> >> +
> >> +     /* flush in-flight faults */
> >> +     xfs_ilock(ip, XFS_MMAPLOCK_EXCL);
> >> +     xfs_iunlock(ip, XFS_MMAPLOCK_EXCL);
> >
> > Urk. That's nasty. And why is it even necessary? Please explain why
> > this is necessary in the comment, because it's not at all obvious to
> > me...
> 
> This is related to your other observation about i_mapdcount and adding
> an iomap_can_allocate() helper. I think I can clean both of these up
> by using a call to break_layout(inode, false) and bailing in
> ->iomap_begin() if it returns EWOULDBLOCK. This would also fix the
> current problem that allocating write-faults don't start the lease
> break process.

OK.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

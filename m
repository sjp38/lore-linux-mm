Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id B84966B0003
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 01:42:43 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id d23-v6so26247584ywd.8
        for <linux-mm@kvack.org>; Sun, 21 Oct 2018 22:42:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p1-v6sor3681663ywl.171.2018.10.21.22.42.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 21 Oct 2018 22:42:41 -0700 (PDT)
MIME-Version: 1.0
References: <154013850285.29026.16168387526580596209.stgit@magnolia>
 <20181022022112.GW6311@dastard> <20181022043741.GX6311@dastard>
 <20181022045249.GP32577@ZenIV.linux.org.uk> <20181022050851.GY6311@dastard>
In-Reply-To: <20181022050851.GY6311@dastard>
From: Amir Goldstein <amir73il@gmail.com>
Date: Mon, 22 Oct 2018 08:42:29 +0300
Message-ID: <CAOQ4uxhjpieVdDfrATStT8YQZZwX=rrWtiMX=FSXFdHdqsUaDg@mail.gmail.com>
Subject: Re: [PATCH v6 00/28] fs: fixes for serious clone/dedupe problems
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, "Darrick J. Wong" <darrick.wong@oracle.com>, Eric Sandeen <sandeen@redhat.com>, Linux NFS Mailing List <linux-nfs@vger.kernel.org>, linux-cifs@vger.kernel.org, overlayfs <linux-unionfs@vger.kernel.org>, linux-xfs <linux-xfs@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Btrfs <linux-btrfs@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, ocfs2-devel@oss.oracle.com

On Mon, Oct 22, 2018 at 8:09 AM Dave Chinner <david@fromorbit.com> wrote:
>
> On Mon, Oct 22, 2018 at 05:52:49AM +0100, Al Viro wrote:
> > On Mon, Oct 22, 2018 at 03:37:41PM +1100, Dave Chinner wrote:
> >
> > > Ok, this is a bit of a mess. the patches do not merge cleanly to a
> > > 4.19-rc1 base kernel because of all the changes to
> > > include/linux/fs.h that have hit the tree after this. There's also
> > > failures against Documentation/filesystems/fs.h
> > >
> > > IOWs, it's not going to get merged through the main XFS tree because
> > > I don't have the patience to resolve all the patch application
> > > failures, then when it comes to merge make sure all the merge
> > > failures end up being resolved correctly.
> > >
> > > So if I take it through the XFS tree, it will being a standalone
> > > branch based on 4.19-rc8 and won't hit linux-next until after the
> > > first XFS merge when I can rebase the for-next branch...
> >
> > How many conflicts does it have with XFS tree?  I can take it via
> > vfs.git...
>
> I gave up after 4 of the first 6 or 7 patches had conflicts in vfs
> and documentation code.
>
> There were changes that went into 4.19-rc7 that changed
> {do|vfs}_clone_file_range() prototypes and this patchset hits
> prototypes adjacent to that multiple times. There's also a conflicts
> against a new f_ops->fadvise method. These all appear to be direct
> fallout of fixes needed for all the overlay f_ops changes.
>
> The XFS changes at the end of the patchset are based on
> commits that were merged into -rc7 and -rc8, so if you are using
> -rc8 as your base, then it all merges cleanly. There are no
> conflicts with the current xfs/for-next branch.
>
> I've just merged and built it into my test tree (-rc8, xfs/for-next,
> djwong/devel) so I can test it properly, but if it merges cleanly
> with the vfs tree you are building then that's probably the easiest
> way to merge it all...
>

Dave,

Pardon my ignorance, but its an opportunity for me to learn a thing
or two about kernel development process.

First, I asked Darrick to base his patches on top of -rc8 intentionally
to avoid the conflict with "swap names of {do|vfs}_clone_file_range()" (*).
My change pre dates his changes so it makes sense.

What I don't get is why does it need to create a problem?
Can you not back merge -rc8 into xfs/for-next (or into vfs/for-next for
that matter) and then merge Darrick's patches?

What is the culprit with doing that?

Thanks,
Amir.

(*) Yes, I do realize "swap names of {do|vfs}_clone_file_range()"
is a backporting landmine. It's been on my todo list to send it to Greg
here I am going to do it now...

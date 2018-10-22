Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id C780E6B0003
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 02:55:48 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id s24-v6so29642892plp.12
        for <linux-mm@kvack.org>; Sun, 21 Oct 2018 23:55:48 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id p1-v6si29987998plb.341.2018.10.21.23.55.46
        for <linux-mm@kvack.org>;
        Sun, 21 Oct 2018 23:55:47 -0700 (PDT)
Date: Mon, 22 Oct 2018 17:55:42 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v6 00/28] fs: fixes for serious clone/dedupe problems
Message-ID: <20181022065542.GZ6311@dastard>
References: <154013850285.29026.16168387526580596209.stgit@magnolia>
 <20181022022112.GW6311@dastard>
 <20181022043741.GX6311@dastard>
 <20181022045249.GP32577@ZenIV.linux.org.uk>
 <20181022050851.GY6311@dastard>
 <CAOQ4uxhjpieVdDfrATStT8YQZZwX=rrWtiMX=FSXFdHdqsUaDg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOQ4uxhjpieVdDfrATStT8YQZZwX=rrWtiMX=FSXFdHdqsUaDg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Amir Goldstein <amir73il@gmail.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, "Darrick J. Wong" <darrick.wong@oracle.com>, Eric Sandeen <sandeen@redhat.com>, Linux NFS Mailing List <linux-nfs@vger.kernel.org>, linux-cifs@vger.kernel.org, overlayfs <linux-unionfs@vger.kernel.org>, linux-xfs <linux-xfs@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Btrfs <linux-btrfs@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, ocfs2-devel@oss.oracle.com

On Mon, Oct 22, 2018 at 08:42:29AM +0300, Amir Goldstein wrote:
> On Mon, Oct 22, 2018 at 8:09 AM Dave Chinner <david@fromorbit.com> wrote:
> >
> > On Mon, Oct 22, 2018 at 05:52:49AM +0100, Al Viro wrote:
> > > On Mon, Oct 22, 2018 at 03:37:41PM +1100, Dave Chinner wrote:
> > >
> > > > Ok, this is a bit of a mess. the patches do not merge cleanly to a
> > > > 4.19-rc1 base kernel because of all the changes to
> > > > include/linux/fs.h that have hit the tree after this. There's also
> > > > failures against Documentation/filesystems/fs.h
> > > >
> > > > IOWs, it's not going to get merged through the main XFS tree because
> > > > I don't have the patience to resolve all the patch application
> > > > failures, then when it comes to merge make sure all the merge
> > > > failures end up being resolved correctly.
> > > >
> > > > So if I take it through the XFS tree, it will being a standalone
> > > > branch based on 4.19-rc8 and won't hit linux-next until after the
> > > > first XFS merge when I can rebase the for-next branch...
> > >
> > > How many conflicts does it have with XFS tree?  I can take it via
> > > vfs.git...
> >
> > I gave up after 4 of the first 6 or 7 patches had conflicts in vfs
> > and documentation code.
> >
> > There were changes that went into 4.19-rc7 that changed
> > {do|vfs}_clone_file_range() prototypes and this patchset hits
> > prototypes adjacent to that multiple times. There's also a conflicts
> > against a new f_ops->fadvise method. These all appear to be direct
> > fallout of fixes needed for all the overlay f_ops changes.
> >
> > The XFS changes at the end of the patchset are based on
> > commits that were merged into -rc7 and -rc8, so if you are using
> > -rc8 as your base, then it all merges cleanly. There are no
> > conflicts with the current xfs/for-next branch.
> >
> > I've just merged and built it into my test tree (-rc8, xfs/for-next,
> > djwong/devel) so I can test it properly, but if it merges cleanly
> > with the vfs tree you are building then that's probably the easiest
> > way to merge it all...
> >
> 
> Dave,
> 
> Pardon my ignorance, but its an opportunity for me to learn a thing
> or two about kernel development process.
> 
> First, I asked Darrick to base his patches on top of -rc8 intentionally
> to avoid the conflict with "swap names of {do|vfs}_clone_file_range()" (*).
> My change pre dates his changes so it makes sense.

Actually, I asked him to do that because the critical clone/dedupe
data corruption bug fixes for XFS that were merged into -rc8. They
created substantial conflicts with the XFS code being
rearranged in the patch set, and that wasn't something easy to
resolve.

But because those XFS commits in 4.19-rc8 are from a stable in a
topic branch in the xfs tree (xfs-4.19-fixes-1) which is merged into
the for-next tree before anything else, the XFS changes in Darrick's
patchset merge cleanly with the XFS for-next branch.

What doesn't merge cleanly is all the VFS API and prototype stuff
that got changed after -rc1 because it's not in the master branch of
the xfs dev tree.

> What I don't get is why does it need to create a problem?
> Can you not back merge -rc8 into xfs/for-next (or into vfs/for-next for
> that matter) and then merge Darrick's patches?

Because it forces everyone to move their base kernel forward to test
the latest fixes. i.e. i forces everyone to rebase their local dev
trees to -rc8 regardless of whether they want to or not.

If you're doing work outside the XFS tree, then that forces you to
rebase everything you are working on, not just modify your XFS
patches that are affected by the new XFS changes. it also breaks the
concept of having a baseline for regression tests - force upgrading
to -rc8 breaks the baseline for comparing just XFS changes.

The other reason is topic branches. They need to have a stable base.
i.e. all your topic branches that get merged in need to be on the
same base commit so they can be merged and rearranged without
problems or having to rewrite commits. The for-next tree can move
forward on a rebase with topic branches if necessary, but  it has
downsides for downstream developers.

For example, I can do:

git reset --hard v4.19-rc8
git am djw-clone-dedupe-rework

and have it apply cleanly. But I can't turn that into a topic branch
for merge into linux-xfs/for-next because it's not based on the
correct branch.  i.e. I need to do this to create a topic branch for
for-next merge:

git reset --hard linux-xfs/master
git merge linux-xfs/xfs-4.19-fixes-1
git am djw-clone-dedupe-rework
{rejects galore}

I can fix all the rejectsi (boring, tedious, time consuming), but
then when I go to merge it back into a 4.19-rc8 kernel like so:

git reset --hard v4.19-rc8
git merge linux-xfs/vfs-4.20-clone-dedupe-rework
[conflicts!]

I essentially have to revert all of the conflict resolution I just
did to get it into ithe XFS topic branch. And those conflicts will
need to be resolved in the upstream merge, too, and by every XFS
developer who changes their base kernel to >=4.19-rc7.

IOWs, there's downsides everywhere. Yes, we could rebase the entire
tree on 4.19-rc8, but Linus *really* didn't like dev trees to be
rebased to a late -rcX just to clean up merge issues like this. He
wanted to see the development history of the code he was asked to
pull and wanted to see merge conflicts and resolve them himself so
he knew who and what was causing problems when merging code. That
way he nkew in future what changes to allow late in -rcX releases
and what to defer to after the next merge window.

Co-ordination between tree is important - high level API changes are
exactly the sort of thing that causes dev tree merge pain late in a
dev cycle. Hence this sort of thing is best done immediately after
-rc1 when everyone is getting ready to rebase and start their next
dev cycle and nobody is really affected by the API change.

So, historically speaking, I've done things this way because that's
how Linus wanted them done to make life easier for both himself and
everyone who manages a dev tree.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

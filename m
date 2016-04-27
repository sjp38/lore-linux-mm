Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f198.google.com (mail-ig0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id EB1716B007E
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 18:55:19 -0400 (EDT)
Received: by mail-ig0-f198.google.com with SMTP id z8so130800718igl.3
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 15:55:19 -0700 (PDT)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id f8si32438059igp.61.2016.04.27.15.55.18
        for <linux-mm@kvack.org>;
        Wed, 27 Apr 2016 15:55:19 -0700 (PDT)
Date: Thu, 28 Apr 2016 08:55:14 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 2/2] mm, debug: report when GFP_NO{FS,IO} is used
 explicitly from memalloc_no{fs,io}_{save,restore} context
Message-ID: <20160427225514.GJ26977@dastard>
References: <1461671772-1269-1-git-send-email-mhocko@kernel.org>
 <1461671772-1269-3-git-send-email-mhocko@kernel.org>
 <20160426225845.GF26977@dastard>
 <20160427080311.GC2179@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160427080311.GC2179@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>

On Wed, Apr 27, 2016 at 10:03:11AM +0200, Michal Hocko wrote:
> On Wed 27-04-16 08:58:45, Dave Chinner wrote:
> > On Tue, Apr 26, 2016 at 01:56:12PM +0200, Michal Hocko wrote:
> > > From: Michal Hocko <mhocko@suse.com>
> > > 
> > > THIS PATCH IS FOR TESTING ONLY AND NOT MEANT TO HIT LINUS TREE
> > > 
> > > It is desirable to reduce the direct GFP_NO{FS,IO} usage at minimum and
> > > prefer scope usage defined by memalloc_no{fs,io}_{save,restore} API.
> > > 
> > > Let's help this process and add a debugging tool to catch when an
> > > explicit allocation request for GFP_NO{FS,IO} is done from the scope
> > > context. The printed stacktrace should help to identify the caller
> > > and evaluate whether it can be changed to use a wider context or whether
> > > it is called from another potentially dangerous context which needs
> > > a scope protection as well.
> > 
> > You're going to get a large number of these from XFS. There are call
> > paths in XFs that get called both inside and outside transaction
> > context, and many of them are marked with GFP_NOFS to prevent issues
> > that have cropped up in the past.
> > 
> > Often these are to silence lockdep warnings (e.g. commit b17cb36
> > ("xfs: fix missing KM_NOFS tags to keep lockdep happy")) because
> > lockdep gets very unhappy about the same functions being called with
> > different reclaim contexts. e.g.  directory block mapping might
> > occur from readdir (no transaction context) or within transactions
> > (create/unlink). hence paths like this are tagged with GFP_NOFS to
> > stop lockdep emitting false positive warnings....
> 
> I would much rather see lockdep being fixed than abusing GFP_NOFS to
> workaround its limitations. GFP_NOFS has a real consequences to the
> memory reclaim. I will go and check the commit you mentioned and try
> to understand why that is a problem. From what you described above
> I would like to get rid of exactly this kind of usage which is not
> really needed for the recursion protection.

The problem is that every time we come across this, the answer is
"use lockdep annotations". Our lockdep annotations are freakin'
complex because of this, and more often than not lockdep false
positives occur due to bugs in the annotations. e.g. see
fs/xfs/xfs_inode.h for all the inode locking annotations we have to
use and the hoops we have to jump through because we are limited to
8 subclasses and we have to be able to annotate nested inode locks
5 deep in places (RENAME_WHITEOUT, thanks).

At one point, we had to reset lockdep classes for inodes in reclaim
so that they didn't throw lockdep false positives the moment an
inode was locked in a memory reclaim context. We had to change
locking to remove that problem (commit 4f59af7 ("xfs: remove iolock
lock classes"). Then there were all the problems with reclaim
triggering lockdep warnings on directory inodes - we had to add a
separate directory inode class for them, and even then we still need
GFP_NOFS in places to minimise reclaim noise (as per the above
commit).

Put simply: we've had to resort to designing locking and allocation
strategies around the limitations of lockdep annotations, as opposed
to what is actually possible or even optimal. i.e. when the choice
is a 2 minute fix to add GFP_NOFS in cases like this, versus another
week long effort to rewrite the inode annotations (again) like this
one last year:

commit 0952c8183c1575a78dc416b5e168987ff98728bb
Author: Dave Chinner <dchinner@redhat.com>
Date:   Wed Aug 19 10:32:49 2015 +1000

    xfs: clean up inode lockdep annotations
    
    Lockdep annotations are a maintenance nightmare. Locking has to be
    modified to suit the limitations of the annotations, and we're
    always having to fix the annotations because they are unable to
    express the complexity of locking heirarchies correctly.
.....

It's a no-brainer to see why GFP_NOFS will be added to the
allocation in question. I've been saying for years that I consider
lockdep harmful - if you want to get rid of GFP_NOFS, then you're
going to need to sort out the lockdep reclaim annotation mess at the
same time...

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

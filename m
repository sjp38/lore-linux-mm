Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0C6AF6B007E
	for <linux-mm@kvack.org>; Fri, 29 Apr 2016 20:24:29 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id vv3so193824497pab.2
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 17:24:29 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id b1si24381971pax.45.2016.04.29.17.24.27
        for <linux-mm@kvack.org>;
        Fri, 29 Apr 2016 17:24:28 -0700 (PDT)
Date: Sat, 30 Apr 2016 10:24:18 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 0/2] scop GFP_NOFS api
Message-ID: <20160430002418.GP26977@dastard>
References: <1461671772-1269-1-git-send-email-mhocko@kernel.org>
 <8737q5ugcx.fsf@notabene.neil.brown.name>
 <20160429120418.GK21977@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160429120418.GK21977@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: NeilBrown <mr@neil.brown.name>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>

On Fri, Apr 29, 2016 at 02:04:18PM +0200, Michal Hocko wrote:
> I would also like to revisit generic inode/dentry shrinker and see
> whether it could be more __GFP_FS friendly. As you say many FS might
> even not depend on some FS internal locks so pushing GFP_FS check down
> the layers might make a lot of sense and allow to clean some [id]cache
> even for __GFP_FS context.

That's precisely my point about passing a context to the shrinker.
It's recursion within a single superblock context that makes up the
majority of cases GFP_NOFS is used for, so passing the superblock
immediately allows for reclaim to run the superblock shrinker on
every other superblock.

We can refine it further from there, but I strongly suspect that
further refinement is going to require filesystems to specifically
configure the superblock shrinker.

e.g. in XFS, we can't allow evict() even on clean VFS inodes in a
PF_FSTRANS context, because we may run a transaction on a clean
VFS inode to prepare it for reclaim.  We can, however,
allow the fs-specific shrinker callouts to run (i.e. call into
.free_cached_objects) so that it can reclaim clean XFS inodes
because that doesn't require transactions....

i.e. the infrastructure I suggested we use is aimed directly at
providing the mechanism required for finer-grained inode/dentry
cache reclaim in contexts that it is currently disallowed
completely. I was also implying that once the infrastructure to pass
contexts is in place, I'd then make the changes to the generic
superblock shrinker code to enable finer grained reclaim and
optimise the XFS shrinkers to make use of it...

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

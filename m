Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 6AA906B0070
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 02:25:24 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id lj1so10538673pab.36
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 23:25:24 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:6])
        by mx.google.com with ESMTP id wh4si12112368pbc.90.2014.04.15.23.25.22
        for <linux-mm@kvack.org>;
        Tue, 15 Apr 2014 23:25:23 -0700 (PDT)
Date: Wed, 16 Apr 2014 16:25:20 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 16/19] VFS: use GFP_NOFS rather than GFP_KERNEL in
 __d_alloc.
Message-ID: <20140416062520.GG15995@dastard>
References: <20140416033623.10604.69237.stgit@notabene.brown>
 <20140416040337.10604.61837.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140416040337.10604.61837.stgit@notabene.brown>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.de>
Cc: linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, xfs@oss.sgi.com

On Wed, Apr 16, 2014 at 02:03:37PM +1000, NeilBrown wrote:
> __d_alloc can be called with i_mutex held, so it is safer to
> use GFP_NOFS.
> 
> lockdep reports this can deadlock when loop-back NFS is in use,
> as nfsd may be required to write out for reclaim, and nfsd certainly
> takes i_mutex.

But not the same i_mutex as is currently held. To me, this seems
like a false positive? If you are holding the i_mutex on an inode,
then you have a reference to the inode and hence memory reclaim
won't ever take the i_mutex on that inode.

FWIW, this sort of false positive was a long stabding problem for
XFS - we managed to get rid of most of the false positives like this
by ensuring that only the ilock is taken within memory reclaim and
memory reclaim can't be entered while we hold the ilock.

You can't do that with the i_mutex, though....

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

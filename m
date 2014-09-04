Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id C47C76B0038
	for <linux-mm@kvack.org>; Thu,  4 Sep 2014 05:05:55 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id fp1so13253418pdb.40
        for <linux-mm@kvack.org>; Thu, 04 Sep 2014 02:05:53 -0700 (PDT)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id bt7si2398792pdb.103.2014.09.04.02.05.37
        for <linux-mm@kvack.org>;
        Thu, 04 Sep 2014 02:05:39 -0700 (PDT)
Date: Thu, 4 Sep 2014 19:05:12 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] mm: clear __GFP_FS when PF_MEMALLOC_NOIO is set
Message-ID: <20140904090512.GL20473@dastard>
References: <1409723694-16047-1-git-send-email-junxiao.bi@oracle.com>
 <20140903161000.f383fa4c1a4086de054cb6a0@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140903161000.f383fa4c1a4086de054cb6a0@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Junxiao Bi <junxiao.bi@oracle.com>, xuejiufei@huawei.com, ming.lei@canonical.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Wed, Sep 03, 2014 at 04:10:00PM -0700, Andrew Morton wrote:
> On Wed,  3 Sep 2014 13:54:54 +0800 Junxiao Bi <junxiao.bi@oracle.com> wrote:
> 
> > commit 21caf2fc1931 ("mm: teach mm by current context info to not do I/O during memory allocation")
> > introduces PF_MEMALLOC_NOIO flag to avoid doing I/O inside memory allocation, __GFP_IO is cleared
> > when this flag is set, but __GFP_FS implies __GFP_IO, it should also be cleared. Or it may still
> > run into I/O, like in superblock shrinker.
> 
> Is there an actual bug which inspired this fix?  If so, please describe
> it.
> 
> I don't think it's accurate to say that __GFP_FS implies __GFP_IO. 
> Where did that info come from?

Pretty damn clear to me:

#define GFP_ATOMIC      (__GFP_HIGH)
#define GFP_NOIO        (__GFP_WAIT)
#define GFP_NOFS        (__GFP_WAIT | __GFP_IO)
#define GFP_KERNEL      (__GFP_WAIT | __GFP_IO | __GFP_FS)

especially when you consider the layering of the subsystems that use
these contexts. i.e. KERNEL on top of FS on top of IO on top of
ATOMIC....

IOWs, asking for (__GFP_WAIT | __GFP_FS) reclaim context is
something outside the defined reclaim heirarchy. Filesystems
*depend* on being about to do IO to perform recalim of dirty
objects, whether it be the page cache, inode cache or any other
filesystem cache that can hold dirty objects.

> And the superblock shrinker is a good example of why this shouldn't be
> the case.  The main thing that code does is to reclaim clean fs objects
> without performing IO.

Filesystem shrinkers do indeed perform IO from the superblock
shrinker and have for years. Even clean inodes can require IO before
they can be freed - e.g. on an orphan list, need truncation of
post-eof blocks, need to wait for ordered operations to complete
before it can be freed, etc.

IOWs, Ext4, btrfs and XFS all can issue and/or block on
arbitrary amounts of IO in the superblock shrinker context. XFS, in
particular, has been doing transactions and IO from the VFS inode
cache shrinker since it was first introduced....

> AFAICT the proposed patch will significantly
> weaken PF_MEMALLOC_NOIO allocation attempts by needlessly preventing
> the kernel from reclaiming such objects?

PF_MEMALLOC_NOIO is the anomolous case. It also has very few users,
who all happen to be working around very rare deadlocks caused by
vmalloc() hard coding GFP_KERNEL allocations deep in it's stack. So
the impact of fixing this anomoly is going to be completely
unnoticable...

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

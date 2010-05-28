Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 974516B01B6
	for <linux-mm@kvack.org>; Fri, 28 May 2010 03:44:38 -0400 (EDT)
Subject: Re: [PATCH 0/5] Per superblock shrinkers V2
From: Artem Bityutskiy <dedekind1@gmail.com>
Reply-To: dedekind1@gmail.com
In-Reply-To: <20100527133223.efa4740a.akpm@linux-foundation.org>
References: <1274777588-21494-1-git-send-email-david@fromorbit.com>
	 <20100527133223.efa4740a.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 28 May 2010 10:42:06 +0300
Message-ID: <1275032526.15516.83.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com
List-ID: <linux-mm.kvack.org>

On Thu, 2010-05-27 at 13:32 -0700, Andrew Morton wrote:
> On Tue, 25 May 2010 18:53:03 +1000
> Dave Chinner <david@fromorbit.com> wrote:
> 
> > This series reworks the filesystem shrinkers. We currently have a
> > set of issues with the current filesystem shrinkers:
> > 
> >         1. There is an dependency between dentry and inode cache
> >            shrinking that is only implicitly defined by the order of
> >            shrinker registration.
> >         2. The shrinkers need to walk the superblock list and pin
> >            the superblock to avoid unmount races with the sb going
> >            away.
> >         3. The dentry cache uses per-superblock LRUs and proportions
> >            reclaim between all the superblocks which means we are
> >            doing breadth based reclaim. This means we touch every
> >            superblock for every shrinker call, and may only reclaim
> >            a single dentry at a time from a given superblock.
> >         4. The inode cache has a global LRU, so it has different
> >            reclaim patterns to the dentry cache, despite the fact
> >            that the dentry cache is generally the only thing that
> >            pins inodes in memory.
> >         5. Filesystems need to register their own shrinkers for
> >            caches and can't co-ordinate them with the dentry and
> >            inode cache shrinkers.
> 
> Nice description, but...  it never actually told us what the benefit of
> the changes are.  Presumably some undescribed workload had some
> undescribed user-visible problem.  But what was that workload, and what
> was the user-visible problem, and how does the patch affect all this?

For UBIFS it wwill give a benefit in terms of simpler UBIFS code - we
now have to keep our own list of UBIFS superblocks, provide locking for
it, and maintain. This is just extra burden. So the item 2 above will be
useful for UBIFS.

-- 
Best Regards,
Artem Bityutskiy (D?N?N?N?D 1/4  D?D,N?N?N?DoD,D1)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-gg0-f179.google.com (mail-gg0-f179.google.com [209.85.161.179])
	by kanga.kvack.org (Postfix) with ESMTP id 9A0246B0031
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 19:22:21 -0500 (EST)
Received: by mail-gg0-f179.google.com with SMTP id e5so311333ggh.24
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 16:22:21 -0800 (PST)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:5])
        by mx.google.com with ESMTP id e3si2785407yhj.111.2014.01.14.16.22.19
        for <linux-mm@kvack.org>;
        Tue, 14 Jan 2014 16:22:20 -0800 (PST)
Date: Wed, 15 Jan 2014 11:22:15 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 2/3] Add shrink_pagecache_parent
Message-ID: <20140115002215.GP3469@dastard>
References: <cover.1388409686.git.liwang@ubuntukylin.com>
 <249cbd3edaa84dd58a0626780fb546ddf7c1dc11.1388409687.git.liwang@ubuntukylin.com>
 <20140102155534.9b0cd498209d835d0c93837e@linux-foundation.org>
 <52CCB2A7.2000300@ubuntukylin.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52CCB2A7.2000300@ubuntukylin.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Wang <liwang@ubuntukylin.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Cong Wang <xiyou.wangcong@gmail.com>, Zefan Li <lizefan@huawei.com>, Matthew Wilcox <matthew@wil.cx>, Yunchuan Wen <yunchuanwen@ubuntukylin.com>

On Wed, Jan 08, 2014 at 10:06:31AM +0800, Li Wang wrote:
> Hi,
> 
> On 01/03/2014 07:55 AM, Andrew Morton wrote:
> >On Mon, 30 Dec 2013 21:45:17 +0800 Li Wang <liwang@ubuntukylin.com> wrote:
> >
> >>Analogous to shrink_dcache_parent except that it collects inodes.
> >>It is not very appropriate to be put in dcache.c, but d_walk can only
> >>be invoked from here.
> >However...  most inodes will be on an LRU list, won't they?  Doesn't
> >this reuse of i_lru mean that many inodes will fail to be processed?
> >If so, we might need to add a new list_head to the inode, which will be
> >problematic.
> >
> As far as I know, fix me if i am wrong, only when inode has zero
> reference count, it will be put into superblock lru list. For most
> situations, there is at least a dentry refers to it, so it will not
> be on any lru list.

Yes, that's when they get added to the LRU, but they don't get
removed if they are referenced again by a dentry. Hence dentries can
be reclaimed, which puts the inode on it's LRU, but then the
directory is read again and a new dentry allocated to point to it.
We do not remove the inode from the LRU at this point in time.
Hence you can have referenced inodes that are on the LRU, and in
many workloads most of the referenced inodes in the system are on
the LRU....

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

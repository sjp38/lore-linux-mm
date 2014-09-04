Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 2BE5D6B0035
	for <linux-mm@kvack.org>; Thu,  4 Sep 2014 05:22:00 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id fp1so13121312pdb.13
        for <linux-mm@kvack.org>; Thu, 04 Sep 2014 02:21:58 -0700 (PDT)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id fi2si2419240pad.144.2014.09.04.02.21.45
        for <linux-mm@kvack.org>;
        Thu, 04 Sep 2014 02:21:46 -0700 (PDT)
Date: Thu, 4 Sep 2014 19:21:31 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] mm: clear __GFP_FS when PF_MEMALLOC_NOIO is set
Message-ID: <20140904092131.GM20473@dastard>
References: <1409723694-16047-1-git-send-email-junxiao.bi@oracle.com>
 <20140903161000.f383fa4c1a4086de054cb6a0@linux-foundation.org>
 <5407C989.50605@oracle.com>
 <20140903193058.2bc891a7.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140903193058.2bc891a7.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Junxiao Bi <junxiao.bi@oracle.com>, xuejiufei@huawei.com, ming.lei@canonical.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Wed, Sep 03, 2014 at 07:30:58PM -0700, Andrew Morton wrote:
> > PF_MEMALLOC_NOIO is only set for some special processes. I think it
> > won't affect much.
> 
> Maybe not now.  But once we add hacks like this, people say "goody" and
> go and use them rather than exerting the effort to sort out their
> deadlocks properly :( There will be more PF_MEMALLOC_NOIO users in
> 2019.

We got PF_MEMALLOC_NOIO because we failed to get vmalloc deadlocks
fixed. The reason vmalloc didn't get fixed?

"there will be more vmalloc users".

> Dunno, I'd like to hear David's thoughts but perhaps it would be better
> to find some way to continue to permit PF_MEMALLOC_NOIO to shrink VFS
> caches for most filesystems and find some fs-specific fix for ocfs2. 
> That would mean testing PF_MEMALLOC_NOIO directly I guess.

No special flags in the superblock shrinker, please. We have tens of
other filesystem shrinkers that might be impacted, too. If we do not
want filesystem shrinkers (note the plural) to run, the
shrink_control->gfp_mask needs to have __GFP_FS cleared from it when
it is first configured and so that context is constant across all
shrinker reclaim cases.

If you're really worried by changing PF_MEMALLOC_NOIO, then we can
introduce PF_MEMALLOC_NOFS and have the mm subsystem mask both flags
appropriately when setting the gfp_mask in the shrink_control
settings. But fundamentally, our reclaim heirarchy defines that NOIO
implies NOFS, and so we need to fix PF_MEMALLOC_NOIO anyway.

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

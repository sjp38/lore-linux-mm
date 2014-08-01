Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id A853C6B0038
	for <linux-mm@kvack.org>; Fri,  1 Aug 2014 05:57:05 -0400 (EDT)
Received: by mail-wg0-f41.google.com with SMTP id z12so4128300wgg.24
        for <linux-mm@kvack.org>; Fri, 01 Aug 2014 02:57:05 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id vv7si17337081wjc.156.2014.08.01.02.57.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 01 Aug 2014 02:57:03 -0700 (PDT)
Date: Fri, 1 Aug 2014 11:57:00 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 0/2] new API to allocate buffer-cache for superblock in
 non-movable area
Message-ID: <20140801095700.GB27281@quack.suse.cz>
References: <20140722073005.GT3935@laptop>
 <20140722093838.GA22331@quack.suse.cz>
 <53D8A258.7010904@lge.com>
 <20140730101143.GB19205@quack.suse.cz>
 <53D985C0.3070300@lge.com>
 <20140731000355.GB25362@quack.suse.cz>
 <53D98FBB.6060700@lge.com>
 <20140731122114.GA5240@quack.suse.cz>
 <53DADA2F.1020404@lge.com>
 <53DAE820.7050508@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53DAE820.7050508@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>
Cc: Jan Kara <jack@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <js1304@gmail.com>

On Fri 01-08-14 10:06:40, Gioh Kim wrote:
> Function path is like followings:
> 
> [   97.868304] [<8011a750>] (drop_buffers+0xfc/0x168) from [<8011bc64>] (try_to_free_buffers+0x50/0xbc)
> [   97.877457] [<8011bc64>] (try_to_free_buffers+0x50/0xbc) from [<80121e40>] (blkdev_releasepage+0x38/0x48)
> [   97.887093] [<80121e40>] (blkdev_releasepage+0x38/0x48) from [<800add8c>] (try_to_release_page+0x40/0x5c)
> [   97.896728] [<800add8c>] (try_to_release_page+0x40/0x5c) from [<800bd9bc>] (shrink_page_list+0x508/0x8a4)
> [   97.906334] [<800bd9bc>] (shrink_page_list+0x508/0x8a4) from [<800bde5c>] (reclaim_clean_pages_from_list+0x104/0x148)
> [   97.917017] [<800bde5c>] (reclaim_clean_pages_from_list+0x104/0x148) from [<800b5dec>] (alloc_contig_range+0x114/0x2dc)
> [   97.927856] [<800b5dec>] (alloc_contig_range+0x114/0x2dc) from [<802f6c04>] (dma_alloc_from_contiguous+0x8c/0x14c)
> [   97.938264] [<802f6c04>] (dma_alloc_from_contiguous+0x8c/0x14c) from [<80017b6c>] (__alloc_from_contiguous+0x34/0xc0)
> [   97.948926] [<80017b6c>] (__alloc_from_contiguous+0x34/0xc0) from [<80017d40>] (__dma_alloc+0xc4/0x2a0)
> [   97.958362] [<80017d40>] (__dma_alloc+0xc4/0x2a0) from [<8001803c>] (arm_dma_alloc+0x80/0x98)
> [   97.966916] [<8001803c>] (arm_dma_alloc+0x80/0x98) from [<7f6ea188>] (cma_test_probe+0xe0/0x1f0 [drv])
  OK, this makes more sense to me. But also as Joonsoo Kim pointed out
even if we go into the migration path, we will end up calling
try_to_free_buffers() because blkdev pages are one of those which use
fallback_migrate_page() as their ->migratepage callback.

Now regarding your quest to make all pages in the movable zone really
movable - you are going to have hard time to achieve that for blkdev pages.
E.g. when a metadata buffer is part of a running transaction, it will be
pinned in memory until that transaction commits which easily takes seconds.
And for busy metadata buffer there's no guarantee that after that
transaction commits the buffer isn't already part of the newly started
transaction. So these buffers may be effectively unmovable while someone
writes to the filesystem.

So the quiestion really is how hard guarantee do you need that a page in
movable zone is really movable. Or better in what timeframe should it be
movable? It may be possible to make e.g. migratepage callback for ext4
blkdev pages which will handle migration of pages that are just idly
sitting in a journal waiting to be committed. That may be reasonably doable
although it won't be perfect. Or we may just decide it's not worth the
bother and allocate all blkdev pages from unmovable zone...

								Honza

-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

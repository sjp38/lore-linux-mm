Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id A6ABD6B006C
	for <linux-mm@kvack.org>; Thu,  8 Jan 2015 04:31:03 -0500 (EST)
Received: by mail-lb0-f180.google.com with SMTP id l4so1856741lbv.11
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 01:31:02 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q13si6957878laa.27.2015.01.08.01.31.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 08 Jan 2015 01:31:02 -0800 (PST)
Date: Thu, 8 Jan 2015 10:30:57 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCHSET RFC block/for-next] writeback: cgroup writeback support
Message-ID: <20150108093057.GD14705@quack.suse.cz>
References: <1420579582-8516-1-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1420579582-8516-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com

  Hello,

On Tue 06-01-15 16:25:37, Tejun Heo wrote:
> blkio cgroup (blkcg) is severely crippled in that it can only control
> read and direct write IOs.  blkcg can't tell which cgroup should be
> held responsible for a given writeback IO and charges all of them to
> the root cgroup - all normal write traffic ends up in the root cgroup.
> Although the problem has been identified years ago, mainly because it
> interacts with so many subsystems, it hasn't been solved yet.
> 
> This patchset finally implements cgroup writeback support so that
> writeback of a page is attributed to the corresponding blkcg of the
> memcg that the page belongs to.
> 
> Overall design
> --------------
> 
> * This requires cooperation between memcg and blkcg.  The IOs are
>   charged to the blkcg that the page's memcg corresponds to.  This
>   currently works only on the unified hierarchy.
> 
> * Each memcg maintains reference counted front and back pointers to
>   the correspending blkcg.  Whenever a page gets dirtied or initiates
>   writeback, it uses the blkcg the front one points to.  The reference
>   counting ensures that the association remains till the page is done
>   and having front and back pointers guarantees that the association
>   can change without being live-locked by pages being contiuously
>   dirtied.
> 
> * struct bdi_writeback (wb) was always embedded in struct
>   backing_dev_info (bdi) and the distinction between the two wasn't
>   clear.  This patchset makes wb operate as an independent writeback
> 
>   execution.  bdi->wb is still embedded and serves the root cgroup but
>   other wb's can be associated with a single bdi each serving a
>   non-root wb.
> 
> * All writeback operations are made per-wb instead of per-bdi.
>   bdi-wide operations are split across all member wb's.  If some
>   finite amount needs to be distributed, be it number of pages to
>   writeback or bdi->min/max_ratio, it's distributed according to the
>   bandwidth proportion a wb has in the bdi.
> 
> * Non-root wb's host and write back only dirty pages (I_DIRTY_PAGES).
>   I_DIRTY_[DATA]SYNC is always handled by the root wb.
> 
> * An inode may have pages dirtied by different memcgs, which naturally
>   means that it should be able to be dirtied against multiple wb's.
>   To support linking an inode against multiple wb's, iwbl
>   (inode_wb_link) is introduced.  An inode has multiple iwbl's
>   associated with it if it's dirty against multiple wb's.
  Is the ability for inode to belong to multiple memcgs really worth the
effort? It brings significant complications (see also Dave's email) and
the last time we were discussing cgroup writeback support the demand from
users for this was small... How hard would it be to just start with an
implementation which attaches the inode to the first memcg that dirties it
(and detaches it when inode gets clean)? And implement sharing of inodes
among mecgs only if there's a real demand for it?

								Honza

-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

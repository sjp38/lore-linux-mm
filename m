Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id D97D98E0001
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 09:49:10 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id c34so8824768edb.8
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 06:49:10 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e3si1638479edj.200.2018.12.17.06.49.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 06:49:09 -0800 (PST)
Date: Mon, 17 Dec 2018 15:49:08 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] squashfs: enable __GFP_FS in ->readpage to prevent hang
 in mem alloc
Message-ID: <20181217144908.GQ30879@dhcp22.suse.cz>
References: <20181204020840.49576-1-houtao1@huawei.com>
 <20181215143824.GJ10600@bombadil.infradead.org>
 <69457a5a-79c9-4950-37ae-eff7fa4f949a@huawei.com>
 <20181217035157.GK10600@bombadil.infradead.org>
 <20181217093337.GC30879@dhcp22.suse.cz>
 <00ff5d2d-a50f-4730-db8a-cea3d7a3eef7@I-love.SAKURA.ne.jp>
 <20181217122546.GL10600@bombadil.infradead.org>
 <20181217141044.GP30879@dhcp22.suse.cz>
 <20181217144101.GN10600@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181217144101.GN10600@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Hou Tao <houtao1@huawei.com>, phillip@squashfs.org.uk, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon 17-12-18 06:41:01, Matthew Wilcox wrote:
> On Mon, Dec 17, 2018 at 03:10:44PM +0100, Michal Hocko wrote:
> > On Mon 17-12-18 04:25:46, Matthew Wilcox wrote:
> > > It's worth noticing that squashfs _is_ in fact holding a page locked in
> > > squashfs_copy_cache() when it calls grab_cache_page_nowait().  I'm not
> > > sure if this will lead to trouble or not because I'm insufficiently
> > > familiar with the reclaim path.
> > 
> > Hmm, this is more interesting then. If there is any memcg accounted
> > allocation down that path _and_ the squashfs writeout can lock more
> > pages and mark them writeback before they are really sent to the storage
> > then we have a problem. See [1]
> > 
> > [1] http://lkml.kernel.org/r/20181213092221.27270-1-mhocko@kernel.org
> 
> Squashfs is read only, so it'll never have dirty pages and never do
> writeout.
> 
> But ... maybe the GFP flags being used for grab_cache_page_nowait() are
> wrong.  It does, after all, say "nowait".  Perhaps it shouldn't be trying
> direct reclaim at all, but rather fail earlier.  Like this:
> 
> +++ b/mm/filemap.c
> @@ -1550,6 +1550,8 @@ struct page *pagecache_get_page(struct address_space *mapping, pgoff_t offset,
>                         gfp_mask |= __GFP_WRITE;
>                 if (fgp_flags & FGP_NOFS)
>                         gfp_mask &= ~__GFP_FS;
> +               if (fgp_flags & FGP_NOWAIT)
> +                       gfp_mask &= ~__GFP_DIRECT_RECLAIM;
>  
>                 page = __page_cache_alloc(gfp_mask);
>                 if (!page)

Isn't FGP_NOWAIT about page lock rather than the allocation context?

-- 
Michal Hocko
SUSE Labs

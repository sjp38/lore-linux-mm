Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4F8306B0007
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 06:28:49 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id u11-v6so7323680pls.22
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 03:28:49 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e12si893170pgt.208.2018.04.10.03.28.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 Apr 2018 03:28:48 -0700 (PDT)
Date: Tue, 10 Apr 2018 12:28:45 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm: workingset: fix NULL ptr dereference
Message-ID: <20180410102845.3ixg2lbnumqn2o6z@quack2.suse.cz>
References: <20180409015815.235943-1-minchan@kernel.org>
 <20180410082243.GW21835@dhcp22.suse.cz>
 <20180410085531.m2xvzi7nenbrgbve@quack2.suse.cz>
 <20180410093241.GA21835@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180410093241.GA21835@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Jan Kara <jack@suse.cz>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Chris Fries <cfries@google.com>

On Tue 10-04-18 11:32:41, Michal Hocko wrote:
> On Tue 10-04-18 10:55:31, Jan Kara wrote:
> > On Tue 10-04-18 10:22:43, Michal Hocko wrote:
> > > On Mon 09-04-18 10:58:15, Minchan Kim wrote:
> > > > Recently, I got a report like below.
> > > > 
> > > > [ 7858.792946] [<ffffff80086f4de0>] __list_del_entry+0x30/0xd0
> > > > [ 7858.792951] [<ffffff8008362018>] list_lru_del+0xac/0x1ac
> > > > [ 7858.792957] [<ffffff800830f04c>] page_cache_tree_insert+0xd8/0x110
> > > > [ 7858.792962] [<ffffff8008310188>] __add_to_page_cache_locked+0xf8/0x4e0
> > > > [ 7858.792967] [<ffffff800830ff34>] add_to_page_cache_lru+0x50/0x1ac
> > > > [ 7858.792972] [<ffffff800830fdd0>] pagecache_get_page+0x468/0x57c
> > > > [ 7858.792979] [<ffffff80085d081c>] __get_node_page+0x84/0x764
> > > > [ 7858.792986] [<ffffff800859cd94>] f2fs_iget+0x264/0xdc8
> > > > [ 7858.792991] [<ffffff800859ee00>] f2fs_lookup+0x3b4/0x660
> > > > [ 7858.792998] [<ffffff80083d2540>] lookup_slow+0x1e4/0x348
> > > > [ 7858.793003] [<ffffff80083d0eb8>] walk_component+0x21c/0x320
> > > > [ 7858.793008] [<ffffff80083d0010>] path_lookupat+0x90/0x1bc
> > > > [ 7858.793013] [<ffffff80083cfe6c>] filename_lookup+0x8c/0x1a0
> > > > [ 7858.793018] [<ffffff80083c52d0>] vfs_fstatat+0x84/0x10c
> > > > [ 7858.793023] [<ffffff80083c5b00>] SyS_newfstatat+0x28/0x64
> > > > 
> > > > v4.9 kenrel already has the d3798ae8c6f3,("mm: filemap: don't
> > > > plant shadow entries without radix tree node") so I thought
> > > > it should be okay. When I was googling, I found others report
> > > > such problem and I think current kernel still has the problem.
> > > > 
> > > > https://bugzilla.redhat.com/show_bug.cgi?id=1431567
> > > > https://bugzilla.redhat.com/show_bug.cgi?id=1420335
> > > > 
> > > > It assumes shadow entry of radix tree relies on the init state
> > > > that node->private_list allocated should be list_empty state.
> > > > Currently, it's initailized in SLAB constructor which means
> > > > node of radix tree would be initialized only when *slub allocates
> > > > new page*, not *new object*. So, if some FS or subsystem pass
> > > > gfp_mask to __GFP_ZERO, slub allocator will do memset blindly.
> > > > That means allocated node can have !list_empty(node->private_list).
> > > > It ends up calling NULL deference at workingset_update_node by
> > > > failing list_empty check.
> > > > 
> > > > This patch should fix it.
> > > > 
> > > > Fixes: 449dd6984d0e ("mm: keep page cache radix tree nodes in check")
> > > > Reported-by: Chris Fries <cfries@google.com>
> > > > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > > > Cc: Jan Kara <jack@suse.cz>
> > > > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > > 
> > > Regardless of whether it makes sense to use __GFP_ZERO from the upper
> > > layer or not, it is subtle as hell to rely on the pre-existing state
> > > for a newly allocated object. So yes this makes perfect sense.
> > > 
> > > Do we want CC: stable?
> > > Acked-by: Michal Hocko <mhocko@suse.com>
> > 
> > Well, for hot allocations we do rely on previous state a lot. After all
> > that's what slab constructor was created for. Whether radix tree node
> > allocation is such a hot path is a question for debate, I agree.
> 
> I really doubt that LIST_INIT is something to notice for the radix tree
> allocation.

I agree with that.

> So I would rather have safe code than rely on the previous state which is
> really subtle.

And I agree on subtlety part here as well. But even with LIST_INIT we'll be
relying on some fields being 0 / NULL so you cannot really say that with
LIST_INIT we won't be relying on previous state. And fully memsetting
radix_tree_node on allocation *would* IMO have effect on the performance.
So I'm not convinced LIST_INIT buys us much. It deals with __GFP_ZERO
problem but not much else.

> Btw. I am not a huge fan of ctor semantic as we have it. I am not really
> sure all users understand when it is called...

Yeah, ctor semantics is subtle and we had some hard to debug bugs in VFS
because someone didn't understand the semantics. But OTOH for large
structures and frequent allocations the gain is worth it.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

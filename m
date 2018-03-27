Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 893926B0025
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 12:45:05 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id e7-v6so13413888plk.0
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 09:45:05 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e11si1122825pgr.231.2018.03.27.09.45.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 27 Mar 2018 09:45:03 -0700 (PDT)
Date: Tue, 27 Mar 2018 09:45:01 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 1/3] fs: Perform writebacks under memalloc_nofs
Message-ID: <20180327164501.GA21975@bombadil.infradead.org>
References: <20180321224429.15860-1-rgoldwyn@suse.de>
 <20180321224429.15860-2-rgoldwyn@suse.de>
 <20180322070808.GU23100@dhcp22.suse.cz>
 <d44ff1ea-e618-4cf6-b9b5-3e8fc7f03c14@suse.de>
 <20180327142150.GA13604@bombadil.infradead.org>
 <3a96b6ff-7d55-9bb6-8a30-f32f5dd0b054@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3a96b6ff-7d55-9bb6-8a30-f32f5dd0b054@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Goldwyn Rodrigues <rgoldwyn@suse.de>
Cc: Michal Hocko <mhocko@kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, david@fromorbit.com

On Tue, Mar 27, 2018 at 10:13:53AM -0500, Goldwyn Rodrigues wrote:
> On 03/27/2018 09:21 AM, Matthew Wilcox wrote:
> > On Tue, Mar 27, 2018 at 07:52:48AM -0500, Goldwyn Rodrigues wrote:
> >> I am not sure if I missed a condition in the code, but here is one of
> >> the call lineup:
> >>
> >> writepages() -> writepage() -> kmalloc() -> __alloc_pages() ->
> >> __alloc_pages_nodemask -> __alloc_pages_slowpath ->
> >> __alloc_pages_direct_reclaim() -> try_to_free_pages() ->
> >> do_try_to_free_pages() -> shrink_zones() -> shrink_node() ->
> >> shrink_slab() -> do_shrink_slab() -> shrinker.scan_objects() ->
> >> super_cache_scan() -> prune_icache_sb() -> fs/inode.c:dispose_list() ->
> >> evict(inode) -> evict_inode() for ext4 ->  filemap_write_and_wait() ->
> >> filemap_fdatawrite(mapping) -> __filemap_fdatawrite_range() ->
> >> do_writepages -> writepages()
> >>
> >> Please note, most filesystems currently have a safeguard in writepage()
> >> which will return if the PF_MEMALLOC is set. The other safeguard is
> >> __GFP_FS which we are trying to eliminate.
> > 
> > But is that harmful?  ext4_writepage() (for example) says that it will
> > not deadlock in that circumstance:
> 
> No, it is not harmful.
> 
> > 
> >  * We can get recursively called as show below.
> >  *
> >  *      ext4_writepage() -> kmalloc() -> __alloc_pages() -> page_launder() ->
> >  *              ext4_writepage()
> >  *
> >  * But since we don't do any block allocation we should not deadlock.
> >  * Page also have the dirty flag cleared so we don't get recurive page_lock.
> 
> Yes, and it avoids this by checking for PF_MEMALLOC flag.
> 
> > 
> > One might well argue that it's not *useful*; if we've gone into
> > writepage already, there's no point in re-entering writepage.  And the
> > last thing we want to do is 
> 
> ?

Sorry, got cut off.  The last thing we want to do is blow the stack by
recursing too deeply, but I don't think we're going to go through this
loop more than once.

> > But I could see filesystems behaving differently when entered
> > for writepage-for-regularly-scheduled-writeback versus
> > writepage-for-shrinking, so maybe they can make progress.
> > 
> 
> do_writepages() is the same for both, and hence the memalloc_* API patch.

But we don't want to avoid this particular recursion.  We only need to
avoid the recursion if it would result in a deadlock.

> > Maybe no real filesystem behaves that way.  We need feedback from
> > filesystem people.
> 
> The idea is to:
> * Keep a central location for check, rather than individual filesystem
> writepage(). It should reduce code as well.
> * Filesystem developers call memory allocations without thinking twice
> about which GFP flag to use: GFP_KERNEL or GFP_NOFS. In essence
> eliminate GFP_NOFS.

I know the goal is to eliminate GFP_NOFS.  I'm very much in favour
of that idea.  I'm just not sure you're going about it the right way.
Probably we will have a good discussion about it next month.

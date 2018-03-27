Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id ED5F76B0011
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 10:21:53 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id 1-v6so15494203plv.6
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 07:21:53 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m137si946384pga.382.2018.03.27.07.21.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 27 Mar 2018 07:21:52 -0700 (PDT)
Date: Tue, 27 Mar 2018 07:21:50 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 1/3] fs: Perform writebacks under memalloc_nofs
Message-ID: <20180327142150.GA13604@bombadil.infradead.org>
References: <20180321224429.15860-1-rgoldwyn@suse.de>
 <20180321224429.15860-2-rgoldwyn@suse.de>
 <20180322070808.GU23100@dhcp22.suse.cz>
 <d44ff1ea-e618-4cf6-b9b5-3e8fc7f03c14@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d44ff1ea-e618-4cf6-b9b5-3e8fc7f03c14@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Goldwyn Rodrigues <rgoldwyn@suse.de>
Cc: Michal Hocko <mhocko@kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, david@fromorbit.com, Goldwyn Rodrigues <rgoldwyn@suse.com>

On Tue, Mar 27, 2018 at 07:52:48AM -0500, Goldwyn Rodrigues wrote:
> I am not sure if I missed a condition in the code, but here is one of
> the call lineup:
> 
> writepages() -> writepage() -> kmalloc() -> __alloc_pages() ->
> __alloc_pages_nodemask -> __alloc_pages_slowpath ->
> __alloc_pages_direct_reclaim() -> try_to_free_pages() ->
> do_try_to_free_pages() -> shrink_zones() -> shrink_node() ->
> shrink_slab() -> do_shrink_slab() -> shrinker.scan_objects() ->
> super_cache_scan() -> prune_icache_sb() -> fs/inode.c:dispose_list() ->
> evict(inode) -> evict_inode() for ext4 ->  filemap_write_and_wait() ->
> filemap_fdatawrite(mapping) -> __filemap_fdatawrite_range() ->
> do_writepages -> writepages()
> 
> Please note, most filesystems currently have a safeguard in writepage()
> which will return if the PF_MEMALLOC is set. The other safeguard is
> __GFP_FS which we are trying to eliminate.

But is that harmful?  ext4_writepage() (for example) says that it will
not deadlock in that circumstance:

 * We can get recursively called as show below.
 *
 *      ext4_writepage() -> kmalloc() -> __alloc_pages() -> page_launder() ->
 *              ext4_writepage()
 *
 * But since we don't do any block allocation we should not deadlock.
 * Page also have the dirty flag cleared so we don't get recurive page_lock.

One might well argue that it's not *useful*; if we've gone into
writepage already, there's no point in re-entering writepage.  And the
last thing we want to do is 
But I could see filesystems behaving differently when entered
for writepage-for-regularly-scheduled-writeback versus
writepage-for-shrinking, so maybe they can make progress.

Maybe no real filesystem behaves that way.  We need feedback from
filesystem people.

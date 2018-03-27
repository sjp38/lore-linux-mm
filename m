Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id A7F226B002B
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 11:13:58 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id i4so363508wrh.4
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 08:13:58 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m200si1213117wmb.23.2018.03.27.08.13.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Mar 2018 08:13:57 -0700 (PDT)
Subject: Re: [PATCH 1/3] fs: Perform writebacks under memalloc_nofs
References: <20180321224429.15860-1-rgoldwyn@suse.de>
 <20180321224429.15860-2-rgoldwyn@suse.de>
 <20180322070808.GU23100@dhcp22.suse.cz>
 <d44ff1ea-e618-4cf6-b9b5-3e8fc7f03c14@suse.de>
 <20180327142150.GA13604@bombadil.infradead.org>
From: Goldwyn Rodrigues <rgoldwyn@suse.de>
Message-ID: <3a96b6ff-7d55-9bb6-8a30-f32f5dd0b054@suse.de>
Date: Tue, 27 Mar 2018 10:13:53 -0500
MIME-Version: 1.0
In-Reply-To: <20180327142150.GA13604@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Goldwyn Rodrigues <rgoldwyn@suse.de>
Cc: Michal Hocko <mhocko@kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, david@fromorbit.com



On 03/27/2018 09:21 AM, Matthew Wilcox wrote:
> On Tue, Mar 27, 2018 at 07:52:48AM -0500, Goldwyn Rodrigues wrote:
>> I am not sure if I missed a condition in the code, but here is one of
>> the call lineup:
>>
>> writepages() -> writepage() -> kmalloc() -> __alloc_pages() ->
>> __alloc_pages_nodemask -> __alloc_pages_slowpath ->
>> __alloc_pages_direct_reclaim() -> try_to_free_pages() ->
>> do_try_to_free_pages() -> shrink_zones() -> shrink_node() ->
>> shrink_slab() -> do_shrink_slab() -> shrinker.scan_objects() ->
>> super_cache_scan() -> prune_icache_sb() -> fs/inode.c:dispose_list() ->
>> evict(inode) -> evict_inode() for ext4 ->  filemap_write_and_wait() ->
>> filemap_fdatawrite(mapping) -> __filemap_fdatawrite_range() ->
>> do_writepages -> writepages()
>>
>> Please note, most filesystems currently have a safeguard in writepage()
>> which will return if the PF_MEMALLOC is set. The other safeguard is
>> __GFP_FS which we are trying to eliminate.
> 
> But is that harmful?  ext4_writepage() (for example) says that it will
> not deadlock in that circumstance:

No, it is not harmful.

> 
>  * We can get recursively called as show below.
>  *
>  *      ext4_writepage() -> kmalloc() -> __alloc_pages() -> page_launder() ->
>  *              ext4_writepage()
>  *
>  * But since we don't do any block allocation we should not deadlock.
>  * Page also have the dirty flag cleared so we don't get recurive page_lock.

Yes, and it avoids this by checking for PF_MEMALLOC flag.

> 
> One might well argue that it's not *useful*; if we've gone into
> writepage already, there's no point in re-entering writepage.  And the
> last thing we want to do is 

?

> But I could see filesystems behaving differently when entered
> for writepage-for-regularly-scheduled-writeback versus
> writepage-for-shrinking, so maybe they can make progress.
> 

do_writepages() is the same for both, and hence the memalloc_* API patch.

> Maybe no real filesystem behaves that way.  We need feedback from
> filesystem people.

The idea is to:
* Keep a central location for check, rather than individual filesystem
writepage(). It should reduce code as well.
* Filesystem developers call memory allocations without thinking twice
about which GFP flag to use: GFP_KERNEL or GFP_NOFS. In essence
eliminate GFP_NOFS.


-- 
Goldwyn

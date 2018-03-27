Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 502696B0008
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 08:52:54 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id k44so11886549wrc.3
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 05:52:54 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b65si993786wmd.186.2018.03.27.05.52.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Mar 2018 05:52:52 -0700 (PDT)
Subject: Re: [PATCH 1/3] fs: Perform writebacks under memalloc_nofs
References: <20180321224429.15860-1-rgoldwyn@suse.de>
 <20180321224429.15860-2-rgoldwyn@suse.de>
 <20180322070808.GU23100@dhcp22.suse.cz>
From: Goldwyn Rodrigues <rgoldwyn@suse.de>
Message-ID: <d44ff1ea-e618-4cf6-b9b5-3e8fc7f03c14@suse.de>
Date: Tue, 27 Mar 2018 07:52:48 -0500
MIME-Version: 1.0
In-Reply-To: <20180322070808.GU23100@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, david@fromorbit.com, Goldwyn Rodrigues <rgoldwyn@suse.com>



On 03/22/2018 02:08 AM, Michal Hocko wrote:
> On Wed 21-03-18 17:44:27, Goldwyn Rodrigues wrote:
>> From: Goldwyn Rodrigues <rgoldwyn@suse.com>
>>
>> writebacks can recurse into itself under low memory situations.
>> Set memalloc_nofs_save() in order to make sure it does not
>> recurse.
> 
> How? We are not doing writeback from the direct reclaim context.
> 

I am not sure if I missed a condition in the code, but here is one of
the call lineup:

writepages() -> writepage() -> kmalloc() -> __alloc_pages() ->
__alloc_pages_nodemask -> __alloc_pages_slowpath ->
__alloc_pages_direct_reclaim() -> try_to_free_pages() ->
do_try_to_free_pages() -> shrink_zones() -> shrink_node() ->
shrink_slab() -> do_shrink_slab() -> shrinker.scan_objects() ->
super_cache_scan() -> prune_icache_sb() -> fs/inode.c:dispose_list() ->
evict(inode) -> evict_inode() for ext4 ->  filemap_write_and_wait() ->
filemap_fdatawrite(mapping) -> __filemap_fdatawrite_range() ->
do_writepages -> writepages()

Please note, most filesystems currently have a safeguard in writepage()
which will return if the PF_MEMALLOC is set. The other safeguard is
__GFP_FS which we are trying to eliminate.


-- 
Goldwyn

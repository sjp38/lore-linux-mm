Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 14F326B003A
	for <linux-mm@kvack.org>; Tue, 29 Jul 2014 08:13:03 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id hz1so12257989pad.36
        for <linux-mm@kvack.org>; Tue, 29 Jul 2014 05:13:02 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id a1si10484630pdd.251.2014.07.29.05.13.01
        for <linux-mm@kvack.org>;
        Tue, 29 Jul 2014 05:13:02 -0700 (PDT)
Date: Tue, 29 Jul 2014 08:12:59 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v7 07/22] Replace the XIP page fault handler with the DAX
 page fault handler
Message-ID: <20140729121259.GL6754@linux.intel.com>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
 <c2e602f401a580c4fac54b9b8f4a6f8dd0ac1071.1395591795.git.matthew.r.wilcox@intel.com>
 <20140409102758.GM32103@quack.suse.cz>
 <20140409205111.GG5727@linux.intel.com>
 <20140409214331.GQ32103@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140409214331.GQ32103@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Apr 09, 2014 at 11:43:31PM +0200, Jan Kara wrote:
> So there are three places that can fail after we allocate the block:
> 1) We race with truncate reducing i_size
> 2) dax_get_pfn() fails
> 3) vm_insert_mixed() fails
> 
> I would guess that 2) can fail only if the HW has problems and leaking
> block in that case could be acceptable (please correct me if I'm wrong).
> 3) shouldn't fail because of ENOMEM because fault has already allocated all
> the page tables and EBUSY should be handled as well. So the only failure we
> have to care about is 1). And we could move ->get_block() call under
> i_mmap_mutex after the i_size check.  Lock ordering should be fine because
> i_mmap_mutex ranks above page lock under which we do block mapping in
> standard ->page_mkwrite callbacks. The only (big) drawback is that
> i_mmap_mutex will now be held for much longer time and thus the contention
> would be much higher. But hopefully once we resolve our problems with
> mmap_sem and introduce mapping range lock we could scale reasonably.

Lockdep barfs on holding i_mmap_mutex while calling ext4's ->get_block.

Path 1:

ext4_fallocate ->
 ext4_punch_hole ->
  ext4_inode_attach_jinode() -> ... ->
    lock_map_acquire(&handle->h_lockdep_map);
  truncate_pagecache_range() ->
   unmap_mapping_range() ->
    mutex_lock(&mapping->i_mmap_mutex);

Path 2:
do_dax_fault() ->
 mutex_lock(&mapping->i_mmap_mutex);
 ext4_get_block() -> ... ->
  lock_map_acquire(&handle->h_lockdep_map);

So that idea doesn't work.

We can't exclude truncates by incrementing i_dio_count, because we can't
take i_mutex in the fault path.

I'm stumped.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

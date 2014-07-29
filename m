Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 977386B0037
	for <linux-mm@kvack.org>; Tue, 29 Jul 2014 17:05:01 -0400 (EDT)
Received: by mail-wg0-f47.google.com with SMTP id b13so236774wgh.30
        for <linux-mm@kvack.org>; Tue, 29 Jul 2014 14:05:01 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id av8si270214wjc.57.2014.07.29.14.04.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 29 Jul 2014 14:04:59 -0700 (PDT)
Date: Tue, 29 Jul 2014 23:04:57 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v7 07/22] Replace the XIP page fault handler with the DAX
 page fault handler
Message-ID: <20140729210457.GA17807@quack.suse.cz>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
 <c2e602f401a580c4fac54b9b8f4a6f8dd0ac1071.1395591795.git.matthew.r.wilcox@intel.com>
 <20140409102758.GM32103@quack.suse.cz>
 <20140409205111.GG5727@linux.intel.com>
 <20140409214331.GQ32103@quack.suse.cz>
 <20140729121259.GL6754@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140729121259.GL6754@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: Jan Kara <jack@suse.cz>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 29-07-14 08:12:59, Matthew Wilcox wrote:
> On Wed, Apr 09, 2014 at 11:43:31PM +0200, Jan Kara wrote:
> > So there are three places that can fail after we allocate the block:
> > 1) We race with truncate reducing i_size
> > 2) dax_get_pfn() fails
> > 3) vm_insert_mixed() fails
> > 
> > I would guess that 2) can fail only if the HW has problems and leaking
> > block in that case could be acceptable (please correct me if I'm wrong).
> > 3) shouldn't fail because of ENOMEM because fault has already allocated all
> > the page tables and EBUSY should be handled as well. So the only failure we
> > have to care about is 1). And we could move ->get_block() call under
> > i_mmap_mutex after the i_size check.  Lock ordering should be fine because
> > i_mmap_mutex ranks above page lock under which we do block mapping in
> > standard ->page_mkwrite callbacks. The only (big) drawback is that
> > i_mmap_mutex will now be held for much longer time and thus the contention
> > would be much higher. But hopefully once we resolve our problems with
> > mmap_sem and introduce mapping range lock we could scale reasonably.
> 
> Lockdep barfs on holding i_mmap_mutex while calling ext4's ->get_block.
> 
> Path 1:
> 
> ext4_fallocate ->
>  ext4_punch_hole ->
>   ext4_inode_attach_jinode() -> ... ->
>     lock_map_acquire(&handle->h_lockdep_map);
>   truncate_pagecache_range() ->
>    unmap_mapping_range() ->
>     mutex_lock(&mapping->i_mmap_mutex);
  This is strange. I don't see how ext4_inode_attach_jinode() can ever lead
to lock_map_acquire(&handle->h_lockdep_map). Can you post a full trace for
this?

> Path 2:
> do_dax_fault() ->
>  mutex_lock(&mapping->i_mmap_mutex);
>  ext4_get_block() -> ... ->
>   lock_map_acquire(&handle->h_lockdep_map);
  This is obviously correct.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

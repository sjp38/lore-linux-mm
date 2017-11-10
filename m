Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id E7F03440D03
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 23:33:11 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id e64so6605176pfk.0
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 20:33:11 -0800 (PST)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id q10si7740521pge.349.2017.11.09.20.33.09
        for <linux-mm@kvack.org>;
        Thu, 09 Nov 2017 20:33:10 -0800 (PST)
Date: Fri, 10 Nov 2017 15:25:33 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 2/6] writeback: allow for dirty metadata accounting
Message-ID: <20171110042533.GT4094@dastard>
References: <1510255861-8020-1-git-send-email-josef@toxicpanda.com>
 <1510255861-8020-2-git-send-email-josef@toxicpanda.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1510255861-8020-2-git-send-email-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: hannes@cmpxchg.org, linux-mm@kvack.org, akpm@linux-foundation.org, jack@suse.cz, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, linux-btrfs@vger.kernel.org, Josef Bacik <jbacik@fb.com>

On Thu, Nov 09, 2017 at 02:30:57PM -0500, Josef Bacik wrote:
> From: Josef Bacik <jbacik@fb.com>
> 
> Provide a mechanism for file systems to indicate how much dirty metadata they
> are holding.  This introduces a few things
> 
> 1) Zone stats for dirty metadata, which is the same as the NR_FILE_DIRTY.
> 2) WB stat for dirty metadata.  This way we know if we need to try and call into
> the file system to write out metadata.  This could potentially be used in the
> future to make balancing of dirty pages smarter.

Ok, so when you have 64k page size and 4k metadata block size and
you're using kmalloc() to allocate the storage for the metadata,
how do we make use of all this page-based metadata accounting
stuff?

We could use dirty metadata accounting infrastructure in
XFS so the mm/ subsystem can push on dirty metadata before we
get into reclaim situations, but I just can't see how this code
works when raw pages are not used to back the metadata cache.

That is, XFS can use various different sizes of metadata buffers in
the same filesystem. For example, we use sector sized buffers for
static AG metadata, filesystem blocks for per-AG metadata, some
multiple (1-16) of filesystem blocks for inode buffers, and some
multiple (1-128) of filesytem blocks for directory blocks.

This means we have a combination of buffers  we need to account for
that are made up of:
	heap memory when buffer size < page size,
	single pages when buffer size == page size, and
	multiple pages when buffer size > page size.

The default filesystem config on a 4k page machine with 512 byte
sectors will create buffers in all three categories above which
tends to indicate we can't use this new generic infrastructure as
proposeda.

Any thoughts about how we could efficiently support accounting for
variable sized, non-page based metadata with this generic
infrastructure?

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

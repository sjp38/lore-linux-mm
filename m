Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id D4B7C6B0035
	for <linux-mm@kvack.org>; Sun, 14 Sep 2014 22:07:31 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so5176137pdj.36
        for <linux-mm@kvack.org>; Sun, 14 Sep 2014 19:07:31 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id cz6si20083368pdb.198.2014.09.14.19.07.29
        for <linux-mm@kvack.org>;
        Sun, 14 Sep 2014 19:07:30 -0700 (PDT)
Date: Mon, 15 Sep 2014 12:07:14 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Writeback, partial page writes and data corruption (was Re: [PATCH
 v3] ext4: fix data integrity sync in ordered mode)
Message-ID: <20140915020714.GD4322@dastard>
References: <000801cf6a4a$5d5c2dc0$18148940$@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <000801cf6a4a$5d5c2dc0$18148940$@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Namjae Jeon <namjae.jeon@samsung.com>
Cc: Theodore Ts'o <tytso@mit.edu>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-mm@kvack.org, Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org

[cc linux-fsdevel as a heads-up]

On Thu, May 08, 2014 at 08:16:24AM +0900, Namjae Jeon wrote:
> When we perform a data integrity sync we tag all the dirty pages with
> PAGECACHE_TAG_TOWRITE at start of ext4_da_writepages.
> Later we check for this tag in write_cache_pages_da and creates a
> struct mpage_da_data containing contiguously indexed pages tagged with this
> tag and sync these pages with a call to mpage_da_map_and_submit.
> This process is done in while loop until all the PAGECACHE_TAG_TOWRITE pages
> are synced. We also do journal start and stop in each iteration.
> journal_stop could initiate journal commit which would call ext4_writepage
> which in turn will call ext4_bio_write_page even for delayed OR unwritten
> buffers. When ext4_bio_write_page is called for such buffers, even though it
> does not sync them but it clears the PAGECACHE_TAG_TOWRITE of the corresponding
> page and hence these pages are also not synced by the currently running data
> integrity sync. We will end up with dirty pages although sync is completed.
> 
> This could cause a potential data loss when the sync call is followed by a
> truncate_pagecache call, which is exactly the case in collapse_range.
> (It will cause generic/127 failure in xfstests)

Yes, this is a patch that went into 3.16, but I only just found out
about it because Brian just found a very similar data corruption bug
in XFS. i.e. a partial page write was starting writeback and hence
clearing PAGECACHE_TAG_TOWRITE before the page was fully cleaned and
hence WB_SYNC_ALL wasn't writing the entire page.

http://oss.sgi.com/pipermail/xfs/2014-September/038150.html
http://oss.sgi.com/pipermail/xfs/2014-September/038167.html

IOWs, if a filesystem does write-ahead in ->writepages() or
relies on the write_cache_pages() layer to reissue dirty pages in
partial page write situations for data integrity purposes, then it
needs to be converted to use set_page_writeback_keepwrite() until
the page is fully clean, at which point it can then use
set_page_writeback().

For everyone: if one filesystem is using the generic code
incorrectly, then it is likely the same or similar bugs exist in
other filesystems. As a courtesy to your fellow filesystem
developers, if you find a data corruption bug caused by interactions
with the generic code can the fixes please be CC'd to linux-fsdevel
so everyone knows about the issue? This is especially important if
new interfaces in the generic code have been added to avoid the
problem.

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

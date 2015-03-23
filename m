Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id B80E46B006C
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 18:40:52 -0400 (EDT)
Received: by pabxg6 with SMTP id xg6so192417235pab.0
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 15:40:52 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id o7si2816048pdp.136.2015.03.23.15.40.50
        for <linux-mm@kvack.org>;
        Mon, 23 Mar 2015 15:40:52 -0700 (PDT)
Date: Tue, 24 Mar 2015 09:40:47 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 3/3] RFC: dax: dax_prepare_freeze
Message-ID: <20150323224047.GQ28621@dastard>
References: <55100B78.501@plexistor.com>
 <55100D10.6090902@plexistor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55100D10.6090902@plexistor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-nvdimm <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Eryu Guan <eguan@redhat.com>

On Mon, Mar 23, 2015 at 02:54:40PM +0200, Boaz Harrosh wrote:
> From: Boaz Harrosh <boaz@plexistor.com>
> 
> When freezing an FS, we must write protect all IS_DAX()
> inodes that have an mmap mapping on an inode. Otherwise
> application will be able to modify previously faulted-in
> file pages.

All you need to do is lock out page faults once the page is clean;
that's what the sb_start_pagefault() calls are for in the page fault
path - they catch write faults and block them until the filesystem
is unfrozen. Hence I'm not sure why this would be necessary if you
are catching write faults in .pfn_mkwrite....

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

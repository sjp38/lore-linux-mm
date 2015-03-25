Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 081766B0038
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 22:22:28 -0400 (EDT)
Received: by pdbop1 with SMTP id op1so12479585pdb.2
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 19:22:27 -0700 (PDT)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id oa11si1450279pdb.33.2015.03.24.19.22.25
        for <linux-mm@kvack.org>;
        Tue, 24 Mar 2015 19:22:27 -0700 (PDT)
Date: Wed, 25 Mar 2015 13:22:21 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 3/3] RFC: dax: dax_prepare_freeze
Message-ID: <20150325022221.GA31342@dastard>
References: <55100B78.501@plexistor.com>
 <55100D10.6090902@plexistor.com>
 <20150323224047.GQ28621@dastard>
 <551100E3.9010007@plexistor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <551100E3.9010007@plexistor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-nvdimm <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Eryu Guan <eguan@redhat.com>

On Tue, Mar 24, 2015 at 08:14:59AM +0200, Boaz Harrosh wrote:
> On 03/24/2015 12:40 AM, Dave Chinner wrote:
> > On Mon, Mar 23, 2015 at 02:54:40PM +0200, Boaz Harrosh wrote:
> >> From: Boaz Harrosh <boaz@plexistor.com>
> >>
> >> When freezing an FS, we must write protect all IS_DAX()
> >> inodes that have an mmap mapping on an inode. Otherwise
> >> application will be able to modify previously faulted-in
> >> file pages.
> > 
> > All you need to do is lock out page faults once the page is clean;
> > that's what the sb_start_pagefault() calls are for in the page fault
> > path - they catch write faults and block them until the filesystem
> > is unfrozen. Hence I'm not sure why this would be necessary if you
> > are catching write faults in .pfn_mkwrite....
> > 
> 
> Jan pointed it out and he was right I have a test for this. What
> happens is that since we had a mapping from before the freeze we will
> not have a page-fault. And the buffers will be modified.
> 
> As Jan explained in the cache path we do a writeback which turns
> all pages to read-only. But with dax we do not have writeback
> so the pages stay read-write mapped. Something needs to loop
> through the pages and write-protect them. I chose to unmap
> them because it is the much-much smaller code, and I do not care
> to optimize the freeze.

Then we have wider problem with DAX, then: sync doesn't work
properly. i.e. if we still has write mapped pages, then we haven't
flushed dirty cache lines on write-mapped files to the persistent
domain by the time sync completes.

So, this shouldn't be some special case that only the freeze code
takes into account - we need to make sure that sync (and therefore
freeze) flushes all dirty cache lines and marks all mappings
clean....

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

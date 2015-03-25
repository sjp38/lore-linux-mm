Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 303906B0032
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 16:05:21 -0400 (EDT)
Received: by pdbcz9 with SMTP id cz9so38773235pdb.3
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 13:05:20 -0700 (PDT)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id ce13si5058612pdb.224.2015.03.25.13.05.19
        for <linux-mm@kvack.org>;
        Wed, 25 Mar 2015 13:05:20 -0700 (PDT)
Date: Thu, 26 Mar 2015 07:05:16 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 3/3] RFC: dax: dax_prepare_freeze
Message-ID: <20150325200516.GK31342@dastard>
References: <55100B78.501@plexistor.com>
 <55100D10.6090902@plexistor.com>
 <55115A99.40705@plexistor.com>
 <20150325022633.GB31342@dastard>
 <5512725A.1010905@plexistor.com>
 <20150325094135.GI31342@dastard>
 <551290AC.7080402@plexistor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <551290AC.7080402@plexistor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-nvdimm <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Eryu Guan <eguan@redhat.com>

On Wed, Mar 25, 2015 at 12:40:44PM +0200, Boaz Harrosh wrote:
> On 03/25/2015 11:41 AM, Dave Chinner wrote:
> > On Wed, Mar 25, 2015 at 10:31:22AM +0200, Boaz Harrosh wrote:
> >> On 03/25/2015 04:26 AM, Dave Chinner wrote:
> <>
> >> sync and fsync should and will work correctly, but this does not
> >> solve our problem. because what turns pages to read-only is the
> >> writeback. And we do not have this in dax. Therefore we need to
> >> do this here as a special case.
> > 
> > We can still use exactly the same dirty tracking as we use for data
> > writeback. The difference is that we don't need to go through all
> > teh page writeback; we can just flush the CPU caches and mark all
> > the mappings clean, then clear the I_DIRTY_PAGES flag and move on to
> > inode writeback....
> > 
> 
> I see what you mean. the sb wide sync will not step into mmaped inodes
> and fsync them.
> 
> If we go my way and write NT (None Temporal) style in Kernel.
> NT instructions exist since xeon and all the Intel iX core CPUs have
> them. In tests we conducted doing xeon NT-writes vs
> regular-writes-and-cl_flush at .fsync showed minimum of 20% improvement.
> That is on very large IOs. On 4k IOs it was even better.

As I said before, relying on specific instructions is a non-starter
for mmap writes, and that's the problem we need to solve here.

> It looks like you have a much better picture in your mind how to
> fit this properly at the inode-dirty picture. Can you attempt a rough draft?
> 
> If we are going the NT way. Then we can only I_DIRTY_ track the mmaped
> inodes. For me this is really scary because I do not want to trigger
> any writeback threads. If you could please draw me an outline (or write
> something up ;-)) it would be great.

Writeback threads are not used for fsync - they are used for sync
and background writeback. They are already active on DAX filesystems
that track dirty inodes on the VFS superblock, as this is the way
inodes are written back on some filesystems.

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

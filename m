Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id E6F566B0032
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 16:00:30 -0400 (EDT)
Received: by pagj7 with SMTP id j7so39365191pag.2
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 13:00:30 -0700 (PDT)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id to6si5105084pac.14.2015.03.25.13.00.28
        for <linux-mm@kvack.org>;
        Wed, 25 Mar 2015 13:00:29 -0700 (PDT)
Date: Thu, 26 Mar 2015 07:00:24 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 3/3] RFC: dax: dax_prepare_freeze
Message-ID: <20150325200024.GJ31342@dastard>
References: <55100B78.501@plexistor.com>
 <55100D10.6090902@plexistor.com>
 <20150323224047.GQ28621@dastard>
 <551100E3.9010007@plexistor.com>
 <20150325022221.GA31342@dastard>
 <55126D77.7040105@plexistor.com>
 <20150325092922.GH31342@dastard>
 <55128BC6.7090105@plexistor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55128BC6.7090105@plexistor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-nvdimm <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Eryu Guan <eguan@redhat.com>

On Wed, Mar 25, 2015 at 12:19:50PM +0200, Boaz Harrosh wrote:
> On 03/25/2015 11:29 AM, Dave Chinner wrote:
> > On Wed, Mar 25, 2015 at 10:10:31AM +0200, Boaz Harrosh wrote:
> >> On 03/25/2015 04:22 AM, Dave Chinner wrote:
> >>> On Tue, Mar 24, 2015 at 08:14:59AM +0200, Boaz Harrosh wrote:
> >> <>
> <>
> >> The sync does happen, .fsync of the FS is called on each
> >> file just as if the user called it. If this is broken it just
> >> needs to be fixed there at the .fsync vector. POSIX mandate
> >> persistence at .fsync so at the vfs layer we rely on that.
> > 
> > right now, the filesystems will see that there are no dirty pages
> > on the inode, and then just sync the inode metadata. They will do
> > nothing else as filesystems are not aware of CPU cachelines at all.
> > 
> 
> Sigh yes. There is this bug. And I am sitting on a wide fix for this.
> 
> The strategy is. All Kernel writes are done with a new copy_user_nt.
> NT stands for none-temporal. This shows 20% improvements since cachelines
> need not be fetched when written too.

That's unenforcable for mmap writes from userspace. And those are
the writes that will trigger the dirty write mapping problem.

> >> And because of that nothing turned the
> >> user mappings to read only. This is what I do here but
> >> instead of write-protecting I just unmap because it is
> >> easier for me to code it.
> > 
> > That doesn't mean it is the correct solution.
> 
> Please note that even if we properly .fsync cachlines the page-faults
> are orthogonal to this. There is no point in making mmapped dax pages
> read-only after every .fsync and pay a page-fault. We should leave them
> mapped has is. The only place that we need page protection is at freeze
> time.

Actually, current behaviour of filesystems is that fsync cleans all
the pages in the range, and means all the mappings are marked
read-only and so we get new calls into .page_mkwrite when write
faults occur. We need that .page_mkwrite call to be able to a)
update the mtime of the inode, and b) mark the inode "data dirty" so
that fsync knows it needs to do something....

Hence I'd much prefer we start with identical behaviour to normal
files, then we can optimise from a sane start point when write page
faults show up as a performance problem. i.e. Correctness first,
performance second.

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

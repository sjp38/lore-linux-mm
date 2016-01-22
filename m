Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f170.google.com (mail-io0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 3D2C96B0005
	for <linux-mm@kvack.org>; Fri, 22 Jan 2016 06:26:24 -0500 (EST)
Received: by mail-io0-f170.google.com with SMTP id q21so85152762iod.0
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 03:26:24 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id me4si4583010igb.100.2016.01.22.03.26.22
        for <linux-mm@kvack.org>;
        Fri, 22 Jan 2016 03:26:23 -0800 (PST)
Date: Fri, 22 Jan 2016 22:26:19 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v3 0/8] Support for transparent PUD pages for DAX files
Message-ID: <20160122112619.GC6033@dastard>
References: <1452282592-27290-1-git-send-email-matthew.r.wilcox@intel.com>
 <20160115194150.GA5751@birch.djwong.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160115194150.GA5751@birch.djwong.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org

On Fri, Jan 15, 2016 at 11:41:50AM -0800, Darrick J. Wong wrote:
> On Fri, Jan 08, 2016 at 02:49:44PM -0500, Matthew Wilcox wrote:
> > From: Matthew Wilcox <willy@linux.intel.com>
> > 
> > Andrew, I think this is ready for a spin in -mm.
> > 
> > v3: Rebased against current mmtom
> > v2: Reduced churn in filesystems by switching to ->huge_fault interface
> >     Addressed concerns from Kirill
> > 
> > We have customer demand to use 1GB pages to map DAX files.  Unlike the 2MB
> > page support, the Linux MM does not currently support PUD pages, so I have
> > attempted to add support for the necessary pieces for DAX huge PUD pages.
> > 
> > Filesystems still need work to allocate 1GB pages.  With ext4, I can
> > only get 16MB of contiguous space, although it is aligned.  With XFS,
> > I can get 80MB less than 1GB, and it's not aligned.  The XFS problem
> > may be due to the small amount of RAM in my test machine.
> 
> "It's not aligned"... I don't know the details of what you're trying to do, but
> are you trying to create a file where each GB of logical address space maps to
> a contiguous GB of physical space, and both logical and physical offsets align
> to a 1GB boundary?
> 
> If the XFS is formatted with stripe unit/width of 1G, an extent size hint of 1G
> is put on the file, and the whole file is allocated in 1G chunks, I think
> you're supposed to be able to make the above happen:

If you really, really want to guarantee 1GB aligned extents for file
data on XFS, use the realtime device with a 1GB extent size.....

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

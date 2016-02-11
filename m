Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f169.google.com (mail-io0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 23E946B0005
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 18:44:20 -0500 (EST)
Received: by mail-io0-f169.google.com with SMTP id 9so75207052iom.1
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 15:44:20 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id 82si16079304iok.187.2016.02.11.15.44.18
        for <linux-mm@kvack.org>;
        Thu, 11 Feb 2016 15:44:19 -0800 (PST)
Date: Fri, 12 Feb 2016 10:44:15 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v2 2/2] dax: move writeback calls into the filesystems
Message-ID: <20160211234415.GM19486@dastard>
References: <1455137336-28720-1-git-send-email-ross.zwisler@linux.intel.com>
 <1455137336-28720-3-git-send-email-ross.zwisler@linux.intel.com>
 <20160210220312.GP14668@dastard>
 <20160210224340.GA30938@linux.intel.com>
 <20160211125044.GJ21760@quack.suse.cz>
 <CAPcyv4g60iOTd-ShBCfsK+B7xArcc5pWXWktNop53otDbUW-3g@mail.gmail.com>
 <20160211204635.GI19486@dastard>
 <CAPcyv4h4u+LB5U5nm4Jo32r=33D02yv36k5QxmJoy3DRiHmQEQ@mail.gmail.com>
 <20160211224616.GL19486@dastard>
 <CAPcyv4hR60bahtQq68SgSG2uT9zP4H8u3zbUqtqndnx=ogwVtA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4hR60bahtQq68SgSG2uT9zP4H8u3zbUqtqndnx=ogwVtA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.com>, Matthew Wilcox <willy@linux.intel.com>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, XFS Developers <xfs@oss.sgi.com>

On Thu, Feb 11, 2016 at 02:59:14PM -0800, Dan Williams wrote:
> On Thu, Feb 11, 2016 at 2:46 PM, Dave Chinner <david@fromorbit.com> wrote:
> > On Thu, Feb 11, 2016 at 12:58:38PM -0800, Dan Williams wrote:
> >> On Thu, Feb 11, 2016 at 12:46 PM, Dave Chinner <david@fromorbit.com> wrote:
> >> Maybe I don't need to worry because it's already the case that a
> >> mmap of the raw device may not see the most up to date data for a
> >> file that has dirty fs-page-cache data.
> >
> > It goes both ways. What happens if mkfs or fsck modifies the
> > block device via mmap+DAX and then the filesystem mounts the block
> > device and tries to read that metadata via the block device page
> > cache?
> >
> > Quite frankly, DAX on the block device is a can of worms we really
> > don't need to deal with right now. IMO it's a solution looking for a
> > problem to solve,
> 
> Virtualization use cases want to give large ranges to guest-VMs, and
> it is currently the only way to reliably get 1GiB mappings.

Precisely my point - block devices are not the best way to solve
this problem.

A file, on XFS, with a 1GB extent size hint and preallocated to be
aligned to 1GB addresses (i.e. mkfs.xfs -d su=1G,sw=1 on the host
filesystem) will give reliable 1GB aligned blocks for DAX mappings,
just like a block device will. Peformance wise it's little different
to using the block device directly. Management wise it's way more
flexible, especially as such image files can be recycled for new VMs
almost instantly via FALLOC_FL_FLAG_ZERO_RANGE.

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

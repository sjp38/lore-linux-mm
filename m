Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 67CAF6B025F
	for <linux-mm@kvack.org>; Sun,  1 Oct 2017 04:17:04 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id k7so545018wre.22
        for <linux-mm@kvack.org>; Sun, 01 Oct 2017 01:17:04 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id c12si6567534wrd.406.2017.10.01.01.17.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Oct 2017 01:17:03 -0700 (PDT)
Date: Sun, 1 Oct 2017 10:17:02 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 1/7] xfs: always use DAX if mount option is used
Message-ID: <20171001081702.GC11895@lst.de>
References: <20170925231404.32723-1-ross.zwisler@linux.intel.com> <20170925231404.32723-2-ross.zwisler@linux.intel.com> <20170925233812.GM10955@dastard> <20170926093548.GB13627@quack2.suse.cz> <20170926110957.GR10955@dastard> <20170926143743.GB18758@lst.de> <20170926173057.GB20159@linux.intel.com> <20170927064001.GA27601@infradead.org> <20170927161510.GB24314@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170927161510.GB24314@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@infradead.org>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Darrick J. Wong" <darrick.wong@oracle.com>, "J. Bruce Fields" <bfields@fieldses.org>, Dan Williams <dan.j.williams@intel.com>, Jeff Layton <jlayton@poochiereds.net>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Wed, Sep 27, 2017 at 10:15:10AM -0600, Ross Zwisler wrote:
> Well, I don't know if platforms that support HMAT + PMEM are widely available,
> but we have all the details in the ACPI spec, so we could begin to code it up
> and things will "just work" when platforms arrive.

Then again currently all actually shipping NVDIMMs are battery backed
dram and DAX mode should work just fine for them.  Things will get
interesting once companies start shipping actually persistent technologies
that will be significantly slower than DRAM.  And we sould make sure
we have the infrastruture for that in place.

> Hum, I wonder if maybe we need/want three different mount modes?  What about:
> 
> autodax (the default): the filesystem is free to use DAX or not, as it sees
> fit and thinks is optimal.  For the time being we can make this mean "don't
> use DAX", and phase in DAX usage as we add support for the HMAT, etc.

What does "use DAX" really mean anyway?

I think we are conflating a few things:

 a) use a block device or use a dax_device for accessing the device
 b) use the pagecache for caching data in DRAM or not.

Now we actually have a really nice way to control a) already, it's
called O_DIRECT.  Currently O_DIRECT only works with read/write I/O,
but with a byte addressable scheme we now can implement it for mmap
as well, which is what the DAX mmap path does.

b) right now is implied by a), but it's really an implementation
detail.

So the modes would be more like two options to:

 a) disallow any byte-level access.  The right way to do that would
    be to mount the /dev/dax* device instead of the block device
    to allow byte access, and disallow any DAXish operation if you
    mount the block device in the long run.
 b) have a mode to always force an O_DIRECT-like mode for devices
    that are fast enough.  We should always do that with the right
    HMAT entries if mounting the /dev/dax devices, and maybe have
    a mount option to force it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

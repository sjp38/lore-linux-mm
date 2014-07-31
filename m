Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 8A32F6B0035
	for <linux-mm@kvack.org>; Thu, 31 Jul 2014 13:22:12 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id g10so3869692pdj.29
        for <linux-mm@kvack.org>; Thu, 31 Jul 2014 10:22:12 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ku7si6644352pbc.107.2014.07.31.10.22.11
        for <linux-mm@kvack.org>;
        Thu, 31 Jul 2014 10:22:11 -0700 (PDT)
Date: Thu, 31 Jul 2014 13:19:53 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v8 04/22] Change direct_access calling convention
Message-ID: <20140731171953.GU6754@linux.intel.com>
References: <cover.1406058387.git.matthew.r.wilcox@intel.com>
 <b78b33d94b669a5fbd02e06f2493b43dd5d77698.1406058387.git.matthew.r.wilcox@intel.com>
 <53D9174C.7040906@gmail.com>
 <20140730194503.GQ6754@linux.intel.com>
 <53DA165E.8040601@gmail.com>
 <20140731141315.GT6754@linux.intel.com>
 <53DA60A5.1030304@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53DA60A5.1030304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <openosd@gmail.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jul 31, 2014 at 06:28:37PM +0300, Boaz Harrosh wrote:
> Matthew what is your opinion about this, do we need to push for removal
> of the partition dead code which never worked for brd, or we need to push
> for fixing and implementing new partition support for brd?

Fixing the code gets my vote.  brd is useful for testing things ... and
sometimes we need to test things that involve partitions.

> Also another thing I saw is that if we leave the flag 
> 	GENHD_FL_SUPPRESS_PARTITION_INFO
> 
> then mount -U UUID stops to work, regardless of partitions or not,
> this is because Kernel will not put us on /proc/patitions.
> I'll submit another patch to remove it.

Yes, we should probably fix that too.

> BTW I hit another funny bug where the partition beginning was not
> 4K aligned apparently fdisk lets you do this if the total size is small
> enough  (like 4096 which is default for brd) so I ended up with accessing
> sec zero, the supper-block, failing because of the alignment check at
> direct_access().

That's why I added on the partition start before doing the alignment
check :-)

> Do you know of any API that brd/prd can do to not let fdisk do this?
> I'm looking at it right now I just thought it is worth asking.

I think it's enough to refuse the mount.  That feels like a patch to
ext2/4 (or maybe ext2/4 has a way to start the filesystem on a different
block boundary?)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

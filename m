Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0EB516B0038
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 02:34:04 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id q132so920868wmd.22
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 23:34:04 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id w18si6470721wra.410.2017.09.25.23.34.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Sep 2017 23:34:03 -0700 (PDT)
Date: Tue, 26 Sep 2017 08:34:02 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 6/7] mm, fs: introduce file_operations->post_mmap()
Message-ID: <20170926063402.GC6870@lst.de>
References: <20170925231404.32723-1-ross.zwisler@linux.intel.com> <20170925231404.32723-7-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170925231404.32723-7-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Darrick J. Wong" <darrick.wong@oracle.com>, "J. Bruce Fields" <bfields@fieldses.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@poochiereds.net>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Mon, Sep 25, 2017 at 05:14:03PM -0600, Ross Zwisler wrote:
> When mappings are created the vma->vm_flags that they use vary based on
> whether the inode being mapped is using DAX or not.  This setup happens in
> XFS via mmap_region()=>call_mmap()=>xfs_file_mmap().
> 
> For us to be able to safely use the DAX per-inode flag we need to prevent
> S_DAX transitions when any mappings are present, and we will do that by
> looking at the address_space->i_mmap tree and returning -EBUSY if any
> mappings are present.
> 
> Unfortunately at the time that the filesystem's file_operations->mmap()
> entry point is called the mapping has not yet been added to the
> address_space->i_mmap tree.  This means that at that point in time we
> cannot determine whether or not the mapping will be set up to support DAX.
> 
> Fix this by adding a new file_operations entry called post_mmap() which is
> called after the mapping has been added to the address_space->i_mmap tree.
> This post_mmap() op now happens at a time when we can be sure whether the
> mapping will use DAX or not, and we can set up the vma->vm_flags
> appropriately.

Just like in the read/write path we'll need a flag that is passed down
from the VM based on checking IS_DAX once and exactly once instead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

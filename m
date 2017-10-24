Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id EEED56B0038
	for <linux-mm@kvack.org>; Tue, 24 Oct 2017 17:29:10 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id v2so19296943pfa.10
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 14:29:10 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id h1si639686pln.309.2017.10.24.14.29.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Oct 2017 14:29:09 -0700 (PDT)
Date: Tue, 24 Oct 2017 15:29:08 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 17/17] xfs: support for synchronous DAX faults
Message-ID: <20171024212908.GC1611@linux.intel.com>
References: <20171024152415.22864-1-jack@suse.cz>
 <20171024152415.22864-18-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171024152415.22864-18-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@infradead.org>, linux-ext4@vger.kernel.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>

On Tue, Oct 24, 2017 at 05:24:14PM +0200, Jan Kara wrote:
> From: Christoph Hellwig <hch@lst.de>
> 
> Return IOMAP_F_DIRTY from xfs_file_iomap_begin() when asked to prepare
> blocks for writing and the inode is pinned, and has dirty fields other
> than the timestamps.  In __xfs_filemap_fault() we then detect this case
> and call dax_finish_sync_fault() to make sure all metadata is committed,
> and to insert the page table entry.
> 
> Note that this will also dirty corresponding radix tree entry which is
> what we want - fsync(2) will still provide data integrity guarantees for
> applications not using userspace flushing. And applications using
> userspace flushing can avoid calling fsync(2) and thus avoid the
> performance overhead.
> 
> [JK: Added VM_SYNC flag handling]
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Signed-off-by: Jan Kara <jack@suse.cz>

I don't know enough about XFS dirty inode handling to be able to comment on
the changes in xfs_file_iomap_begin(), but the rest looks good.

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 26A366B025E
	for <linux-mm@kvack.org>; Thu,  6 Oct 2016 22:58:36 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id u84so15104336pfj.1
        for <linux-mm@kvack.org>; Thu, 06 Oct 2016 19:58:36 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id qj2si15100605pac.7.2016.10.06.19.58.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 06 Oct 2016 19:58:35 -0700 (PDT)
Date: Thu, 6 Oct 2016 20:58:33 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v4 10/12] dax: add struct iomap based DAX PMD support
Message-ID: <20161007025833.GA2934@linux.intel.com>
References: <1475189370-31634-1-git-send-email-ross.zwisler@linux.intel.com>
 <1475189370-31634-11-git-send-email-ross.zwisler@linux.intel.com>
 <20161003105949.GP6457@quack2.suse.cz>
 <20161003210557.GA28177@linux.intel.com>
 <20161006213424.GA4569@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161006213424.GA4569@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Thu, Oct 06, 2016 at 03:34:24PM -0600, Ross Zwisler wrote:
> Interesting - adding iomap_end() calls to the DAX PTE fault handler causes an
> AA deadlock because we try and retake ei->dax_sem.  We take dax_sem in
> ext2_dax_fault() before calling into the DAX code, then if we end up going
> through the error path in ext2_iomap_end(), we call 
>   ext2_write_failed()
>     ext2_truncate_blocks()
>       dax_sem_down_write()
> 
> Where we try and take dax_sem again.  This error path is really only valid for
> I/O operations, but we happen to call it for page faults because 'written' in
> ext2_iomap_end() is just 0.
> 
> So...how should we handle this?  A few ideas:
> 
> 1) Just continue to omit the calls to iomap_end() in the DAX page fault
> handlers for now, and add them when there is useful work to be done in one of
> the filesystems.
> 
> 2) Add an IOMAP_FAULT flag to the flags passed into iomap_begin() and
> iomap_end() so make it explicit that we are calling as part of a fault handler
> and not an I/O operation, and use this to adjust the error handling in
> ext2_iomap_end().
> 
> 3) Just work around the existing error handling in ext2_iomap_end() by either
> unsetting IOMAP_WRITE or by setting 'written' to the size of the fault.
> 
> For #2 or #3, probably add a comment explaining the deadlock and why we need
> to never call ext2_write_failed() while handling a page fault.
> 
> Thoughts?

Never mind, #3 it is, I think it was just a plain bug to call iomap_end() with
'length' != 'written'.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

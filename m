Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 4433C6B0038
	for <linux-mm@kvack.org>; Wed,  2 Sep 2015 15:04:10 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so20514933pac.2
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 12:04:10 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id ue3si37009620pab.213.2015.09.02.12.04.09
        for <linux-mm@kvack.org>;
        Wed, 02 Sep 2015 12:04:09 -0700 (PDT)
Date: Wed, 2 Sep 2015 13:04:01 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH] dax, pmem: add support for msync
Message-ID: <20150902190401.GC32255@linux.intel.com>
References: <1441047584-14664-1-git-send-email-ross.zwisler@linux.intel.com>
 <20150831233803.GO3902@dastard>
 <20150901070608.GA5482@lst.de>
 <55E597A1.9090205@plexistor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55E597A1.9090205@plexistor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@osdl.org>, Dave Hansen <dave.hansen@linux.intel.com>, linux-nvdimm@lists.01.org, Peter Zijlstra <peterz@infradead.org>, x86@kernel.org, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, "H. Peter Anvin" <hpa@zytor.com>, linux-fsdevel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Sep 01, 2015 at 03:18:41PM +0300, Boaz Harrosh wrote:
> So the approach we took was a bit different to exactly solve these
> problem, and to also not over flush too much. here is what we did.
> 
> * At vm_operations_struct we also override the .close vector (say call it dax_vm_close)
> 
> * At dax_vm_close() on writable files call ->fsync(,vma->vm_start, vma->vm_end,)
>   (We have an inode flag if the file was actually dirtied, but even if not, that will
>    not be that bad, so a file was opened for write, mmapped, but actually never
>    modified. Not a lot of these, and the do nothing cl_flushing is very fast)
> 
> * At ->fsync() do the actual cl_flush for all cases but only iff
> 	if (mapping_mapped(inode->i_mapping) == 0)
> 		return 0;
> 
>   This is because data written not through mmap is already persistent and we
>   do not need the cl_flushing
> 
> Apps expect all these to work:
> 1. open mmap m-write msync ... close
> 2. open mmap m-write fsync ... close
> 3. open mmap m-write unmap ... fsync close
> 
> 4. open mmap m-write sync ...

So basically you made close have an implicit fsync?  What about the flow that
looks like this:

5. open mmap close m-write

This guy definitely needs an msync/fsync at the end to make sure that the
m-write becomes durable.  

Also, the CLOSE(2) man page specifically says that a flush does not occur at
close:
	A successful close does not guarantee that the data has been
	successfully  saved  to  disk,  as  the  kernel defers  writes.   It
	is not common for a filesystem to flush the buffers when the stream is
	closed.  If you need to be sure that the data is physically stored,
	use fsync(2).  (It will depend on the disk  hardware  at this point.)

I don't think that adding an implicit fsync to close is the right solution -
we just need to get msync and fsync correctly working.

> The first 3 are supported with above, because what happens is that at [3]
> the fsync actually happens on unmap and fsync is redundant in that case.
> 
> The only broken scenario is [3]. We do not have a list of "dax-dirty" inodes
> per sb to iterate on and call inode-sync on. This cause problems mostly in
> freeze because with actual [3] scenario the file will be eventually closed
> and persistent, but after the call to sync returns.
> 
> Its on my TODO to fix [3] based on instructions from Dave.
> The mmap call will put the inode on the list and the dax_vm_close will
> remove it. One of the regular dirty list should be used as suggested by
> Dave.

I believe in the above two paragraphs you meant [4], so the 

4. open mmap m-write sync ...

case needs to be fixed so that we can detect DAX-dirty inodes?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

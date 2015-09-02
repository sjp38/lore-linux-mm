Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 7F0696B0038
	for <linux-mm@kvack.org>; Wed,  2 Sep 2015 16:17:42 -0400 (EDT)
Received: by wicmc4 with SMTP id mc4so77819455wic.0
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 13:17:42 -0700 (PDT)
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com. [209.85.212.178])
        by mx.google.com with ESMTPS id c9si6500839wie.49.2015.09.02.13.17.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Sep 2015 13:17:40 -0700 (PDT)
Received: by wicge5 with SMTP id ge5so52782697wic.0
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 13:17:40 -0700 (PDT)
Date: Wed, 2 Sep 2015 23:17:38 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] dax, pmem: add support for msync
Message-ID: <20150902201738.GA5775@node.dhcp.inet.fi>
References: <1441047584-14664-1-git-send-email-ross.zwisler@linux.intel.com>
 <20150831233803.GO3902@dastard>
 <20150901070608.GA5482@lst.de>
 <55E597A1.9090205@plexistor.com>
 <20150902190401.GC32255@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150902190401.GC32255@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Boaz Harrosh <boaz@plexistor.com>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@osdl.org>, Dave Hansen <dave.hansen@linux.intel.com>, linux-nvdimm@lists.01.org, Peter Zijlstra <peterz@infradead.org>, x86@kernel.org, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, "H. Peter Anvin" <hpa@zytor.com>, linux-fsdevel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Wed, Sep 02, 2015 at 01:04:01PM -0600, Ross Zwisler wrote:
> On Tue, Sep 01, 2015 at 03:18:41PM +0300, Boaz Harrosh wrote:
> > So the approach we took was a bit different to exactly solve these
> > problem, and to also not over flush too much. here is what we did.
> > 
> > * At vm_operations_struct we also override the .close vector (say call it dax_vm_close)
> > 
> > * At dax_vm_close() on writable files call ->fsync(,vma->vm_start, vma->vm_end,)
> >   (We have an inode flag if the file was actually dirtied, but even if not, that will
> >    not be that bad, so a file was opened for write, mmapped, but actually never
> >    modified. Not a lot of these, and the do nothing cl_flushing is very fast)
> > 
> > * At ->fsync() do the actual cl_flush for all cases but only iff
> > 	if (mapping_mapped(inode->i_mapping) == 0)
> > 		return 0;
> > 
> >   This is because data written not through mmap is already persistent and we
> >   do not need the cl_flushing
> > 
> > Apps expect all these to work:
> > 1. open mmap m-write msync ... close
> > 2. open mmap m-write fsync ... close
> > 3. open mmap m-write unmap ... fsync close
> > 
> > 4. open mmap m-write sync ...
> 
> So basically you made close have an implicit fsync?  What about the flow that
> looks like this:
> 
> 5. open mmap close m-write
> 
> This guy definitely needs an msync/fsync at the end to make sure that the
> m-write becomes durable.  

We can sync on pte_dirty() during zap_page_range(): it's practically free,
since we page walk anyway.

With this approach it probably makes sense to come back to page walk on
msync() side too to be consistent wrt pte_dirty() meaning.

> Also, the CLOSE(2) man page specifically says that a flush does not occur at
> close:
> 	A successful close does not guarantee that the data has been
> 	successfully  saved  to  disk,  as  the  kernel defers  writes.   It
> 	is not common for a filesystem to flush the buffers when the stream is
> 	closed.  If you need to be sure that the data is physically stored,
> 	use fsync(2).  (It will depend on the disk  hardware  at this point.)
> 
> I don't think that adding an implicit fsync to close is the right solution -
> we just need to get msync and fsync correctly working.

I doesn't mean we can't sync if we can do without noticible performance
degradation.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

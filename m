Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 398DB6B0253
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 21:02:41 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id c21so265044578ioj.5
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 18:02:41 -0800 (PST)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id z29si2135132ioi.111.2016.11.28.18.02.39
        for <linux-mm@kvack.org>;
        Mon, 28 Nov 2016 18:02:40 -0800 (PST)
Date: Tue, 29 Nov 2016 13:02:33 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 3/6] dax: add tracepoint infrastructure, PMD tracing
Message-ID: <20161129020233.GE28177@dastard>
References: <1479926662-21718-1-git-send-email-ross.zwisler@linux.intel.com>
 <1479926662-21718-4-git-send-email-ross.zwisler@linux.intel.com>
 <20161125030059.GY31101@dastard>
 <20161128224651.GA1243@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161128224651.GA1243@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Steven Rostedt <rostedt@goodmis.org>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

On Mon, Nov 28, 2016 at 03:46:51PM -0700, Ross Zwisler wrote:
> On Fri, Nov 25, 2016 at 02:00:59PM +1100, Dave Chinner wrote:
> > On Wed, Nov 23, 2016 at 11:44:19AM -0700, Ross Zwisler wrote:
> > > Tracepoints are the standard way to capture debugging and tracing
> > > information in many parts of the kernel, including the XFS and ext4
> > > filesystems.  Create a tracepoint header for FS DAX and add the first DAX
> > > tracepoints to the PMD fault handler.  This allows the tracing for DAX to
> > > be done in the same way as the filesystem tracing so that developers can
> > > look at them together and get a coherent idea of what the system is doing.
> > > 
> > > I added both an entry and exit tracepoint because future patches will add
> > > tracepoints to child functions of dax_iomap_pmd_fault() like
> > > dax_pmd_load_hole() and dax_pmd_insert_mapping(). We want those messages to
> > > be wrapped by the parent function tracepoints so the code flow is more
> > > easily understood.  Having entry and exit tracepoints for faults also
> > > allows us to easily see what filesystems functions were called during the
> > > fault.  These filesystem functions get executed via iomap_begin() and
> > > iomap_end() calls, for example, and will have their own tracepoints.
> > > 
> > > For PMD faults we primarily want to understand the faulting address and
> > > whether it fell back to 4k faults.  If it fell back to 4k faults the
> > > tracepoints should let us understand why.
> > > 
> > > I named the new tracepoint header file "fs_dax.h" to allow for device DAX
> > > to have its own separate tracing header in the same directory at some
> > > point.
> > > 
> > > Here is an example output for these events from a successful PMD fault:
> > > 
> > > big-2057  [000] ....   136.396855: dax_pmd_fault: shared mapping write
> > > address 0x10505000 vm_start 0x10200000 vm_end 0x10700000 pgoff 0x200
> > > max_pgoff 0x1400
> > > 
> > > big-2057  [000] ....   136.397943: dax_pmd_fault_done: shared mapping write
> > > address 0x10505000 vm_start 0x10200000 vm_end 0x10700000 pgoff 0x200
> > > max_pgoff 0x1400 NOPAGE
> > 
> > Can we make the output use the same format as most of the filesystem
> > code? i.e. the output starts with backing device + inode number like
> > so:
> > 
> > 	xfs_ilock:            dev 8:96 ino 0x493 flags ILOCK_EXCL....
> > 
> > This way we can filter the output easily across both dax and
> > filesystem tracepoints with 'grep "ino 0x493"'...
> 
> I think I can include the inode number, which I have via mapping->host.  Am I
> correct in assuming "struct inode.i_ino" will always be the same as
> "struct xfs_inode.i_ino"?

Yes - just use inode.i_ino.

> Unfortunately I don't have access to the major/minor (the dev_t) until I call
> iomap_begin(). 

In general, filesystem tracing uses inode->sb->s_dev as the
identifier. NFS, gfs2, XFS, ext4 and others all use this.

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

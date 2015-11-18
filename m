Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id AA0526B0038
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 12:00:25 -0500 (EST)
Received: by qgea14 with SMTP id a14so32101746qge.0
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 09:00:25 -0800 (PST)
Received: from iolanthe.rowland.org (iolanthe.rowland.org. [192.131.102.54])
        by mx.google.com with SMTP id h35si3010076qgh.126.2015.11.18.09.00.24
        for <linux-mm@kvack.org>;
        Wed, 18 Nov 2015 09:00:24 -0800 (PST)
Date: Wed, 18 Nov 2015 12:00:23 -0500 (EST)
From: Alan Stern <stern@rowland.harvard.edu>
Subject: Allocating DMA-able memory for user programs
In-Reply-To: <1447831502.5522.5.camel@suse.com>
Message-ID: <Pine.LNX.4.44L0.1511181123220.1688-100000@iolanthe.rowland.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Oliver Neukum <oneukum@suse.com>, "Steinar H. Gunderson" <sgunderson@bigfoot.com>, Markus Rechberger <mrechberger@gmail.com>, USB list <linux-usb@vger.kernel.org>

Memory management folk:

People have been complaining about memory-related problems with their 
userspace USB drivers.  There are two basic issues:

	Memory fragmentation eventually prevents the kernel from 
	allocating contiguous buffers large enough to hold the I/O 
	data.  Such buffers currently have to be allocated for
	each individual I/O transfer.

	Copying data back and forth between the userspace and kernel
	buffers wastes a lot of time.

The ideal solution, of course, is to use some form of zerocopy I/O, 
telling the hardware to DMA to/from the userspace buffer directly.  
However, we are under some constraints that make this difficult.

	Mapping a userspace buffer for DMA implies using some form of
	scatter-gather, because pages with adjacent virtual addresses
	generally are not physically adjacent.  But the USB kernel
	drivers do not support scatter-gather for isochronous
	transfers, only for bulk transfers (and the complaints here
	are concerned with isochronous).

	Even if scatter-gather weren't an issue, user memory pages
	are not always usable for hardware DMA.  Lots of USB 
	controllers do only 32-bit DMA, so the pages containing the
	user buffer would have to be located physically below 4 GB.
	(If an IOMMU is present this may not matter, but plenty of
	lower-end systems don't have an IOMMU.)

	We want to avoid using automatic bounce buffers, for two
	reasons.  First, they obviously defeat the purpose of
	zerocopy I/O.  Second, isochronous READ transfers often
	leave gaps in the data buffer.  (For example, a buffer might
	be set up to hold two 32-byte transfers, but the first
	transfer might only receive 20 bytes of data.  The buffer
	would end up containing 20 bytes of data read in, followed
	by a 12-byte gap holding stale data -- whatever happened to be 
	there before -- followed by 32 bytes of data read in.)  If we 
	use a bounce buffer automatically allocated in the kernel, we
	have no way to prevent the stale data in the gaps from being
	copied back to userspace, which would be a security leak.

The only solution we have come up with is to create a device-specific
mmap(2) implementation that would allocate contiguous pages within the
device's DMA mask and map them into the user's virtual address space.  
The user program could then use these pages as a buffer to get true
zerocopy I/O.

There's the potential issue of exhausting a limited resource (memory
below 4 GB), but we can take care of that by placing on overall cap on
the amount of memory allocated using this mechanism.

Does this seem reasonable?  I'm not certain about the wisdom of
creating an API for allocating and locking pages below 4 GB and then
hiding it away in the USB subsystem.  But if you folks say it's okay, 
we'll go ahead and do it.

Alan Stern

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

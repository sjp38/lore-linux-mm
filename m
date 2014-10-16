Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id AE7136B0038
	for <linux-mm@kvack.org>; Thu, 16 Oct 2014 15:39:25 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id eu11so4071280pac.0
        for <linux-mm@kvack.org>; Thu, 16 Oct 2014 12:39:25 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id hu1si18771486pbb.245.2014.10.16.12.39.24
        for <linux-mm@kvack.org>;
        Thu, 16 Oct 2014 12:39:24 -0700 (PDT)
Date: Thu, 16 Oct 2014 15:39:21 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v11 02/21] block: Change direct_access calling convention
Message-ID: <20141016193921.GC11522@wil.cx>
References: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com>
 <1411677218-29146-3-git-send-email-matthew.r.wilcox@intel.com>
 <20141016084550.GA19075@thinkos.etherlink>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141016084550.GA19075@thinkos.etherlink>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Oct 16, 2014 at 10:45:50AM +0200, Mathieu Desnoyers wrote:
> > -static int
> > +static long
> >  axon_ram_direct_access(struct block_device *device, sector_t sector,
> > -		       void **kaddr, unsigned long *pfn)
> > +		       void **kaddr, unsigned long *pfn, long size)
> 
> Why "long" as type for size ? What is the intent to have it signed, and
> why using a 32-bit type on 32-bit architectures rather than 64-bit ?
> Can we run into issues if we try to map a >2GB file on 32-bit
> architectures ?

The interface requires that the entirety of the pmem be mapped at
all times (see the void **kaddr).  So the total amount of pmem in the
system can't be larger than 4GB on a 32-bit system.  On x86-32, that's
actually limited to 1GB (because we give userspace 3GB), so the problem
doesn't come up.  Maybe this would be more of a potetial problem on
other architectures.

As noted elsewhere in the thread, it would be possible, and maybe
desirable, to remove the need to have all of pmem mapped into the kernel
address space at all times, but I'm not looking to solve that problem
with this patch-set.

The intent of having it signed is that users pass in the size they want
to have and are returned the size they actually got.  Since the function
must be able to return an error, keeping size signed is natural.

> > +long bdev_direct_access(struct block_device *bdev, sector_t sector,
> > +			void **addr, unsigned long *pfn, long size)
> > +{
> > +	long avail;
> > +	const struct block_device_operations *ops = bdev->bd_disk->fops;
> > +
> > +	if (size < 0)
> > +		return size;
> 
> I'm wondering how we should handle size == 0 here. Should it be accepted
> or refused ?

It is a bit of a bizarre case.  I'm inclined to the current behaviour
of saying "this is the address where you can access zero bytes" :-)

But maybe it indicates a bug in the caller, and being noisy about it
would result in the caller getting fixed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

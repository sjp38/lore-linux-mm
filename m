Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 759C76B0036
	for <linux-mm@kvack.org>; Fri, 31 Jan 2014 00:45:36 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id z10so3890238pdj.19
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 21:45:36 -0800 (PST)
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTP id ui8si9137409pac.3.2014.01.30.21.45.34
        for <linux-mm@kvack.org>;
        Thu, 30 Jan 2014 21:45:35 -0800 (PST)
Message-ID: <1391147127.2181.159.camel@dabdike.int.hansenpartnership.com>
Subject: Re: [PATCH] block devices: validate block device capacity
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Thu, 30 Jan 2014 21:45:27 -0800
In-Reply-To: <alpine.LRH.2.02.1401302116180.9767@file01.intranet.prod.int.rdu2.redhat.com>
References: 
	<alpine.LRH.2.02.1401301531040.29912@file01.intranet.prod.int.rdu2.redhat.com>
	   <1391122163.2181.103.camel@dabdike.int.hansenpartnership.com>
	   <alpine.LRH.2.02.1401301805590.19506@file01.intranet.prod.int.rdu2.redhat.com>
	  <1391125027.2181.114.camel@dabdike.int.hansenpartnership.com>
	  <alpine.LRH.2.02.1401301905520.25766@file01.intranet.prod.int.rdu2.redhat.com>
	 <1391132609.2181.131.camel@dabdike.int.hansenpartnership.com>
	 <alpine.LRH.2.02.1401302116180.9767@file01.intranet.prod.int.rdu2.redhat.com>
Content-Type: text/plain; charset="ISO-8859-15"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>, "Alasdair G. Kergon" <agk@redhat.com>, Mike Snitzer <msnitzer@redhat.com>, dm-devel@redhat.com, "David S. Miller" <davem@davemloft.net>, linux-ide@vger.kernel.org, linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org, Neil Brown <neilb@suse.de>, linux-raid@vger.kernel.org, linux-mm@kvack.org

On Thu, 2014-01-30 at 21:43 -0500, Mikulas Patocka wrote:
> 
> On Thu, 30 Jan 2014, James Bottomley wrote:
> 
> > > A device may be accessed direcly (by opening /dev/sdX) and it creates a 
> > > mapping too - thus, the size of a mapping limits the size of a block 
> > > device.
> > 
> > Right, that's what I suspected below.  We can't damage large block
> > support on filesystems just because of this corner case.
> 
> Devices larger than 16TiB never worked on 32-bit kernel, so this patch 
> isn't damaging anything.

expectations: 32 bit with CONFIG_LBDAF is supposed to be able to do
almost everything 64 bits can

> Note that if you attach a 16TiB block device, don't open it and mount it, 
> it still won't work, because the buffer cache uses the page cache (see the 
> function __find_get_block_slow and the variable "pgoff_t index" - that 
> variable would overflow if the filesystem accessed a buffer beyond 16TiB).

That depends on the layout of the fs metadata.

> > > The main problem is that pgoff_t has 4 bytes - chaning it to 8 bytes may 
> > > fix it - but there may be some hidden places where pgoff is converted to 
> > > unsigned long - who knows, if they exist or not?
> > 
> > I don't think we want to do that ... it will make struct page fatter and
> > have knock on impacts in the radix tree code.  To fix this, we need to
> > make the corner case (i.e. opening large block devices without a
> > filesystem) bear the pain.  It sort of looks like we want to do a linear
> > array of mappings of 64TB for the device so the page cache calculations
> > don't overflow.
> 
> The code that reads and writes data to block devices and files is shared - 
> the functions in mm/filemap.c work for both files and block devices.

Yes.

> So, if you want 64-bit page offsets, you need to increase pgoff_t size, 
> and that will increase the limit for both files and block devices.

No.  The point is the page cache mapping of the device uses a
manufactured inode saved in the backing device. It looks fixable in the
buffer code before the page cache gets involved.

> You shouldn't have separate functions for managing pages on files and 
> separate functions for managing pages on block devices - that would 
> increase code size and cause maintenance problems.

It wouldn't it would add structure to the buffer cache for large
devices.

> > > Though, we need to know if the people who designed memory management agree 
> > > with changing pgoff_t to 64 bits.
> > 
> > I don't think we can change the size of pgoff_t ... because it won't
> > just be that, it will be other problems like the radix tree.
> 
> If we can't change it, then we must stay with the current 16TiB limit. 
> There's no other way.
> 
> > However, you also have to bear in mind that truncating large block
> > device support to 64TB on 32 bits is a technical ABI break.  Hopefully
> > it is only technical because I don't know of any current consumer block
> > device that is 64TB yet, but anyone who'd created a filesystem >64TB
> > would find it no-longer mounted on 32 bits.
> > James
> 
> It is not ABI break, because block devices larger than 16TiB never worked 
> on 32-bit architectures. So it's better to refuse them outright, than to 
> cause subtle lockups or data corruption.

An ABI is a contract between the userspace and the kernel.  Saying we
can remove a clause in the contract because no-one ever exercised it and
not call it changing the contract is sophistry.  The correct thing to do
would be to call it a bug and fix it.

In a couple of short years we'll be over 16TB for hard drives.  I don't
really want to be the one explaining to the personal storage people that
the only way to install a 16+TB drive in their arm (or quark) based
Linux systems is a processor upgrade.

I suppose there are a couple of possibilities: pgoff_t + radix tree
expansion or double radix tree in the buffer code.  This should probably
be taken to fsdevel where they might have better ideas.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id BC6FC6B0036
	for <linux-mm@kvack.org>; Thu, 30 Jan 2014 20:43:34 -0500 (EST)
Received: by mail-pb0-f53.google.com with SMTP id md12so3841313pbc.40
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 17:43:34 -0800 (PST)
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTP id i4si8515988pad.170.2014.01.30.17.43.33
        for <linux-mm@kvack.org>;
        Thu, 30 Jan 2014 17:43:33 -0800 (PST)
Message-ID: <1391132609.2181.131.camel@dabdike.int.hansenpartnership.com>
Subject: Re: [PATCH] block devices: validate block device capacity
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Thu, 30 Jan 2014 17:43:29 -0800
In-Reply-To: <alpine.LRH.2.02.1401301905520.25766@file01.intranet.prod.int.rdu2.redhat.com>
References: 
	<alpine.LRH.2.02.1401301531040.29912@file01.intranet.prod.int.rdu2.redhat.com>
	  <1391122163.2181.103.camel@dabdike.int.hansenpartnership.com>
	  <alpine.LRH.2.02.1401301805590.19506@file01.intranet.prod.int.rdu2.redhat.com>
	 <1391125027.2181.114.camel@dabdike.int.hansenpartnership.com>
	 <alpine.LRH.2.02.1401301905520.25766@file01.intranet.prod.int.rdu2.redhat.com>
Content-Type: text/plain; charset="ISO-8859-15"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>, "Alasdair G. Kergon" <agk@redhat.com>, Mike Snitzer <msnitzer@redhat.com>, dm-devel@redhat.com, "David S. Miller" <davem@davemloft.net>, linux-ide@vger.kernel.org, linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org, Neil Brown <neilb@suse.de>, linux-raid@vger.kernel.org, linux-mm@kvack.org

On Thu, 2014-01-30 at 19:20 -0500, Mikulas Patocka wrote:
> 
> On Thu, 30 Jan 2014, James Bottomley wrote:
> 
> > On Thu, 2014-01-30 at 18:10 -0500, Mikulas Patocka wrote:
> > > 
> > > On Thu, 30 Jan 2014, James Bottomley wrote:
> > > 
> > > > Why is this?  the whole reason for CONFIG_LBDAF is supposed to be to
> > > > allow 64 bit offsets for block devices on 32 bit.  It sounds like
> > > > there's somewhere not using sector_t ... or using it wrongly which needs
> > > > fixing.
> > > 
> > > The page cache uses unsigned long as a page index. Therefore, if unsigned 
> > > long is 32-bit, the block device may have at most 2^32-1 pages.
> > 
> > Um, that's the index into the mapping, not the device; a device can have
> > multiple mappings and each mapping has a radix tree of pages.  For most
> > filesystems a mapping is equivalent to a file, so we can have large
> > filesystems, but they can't have files over actually 4GB on 32 bits
> > otherwise mmap fails.
> 
> A device may be accessed direcly (by opening /dev/sdX) and it creates a 
> mapping too - thus, the size of a mapping limits the size of a block 
> device.

Right, that's what I suspected below.  We can't damage large block
support on filesystems just because of this corner case.

> The main problem is that pgoff_t has 4 bytes - chaning it to 8 bytes may 
> fix it - but there may be some hidden places where pgoff is converted to 
> unsigned long - who knows, if they exist or not?

I don't think we want to do that ... it will make struct page fatter and
have knock on impacts in the radix tree code.  To fix this, we need to
make the corner case (i.e. opening large block devices without a
filesystem) bear the pain.  It sort of looks like we want to do a linear
array of mappings of 64TB for the device so the page cache calculations
don't overflow.

> > Are we running into a problems with struct address_space where we've
> > assumed the inode belongs to the file and lvm is doing something where
> > it's the whole device?
> 
> lvm creates a 64TiB device, udev runs blkid on that device and blkid opens 
> the device and gets stuck because of unsigned long overflow.

well a simple open won't cause this ... it must be trying to read the
end of the device for some reason.  But anyway, the way to fix this is
to fix the large block open as a corner case.

> > > > > On 32-bit architectures, we must limit block device size to
> > > > > PAGE_SIZE*(2^32-1).
> > > > 
> > > > So you're saying CONFIG_LBDAF can never work, why?
> > > > 
> > > > James
> > > 
> > > CONFIG_LBDAF works, but it doesn't allow unlimited capacity: on x86, 
> > > without CONFIG_LBDAF, the limit is 2TiB. With CONFIG_LBDAF, the limit is 
> > > 16TiB (4096*2^32).
> > 
> > I don't think the people who did the large block device work expected to
> > gain only 3 bits for all their pain.
> > 
> > James
> 
> One could change it to have three choices:
> 2TiB limit - 32-bit sector_t and 32-bit pgoff_t
> 16TiB limit - 64-bit sector_t and 32-bit pgoff_t
> 32PiB limit - 64-bit sector_t and 64-bit pgoff_t
> 
> Though, we need to know if the people who designed memory management agree 
> with changing pgoff_t to 64 bits.

I don't think we can change the size of pgoff_t ... because it won't
just be that, it will be other problems like the radix tree.

However, you also have to bear in mind that truncating large block
device support to 64TB on 32 bits is a technical ABI break.  Hopefully
it is only technical because I don't know of any current consumer block
device that is 64TB yet, but anyone who'd created a filesystem >64TB
would find it no-longer mounted on 32 bits.
James

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

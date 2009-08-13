Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 708366B004F
	for <linux-mm@kvack.org>; Thu, 13 Aug 2009 14:09:00 -0400 (EDT)
Message-ID: <4A8456B6.9050503@interlog.com>
Date: Thu, 13 Aug 2009 14:08:54 -0400
From: Douglas Gilbert <dgilbert@interlog.com>
Reply-To: dgilbert@interlog.com
MIME-Version: 1.0
Subject: Re: Discard support (was Re: [PATCH] swap: send callback when swap
 slot is freed)
References: <200908122007.43522.ngupta@vflare.org> <Pine.LNX.4.64.0908122312380.25501@sister.anvils> <20090813151312.GA13559@linux.intel.com>
In-Reply-To: <20090813151312.GA13559@linux.intel.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Matthew Wilcox <willy@linux.intel.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nitin Gupta <ngupta@vflare.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Matthew Wilcox wrote:
> On Wed, Aug 12, 2009 at 11:48:27PM +0100, Hugh Dickins wrote:
>> But fundamentally, though I can see how this cutdown communication
>> path is useful to compcache, I'd much rather deal with it by the more
>> general discard route if we can.  (I'm one of those still puzzled by
>> the way swap is mixed up with block device in compcache: probably
>> because I never found time to pay attention when you explained.)
>>
>> You're right to question the utility of the current swap discard
>> placement.  That code is almost a year old, written from a position
>> of great ignorance, yet only now do we appear to be on the threshold
>> of having an SSD which really supports TRIM (ah, the Linux ATA TRIM
>> support seems to have gone missing now, but perhaps it's been
>> waiting for a reality to check against too - Willy?).
> 
> I am indeed waiting for hardware with TRIM support to appear on my
> desk before resubmitting the TRIM code.  It'd also be nice to be able to
> get some performance numbers.
> 
>> I won't be surprised if we find that we need to move swap discard
>> support much closer to swap_free (though I know from trying before
>> that it's much messier there): in which case, even if we decided to
>> keep your hotline to compcache (to avoid allocating bios etc.), it
>> would be better placed alongside.
> 
> It turns out there are a lot of tradeoffs involved with discard, and
> they're different between TRIM and UNMAP.
> 
> Let's start with UNMAP.  This SCSI command is used by giant arrays.
> They want to do Thin Provisioning, so allocate physical storage to virtual
> LUNs on demand, and want to deallocate it when they get an UNMAP command.
> They allocate storage in large chunks (hundreds of kilobytes at a time).
> They only care about discards that enable them to free an entire chunk.
> The vast majority of users *do not care* about these arrays, because
> they don't have one, and will never be able to afford one.  We should
> ignore the desires of these vendors when designing our software.

Yes, the SCSI UNMAP command has high end uses with
maximum and optimal values specified in the Block Limits
VPD page. There is nothing stopping the SCSI UNMAP command
trimming a single logical block.

Being pedantic again there is no ATA TRIM command, there is
DATA SET MANAGEMENT command with a "Trim" bit, a count
field (2 byte, permitting up to 65536, 512 byte blocks to
be trimmed) and a LBA field which is reserved (??
d2015r1a.pdf).

As I noted a week ago we will need to revisit the SATL code
in libata if SAT-2 in its current form gets approved. Discard
support may be another reason to visit that SATL code. Since
we have many SATA devices being viewed as "SCSI" due to
libata's SATL, mapping the SCSI UNMAP command ** to one or more
ATA DATA SET MANAGEMENT commands may be helpful. IMO that
would be simpler than upper layers needing to worry about
using the SCSI ATA PASS-THROUGH commands to get Trim
functionality.


** and the SCSI WRITE SAME commands with their Unmap bits set

Doug Gilbert

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

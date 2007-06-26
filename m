Message-ID: <468082FF.6090704@yahoo.com.au>
Date: Tue, 26 Jun 2007 13:07:43 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 1/3] add the fsblock layer
References: <20070624014528.GA17609@wotan.suse.de>	<20070624014613.GB17609@wotan.suse.de>	<18046.63436.472085.535177@notabene.brown>	<467F71C6.6040204@yahoo.com.au>	<20070625122906.GB12446@think.oraclecorp.com>	<46807B32.6050302@yahoo.com.au> <18048.32372.40011.10896@notabene.brown>
In-Reply-To: <18048.32372.40011.10896@notabene.brown>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Neil Brown <neilb@suse.de>
Cc: Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Neil Brown wrote:
> On Tuesday June 26, nickpiggin@yahoo.com.au wrote:
> 
>>Chris Mason wrote:
>>
>>>The block device pagecache isn't special, and certainly isn't that much
>>>code.  I would suggest keeping it buffer head specific and making a
>>>second variant that does only fsblocks.  This is mostly to keep the
>>>semantics of PagePrivate sane, lets not fuzz the line.
>>
>>That would require a new inode and address_space for the fsblock
>>type blockdev pagecache, wouldn't it? I just can't think of a
>>better non-intrusive way of allowing a buffer_head filesystem and
>>an fsblock filesystem to live on the same blkdev together.
> 
> 
> I don't think they would ever try to.  Both filesystems would bd_claim
> the blkdev, and only one would win.

Hmm OK, I might have confused myself thinking about partitions...

> The issue is more of a filesystem sharing a blockdev with the
> block-special device (i.e. open("/dev/sda1"), read) isn't it?
> 
> If a filesystem wants to attach information to the blockdev pagecache
> that is different to what blockdev want to attach, then I think "Yes"
> - a new inode and address space is what it needs to create.
> 
> Then you get into consistency issues between the metadata and direct
> blockdevice access.  Do we care about those?

Yeah that issue is definitely a real one. The problem is not just
consistency, but "how do the block device aops even know that the
PG_private page they have has buffer heads or fsblocks", so it is
an oopsable condition rather than just a plain consistency issue
(consistency is already not guaranteed).

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

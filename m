Received: from renko.ucs.ed.ac.uk (renko.ucs.ed.ac.uk [129.215.13.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA04386
	for <linux-mm@kvack.org>; Thu, 23 Jul 1998 08:51:02 -0400
Date: Thu, 23 Jul 1998 13:22:00 +0100
Message-Id: <199807231222.NAA04748@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: More info: 2.1.108 page cache performance on low memory
In-Reply-To: <87iukovq42.fsf@atlas.CARNet.hr>
References: <199807131653.RAA06838@dax.dcs.ed.ac.uk>
	<m190lxmxmv.fsf@flinx.npwt.net>
	<199807141730.SAA07239@dax.dcs.ed.ac.uk>
	<m14swgm0am.fsf@flinx.npwt.net>
	<87d8b370ge.fsf@atlas.CARNet.hr>
	<m1pvf3jeob.fsf@flinx.npwt.net>
	<87hg0c6fz3.fsf@atlas.CARNet.hr>
	<199807221040.LAA00832@dax.dcs.ed.ac.uk>
	<87iukovq42.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: Zlatko.Calusic@CARNet.hr
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "Eric W. Biederman" <ebiederm+eric@npwt.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On 23 Jul 1998 12:06:05 +0200, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
said:

> Yes, I'm aware of lots of problems that would need to be resolved in
> order to get rid of buffer cache (probably just to reinvent it, as you
> said :)). But, then again, if I understand you completely, we will
> always have the buffer cache as it is implemented now?!

I don't see any pressing need to replace it.  Changing the _management_
of the buffer cache, and doing things like modifying the file write
paths, are different issues which we probably should do.

Ultimately we need synchronised access to individual blocks of a block
device.  We need something which can talk directly to the block device
drivers.  Once you have that in place, with a suitable form of buffering
added, you have something that necessarily looks sufficiently like the
buffer cache that I can't see a need to get rid of the current one.
That doesn't mean we can't improve the current system, but improving and
replacing are two very different things.

> Non-page aligned filesystem metadata, really looks like a hard problem
> to solve without buffer cache mechanism, that's out of question, but
> is there any posibility that we will introduce some logic to use
> somewhat improved page cache with buffer head functionality (or
> similar) that will allow us to use page cache in similar way that we
> use buffer cache now?

We still need a way to go to the block device drivers.  As you say, we
still need the buffer_head.  We _already_ have a way of using
buffer_heads without full buffers allocated in the cache (the swapper
uses such temporary buffer_heads, for example).  We also need mechanisms
for things like loop devices and RAID.  There's a lot going on in the
buffer cache!

> Two days ago, I rebooted unpatched 2.1.110 with mem=32m, just to find
> it dead today:

> I left at cca 22:00h on Jul 21.

> Jul 21 22:16:43 atlas kernel: eth0: media is 100Mb/s full duplex. 
> Jul 21 22:34:31 atlas kernel: eth0: Insufficient memory; nuking
> packet. 

I've got a fix for some of the (serious) fragmentation problems in 110.
111-pre1 with the fixes is looking really, really good.  Post with patch
to follow.

> My observations with low memory machines led me to conclusion that
> inode memory grows monotonically until it takes cca 1.5MB of
> unswappable memory. That is around half of usable memory on 5MB
> machine. You seconded that in private mail you sent me in January.

Does this still happen?  My own tests show 110 behaving very much better
in this respect.

> Is there any possibility that we could use slab allocator for inode
> allocation/deallocation?

Yes.  I'll have to benchmark to see how much better it gets, but (a) 110
seems to need it less anyway, and (b) it opens up a whole new pile of
synchronisation problems in fs/inode.c, which can currently make the
assumption that an inode structure can move lists but can never actually
die if the inode spinlock is dropped.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org

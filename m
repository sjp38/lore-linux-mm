Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA04837
	for <linux-mm@kvack.org>; Thu, 23 Jul 1998 10:07:34 -0400
Subject: Re: More info: 2.1.108 page cache performance on low memory
References: <199807131653.RAA06838@dax.dcs.ed.ac.uk> 	<m190lxmxmv.fsf@flinx.npwt.net> 	<199807141730.SAA07239@dax.dcs.ed.ac.uk> 	<m14swgm0am.fsf@flinx.npwt.net> 	<87d8b370ge.fsf@atlas.CARNet.hr> 	<m1pvf3jeob.fsf@flinx.npwt.net> 	<87hg0c6fz3.fsf@atlas.CARNet.hr> 	<199807221040.LAA00832@dax.dcs.ed.ac.uk> 	<87iukovq42.fsf@atlas.CARNet.hr> <199807231222.NAA04748@dax.dcs.ed.ac.uk>
Reply-To: Zlatko.Calusic@CARNet.hr
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 23 Jul 1998 16:07:23 +0200
In-Reply-To: "Stephen C. Tweedie"'s message of "Thu, 23 Jul 1998 13:22:00 +0100"
Message-ID: <87zpe0u0dg.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: "Eric W. Biederman" <ebiederm+eric@npwt.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" <sct@redhat.com> writes:

> Hi,
> 
> On 23 Jul 1998 12:06:05 +0200, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
> said:
> 
> > Yes, I'm aware of lots of problems that would need to be resolved in
> > order to get rid of buffer cache (probably just to reinvent it, as you
> > said :)). But, then again, if I understand you completely, we will
> > always have the buffer cache as it is implemented now?!
> 
> I don't see any pressing need to replace it.  Changing the _management_
> of the buffer cache, and doing things like modifying the file write
> paths, are different issues which we probably should do.
> 
> Ultimately we need synchronised access to individual blocks of a block
> device.  We need something which can talk directly to the block device
> drivers.  Once you have that in place, with a suitable form of buffering
> added, you have something that necessarily looks sufficiently like the
> buffer cache that I can't see a need to get rid of the current one.
> That doesn't mean we can't improve the current system, but improving and
> replacing are two very different things.
> 

OK, I understand. I needed to hear opinion of someone who *really*
does know how things work.

One of the thoughts that influenced me is text at:

http://www.caip.rutgers.edu/~davem/vfsmm.html

but I can't (and won't) pretend that I understand everything that's
mentioned there. :)

Strangely enough, I think I never explained why do *I* think
integrating buffer cache functionality into page cache would (in my
thought) be a good thing. Since both caches are very different, I'm
not sure memory management can be fair enough in some cases.

Take a simple example: two applications, I/O bound, where one is
accessing raw partition (e.g. fsck) and other uses filesystem (web,
ftp...). Question is, how do I know that MM is fair. Maybe page cache
grows too large on behalf of buffer cache, so fsck runs much slower
than it could. Or if buffer cache grows faster (which is not the case,
IMO) then web would be fast, but fsck (or some database accessing raw
partition) could take a penalty.

Integrating both caches could help in these cases, which are not
uncommon (isn't Linux a beautiful multitasker? :)).

All this is consequence of buffer cache buffering raw blocks
(including FS metadata), and page cache buffering FS data.

BUT! if you say buffer cache won't go, then I believe you, just to
make it straight. :)

And thanks for explanation.
I hope my bad English doesn't make you to much trouble understanding.

> > Non-page aligned filesystem metadata, really looks like a hard problem
> > to solve without buffer cache mechanism, that's out of question, but
> > is there any posibility that we will introduce some logic to use
> > somewhat improved page cache with buffer head functionality (or
> > similar) that will allow us to use page cache in similar way that we
> > use buffer cache now?
> 
> We still need a way to go to the block device drivers.  As you say, we
> still need the buffer_head.  We _already_ have a way of using
> buffer_heads without full buffers allocated in the cache (the swapper
> uses such temporary buffer_heads, for example).  We also need mechanisms
> for things like loop devices and RAID.  There's a lot going on in the
> buffer cache!
> 

No doubt!
I never tried to underestimate buffer cache complexness and functionality. :)

> > Two days ago, I rebooted unpatched 2.1.110 with mem=32m, just to find
> > it dead today:
> 
> > I left at cca 22:00h on Jul 21.
> 
> > Jul 21 22:16:43 atlas kernel: eth0: media is 100Mb/s full duplex. 
> > Jul 21 22:34:31 atlas kernel: eth0: Insufficient memory; nuking
> > packet. 
> 
> I've got a fix for some of the (serious) fragmentation problems in 110.
> 111-pre1 with the fixes is looking really, really good.  Post with patch
> to follow.
> 

Nice, I will test it right away.

> > My observations with low memory machines led me to conclusiaon that
> > inode memory grows monotonically until it takes cca 1.5MB of
> > unswappable memory. That is around half of usable memory on 5MB
> > machine. You seconded that in private mail you sent me in January.
> 
> Does this still happen?  My own tests show 110 behaving very much better
> in this respect.

Huh, my apology needed here.

My tests on lowmem machine took place around New Year. I have that
386DX/40 with 5MB at home, but I'm rarely home. :)

So, everything I said reflects a situation before 7 months. I didn't
made any tests in the mean time. Here, at work, Linux is installed on
more appropriate hardware. :)

> 
> > Is there any possibility that we could use slab allocator for inode
> > allocation/deallocation?
> 
> Yes.  I'll have to benchmark to see how much better it gets, but (a) 110
> seems to need it less anyway, and (b) it opens up a whole new pile of
> synchronisation problems in fs/inode.c, which can currently make the
> assumption that an inode structure can move lists but can never actually
> die if the inode spinlock is dropped.
> 

Wish you luck!

Regards,
-- 
Posted by Zlatko Calusic           E-mail: <Zlatko.Calusic@CARNet.hr>
---------------------------------------------------------------------
		       Don't mess with Murphy.
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org

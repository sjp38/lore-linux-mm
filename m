Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id GAA03627
	for <linux-mm@kvack.org>; Thu, 23 Jul 1998 06:06:21 -0400
Subject: Re: More info: 2.1.108 page cache performance on low memory
References: <199807131653.RAA06838@dax.dcs.ed.ac.uk> 	<m190lxmxmv.fsf@flinx.npwt.net> 	<199807141730.SAA07239@dax.dcs.ed.ac.uk> 	<m14swgm0am.fsf@flinx.npwt.net> 	<87d8b370ge.fsf@atlas.CARNet.hr> 	<m1pvf3jeob.fsf@flinx.npwt.net> 	<87hg0c6fz3.fsf@atlas.CARNet.hr> <199807221040.LAA00832@dax.dcs.ed.ac.uk>
Reply-To: Zlatko.Calusic@CARNet.hr
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 23 Jul 1998 12:06:05 +0200
In-Reply-To: "Stephen C. Tweedie"'s message of "Wed, 22 Jul 1998 11:40:48 +0100"
Message-ID: <87iukovq42.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: "Eric W. Biederman" <ebiederm+eric@npwt.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" <sct@redhat.com> writes:

> Hi,
> 
> On 20 Jul 1998 11:15:12 +0200, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
> said:
> 
> > I don't know if its easy, but we probably should get rid of buffer
> > cache completely, at one point in time. It's hard to balance things
> > between two caches, not to mention other memory objects in kernel.
> 
> No, we need the buffer cache for all sorts of things.  You'd have to
> reinvent it if you got rid of it, since it is the main mechanism by
> which we can reliably label IO for the block device driver layer, and we
> also cache non-page-aligned filesystem metadata there.

Yes, I'm aware of lots of problems that would need to be resolved in
order to get rid of buffer cache (probably just to reinvent it, as you
said :)). But, then again, if I understand you completely, we will
always have the buffer cache as it is implemented now?!

Non-page aligned filesystem metadata, really looks like a hard problem
to solve without buffer cache mechanism, that's out of question, but
is there any posibility that we will introduce some logic to use
somewhat improved page cache with buffer head functionality (or
similar) that will allow us to use page cache in similar way that we
use buffer cache now?

Even I didn't investigate it that lot, I still see Erics work on
adding dirty page functionality as a step toward this.

Disclaimer: I really don't see myself as any kind of expert in this
area. But that's a one motivation more for me to try to understand
things that I don't have at control presently. :)

I've been browsing Linux source actively for the last 12 months, as
time permitted. MM area is by far of the biggest interest for me. But,
I'm still learning.

> 
> > Then again, I have made some changes that make my system very stable
> > wrt memory fragmentation:
> 
> > #define SLAB_MIN_OBJS_PER_SLAB  1
> > #define SLAB_BREAK_GFP_ORDER    1
> 
> The SLAB_BREAK_GFP_ORDER one is the important one on low memory
> configurations.  I need to use this setting to get 2.1.110 to work at
> all with NFS in low memory.
> 
> > I discussed this privately with slab maintainer Mark Hemment, where
> > he pointed out that with this setting slab is probably not as
> > efficient as it could be. Also, slack is bigger, obviously.
> 
> Correct, but then the main user of these larger packets is networking,
> where the memory is typically short lived anyway.

Two days ago, I rebooted unpatched 2.1.110 with mem=32m, just to find
it dead today:

I left at cca 22:00h on Jul 21.

Jul 21 22:16:43 atlas kernel: eth0: media is 100Mb/s full duplex. 
Jul 21 22:34:31 atlas kernel: eth0: Insufficient memory; nuking packet. 
Jul 21 22:34:44 atlas last message repeated 174 times
Jul 22 16:03:40 atlas kernel: eth0: media is TP full duplex. 
Jul 22 16:03:43 atlas kernel: eth0: media is unconnected, link down or incompati
ble connection. 
...

Used to patch every kernel that I download, I forgot how unstable
official kernels are. And that's not good. :(

Machine's only task, when I'm not logged in, is to transfer mail
(fetchmail + sendmail).

> 
> > But system is much more stable, and it is now very *very* hard to get
> > that annoying "Couldn't get a free page..." message than before (with
> > default setup), when it was as easy as clicking a button in the
> > Netscape.
> 
> I can still reproduce it if I let the inode cache grow too large: it
> behaves really badly and seems to lock up rather a lot of memory.  Still
> chasing this one; it's a killer right now.
> 

My observations with low memory machines led me to conclusion that
inode memory grows monotonically until it takes cca 1.5MB of
unswappable memory. That is around half of usable memory on 5MB
machine. You seconded that in private mail you sent me in January.

Is there any possibility that we could use slab allocator for inode
allocation/deallocation?

Reagrds,
-- 
Posted by Zlatko Calusic           E-mail: <Zlatko.Calusic@CARNet.hr>
---------------------------------------------------------------------
		  So much time, and so little to do.
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org

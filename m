Received: from haymarket.ed.ac.uk (haymarket.ed.ac.uk [129.215.128.53])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA30898
	for <linux-mm@kvack.org>; Wed, 22 Jul 1998 10:27:57 -0400
Date: Wed, 22 Jul 1998 11:40:48 +0100
Message-Id: <199807221040.LAA00832@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: More info: 2.1.108 page cache performance on low memory
In-Reply-To: <87hg0c6fz3.fsf@atlas.CARNet.hr>
References: <199807131653.RAA06838@dax.dcs.ed.ac.uk>
	<m190lxmxmv.fsf@flinx.npwt.net>
	<199807141730.SAA07239@dax.dcs.ed.ac.uk>
	<m14swgm0am.fsf@flinx.npwt.net>
	<87d8b370ge.fsf@atlas.CARNet.hr>
	<m1pvf3jeob.fsf@flinx.npwt.net>
	<87hg0c6fz3.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: Zlatko.Calusic@CARNet.hr
Cc: "Eric W. Biederman" <ebiederm+eric@npwt.net>, "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On 20 Jul 1998 11:15:12 +0200, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
said:

> I don't know if its easy, but we probably should get rid of buffer
> cache completely, at one point in time. It's hard to balance things
> between two caches, not to mention other memory objects in kernel.

No, we need the buffer cache for all sorts of things.  You'd have to
reinvent it if you got rid of it, since it is the main mechanism by
which we can reliably label IO for the block device driver layer, and we
also cache non-page-aligned filesystem metadata there.

> Then again, I have made some changes that make my system very stable
> wrt memory fragmentation:

> #define SLAB_MIN_OBJS_PER_SLAB  1
> #define SLAB_BREAK_GFP_ORDER    1

The SLAB_BREAK_GFP_ORDER one is the important one on low memory
configurations.  I need to use this setting to get 2.1.110 to work at
all with NFS in low memory.

> I discussed this privately with slab maintainer Mark Hemment, where
> he pointed out that with this setting slab is probably not as
> efficient as it could be. Also, slack is bigger, obviously.

Correct, but then the main user of these larger packets is networking,
where the memory is typically short lived anyway.

> But system is much more stable, and it is now very *very* hard to get
> that annoying "Couldn't get a free page..." message than before (with
> default setup), when it was as easy as clicking a button in the
> Netscape.

I can still reproduce it if I let the inode cache grow too large: it
behaves really badly and seems to lock up rather a lot of memory.  Still
chasing this one; it's a killer right now.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org

Received: from flecktone.americas.sgi.com (flecktone.americas.sgi.com [192.48.203.135])
	by omx1.americas.sgi.com (8.12.10/8.12.9/linux-outbound_gateway-1.1) with ESMTP id i6MK1L0f014026
	for <linux-mm@kvack.org>; Thu, 22 Jul 2004 15:01:21 -0500
Received: from kzerza.americas.sgi.com (kzerza.americas.sgi.com [128.162.233.27])
	by flecktone.americas.sgi.com (8.12.9/8.12.10/SGI_generic_relay-1.2) with ESMTP id i6MK1LOW43373217
	for <linux-mm@kvack.org>; Thu, 22 Jul 2004 15:01:21 -0500 (CDT)
Date: Thu, 22 Jul 2004 15:01:21 -0500
From: Brent Casavant <bcasavan@sgi.com>
Reply-To: Brent Casavant <bcasavan@sgi.com>
Subject: struct shmem_inode_info lock scaling
Message-ID: <Pine.SGI.4.58.0407221447150.7422@kzerza.americas.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

In my further efforts to improve the page faulting performance of
the mm/shmem.c code, and building upon work that Hugh and I did a
week or two ago, I've run up against the "lock" field of shmem_inode_info
being the next big hurdle.

I've stared at this code upside-right and upside-down, and the best
solution I can even envision is atomic updates of next_index, *i_direct,
and *i_indirect, leaving the remaining fields protected by the lock.
This is assuming, of course, that there's no harm if the remaining
fields are momentarily out-of-sync with the swap entries and next_index,
something which I haven't convinced myself of quite yet.

However, this would be a huge amount of work as there'd be a lot of
operations performed which have to check at various points whether
the state of the inode has changed, and start the operation over again.
This way of going about things seems to be fraught with end cases
and subtle gotchas that, frankly, I don't have the Linux kernel
experience to realize up-front.  And I probably have a realistic view
of how likely I am to get it correct. :)

Before I start hacking on the code and going down such a path, I'd
like to know if any ideas just pop out of anyone's head.  Bear in
mind that this is really only needed for the "internal" types of
mappings, like /dev/zero and System V shared memory, which thanks
to Hugh's work we can now quite easily differentiate from tmpfs
inodes.

Also, before I go down this route, does anyone think that there's
a snowball's chance that this type of change would be acceptable?
I suspect the code diff would be quite substantial by the time I
get done with it.

Thanks,
Brent

-- 
Brent Casavant             bcasavan@sgi.com        Forget bright-eyed and
Operating System Engineer  http://www.sgi.com/     bushy-tailed; I'm red-
Silicon Graphics, Inc.     44.8562N 93.1355W 860F  eyed and bushy-haired.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

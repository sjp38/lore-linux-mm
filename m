Received: from dm.cobaltmicro.com (davem@dm.cobaltmicro.com [209.133.34.35])
	by kvack.org (8.8.7/8.8.7) with ESMTP id TAA07796
	for <linux-mm@kvack.org>; Fri, 8 Jan 1999 19:49:50 -0500
Date: Fri, 8 Jan 1999 16:50:44 -0800
Message-Id: <199901090050.QAA12495@dm.cobaltmicro.com>
From: "David S. Miller" <davem@dm.cobaltmicro.com>
In-reply-to: <Pine.LNX.3.95.990107093746.4270H-100000@penguin.transmeta.com>
	(message from Linus Torvalds on Thu, 7 Jan 1999 09:56:03 -0800 (PST))
Subject: Re: arca-vm-8 [Re: [patch] arca-vm-6, killed kswapd [Re: [patch] new-vm , improvement , [Re: 2.2.0 Bug summary]]]
References: <Pine.LNX.3.95.990107093746.4270H-100000@penguin.transmeta.com>
Sender: owner-linux-mm@kvack.org
To: torvalds@transmeta.com
Cc: ebiederm+eric@ccr.net, andrea@e-mind.com, steve@netplus.net, damonbrent@earthlink.net, reese@isn.net, kalle.andersson@mbox303.swipnet.se, Zlatko.Calusic@CARNet.hr, bmccann@indusriver.com, alan@lxorguk.ukuu.org.uk, bredelin@ucsd.edu, sct@redhat.com, linux-kernel@vger.rutgers.edu, H.H.vanRiel@phys.uu.nl, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

   Date: 	Thu, 7 Jan 1999 09:56:03 -0800 (PST)
   From: Linus Torvalds <torvalds@transmeta.com>

   The positive news is that if I'm right in my suspicions it can only
   happen with shared writable mappings or shared memory segments. The
   bad news is that the bug appears rather old, and no immediate
   solution presents itself.

We could drop the superblock lock right before the actual bread()
call, grab it again right afterwards, then idicate back down to the
original caller that he should restart his search from the beginning
of the toplevel logic in ext2_free_blocks/ext2_new_block.

The second time around a bread() won't happen.

>From a performance standpoint, since we are doing a disk I/O anyways,
the extra software overhead here will be mute.

However, I am concerned about deadlocks in this scheme where the
bread() kicks some other bitmap block back out to disk, and we loop
forever pingponging block bitmap blocks back and forth with no forward
progress being made.  Also the logic in these functions is non-trivial
and making an "obviously correct" patch, ignoring the possible
deadlock mentioned here, might not be easy.

We've had a couple strange issues like this, with recursive superblock
lock problems, recall the quota writeback deadlock Bill Hawes fixed a
few months ago, very similar.

Later,
David S. Miller
davem@dm.cobaltmicro.com
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org

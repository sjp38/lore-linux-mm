Received: from mail.ccr.net (ccr@alogconduit1am.ccr.net [208.130.159.13])
	by kvack.org (8.8.7/8.8.7) with ESMTP id WAA01400
	for <linux-mm@kvack.org>; Thu, 7 Jan 1999 22:43:33 -0500
Subject: Re: arca-vm-8 [Re: [patch] arca-vm-6, killed kswapd [Re: [patch] new-vm , improvement , [Re: 2.2.0 Bug summary]]]
References: <Pine.LNX.3.95.990107093746.4270H-100000@penguin.transmeta.com>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 07 Jan 1999 20:56:52 -0600
In-Reply-To: Linus Torvalds's message of "Thu, 7 Jan 1999 09:56:03 -0800 (PST)"
Message-ID: <m1u2y2cw0b.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Andrea Arcangeli <andrea@e-mind.com>, steve@netplus.net, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "LT" == Linus Torvalds <torvalds@transmeta.com> writes:

LT> On 6 Jan 1999, Eric W. Biederman wrote:
>> 
>> 1) With your comments on PG_dirty/(what shrink_mmap should do) you
>> have worked out what needs to happen for the mapped in memory case,
>> and I haven't quite gotten there.  Thank You.

LT> Note that it is not finalized. That's why I didn't write the code (which
LT> should be fairly simple), because it has some fairly subtle issues and
LT> thus becomes a 2.3.x thing, I very much suspect.

The code probably will be simple enough, but there are issues.
The complete issue for 2.3.x is dirty data in the page cache,
mapped shared pages are just a small subset.

This will be much more important for NFS, e2compr, and not
double buffering between the page cache and the buffer cache,
than for this case.


>> 2) I have tested using PG_dirty from shrink_mmap and it is a
>> performance problem because it loses all locality of reference,
>> and because it forces shrink_mmap into a dual role, of freeing and
>> writing pages, which need seperate tuning.

LT> Exactly. This is part of the complexity.

LT> The right solution (I _think_) is to conceptually always mark it PG_dirty
LT> in vmscan, and basically leave all the nasty cases to the filemap physical
LT> page scan. But in the simple cases (ie a swap-cached page that is only
LT> mapped by one process and doesn't have any other users), you'd start the
LT> IO "early".

This sounds good for the subset of the problem you are considering.

>From where I'm at something that allocates a streamlined buffer_head
to the diry pages, sounds even better.  That and having a peridic
scan of the page tables that removes the dirty bit and marks the 
pages dirty, before we need the pages to be clean.

LT> Basically, I think that the stuff we handle now with the swap-cache we do
LT> well on already, and we'd only really want to handle the shared memory
LT> case with PG_dirty. But I think this is a 2.3 issue, and I only added the
LT> comment (and the PG_dirty define) for now. 

Thanks it does give some encouragement and some relief.  There are enough
things to get shaken out,  I am much more comfortable with early 2.3,
where we have time to convert things to a new way of doing things.

LT> It might be something good to test out, but I really don't want patches at
LT> this date (unless your patches also fix the above deadlock problem, which
LT> I can't see them doing ;)

Then I will proceed with my previous plan and see if I can get a fairly
complete set of patches ready for 2.3.early

Eric

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org

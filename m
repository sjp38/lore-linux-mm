Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA29703
	for <linux-mm@kvack.org>; Thu, 7 Jan 1999 12:59:23 -0500
Date: Thu, 7 Jan 1999 09:56:03 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: arca-vm-8 [Re: [patch] arca-vm-6, killed kswapd [Re: [patch] new-vm , improvement , [Re: 2.2.0 Bug summary]]]
In-Reply-To: <m1aezvg0vw.fsf@flinx.ccr.net>
Message-ID: <Pine.LNX.3.95.990107093746.4270H-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: Andrea Arcangeli <andrea@e-mind.com>, steve@netplus.net, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On 6 Jan 1999, Eric W. Biederman wrote:
> 
> 1) With your comments on PG_dirty/(what shrink_mmap should do) you
>    have worked out what needs to happen for the mapped in memory case,
>    and I haven't quite gotten there.  Thank You.

Note that it is not finalized. That's why I didn't write the code (which
should be fairly simple), because it has some fairly subtle issues and
thus becomes a 2.3.x thing, I very much suspect.

Basically, my rule of thumb for the changes I did was: "it should have the
same code paths as the old code". What that means is that I didn't
actually do any changes that changed real code: I did only changes that
changed _behaviour_.

That way I can be reasonably hopeful that there are no new bugs introduced
even though performance is very different. I _do_ have some early data
that seems to say that this _has_ uncovered a very old deadlock condition: 
something that could happen before but was almost impossible to trigger. 

The deadlock I suspect is:
 - we're low on memory
 - we allocate or look up a new block on the filesystem. This involves
   getting the ext2 superblock lock, and doing a "bread()" of the free
   block bitmap block.
 - this causes us to try to allocate a new buffer, and we are so low on
   memory that we go into try_to_free_pages() to find some more memory.
 - try_to_free_pages() finds a shared memory file to page out.
 - trying to page that out, it looks up the buffers on the filesystem it
   needs, but deadlocks on the superblock lock.

Note that this could happen before too (I've not removed any of the
codepaths that could lead to it), but it was dynamically _much_ less
likely to happen.

I'm not even sure it really exists, but I have some really old reports
that _could_ be due to this, and a few more recent ones (that I never
could explain). And I have a few _really_ recent ones from here internally
at transmeta that looks like it's triggering more easily these days.

(Note that this is not actually pre5-related: I've been chasing this on
and off for some time, and it seems to have just gotten easier to trigger,
which is why I finally have a theory on what is going on - just a theory
though, and I may be completely off the mark). 

The positive news is that if I'm right in my suspicions it can only happen
with shared writable mappings or shared memory segments. The bad news is
that the bug appears rather old, and no immediate solution presents
itself. 

> 2) I have tested using PG_dirty from shrink_mmap and it is a
>    performance problem because it loses all locality of reference,
>    and because it forces shrink_mmap into a dual role, of freeing and
>    writing pages, which need seperate tuning.

Exactly. This is part of the complexity.

The right solution (I _think_) is to conceptually always mark it PG_dirty
in vmscan, and basically leave all the nasty cases to the filemap physical
page scan. But in the simple cases (ie a swap-cached page that is only
mapped by one process and doesn't have any other users), you'd start the
IO "early".

That would essentially mean that normal single mappings get the good
locality, while the case we really suck at right now (multiple mappings
which can all dirty the page) would not cause excessive page-outs. 

Basically, I think that the stuff we handle now with the swap-cache we do
well on already, and we'd only really want to handle the shared memory
case with PG_dirty. But I think this is a 2.3 issue, and I only added the
comment (and the PG_dirty define) for now. 

> Linus is this a case you feel is important to tune for 2.2?
> If so I would be happy to play with it.

It might be something good to test out, but I really don't want patches at
this date (unless your patches also fix the above deadlock problem, which
I can't see them doing ;)

		Linus

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org

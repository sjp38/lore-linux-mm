Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA30328
	for <linux-mm@kvack.org>; Thu, 7 Jan 1999 13:55:32 -0500
Subject: Re: arca-vm-8 [Re: [patch] arca-vm-6, killed kswapd [Re: [patch] new-vm , improvement , [Re: 2.2.0 Bug summary]]]
References: <Pine.LNX.3.95.990107093746.4270H-100000@penguin.transmeta.com>
Reply-To: Zlatko.Calusic@CARNet.hr
MIME-Version: 1.0
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 07 Jan 1999 19:55:25 +0100
In-Reply-To: Linus Torvalds's message of "Thu, 7 Jan 1999 09:56:03 -0800 (PST)"
Message-ID: <87d84qud42.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Eric W. Biederman" <ebiederm+eric@ccr.net>, Andrea Arcangeli <andrea@e-mind.com>, steve@netplus.net, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linus Torvalds <torvalds@transmeta.com> writes:

[snip]
> 
> That way I can be reasonably hopeful that there are no new bugs introduced
> even though performance is very different. I _do_ have some early data
> that seems to say that this _has_ uncovered a very old deadlock condition: 
> something that could happen before but was almost impossible to trigger. 
> 
> The deadlock I suspect is:
>  - we're low on memory
>  - we allocate or look up a new block on the filesystem. This involves
>    getting the ext2 superblock lock, and doing a "bread()" of the free
>    block bitmap block.
>  - this causes us to try to allocate a new buffer, and we are so low on
>    memory that we go into try_to_free_pages() to find some more memory.
>  - try_to_free_pages() finds a shared memory file to page out.
>  - trying to page that out, it looks up the buffers on the filesystem it
>    needs, but deadlocks on the superblock lock.
> 
> Note that this could happen before too (I've not removed any of the
> codepaths that could lead to it), but it was dynamically _much_ less
> likely to happen.

You could be very easily right. Look below.

> 
> I'm not even sure it really exists, but I have some really old reports
> that _could_ be due to this, and a few more recent ones (that I never
> could explain). And I have a few _really_ recent ones from here internally
> at transmeta that looks like it's triggering more easily these days.
> 
> (Note that this is not actually pre5-related: I've been chasing this on
> and off for some time, and it seems to have just gotten easier to trigger,
> which is why I finally have a theory on what is going on - just a theory
> though, and I may be completely off the mark). 
> 
> The positive news is that if I'm right in my suspicions it can only happen
> with shared writable mappings or shared memory segments. The bad news is
> that the bug appears rather old, and no immediate solution presents
> itself. 

Exactly. I was torture testing shared mapping when I got very weird
deadlock. It happened only once, few days ago. Look at report and
enjoy:

Jan  5 03:49:14 atlas kernel: SysRq: Show Memory 
Jan  5 03:49:14 atlas kernel: Mem-info: 
Jan  5 03:49:14 atlas kernel: Free pages:         512kB 
Jan  5 03:49:14 atlas kernel:  ( Free: 128 (128 256 384) 
Jan  5 03:49:14 atlas kernel: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 4*128kB = 512kB) 
Jan  5 03:49:14 atlas kernel: Swap cache: add 131125/131125, delete 130652/13065
2, find 0/0 
Jan  5 03:49:14 atlas kernel: Free swap:       231632kB 
Jan  5 03:49:14 atlas kernel: 16384 pages of RAM 
Jan  5 03:49:14 atlas kernel: 956 reserved pages 
Jan  5 03:49:14 atlas kernel: 17996 pages shared 
Jan  5 03:49:14 atlas kernel: 473 pages swap cached 
Jan  5 03:49:14 atlas kernel: 13 pages in page table cache 
Jan  5 03:49:14 atlas kernel: Buffer memory:    14696kB 
Jan  5 03:49:14 atlas kernel: Buffer heads:     14732 
Jan  5 03:49:14 atlas kernel: Buffer blocks:    14696 
Jan  5 03:49:14 atlas kernel:    CLEAN: 144 buffers, 18 used (last=122), 0 locke
d, 0 protected, 0 dirty 

This looks exactly like the problem you were describing, isn't it?

[snip]
> Basically, I think that the stuff we handle now with the swap-cache we do
> well on already, and we'd only really want to handle the shared memory
> case with PG_dirty. But I think this is a 2.3 issue, and I only added the
> comment (and the PG_dirty define) for now. 

Nice, thanks. That will make experimenting slightly easier and will
give courage to people to actually experiment with PG_Dirty
implementation. So far, only Eric did some work in this area.

Of course, this is all 2.3 work.

> 
> > Linus is this a case you feel is important to tune for 2.2?
> > If so I would be happy to play with it.
> 
> It might be something good to test out, but I really don't want patches at
> this date (unless your patches also fix the above deadlock problem, which
> I can't see them doing ;)
> 

Sure!
-- 
Zlatko
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org

Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA29859
	for <linux-mm@kvack.org>; Thu, 7 Jan 1999 13:19:12 -0500
Date: Thu, 7 Jan 1999 19:18:19 +0100 (CET)
From: Rik van Riel <riel@humbolt.geo.uu.nl>
Subject: Re: arca-vm-8 [Re: [patch] arca-vm-6, killed kswapd [Re: [patch]
 new-vm , improvement , [Re: 2.2.0 Bug summary]]]
In-Reply-To: <Pine.LNX.3.95.990107093746.4270H-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.03.9901071912510.6527-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Eric W. Biederman" <ebiederm+eric@ccr.net>, Andrea Arcangeli <andrea@e-mind.com>, steve@netplus.net, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 7 Jan 1999, Linus Torvalds wrote:
> On 6 Jan 1999, Eric W. Biederman wrote:


> > 2) I have tested using PG_dirty from shrink_mmap and it is a
> >    performance problem because it loses all locality of reference,
> >    and because it forces shrink_mmap into a dual role, of freeing and
> >    writing pages, which need seperate tuning.
> 
> Exactly. This is part of the complexity.

It can be solved by having a 'laundry' list like the *BSD
folks have and maybe a special worker thread to take care
of the laundry (optimizing placement on disk, etc).

> The right solution (I _think_) is to conceptually always mark it
> PG_dirty in vmscan, and basically leave all the nasty cases to the
> filemap physical page scan. But in the simple cases (ie a
> swap-cached page that is only mapped by one process and doesn't
> have any other users), you'd start the IO "early".
>
> That would essentially mean that normal single mappings get the good
> locality, while the case we really suck at right now (multiple mappings
> which can all dirty the page) would not cause excessive page-outs. 

We can already do that by simply not writing the page to
disk if there are other users besides us (keeping in mind
the swap cache and other system things).

One problem might be that we could end up with more on-disk
fragmentation that way (and maybe less clusterable I/O).

> Basically, I think that the stuff we handle now with the
> swap-cache we do well on already, and we'd only really want to
> handle the shared memory case with PG_dirty. But I think this is a
> 2.3 issue, and I only added the comment (and the PG_dirty define)
> for now.

It's quite definately 2.3. It's just a minor performance
issue for most systems (an extra write is an order of
magnitude cheaper than an extra read where a process is
actually waiting).


Rik -- If a Microsoft product fails, who do you sue?
+-------------------------------------------------------------------+
| Linux memory management tour guide.        riel@humbolt.geo.uu.nl |
| Scouting Vries cubscout leader.    http://humbolt.geo.uu.nl/~riel |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org

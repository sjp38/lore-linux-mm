Date: Sun, 24 Sep 2000 23:06:49 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2
In-Reply-To: <Pine.GSO.4.21.0009250101150.14096-100000@weyl.math.psu.edu>
Message-ID: <Pine.LNX.4.10.10009242301230.1293-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Viro <viro@math.psu.edu>
Cc: Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, Alexander Viro <aviro@redhat.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Mon, 25 Sep 2000, Alexander Viro wrote:
> 
> 
> On Sun, 24 Sep 2000, Linus Torvalds wrote:
> 
> > The remaining part if the directory handling. THAT is very buffer-cache
> > intensive, as the directory handling hasn't been moved over to the page
> > cache at all for ext2. Doing a large "find" (or even just a "ls -l") will
> > basically do purely buffer cache accesses, first for the directory data
> > and then for the inode data. With no page cache activity to balance things
> > out at all - leading to a potentially quite unbalanced VM that never
> > really had a good chance to get rid of dentries etc.
> 
> You forgot inode tables themselves.

I don't. That's the "then for the inode data" part.

I'm not claiming that the buffer cache accesses would go away - I'm just
saying that the unbalanced "only buffer cache" case should go away,
because things like "find" and friends will still cause mostly page cache
activity.

(Considering the size of the inode on ext2, I don't know how true this is,
I have to admit. It might still be quite biased towards the buffer cache,
and as such the additional page cache pressure might not be enough to
really cause any major shift in balancing).

> I'll do it and post the result tomorrow. I bet that there will be issues
> I've overlooked (stuff that happens to work on UFS, but needs to be more
> general for ext2), so it's going as "very alpha", but hey, it's pretty
> straightforward, so there is a chance to debug it fast. Yes, famous last
> words and all such...

Sure.

> BTW, we _will_ need it on UFS side in 2.4 anyway. Rationale:

[ reasons removed ]

I have no problem with that. Especially as I suspect the people who use
UFS are more likely to be the technical kind of user who is more inclined
to be able to debug whatever potential problems crop up anyway. Your point
about not duplicating the fragment handling is certainly quite convincing
for the case of UFS.

> 	So some variant of directories in pagecache is needed for 2.4, the
> question being whether it's UFS-only or we use its port on ext2... BTW,
> minixfs/sysvfs can also use the thing, but that's another story.

Let's plan on UFS-only, for all the prudent reasons.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA12293
	for <linux-mm@kvack.ORG>; Thu, 28 Jan 1999 18:01:12 -0500
Date: Thu, 28 Jan 1999 14:53:15 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [patch] fixed both processes in D state and the /proc/ oopses [Re: [patch] Fixed the race that was oopsing Linux-2.2.0]
In-Reply-To: <Pine.LNX.3.96.990128232118.797B-100000@laser.bogus>
Message-ID: <Pine.LNX.3.95.990128144808.956H-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, werner@suse.de, mlord@pobox.com, "David S. Miller" <davem@dm.COBALTMICRO.COM>, gandalf@szene.CH, adamk@3net.net.pl, kiracofe.8@osu.edu, ksi@ksi-linux.COM, djf-lists@ic.NET, tomh@taz.ccs.fau.edu, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Thu, 28 Jan 1999, Andrea Arcangeli wrote:
> 
> I'm afraid. I still think that it will never be needed even removing
> lock_kernel(), because doing that we would need to make atomic the
> decreasing of mm->count with current->mm = &init_mm, otherwise we would
> not know if we can touch the current->mm of a process at any time. 

What?

We can _always_ touch current->mm, because it can _never_ go away from
under us: it will always have a non-zero count exactly because "current"
has a copy of it.

If you want to touch some _other_ process mm pointer, that's when it gets
interesting. Buyer beware.

> But maybe I am missing something, but it's what I think though.

You're missing the fact that whenever we own the mm, we know that NOBODY
else can do anything bad at all, because nobody else can ever think that
the count is zero. Because we hold a reference count to it.

The _only_ interesting case is when multiple threads do "exit()" at the
same time, and then one of them will be the last one - and that last one
will _know_ he is the last one because that's how atomic_dec_and_tes()
works. And once he knows, he no longer has to care about anybody else,
because he knows that nobody else can touch that mm space any more (or it
wouldn't have decremented the counter to zero in the first place). 

So not only does mm->count need to be atomic in the absense of other
locks, but that atomicity is obviously sufficient for allocation purposes. 

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

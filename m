Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA09326
	for <linux-mm@kvack.ORG>; Thu, 28 Jan 1999 13:19:53 -0500
Date: Thu, 28 Jan 1999 10:17:37 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [patch] fixed both processes in D state and the /proc/ oopses [Re: [patch] Fixed the race that was oopsing Linux-2.2.0]
In-Reply-To: <199901281807.SAA03328@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.95.990128101220.32418I-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Andrea Arcangeli <andrea@e-mind.com>, linux-kernel@vger.rutgers.edu, werner@suse.de, mlord@pobox.com, "David S. Miller" <davem@dm.COBALTMICRO.COM>, gandalf@szene.CH, adamk@3net.net.pl, kiracofe.8@osu.edu, ksi@ksi-linux.COM, djf-lists@ic.NET, tomh@taz.ccs.fau.edu, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Thu, 28 Jan 1999, Stephen C. Tweedie wrote:
> 
> Yep, but Andrea did point out what looks like at least one valid race:
> sys_wait* on a zombie task can remove and deallocate the task_struct
> without taking the global lock.  Reverting the diff is the right thing
> for 2.2.1, but once we've done that we may need to look at either
> keeping the task lock until we have finished with the task_struct in
> array.c, or doing a memcpy on the task while we still have it locked.
> That does seem to be a valid fix.

I'd much rather just use some stale "struct task_struct" data.

What we _might_ do in /proc, is to just increment the usage count for the
(double) page that contains the task structure, so that even if a
release() does happen while we're using the page, the page won't get
re-used, and we can essentially look at all the info as it was when it was
released. 

Note that by the time it has become a zombie, it will have released all
the mm stuff anyway, so we don't even have any dangerous stale mm pointers
that we'd follow: we'd only be looking at that one structure. 

Voila, no memcpy(), no silly locks, no problems. 

Anyway, for 2.2.1 I don't even want to be clever. As it is (with the bogus
array.c race "fixes" removed), the page may get freed without any kernel
lock, and we may return _completely_ bogus information, but that is (a) 
extremely unlikely in the first place and (b) basically harmless and
pretty much impossible to exploit. 

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

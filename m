Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA08828
	for <linux-mm@kvack.org>; Thu, 28 Jan 1999 12:42:25 -0500
Date: Thu, 28 Jan 1999 09:36:11 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [patch] fixed both processes in D state and the /proc/ oopses [Re: [patch] Fixed the race that was oopsing Linux-2.2.0]
In-Reply-To: <Pine.LNX.3.96.990128023440.8338A-100000@laser.bogus>
Message-ID: <Pine.LNX.3.95.990128093033.32418B-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, werner@suse.de, mlord@pobox.com, "David S. Miller" <davem@dm.cobaltmicro.com>, gandalf@szene.ch, adamk@3net.net.pl, kiracofe.8@osu.edu, ksi@ksi-linux.com, djf-lists@ic.net, tomh@taz.ccs.fau.edu, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Thu, 28 Jan 1999, Andrea Arcangeli wrote:
>
> Do you want to know why last night I added a spinlock around mmget/mmput
> without thinking twice?  Simply because mm->count was an atomic_t while it
> doesn't need to be an atomic_t in first place.

No. Your argument does not make any sense at all.

Go away, this is not the time to use magic to make kernel patches.

A "atomic_t" _often_ makes sense without having any spinlocks,
_especially_ when used as a reference count. Let me count the ways:

 - when you increase the count because you make a copy, you know that
   you're already a holder of the count, so you don't need any spinlocks
   to protect anything else: you _know_ the area is there.

 - when you decrease the count, you use "atomic_dec_and_test()" because
   you know that the count was > 0, and you know that only _one_ such
   decrementer will get a positive reply for the atomic_dec_and_test. The
   one that is successful doesn't need any locking, because he's now the
   only owner, and should just release everything. 

In short, it has to be atomic, and spinlocks never enter the picture at
all.

Your patches do not make sense. Period. The only thing that makes sense is
to revert the array.c thing to the old one that didn't try to be clever.

		Linus 

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

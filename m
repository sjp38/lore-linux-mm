Received: from chiara.csoma.elte.hu (chiara.csoma.elte.hu [157.181.71.18])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA19975
	for <linux-mm@kvack.ORG>; Fri, 29 Jan 1999 08:49:10 -0500
Date: Fri, 29 Jan 1999 14:19:14 +0100 (CET)
From: MOLNAR Ingo <mingo@chiara.csoma.elte.hu>
Reply-To: MOLNAR Ingo <mingo@chiara.csoma.elte.hu>
Subject: Re: [patch] fixed both processes in D state and the /proc/ oopses [Re: [patch] Fixed the race that was oopsing Linux-2.2.0]
In-Reply-To: <Pine.LNX.3.96.990129124407.639A-100000@laser.bogus>
Message-ID: <Pine.LNX.3.96.990129132505.22453D-100000@chiara.csoma.elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, werner@suse.de, mlord@pobox.com, "David S. Miller" <davem@dm.COBALTMICRO.COM>, gandalf@szene.CH, adamk@3net.net.pl, kiracofe.8@osu.edu, ksi@ksi-linux.COM, djf-lists@ic.NET, tomh@taz.ccs.fau.edu, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 29 Jan 1999, Andrea Arcangeli wrote:

> _Where_ do you want to run atomic_inc_and_test()? On random kernel data

note that in 99% of the cases we need the counter only in the clone(),
exec() and exit() path, for these three cases we know implicitly that it's
a valid buffer. (because we hold a reference to it) [subsequently we dont
need any atomic_inc_and_test thing either for clone+exec+exit] An atomic
counter is just about perfect for those uses, even in the 'no kernel lock'
case. 

I only looked at your last (fairly large) patch, which does not seem to
have _any_ effect at all as far as bugfixes are concerned, except the
array.c change (which again turned out to have nothing to do with the
atomic vs. spinlock thing). 

for 'other process' uses (for cases when we want to dereference an
mm_struct pointer but do not hold a reference to it, eg. /proc or the VM
scanning logic) we will have to do something smart when we remove the
kernel lock in 2.3, but it should not increase the cost of the common case
(clone() + exit()) if possible.

-- mingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

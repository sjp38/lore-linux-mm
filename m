Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA20256
	for <linux-mm@kvack.ORG>; Fri, 29 Jan 1999 09:15:20 -0500
Date: Fri, 29 Jan 1999 15:14:37 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [patch] fixed both processes in D state and the /proc/ oopses [Re: [patch] Fixed the race that was oopsing Linux-2.2.0]
In-Reply-To: <Pine.LNX.3.96.990129132505.22453D-100000@chiara.csoma.elte.hu>
Message-ID: <Pine.LNX.3.96.990129144844.886A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: MOLNAR Ingo <mingo@chiara.csoma.elte.hu>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, werner@suse.de, mlord@pobox.com, "David S. Miller" <davem@dm.COBALTMICRO.COM>, gandalf@szene.CH, adamk@3net.net.pl, kiracofe.8@osu.edu, ksi@ksi-linux.COM, djf-lists@ic.NET, tomh@taz.ccs.fau.edu, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 29 Jan 1999, MOLNAR Ingo wrote:

> note that in 99% of the cases we need the counter only in the clone(),
> exec() and exit() path, for these three cases we know implicitly that it's
> a valid buffer. (because we hold a reference to it) [subsequently we dont
> need any atomic_inc_and_test thing either for clone+exec+exit] An atomic
> counter is just about perfect for those uses, even in the 'no kernel lock'
> case. 

Sure, if you look at my last email to Linus, you'll see that I am _only_
talking about getting the mm of a random process (not the current one!).

Probably I should comment better my patches, but I have really a big
leakage of spare time these days but I _don't_ want to decrease the kernel
hacking (even if Linus asked me to go away two times).

> I only looked at your last (fairly large) patch, which does not seem to
> have _any_ effect at all as far as bugfixes are concerned, except the
> array.c change (which again turned out to have nothing to do with the
> atomic vs. spinlock thing).

Infact, the only bugfix is array.c (as I just pointed out clearly in
bugtraq). Another reason I didn't either checked about lock_kernel() two
night ago before adding mm_lock, is that it was very late, I had a little
time and I seen some bugreport on the list that was oopsing in mmput (so I
thought "yeah, I seen the race!", I thought it was the mmput/current->mm =
&init_mm race). Then I also seen the mm->count as atomic_t so I thought it
was really the case. 

Ah note, there was overhead also in the overhead since checking for
mm->count == 0 in mmget was a nono ;).

> for 'other process' uses (for cases when we want to dereference an
> mm_struct pointer but do not hold a reference to it, eg. /proc or the VM
> scanning logic) we will have to do something smart when we remove the
> kernel lock in 2.3, but it should not increase the cost of the common case
> (clone() + exit()) if possible.

Ok this is a completly different story and I am the first that don't want
to continue it now, but I want to point out that atomic_t is __far__ to be
the only thing we'll nee to make the mm_struct browsing race free (as I
understood from Linus's word).

I am very very happy to see that I was not (completly ;) crazy.

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

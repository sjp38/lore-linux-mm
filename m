Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA12126
	for <linux-mm@kvack.ORG>; Thu, 28 Jan 1999 17:47:18 -0500
Date: Thu, 28 Jan 1999 23:04:42 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Reply-To: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [patch] fixed both processes in D state and the /proc/ oopses [Re: [patch] Fixed the race that was oopsing Linux-2.2.0]
In-Reply-To: <Pine.LNX.3.95.990128095147.32418F-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.3.96.990128205918.438B-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, werner@suse.de, mlord@pobox.com, "David S. Miller" <davem@dm.COBALTMICRO.COM>, gandalf@szene.CH, adamk@3net.net.pl, kiracofe.8@osu.edu, ksi@ksi-linux.COM, djf-lists@ic.NET, tomh@taz.ccs.fau.edu, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 28 Jan 1999, Linus Torvalds wrote:

> Incorrect, see my previous email. It may not be strictly necessary right
> now due to us probably holding the kernel lock everywhere, but it is
> conceptually necessary, and it is _not_ an argument for a spinlock.

If you remove the kernel lock around do_exit() you _need_ my mm_lock
spinlock. You need it to make atomic the decreasing of mm->count and
current->mm = &init_mm. If the two instructions are not atomic you have
_no_ way to know if you can mmget() at any time the mm of a process.

I repeat in another way (just trying to avoid English mistakes): 
decreasing mm->count has to go in sync with updating current->mm,
otherwise you don't know if you can access the mm of a process (and so
also touching mm->count) because the mm of such process could be just been
deallocated (the process could be a zombie).

As far I can see the mm->count will _never_ have 1 reason to be atomic_t
even removing the function lock_kernel() from
/usr/src/linux/include/asm/smplock.h . 

Using an int for mm->count (isntead of atomic_t) is far from be something
of magic. Doing that change it means that I don't expect work by magic,
but I know that it will work fine. It's instead magic (out of the human
reason) how the kernel works now, if you think that we _need_ atomic_t
instead of int. 

It's hard for me to be quiet even if you asked me to go away because I
think you are plain wrong telling that we need mm->count atomic_t for the
future. 

Andrea Arcangeli

PS. You have not hurted me asking me to go away, because I _always_ do the
_best_ I _can_, and if my best is plain wrong I can't change this reality. 
What I care is to do the best I can. Maybe I should really go away and do
something in my sparetime where it's not requested to be clever... I hope
it's not the case though and that you wasn't serious.

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

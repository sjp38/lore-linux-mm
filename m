Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA09131
	for <linux-mm@kvack.ORG>; Thu, 28 Jan 1999 13:08:14 -0500
Date: Thu, 28 Jan 1999 18:07:57 GMT
Message-Id: <199901281807.SAA03328@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: [patch] fixed both processes in D state and the /proc/ oopses [Re: [patch] Fixed the race that was oopsing Linux-2.2.0]
In-Reply-To: <Pine.LNX.3.95.990128095147.32418F-100000@penguin.transmeta.com>
References: <199901281509.PAA02883@dax.scot.redhat.com>
	<Pine.LNX.3.95.990128095147.32418F-100000@penguin.transmeta.com>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Andrea Arcangeli <andrea@e-mind.com>, linux-kernel@vger.rutgers.edu, werner@suse.de, mlord@pobox.com, "David S. Miller" <davem@dm.COBALTMICRO.COM>, gandalf@szene.CH, adamk@3net.net.pl, kiracofe.8@osu.edu, ksi@ksi-linux.COM, djf-lists@ic.NET, tomh@taz.ccs.fau.edu, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 28 Jan 1999 09:54:07 -0800 (PST), Linus Torvalds
<torvalds@transmeta.com> said:

> On Thu, 28 Jan 1999, Stephen C. Tweedie wrote:

>> > Do you want to know why last night I added a spinlock around mmget/mmput
>> > without thinking twice?  Simply because mm->count was an atomic_t while it
>> > doesn't need to be an atomic_t in first place.
>> Agreed.

> Incorrect, see my previous email. It may not be strictly necessary right
> now due to us probably holding the kernel lock everywhere, but it is
> conceptually necessary, and it is _not_ an argument for a spinlock.

Linus, we are in violent agreement: see my previous email. :)  I agree
with both you and Andrea that the atomic_t is not strictly necessary,
and agree vigorously that removing it is wrong because it will just make
the job of fine-graining the locking ever more harder.  As we relax the
kernel locks, the atomic_t becomes more and more important.

> The /proc code has to be fixed, but the easy fix is to just revert to the
> old one as far as I can see. I shouldn't have accepted the /proc patches
> in the first place, and I'm sorry I did.

Yep, but Andrea did point out what looks like at least one valid race:
sys_wait* on a zombie task can remove and deallocate the task_struct
without taking the global lock.  Reverting the diff is the right thing
for 2.2.1, but once we've done that we may need to look at either
keeping the task lock until we have finished with the task_struct in
array.c, or doing a memcpy on the task while we still have it locked.
That does seem to be a valid fix.

--Stephen

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

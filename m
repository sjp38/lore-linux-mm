Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA07362
	for <linux-mm@kvack.ORG>; Thu, 28 Jan 1999 10:09:53 -0500
Date: Thu, 28 Jan 1999 15:09:19 GMT
Message-Id: <199901281509.PAA02883@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: [patch] fixed both processes in D state and the /proc/ oopses [Re: [patch] Fixed the race that was oopsing Linux-2.2.0]
In-Reply-To: <Pine.LNX.3.96.990128023440.8338A-100000@laser.bogus>
References: <Pine.LNX.3.96.990128001800.399A-100000@laser.bogus>
	<Pine.LNX.3.96.990128023440.8338A-100000@laser.bogus>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.rutgers.edu, werner@suse.de, mlord@pobox.com, "David S. Miller" <davem@dm.COBALTMICRO.COM>, gandalf@szene.CH, adamk@3net.net.pl, kiracofe.8@osu.edu, ksi@ksi-linux.COM, djf-lists@ic.NET, tomh@taz.ccs.fau.edu, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 28 Jan 1999 03:50:39 +0100 (CET), Andrea Arcangeli
<andrea@e-mind.com> said:

> Do you want to know why last night I added a spinlock around mmget/mmput
> without thinking twice?  Simply because mm->count was an atomic_t while it
> doesn't need to be an atomic_t in first place.

Agreed.

> So you don't buy my code, but now, I don't buy both all /proc mmget/mmput
> sutff and the mm->count atomic_t.

Agreed.  mm->count might as well remain atomic because that will help
when we come to apply finer grained locking to the mm, but as far as I
am concerned we may as well drop pretty much all of the mmget/mmput
stuff.  The only race I can still see is the possibility of sys_wait*
removing the task struct while we run on SMP.

> I also removed all the memcpy, we only need the read_lock(tasklist_lock)
> held in SMP because otherwise wait4() could remove the stack of the
> process under our eyes as just pointed out in the last email.

Yep, fine, as long as we keep the tasklist_lock right until the end of
our use of the task struct.

> Not doing in 2.2.1 the mm->count s/atomic_t/int/ due worry of races will
> mean that array.c in 2.2.1 will be not safe enough without my mm_lock
> spinlock. Do you understand my point?

No, because we already have a sufficient spinlock to protect us.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

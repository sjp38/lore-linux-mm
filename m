Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA22472
	for <linux-mm@kvack.ORG>; Fri, 29 Jan 1999 13:34:16 -0500
Date: Fri, 29 Jan 1999 10:24:16 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [patch] fixed both processes in D state and the /proc/ oopses [Re: [patch] Fixed the race that was oopsing Linux-2.2.0]
In-Reply-To: <Pine.LNX.3.96.990129015657.8557A-100000@laser.bogus>
Message-ID: <Pine.LNX.3.95.990129101917.12610G-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, werner@suse.de, mlord@pobox.com, "David S. Miller" <davem@dm.COBALTMICRO.COM>, gandalf@szene.CH, adamk@3net.net.pl, kiracofe.8@osu.edu, ksi@ksi-linux.COM, djf-lists@ic.NET, tomh@taz.ccs.fau.edu, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Fri, 29 Jan 1999, Andrea Arcangeli wrote:
> 
> > If you want to touch some _other_ process mm pointer, that's when it gets
> > interesting. Buyer beware.
> 
> Infact this is the point. I really think you are missing something. I read
> your explanation of why we only need atomic_t but it was not touching some
> point I instead thought about.
> 
> Ok, I assume you are right. Please take this example: I am writing a nice
> kernel module that will collect some nice stats from the kernel.

And that's where you have problems. You shouldn't do that, and that's why
/proc is such a nasty beast right now. 

If you want to look at other peoples processes, then the onus should be on
_you_ to do all the extra crap that normal processes do not need to do. 
That extra crap can be a number of things, but you shouldn't penalize the
normal path (which is to touch only your own mm space). 

For example, the thing I suspect we'll have to do in the long run for
/proc is:

 - get the process while holding the tasklist lock, and increment the page
   count so that even if the process exists, the page does not get unused.
 - get the kernel lock. Now we know that we're atomic with regard to
   __exit_mm()
 - look at tsk->mm: it it is not init_mm, you're now safe, because
   __exit_mm is called only with the kernel lock held. 

See? No spinlocks.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

Received: from hoon.perlsupport.com (root@dt0e3na9.tampabay.rr.com [24.92.175.169])
	by kvack.org (8.8.7/8.8.7) with ESMTP id BAA27658
	for <linux-mm@kvack.org>; Mon, 11 Jan 1999 01:21:21 -0500
Received: by hoon.perlsupport.com
	via sendmail from stdin
	id <m0zzant-0001bsC@hoon.perlsupport.com> (Debian Smail3.2.0.102)
	for linux-mm@kvack.org; Mon, 11 Jan 1999 01:26:21 -0500 (EST)
Date: Mon, 11 Jan 1999 01:26:21 -0500
From: Chip Salzenberg <chip@perlsupport.com>
Subject: Re: testing/pre-7 and do_poll()
Message-ID: <19990111012620.B3767@perlsupport.com>
References: <19990110183356.C262@perlsupport.com> <Pine.LNX.3.95.990110220047.1997B-100000@penguin.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.3.95.990110220047.1997B-100000@penguin.transmeta.com>; from Linus Torvalds on Sun, Jan 10, 1999 at 10:02:47PM -0800
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

According to Linus Torvalds:
> On Sun, 10 Jan 1999, Chip Salzenberg wrote:
> > However, the maximum legal millisecond timeout isn't (as shown)
> > MAX_SCHEDULE_TIMEOUT/HZ, but rather MAX_SCHEDULE_TIMEOUT/(1000/HZ).
> > So this code will turn some large timeouts into MAX_SCHEDULE_TIMEOUT
> > unnecessarily.
> 
> Note the comment (and do NOT look at the speeling).  In particular,
> we need to make sure the _intermediate_ value doesn' toverflow.

Of course; that's obvious.  What's perhaps less obvious is that I'm
suggesting a change in the calculation of timeout -- a change which
avoids the creation of unnecessarily large _intermediate_ values.

> > ! 	if (timeout < 0)
> > ! 		timeout = MAX_SCHEDULE_TIMEOUT;
> > ! 	else if (timeout)
> > ! 		timeout = ROUND_UP(timeout, 1000/HZ);
> 
> Eh? And re-introduce the original bug?

Well, I forgot the (unsigned long) cast, as someone else noted:

	timeout = ROUND_UP((unsigned long) timeout, 1000/HZ);

Otherwise, the code is Just Right.
-- 
Chip Salzenberg      - a.k.a. -      <chip@perlsupport.com>
      "When do you work?"   "Whenever I'm not busy."
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org

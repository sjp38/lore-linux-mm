Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id BAA27503
	for <linux-mm@kvack.org>; Mon, 11 Jan 1999 01:03:40 -0500
Date: Sun, 10 Jan 1999 22:02:47 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: testing/pre-7 and do_poll()
In-Reply-To: <19990110183356.C262@perlsupport.com>
Message-ID: <Pine.LNX.3.95.990110220047.1997B-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Chip Salzenberg <chip@perlsupport.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Sun, 10 Jan 1999, Chip Salzenberg wrote:
> 
> Got it, like it -- *except* the fix for overflow in do_poll() is a
> little bit off.  Quoting testing/pre-7:
> 
> 	if (timeout) {
> 		/* Carefula about overflow in the intermediate values */
> 		if ((unsigned long) timeout < MAX_SCHEDULE_TIMEOUT / HZ)
> 			timeout = (timeout*HZ+999)/1000+1;
> 		else /* Negative or overflow */
> 			timeout = MAX_SCHEDULE_TIMEOUT;
> 	}
> 
> However, the maximum legal millisecond timeout isn't (as shown)
> MAX_SCHEDULE_TIMEOUT/HZ, but rather MAX_SCHEDULE_TIMEOUT/(1000/HZ).
> So this code will turn some large timeouts into MAX_SCHEDULE_TIMEOUT
> unnecessarily.

Note the comment (and do NOT look at the speeling).

In particular, we need to make sure the _intermediate_ value doesn'
toverflow. We could do that by using 64-bit arithmetic, but let's not.

> ! 	if (timeout < 0)
> ! 		timeout = MAX_SCHEDULE_TIMEOUT;
> ! 	else if (timeout)
> ! 		timeout = ROUND_UP(timeout, 1000/HZ);

Eh? And re-introduce the original bug?

		Linus

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org

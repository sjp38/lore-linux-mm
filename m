Date: Sun, 26 Mar 2000 22:07:48 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] Re: kswapd
In-Reply-To: <200003270121.RAA88890@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.10.10003262200520.1538-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: riel@nl.linux.org, Russell King <rmk@arm.linux.org.uk>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>


On Sun, 26 Mar 2000, Kanoj Sarcar wrote:
> 
> What is the problem that your patch is fixing?

I agree with Rik's patch - the old behaviour kicked us out of the regular
loop whenever "need_resched" was set, and that is not necessarily a good
idea at all.

>From a conceptual standpoint, going to sleep when "need_resched" gets set
is not the right thing at all - the flag doesn't really have any bearing
on whether kswapd should sleep, it only has meaning from a scheduling
latency standpoint (ie "need_resched" does not mean "go to sleep", it
means "let somebody else run now" - different things).

On the other hand you're definitely right that this is not a new bug
introduced by you, Kanoj - this seems to be just a thinko that has been
there for a long long time. And I suspect I may have been the original
perpetrator of the crime.

The new code looks much saner: it reschedules when asked to, and it stops
looping when it makes sense (ie when there is no longer any reason to free
pages). Instead of mixing the two up.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

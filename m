From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200003270800.AAA65612@google.engr.sgi.com>
Subject: Re: [PATCH] Re: kswapd
Date: Mon, 27 Mar 2000 00:00:21 -0800 (PST)
In-Reply-To: <Pine.LNX.4.10.10003262200520.1538-100000@penguin.transmeta.com> from "Linus Torvalds" at Mar 26, 2000 10:07:48 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: riel@nl.linux.org, Russell King <rmk@arm.linux.org.uk>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

> 
> On the other hand you're definitely right that this is not a new bug
> introduced by you, Kanoj - this seems to be just a thinko that has been

Whew, as long as I can keep that beer I was going to send to Russell on
Rik's suggestion for myself! :-)

On a more serious note, I know too little about the application load 
that Rik/Russell is talking about to understand what's going on, but
I have the vague suspicion that Rik's patch is just a part fix to the 
problem, and that maybe we might be doing too many kswapd wakes ups
via the balancing code. 

This is my reasoning: Rik's patch makes it so that before kswapd 
undertakes heavy weight work, it yields the cpu ... then it checks
whether it has to do the work (via zone_wake_kswapd). This is the
only difference over pre3. If this is improving things a lot, that
makes me believe that the memory-low condition is subsiding (pages
are being freed up) just after kswapd has yielded, and before it
gets scheduled onto the cpu again. This depends on the app and its
priority too, I guess. If there is an app load where the pages are
not freed, Rik's patch would _probably_ not be able to help. Its 
better than nothing, but if you wanted to do the best you could, you
need to add more yield points into the body of kswapd code (which 
I suspect will not be free of side effects possibly). 

The other part about possibly doing too many kswapd wakeups is 
just a hunch, not directly related to this patch. I will forward
a balancing patch on the mailing lists next for people to try.

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

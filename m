Date: Mon, 27 Mar 2000 11:47:06 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: [PATCH] Re: kswapd
In-Reply-To: <200003270800.AAA65612@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.21.0003271139030.1104-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Russell King <rmk@arm.linux.org.uk>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Mon, 27 Mar 2000, Kanoj Sarcar wrote:

> This is my reasoning: Rik's patch makes it so that before kswapd 
> undertakes heavy weight work, it yields the cpu ... then it checks
> whether it has to do the work (via zone_wake_kswapd). This is the
> only difference over pre3. If this is improving things a lot, that
> makes me believe that the memory-low condition is subsiding (pages
> are being freed up) just after kswapd has yielded, and before it
> gets scheduled onto the cpu again.

This is not the case. CPU system time has decreased from 70%
to 7% with the patch in. Kswapd uses about 5 of those 7%, so
it is true that some of the work is done by the applications,
but overall system time has decreased a lot.

> This depends on the app and its priority too, I guess. If there
> is an app load where the pages are not freed, Rik's patch would
> _probably_ not be able to help.

In this case, nothing would help (except having your low-latency
app completely free of memory allocations).

> Its better than nothing, but if you wanted to do the best you
> could, you need to add more yield points into the body of kswapd
> code (which I suspect will not be free of side effects
> possibly).

One resched every do_try_to_free_pages() seems to be enough
for most things, but it should be relatively easy to build
some reschedule points into do_try_to_free_pages() (which
can _only_ be called if current->state == TASK_RUNNING!!).

> The other part about possibly doing too many kswapd wakeups is 
> just a hunch, not directly related to this patch. I will forward
> a balancing patch on the mailing lists next for people to try.

Probably some hysteresis problem. Using all three freepages
thresholds (min, low and high) solved the problem for zoneless
MM, so it should probably work for a zoned VM too.

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

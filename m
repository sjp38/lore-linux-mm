From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200003172351.PAA37000@google.engr.sgi.com>
Subject: Re: More VM balancing issues..
Date: Fri, 17 Mar 2000 15:51:50 -0800 (PST)
In-Reply-To: <Pine.LNX.4.10.10003171523270.987-100000@penguin.transmeta.com> from "Linus Torvalds" at Mar 17, 2000 03:31:52 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Christopher Zimmerman <zim@av.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> 
> Oh, I found another problem: when the VM balancing was rewritten, the
> "pages_low" thing was still calculated, but nothing actually USED it.

2.3.50 did.

This is one of the things I pointed out in the recent balancing patch. 
The patch I sent to Christopher tries to fix it and go back to 2.3.50
bahavior.

Again, Documentation/vm/balance has comments about this which were
true till 2.3.50.

AFAIR, Andrea put this stuff into 2.3, round about 2.3.40 or so timeframe.


> 
> So we had three water-marks: "enough for anything", "low on memory" and
> "critical".
> 
> And we somehow lost the "low on memory" and only used the "enough" and
> "critical" to do all comparisons.

This was also done properly in 2.3.50, and changed in the recent patch.

Maybe its time that tweaks to the balancing code get documented in
Documentation/vm/balance. Its easier all around to keep track of 
what's happening.

Kanoj
> 
> Which makes for a _very_ choppy balance, and is definitely wrong.
> 
> The behaviour should be something like:
>  - whenever we dip below "low", we wake up kswapd. kswapd remains awake
>    (for that zone) until we reach "enough".
>  - whenever we dip below "critical", we start doing synchronous memory
>    freeing ourselves. We continue to do that until we reach "low" again
>    (at which point kswapd will still continue in the background, but we
>    don't depend on the synchronous freeing any more).
> 
> but for some time we appear to have gotten this wrong, and lost the "low"
> mark, and used the "critical" and "high" marks only. 
> 
> Or maybe somebody did some testing and decided to disagree with the old
> three-level thing based on actual numbers? The only coding I've done has
> been based on "this is how I think it should work, and because I'm always
> right it's obviously the way it _should_ work". Which is not always the
> approach that gets the best results ;)
> 
> 		Linus
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

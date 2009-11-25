Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 505F46B0044
	for <linux-mm@kvack.org>; Wed, 25 Nov 2009 07:44:47 -0500 (EST)
Date: Wed, 25 Nov 2009 13:44:33 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] oom_kill: use rss value instead of vm size for badness
Message-ID: <20091125124433.GB27615@random.random>
References: <20091028175846.49a1d29c.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.0910280206430.7122@chino.kir.corp.google.com>
 <abbed627532b26d8d96990e2f95c02fc.squirrel@webmail-b.css.fujitsu.com>
 <20091029100042.973328d3.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.0910290125390.11476@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0910290125390.11476@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, vedran.furac@gmail.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hello,

lengthy discussion on something I think is quite obviously better and
I tried to change a couple of years back already (rss instead of
total_vm).

On Thu, Oct 29, 2009 at 01:31:59AM -0700, David Rientjes wrote:
> total_vm
> 708945 test
> 195695 krunner
> 168881 plasma-desktop
> 130567 ktorrent
> 127081 knotify4
> 125881 icedove-bin
> 123036 akregator
> 118641 kded4
> 
> rss
> 707878 test
> 42201 Xorg
> 13300 icedove-bin
> 10209 ktorrent
> 9277 akregator
> 8878 plasma-desktop
> 7546 krunner
> 4532 mysqld
> 
> This patch would pick the memory hogging task, "test", first everytime 

That is by far the only thing that matters. There's plenty of logic in
the oom killer to remove races with tasks with TIF_MEMDIE set, to
ensure not to fall into the second task until the first task had the
time to release all its memory back to the system.

> just like the current implementation does.  It would then prefer Xorg, 

You're focusing on the noise and not looking at the only thing that
matters.

The noise level with rss went down to 50000, it doesn't matter the
order of what's below 50000. Only thing it matters is the _delta_
between "noise-level innocent apps" and "exploit".

The delta is clearly increase from 708945-max(noise) to
707878-max(noise) which translates to a increase of precision from
513250 to 665677, which shows how much more rss is making the
detection more accurate (i.e. the distance between exploit and first
innocent app). The lower level the noise level starts, the less likely
the innocent apps are killed.

There's simply no way to get to perfection, some innocent apps will
always have high total_vm or rss levels, but this at least removes
lots of innocent apps from the equation. The fact X isn't less
innocent than before is because its rss is quite big, and this is not
an error, luckily much smaller than the hog itself. Surely there are
ways to force X to load huge bitmaps into its address space too
(regardless of total_vm or rss) but again no perfection, just better
with rss even in this testcase.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 4C8B68D0039
	for <linux-mm@kvack.org>; Sat, 29 Jan 2011 14:46:03 -0500 (EST)
Date: Sat, 29 Jan 2011 20:45:34 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: too big min_free_kbytes
Message-ID: <20110129194534.GX16981@random.random>
References: <20110128103539.GA14669@csn.ul.ie>
 <20110128162831.GH16981@random.random>
 <20110128164624.GA23905@csn.ul.ie>
 <4D42F9E3.2010605@redhat.com>
 <20110128174644.GM16981@random.random>
 <4D430506.2070502@redhat.com>
 <20110128182407.GO16981@random.random>
 <4D431A47.90408@redhat.com>
 <20110128194542.GV16981@random.random>
 <4D432D2D.4020504@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4D432D2D.4020504@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "Chen, Tim C" <tim.c.chen@intel.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 28, 2011 at 03:55:09PM -0500, Rik van Riel wrote:
> In that case, every zone will go down to the low watermark
> before kswapd is woken up.

This isn't what happens though, if that would be what happens, we
would see free memory going down back to ~130M and then up to 700M and
then down again to 130M, and not stuck at 700M at all times like
below. Example:

 0  0  70512 134940 379408 2753936    0    0   118    71    5    3  2  1 97  1
 0  0  70512 134808 379408 2753936    0    0     0     0   54   48  0  0 100  0
 0  1  70512 131228 383448 2753928    0    0  4160    68  149  172  0  0 99  1
 0  1  70512 276548 502184 2495564    0    0 118784    36 1357 2084  0  5 73 21
 1  1  70512 507932 624128 2151616    0    0 121984     0 1521 2166  0  6 77 17
 0  1  70512 699264 746484 1860468    0    0 122368     4 1443 2242  0  5 74 20
 0  1  70512 727040 865936 1722716    0    0 119552     0 1344 2194  0  5 75 21
 0  1  70512 733116 984396 1610292    0    0 118528     0 1311 2139  0  4 76 20
 1  0  70512 724064 1102864 1510256    0    0 118528     0 1302 2132  0  4 75 21
 1  0  70512 728900 1224312 1394328    0    0 121472     0 1395 2168  0  4 77 19
 1  0  70512 733736 1337224 1286852    0    0 115840    40 1404 2074  0  4 74 22

> At that point, kswapd will reclaim until every zone is at
> the high watermark, and go back to sleep.
> 
> There is no "free up to high + gap" in your scenario.

Well there clearly is from vmstat... I think you should be able to
reproduce if you boot with something like mem=4200m or so, workload is
simple "cp /dev/sda /dev/null".

Maybe we're waking kswapd too soon. But kswapd definitely goes to
sleep, infact it sleeps most of the time and it runs every once in a
while and it's unclear why the free memory never reaches back the 130M
level that it usually sits when there's no intensive read I/O like
shown above. For now, given what I see, I have to assume kswapd is
waken too soon, and not only when all wmarks reach low or the free
memory wouldn't be stuck at ~700M at all times while cp runs.

If kswapd is wakenup too soon, to me that is a separate problem and I
still don't see a significant benefit of having any "gap" bigger than
"high-low" there...

Like you said kswapd shouldn't run until we hit the low wmark again on
all zones, and I think that's more than enough without more "gap" than
the already available default "high-low" gap for the lower zones. If
the zone is bigger (like the below4g zone above) the wmark will be
bigger relative to the other zones. So when kswapd is wakenup because
all zones reach low wmark (we agree this is what should happen even if
it doesn't look like it's working right with "cp"), assuming all cache
is clean and immediately freeable kswapd will have to invoke
shrink_cache more times for the below4g zone. This "gap" added to
"high-low" will make the above4g lru rotate more times than needed to
reach the high wmark. But we allocated only "high-low" amount of cache
in the above4g zone lru. So I'm not sure if shrinking more than
"high-low" from it is right even from a balancing prospective in the
absolute trivial case of just 1 wakeup every time all zones hits the
low wmark.

At the same time if kswapd frees memory at the same rate that an
over4g allocator is allocating it, kswapd won't go to sleep and there
will be no rotation in the below4g lru at all. This is similar of what
we see above in fact, except for me kswapd goes to sleep because cp
isn't fast enough but a page fault could trigger it and prevent the
lru of the lower zones to ever rotate (simulating a kswapd wakeup too
soon, by just not making kswapd go to sleep and keeping hitting on the
high-low range on the over4g zone). So you see, there is no real
reliable way to have balancing guarantees from kswapd, and for the
trivial case where there is no concurrency between allocator and
kswapd freeing, rotating more the tiny above4g lru than "high-low"
despite we only allocated "high-low" cache into it doesn't sound
obviously right either. Bigger gap to me looks like will do more harm
than good and if we need a real guarantee of balancing we should
rotate the allocations across the zones (bigger lru in a zone will
require it to be hit more frequently because it'll rotate slower than
the other zones, the bias should not even dependent on the zone size
but on the lru size).

So for now it's all statistical but I doubt the "gap" shrunk in
addition of the "high-low" cache max allocated, is providing benefit.

Even in the non racing case all I can see is the smaller zones
(satisfying the "high" wmark faster than the bigger zones) (and the
smaller zones statistically should get a smaller lru too) being
lru-rotated way more than their small "high-low". Smaller zone should
be rotated in proportion of their small "high-low" only, and not
potentially as big as the biggest "high-low" for the biggest zone.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

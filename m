Received: from localhost (blah@localhost)
	by kvack.org (8.8.7/8.8.7) with SMTP id XAA21288
	for <linux-mm@kvack.org>; Thu, 10 Dec 1998 23:50:41 -0500
Date: Thu, 10 Dec 1998 23:50:41 -0500 (U)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Fwd: Strange/poor MM/Sched behaviour, 131ac8
Message-ID: <Pine.LNX.3.95.981210234954.21279A-100000@as200.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[grumble majordomo grumble]

Return-Path: <nconway.list@ukaea.org.uk>
Received: from ukaea.org.uk (gateway.ukaea.org.uk [194.128.63.74])
	by kvack.org (8.8.7/8.8.7) with ESMTP id XAA21150
	for <linux-mm@kvack.org>; Thu, 10 Dec 1998 23:33:44 -0500
Received: by gateway.ukaea.org.uk id <66309>; Fri, 11 Dec 1998 04:30:55 +0000
Sender: <nconway.list@ukaea.org.uk>
Message-Id: <98Dec11.043055gmt.66309@gateway.ukaea.org.uk>
Date: Fri, 11 Dec 1998 04:32:12 +0000
From: Neil Conway <nconway.list@ukaea.org.uk>
Organization: Fusion
X-Mailer: Mozilla 4.06 [en] (X11; I; Linux 2.0.35 i686)
MIME-Version: 1.0
To: Linux MM <linux-mm@kvack.org>,
        "linux-kernel@vger.rutgers.edu" <linux-kernel@vger.rutgers.edu>
Subject: Strange/poor MM/Sched behaviour, 131ac8
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Sorry to post a downer, but I'm somewhat let down by 131 (I leapt right
in at ac8).

On a Dell 410 (2xPII400, 512MB RAM, 512MB Swap, 2xU2W 4GB HD):

Firstly, the scheduler still gives really jerky performance for interactive
things when both CPU's are running CPU-intensive codes.  I'm talking here
about what happens when you type at the command prompt etc. and get slow
echoing of characters. (Rik - I haven't had time to patch in your scheduler
mods yet...).  I do believe this has been fixed by 3rd-party patches and I'll
try some soon, but I had expected the vanilla kernel to have caught up by now
(I mean doesn't anybody else with an SMP system expect decent interactive
response when the CPU's are busy?).  'nice +19' helps a lot, so I think maybe
it's due to the CPU-change penalty being too big, perhaps (!?)

Secondly, the Swap and Cache behaviour is weird...  In a nutshell, when
swapping starts, the kernel seems to let the cache GROW by 50-100% of
the amount that gets swapped out at each interval (I watch it with
'vmstat 1').  So during fast swapping, for every 16megs that gets swapped
out, the cache grows by about 6-8megs, and during slower swapping, I get
about 4-5megs swapped out per second and the cache grows by 4megs per second.
This is simply too weird for me, perhaps it makes sense to others ?  The vm
sysctls are at default settings.

Thirdly, after heavy swapping, ALL memory intensive programs can exit and yet
swap-space is still pseudo-"used", sometimes as much as 150megs or so on my
config. This prevents new codes from using all available virtual memory until
the swap-cache business rights itself.

Finally, during heavy swapping, 'vmstat 1' becomes unable to run once per
second, and it can be as slow as once every 10 seconds.  I found this shocking
and can only imagine that the swapout routines are trying too hard or for too
long at one go ??


To give a little more detail, here's the output of vmstat during one test run:
the program that was run simply allocates 800MB, and writes to each page in
sequence, then exits.  I've inserted comments to clarify.



 procs                  memory    swap        io    system         cpu
 r b w  swpd  free  buff cache  si  so   bi   bo   in   cs  us  sy  id

*** program starts allocating ram now:

 0 1 0 15268 492768  4932 13948  68   0  496    0  211  157   2   3  95
 1 0 0 15268 362408  4932 13972   0   0    0    0  129   31   6  44  50
 1 0 0 15268 231400  4932 13972   0   0    0    7  128    7   7  45  49
 1 0 0 15268 100180  4932 13972   0   0    0    0  114    4   8  43  49

*** now all physical ram consumed, begin swapping

 0 1 1  7228  1368  4932  5572   0 704    0  176  165   61   4  48  49
 0 1 0 19748  1324  4932 12476   0 15256    0 3814  673  903   1  19  80
 0 2 1 35364  1368  4932 19448   8 15480    9 3903  714  970   0  19  81
 0 1 1 50388  1488  4932 25888   4 15028    1 3757  675  902   0  20  80
 1 0 1 66896  1236  4932 33472   0 16644    0 4161  754 1093   0  23  77
 1 0 1 82364  1460  4932 40512   0 15364    0 3841  734 1027   0  23  76
 1 0 0 98100  1392  4932 47320   0 15872    0 3968  675  942   1  18  81
 0 1 1 114292  1088  4932 54388   0 16056    0 4016  693  954   0  16  84
 1 0 0 129588  1380  4932 61176   0 15436    0 3859  688  945   0  17  83
 1 0 1 145344  1028  4932 68336   0 17156    0 4289  831 1197   0  21  79
 1 0 1 162432  1216  4932 76048   0 15580    0 3895  692  977   1  18  81

*** good healthy swapping here, 16mb/sec or so it appears, and vmstat is
    still running once per second.  Context switches/sec ~= 1000.
    BUT: Note that the cache size is climbing upwards at about 7-8megs per
    second too - THIS is so weird -- swapping pages out to disk but caching
    them in RAM ??  Or have I misunderstood?

 1 1 1 178072  1320  4932 82812   8 15780   38 3945  673  939   0  15  84
 1 0 0 193892  1192  4932 89880   8 15844   46 3964  681  941   1  19  80
 0 2 1 209408  1716  4932 96692  20 15396   29 3849  744 1064   0  23  77
 0 1 1 225724  1308  4932 103704   0 16316    0 4079  715 1039   0  23  77
 procs                  memory    swap        io    system         cpu
 r b w  swpd  free  buff cache  si  so   bi   bo   in   cs  us  sy  id
 1 0 1 240692  1432  4932 110220  16 15140   68 3785  676  935   0  23  77
 1 0 1 251496  1444  4932 115300  56 10700   41 2675  522  675   0  17  83

*** Note that a cache pruning occurs here.  These can happen more than once
    per run.

 1 0 0 254752  2676  4932 27160   0 3260    0  817  222  320   5  38  56

*** This is where the trouble starts.  Often this new phase of slow swapping
    at about 4megs per second persists for a while, and during this period the
    cache growth rate is almost EXACTLY the same as swap-out rate.  This has
    me totally beaten; what's the point of swapping if free-ram doesn't go up?

 1 0 0 263656  1056  4932 10000   0 8940    0 2235  496  677   2  40  58
 0 1 0 328524   664  4932 73604  32 66172   38 16550 9829 12147   0  67  33
 0 1 0 371892  1172  4932 116244   4 42204    5 10553 6167 7823   0  64  36

*** Now the shit really hits the fan: look above at the context switch counts,
    and swap-out counts; these are due to huge delays of order 10 seconds.

 1 0 1 377112  1080  4932 120376  16 5236   24 1309  553  570   0  53  47
 0 1 1 382456  1056  4932 124656   0 5348    0 1337  470  605   0  60  40
 1 1 0 415380  3024  4932 154756   4 32928   22 8234 5261 6470   0  75  25

*** Above this line was some more intermittently slow and VERY slow swapping

*** And now the program exits, freeing the RAM.  Note that the swap usage is
    still at roughly 100megs, but only about 6megs worth of programs are running
    on this box.  Hence my "pseudo-swap-usage" reference above.

 1 0 0 98348 412048  4932 95352 800   0  733    0  181  201   4  29  67
 0 0 0 98020 411648  4932 95668 288   0  328    0  179  119   0   0  99
 0 0 0 98020 411648  4932 95668   0   0    0    0  128    4   0   0  99


So...  What gives ?  (Average swap-out speed for entire runs comes out at about
5megs/sec, which is much slower than the peak.  The disks get about 13megs/second
each from hdparm and the swap-space is striped across both of them.  So I'd have
hoped for rather faster average swapping speed.)

To really rub salt into the wound, I have to report than even running the code
with 490megs of RAM allocated, bad stuff happens.  On 2.0.x, repeated runs would
force stuff out of RAM until everything was running smoothly with no swapping
at all.  But on 2.1.131 I get some runs with almost no swapping, and duration of
run 4.4 seconds or so (for a healthy 100megs+ per second), but the speed cycles
up and down with swap and cache sizes cycling up and down to match, and quite a
few runs in any given set of repeat runs takes > 7 seconds.  That's freaky.

I don't know how to tune the VM system so all I can do is report and test...
There's clearly (to me) a problem with cache growth tuning.

Experts, please advise :-)

cheers
Neil

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org

Date: Thu, 18 May 2000 03:17:25 -0700 (MST)
From: Craig Kulesa <ckulesa@loke.as.arizona.edu>
Subject: Re: PATCH: Possible solution to VM problems (take 2)
In-Reply-To: <Pine.LNX.4.21.0005140101390.4107-100000@loke.as.arizona.edu>
Message-ID: <Pine.LNX.4.21.0005180221450.7333-100000@loke.as.arizona.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>


[Regarding Juan Quintela's wait_buffers_02.patch against pre9-2]

Wow. Much better!

The system doesn't hang itself in a CPU-thrashing-knot everytime an app
runs the used+cache allocations up to the limit of physical memory.  Cache
relinquishes gracefully, disk activity is dramatically less.  kswapd is
quiet again, whereas in pre8 it was eating 1/4 the integrated CPU time
as X11 at times.

I'm also not having the "cache content problems" I wrote about a few days
ago either.  Netscape, for example, is now perfectly content to load from
cache in 32 MB of RAM with room to spare.  General VM behavior has
pretty decent "feel" from 16 MB to 128 MB on 4 systems from 486DX2/66 to
PIII/500 under normal development load. 

In contrast, doing _anything_ while building a kernel on a 32 MB
Pentium/75 with pre8 was nothing short of a hair-pulling
experience.  [20 seconds for a bloody xterm?!]  It's smooth and
responsive now, even when assembling 40 MB RPM packages. Paging remains
gentle and not too distracting. Good. 

A stubborn problem that remains is the behavior when lots of
dirty pages pile up quickly.  Doing a giant 'dd' from /dev/zero to a
file on disk still causes gaps of unresponsiveness.  Here's a short vmstat
session on a 128 MB PIII system performing a 'dd if=/dev/zero of=dummy.dat
bs=1024k count=256':

   procs                      memory    swap          io     system         cpu
 r  b  w   swpd   free   buff  cache  si  so    bi    bo   in    cs  us  sy  id
 0  0  0   1392 100844    320  14000   0   0     0     0  186   409   0   0 100
 1  0  1   1392  53652    420  60080   0   0    12  3195  169   133   1  30  69
 0  1  1   1392  27572    444  85324   0   0     0  3487  329   495   0  18  82
 0  1  1   1392  15376    456  97128   0   0     0  3251  314   468   0   9  91
 0  1  2   1392   2332    472 109716   0   0    17  3089  308   466   0  11  89
 2  1  1   2820   2220    144 114392 380 1676   663 26644 20977 31578   0  10  90
 1  2  0   3560   2796    160 114220 284 792   303  9168 6542  7826   0  11  89
 4  2  1   3948   2824    168 114748 388 476   536 12975 9753 14203   1  11  88
 0  5  0   3944   2744    244 114496 552  88   791  4667 3827  4721   1   3  96
 2  0  0   3944   1512    416 115544  72   0   370     0  492  1417   0   3  97
 0  2  0   3916   2668    556 113800 132  36   330     9  415  1845   6   8  86
 1  0  0   3916   1876    720 114172   0   0   166     0  308  1333  14   6  80
 1  0  0   3912   2292    720 114244  76   0    19     0  347  1126   2   2  96
 2  0  0   3912   2292    720 114244   0   0     0     0  136   195   0   0 100

Guess the line when UI responsiveness was lost. :)

Yup.  Nothing abnormal happens until freemem decreases to zero, and then
the excrement hits the fan (albeit fairly briefly in this test).  After
the first wave of dirty pages are written out and the cache stabilizes,
user responsiveness seems to smooth out again. 

On the plus side...
It's relevant to note that this test caused rather reliable OOM
terminations of XFree86 from pre7-x (if not earlier) until this patch. I
haven't been able to generate any OOM process kills yet. And I've tried to
be very imaginative. :)

There's still some work needed, but Juan's patch seems to be resulting in
behavior that is clearly on the right track.  Great job guys, and thanks! 


Respectfully,
Craig Kulesa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

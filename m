Subject: Estrange behaviour of pre9-1
From: "Juan J. Quintela" <quintela@fi.udc.es>
Date: 16 May 2000 00:56:58 +0200
Message-ID: <yttzoprxw05.fsf@vexeta.dc.fi.udc.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Hi,
        this is a report about the actual situation of the VM system
in linux pre9-1.  I have been playing with the two patches from Rik,
with the patch from Linus (sync_buffer_pages), and with mine that
posted yesterday to the list.  I have been playing using the mmap002
code, I know that this is not a good performance test, but it is a
good test for pressure in page allocation.  I am exposing here my
findings expecting that somebody has some idea on how to solve them.

The tests have been done in K6-300Mmz, 98MB ram

       Vanilla pre9-1 dies in all the tries to run the test until the
machine becomes completely frozen.  No answer to ping, no answer to
keyboard, nothing in console, nothing in logs.  The last message
printed is that init has been killed by OOM.

       The one that more helped is Linus patch, it helps a lot in
performance, we go almost as fast as 2.2, the problem with this patch
is that sometimes we get out of memory errors (much less than with
vanilla kernel, but in 5/6 tries we get the error in init, and after
that the system freezes the same that previous paragraph.  Another
problem of the patch is that we spend *a lot of time* in the kernel,
system time has increased a lot.

real    6m12.635s
user    0m16.290s
sys     1m40.420s

In 2.2 the time of the whole process takes less than 2m, and the
system time is around 10 seconds.  At the end it finish killing
processes.


Next try is using the patch from Rik, augmenting also the priority in
try_to_free_pages to 16 (other magic values as 10 tested also) and
playing also with FREE_COUNT and SWAP_COUNT (8, 16 and 32).  The
system normally never kills any process, but it is slow, very slow:

real    11m48.746s
user    0m16.060s
sys     5m22.010s

It takes the double of wall clock time than the Linus version, and
more than thrice the system time.  Noted also that in this version I
see stalls in 'vmstat 1' output of more than 20 seconds.
More about the stalls later.

I tried several combinations of Rik & Linus patches, but I neither
achieve the good points of the two together.  I normally get the
instability of Linus patch (indeed more unstable), and the *slowness*
of Rik patch.  When combined, the system always get killed.

I try to use also the patch that I posted yesterday to minimise the
system time, my patch basically does is maintain the LRU list fixed and
quit/put only the elements that change position.  This helped in some
tests and don't help at all in other tests.  I have reached the
conclusion that the moment in which the system freezes is related when
it kills init, but that moment is *really* related with luck, then you
made a change in _any_ place and things go better, worst or equal and
you can affirm _nothing_ about the last change, the new result can
be very related with luck (or luck of that).

Talking about the stalls, I have noticed that seeing the vmstat output
they happened when the system is using all the page cache for holding
pages that are dirty (mmap002 only generates dirty pages, only reuse
pages after a lot of time).  And it happens when the page cache has
one size of 90MB in one machine with 98MB, in that moment stalls of 20
seconds (or more) happen.

See for instance output from vmstat 1 before one freeze:

 2  0  0   3148   2680     92  80496  36   0    10     7  156    28  62  38   0
 2  0  0   3312   2352     92  89724  40 164    11   707  148    51  67  33   0
 2  0  1   3364   1440    100  90796  52  68    89  4280  487   428  57  29  14
 1  2  0   3368   1784    392  84344 428  68  1475 94051 4852  6388  84  16   1
                                                   ^^^^^
 1  1  0   3372   2296    120  84196  36  40  4558    10  228   217  78  22   0
   procs                      memory    swap          io     system         cpu
 r  b  w   swpd   free   buff  cache  si  so    bi    bo   in    cs  us  sy  id


The system spend in the marked line something similar to 26 minutes,
during this time, no answer to ping, I noticed that the machine was
not dead when I went to copy the results and see that they was not in
the display, have moved.  After that slowdown:

Killed

real    0m23.441s
user    0m3.250s
sys     0m1.900s
Killed

real    26m23.029s
user    0m2.440s
sys     0m6.230s

real    3m6.289s
user    0m15.770s
sys     0m8.170s

real    2m14.012s
user    0m16.080s
sys     0m11.140s


After the two first killed mmap002 (notice the 26min, is not a bug of
the copy paste), the machine goes fast, after that point, no more
killed processes and the system goes fast, 2m14 seconds is quite fast
for this test, and 11 seconds for system time is not high at all.

Surprised for this last result, I send you my findings to the moment,
if you have some comments, suggestions, or you need more detailed
results, let me know.

Thanks for your time, Juan.


-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

Subject: Re: [PATCH] VM patch 3 for -ac7
References: <Pine.LNX.4.21.0006031212580.1123-100000@duckman.distro.conectiva>
Reply-To: zlatko@iskon.hr
From: Zlatko Calusic <zlatko@iskon.hr>
Date: 04 Jun 2000 19:46:27 +0200
In-Reply-To: Rik van Riel's message of "Sat, 3 Jun 2000 12:17:16 -0300 (BRST)"
Message-ID: <87wvk5e3v0.fsf@atlas.iskon.hr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi, Rik!

I tested all versions of your autotune patch (1-3) and am mostly
satisfied with the direction of the development. But still, I have
some objections and lots of questions. :)

First, something that is bothering me for a long time now (as 2.3.42
gets more far away timewise, and I have chosen that kernel version to
represent code that doesn't exhibit this particular bad behaviour):

Bulk I/O is performing terribly. Spurious swapping is killing us as we
read big chunks of data from disk. Ext2 optimizations and
anti-fragmentation code are now officialy obsolete, because they never
have a chance to come in effect. For example, check the following
chunk of "vmstat 1" output:

 0  0  0   6976  85140    232   4772   0   0     0     0  101   469   0   0  99
 0  1  0   6976  74532    244  15284   0   0  2638     7  290   802   1   4  94
 1  0  0   6976  59028    260  30772   0   0  3876     0  347   892   0   5  94
 0  1  0   6976  43012    276  46772   0   0  4004     0  356   779   0   5  95
 1  0  0   6976  26964    292  62900   0   0  4036     0  355   918   0   6  93
 0  1  0   6976  10852    308  78900   0   0  4004     0  355   931   0   5  94
   procs                      memory    swap          io     system         cpu
 r  b  w   swpd   free   buff  cache  si  so    bi    bo   in    cs  us  sy  id
 2  0  0   7304   3128    184  89120   0  56  2978    26  305   780   1  14  85
 1  0  1   8084   2916    156  90320   0 220  2659    55  306   764   0  18  82
 0  2  0   9448   2112    168  92236 104 312  1873    78  281   790   0  11  88
 0  2  0   9916   2656    180  92016 264 212   795    53  199   465   0   4  96
 0  1  1  10340   2956    192  92024   0 288  2175    72  268   727   1  10  89
 0  2  0  10460   1936    204  92928  24 308  2588    77  296   804   1   6  93
 0  1  0  10772   2028    208  93080  16 456  1706   114  252   648   0   8  92
 1  0  1  10824   2900    204  92232   0 556  2402   139  298   784   0   5  94
 0  2  0  10868   2036    192  93124  24 140  2767    35  301   844   0   9  91
 0  2  0  11080   1944    192  93460  16 104  2526    26  286   836   0   6  94
 0  1  0  11620   2604    192  93220   4  88  2553    22  277   760   0  10  90
 0  1  0  11816   2164    196  93844   0 264  2620    66  292   792   0   9  91
 0  2  0  12084   1840    204  94320  80 196  1416    49  232   567   0   5  95
 0  1  0  12084   1708    216  94352 240   0  1467     0  219   676   0   1  98

At time T (top of the output), I started reading a big file from the
4k ext2 FS. The machine is completely idle, and as you can see has
lots of memory free. Before the memory gets filled (first few lines),
you can also see that data is coming at a 16MB/sec pace (bi ~ 4000),
which is _exactly_ the available (and expected) bandwidth.

And *then* we get in the trouble. VM kicks in and starts to swap in
an' out at will. Disk heads starts thrashing with sounds similar to
the ones heard when running netscape on a 16MB machine. Of course, the
reading speed drops drastically, and in the end we finish 10 seconds
later than we expected. I/O bandwidth is effectively halved, and why?
Because we enlarged page cache from completely satisfying 90MB!!! to
95MB (by 5%!), and to get that pissy 5MB we were swapping out as mad,
then processes started recolecting their pages back from the disk,
then all over again...

Now the question is: is such behaviour as expected or will that get
fixed before the final 2.4.0?

I'm worried that we are going to release the ultimate swapping machine
and say to people: here is the new an' great stable kernel! Watch it
swap and never stop. :)

What especially bother me is that nobody sees the problem. Everybody
is talking about better and better kernel, how things are getting
stable and response time is getting better, but I see new releases
getting worse and worse with performance going down the drain. Tell me
that I'm an idiot, that system is supposed to swap all the time and
then I'll maybe stop bitching. But not before. :)

Second thing: Around two years before, IIRC, Linus and people on this
group decided that we don't need page aging, that it only kills
performance and thus code is removed, not to be seen again. I wasn't
so sure then it was such a good idea, but when Andrea's lru page
management got in, I become very satisfied with our page replacement
policies.

Obviously, with zoned memory we got in the trouble once again and now,
as a solution you're getting page aging in the kernel again. Could you
tell us what are you're reasons? What has changed in the meantime, so
that we haven't needed page aging two years before, and now we need
it?

I didn't find any improvement (as can be seen from the vmstat output
above). Yes, I'm well aware of what are you _trying_ to achieve, but
in reality, you've just added lots of logic to the kernel and
accomplished nothing. Not to say we're back to 2.1.something and
history is repeating. :(

Gratuitous adding of untested code this far in the development doesn't
look like a very good idea to me.

In the end, I hope nobody sees this rather long complaint as an
attack, but rather as a call to a debate of how we could improve the
kernel and hopefully get us 2.4.0 out sooner. 2.4.0 we'll be proud of.

Regards,
-- 
Zlatko
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA05235
	for <linux-mm@kvack.org>; Thu, 23 Jul 1998 11:07:00 -0400
Subject: Re: More info: 2.1.108 page cache performance on low memory
References: <199807131653.RAA06838@dax.dcs.ed.ac.uk> 	<m190lxmxmv.fsf@flinx.npwt.net> 	<199807141730.SAA07239@dax.dcs.ed.ac.uk> 	<m14swgm0am.fsf@flinx.npwt.net> 	<87d8b370ge.fsf@atlas.CARNet.hr> 	<199807221033.LAA00826@dax.dcs.ed.ac.uk> 	<87hg08vnmt.fsf@atlas.CARNet.hr> <199807231223.NAA04751@dax.dcs.ed.ac.uk>
Reply-To: Zlatko.Calusic@CARNet.hr
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 23 Jul 1998 17:06:48 +0200
In-Reply-To: "Stephen C. Tweedie"'s message of "Thu, 23 Jul 1998 13:23:25 +0100"
Message-ID: <87btqg1u9j.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: "Eric W. Biederman" <ebiederm+eric@npwt.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" <sct@redhat.com> writes:

> Hi,
> 
> On 23 Jul 1998 12:59:38 +0200, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
> said:
> 
> > As promised, I did some testing and I maybe have a solution (big
> > words, yeah! :)).
> 
> > As I see it, page cache seems too persistant (it grows out of bounds)
> > when we age pages in it.
> 
> Not on 110, it looks.  On low memory, .110 seems to be even better than
> .108 without the page ageing.  It is looking very good right now.
> 
> > I can provide thorough benchmark data, if needed.
> 
> Please do, but is this on .110?
> 

Yes, this is on .110.

Benchmarking methodology: compile kernel, reboot, fire up XDM, few
xterms, Xemacs and Netscape. In one xterm vmstat 10, in another copy
800MB worth of .mp3s :) to /dev/null (nothing special changes if I
copy them to another directory)

Official kernel:
1 x age_page() in shrink_mmap():

 procs                  memory    swap        io    system         cpu
 r b w  swpd  free  buff cache  si  so   bi   bo   in   cs  us  sy  id
 1 0 0     0  6832  4292 22740   0   0  182   15  220  155  25   9  66
 0 0 0     0  6860  4292 22744   0   0    0    5  112   10   0   0 100
 1 0 0   428  1380  1964 31260   0  43 5579   13  221  202   1  22  77
 1 0 0  2472  1428  1964 33256  10 209 5742   53  232  211   2  24  75
 1 0 0  5200  3500  1988 33928   5 273 6017   70  236  216   2  25  73
 1 0 0  7012  2940  1964 36292   6 181 6318   46  243  224   2  27  71
 1 0 0 11036  1084  1964 42168   6 402 5910  101  240  212   1  27  72
 1 0 0 12572  3832  2028 40900   6 154 5939   39  239  211   1  23  76
 1 0 0 14288 11336  1964 35180  10 172 5863   44  233  209   1  24  75
 1 0 0 17484  1188  1964 48552  29 320 5076   81  229  189   1  23  76
 1 0 0 18588 10640  1964 40176  42 111 4668   29  217  187   1  18  81
 1 0 0 21988  1576  1964 52636  43 342 5434   86  240  204   1  22  77
 1 0 0 23524 13676  1964 42076  47 154 5652   39  236  222   1  22  77
 1 1 0 23812  1284  1992 54728  41  31 5915    9  234  230   1  25  74
 1 0 0 24076 24324  2028 31916  40  30 6106    8  239  226   1  24  75
 1 0 0 24092 16064  2028 40188  48   7 5869    3  235  226   1  22  77
 0 0 0 24020  1540  2000 54724  30   0 2356    1  162  114   0  11  89
 0 0 0 23980  1536  2000 54688   8   0    2    0  104   19   0   0 100

24MB outswapped, lots of swapouts and swapins!!!. There would be much
more swap activity if I were actually using Netscape or XEmacs during
I/O, but in both test I didn't! I forgot to put "time" before cp :(,
but... 15 lines x 10 sec = cca 150 seconds to copy files. Also, notice
that I'm not memory starved (starting with cca 7 + 4 + 23 = 34 MB for
caches to use). In the last minute, system practically outswapped
everything it could, so it started to fight for every other page
effectively losing time (~30 pages out, ~40 pages in, every second).
Too bad. :(


Patched with small patch I posted:
3 x age_page() in shrink_mmap():

 procs                  memory    swap        io    system         cpu
 r b w  swpd  free  buff cache  si  so   bi   bo   in   cs  us  sy  id
 1 0 0     0  7072  4292 22768   0   0  172   15  217  153  23   9  68
 0 0 0     0  7048  4292 22736   0   0    0    2  109   11   0   0 100
 1 0 0    76  1044  1964 31444   0   8 5899    4  228  219   1  20  79
 1 0 0   116  6076  1964 26432   0   4 6665    2  243  241   2  27  71
 1 0 0   132  6492  2028 25980   0   2 6723    1  239  238   1  25  75
 1 0 0   488  6816  2028 26016   0  36 6671   10  240  233   1  25  74
 1 0 0  1288  1240  1964 32460   0  80 6163   21  232  220   1  23  76
 1 0 0  2152  1536  1964 33028   0  86 6234   22  233  223   1  24  76
 1 0 0  3008  1384  1964 34032   0  86 6313   22  235  229   1  22  77
 1 0 0  3084  1488  1964 34008   0   8 6135    3  229  223   1  22  77
 1 0 0  4816  1128  1964 36096   0 173 6778   44  247  237   2  25  73
 1 0 0  5912  1172  1964 37152   0 110 7103   28  252  252   1  29  70
 1 0 0  6904  1536  1964 37780   0  99 7247   26  250  252   1  27  72
 1 0 0  8348  3704  2028 36988   0 144 7095   37  255  243   1  25  73
 0 0 0  9164 14980  2028 26608   1  82 3278   22  173  120   1  13  86
 0 0 0  9164 14980  2028 26608   0   0    0    0  102    6   0   0 100

First thing to notice is only 10MB on swap (good). Second, and more
important, system was *not* swapping things in at all, because only
pages that really belonged to swap (unneeded) were swapped out.
Copying finished in 13 x 10 = ~130 seconds. Conclusion: better I/O
performance, better feel when using applications (I didn't have to
wait for Netscape or XEmacs to come from swap when I started to use
them, for real).

I was very carefull to do exactly the same sequence in both tests!
I think it is obvious from the first line of those vmstat reports.

Anything I forgot to test? :)

-- 
Posted by Zlatko Calusic           E-mail: <Zlatko.Calusic@CARNet.hr>
---------------------------------------------------------------------
	Remember that you are unique. Just like everyone else.
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org

Date: Mon, 24 Apr 2000 21:25:16 -0400
From: Simon Kirby <sim@stormix.com>
Subject: Re: [PATCH] 2.3.99-pre6-3+  VM rebalancing
Message-ID: <20000424212516.A4019@stormix.com>
References: <Pine.LNX.4.21.0004222301280.20850-100000@duckman.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.21.0004222301280.20850-100000@duckman.conectiva>; from riel@conectiva.com.br on Sat, Apr 22, 2000 at 11:08:35PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>, Ben LaHaise <bcrl@redhat.com>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Sat, Apr 22, 2000 at 11:08:35PM -0300, Rik van Riel wrote:

> Hi,
> 
> the following patch makes VM in 2.3.99-pre6+ behave more nice
> than in previous versions. It does that by:
> 
> - having a global lru queue for shrink_mmap()
> - slightly improving the lru scanning
> - being less agressive with lru scanning, so we'll have
>   more pages in the lru queue and will do better page
>   aging  (and also gives us a bigger buffer of clean pages,
>   this way big memory hogs have less impact on the rest of
>   the system)
> - freeing some pages from the "wrong" zone when freeing
>   from one particular zone ... this keeps memory balanced
>   because __alloc_pages() will allocate most pages from
>   the least busy zone
> 
> It has done some amazing things in test situations on my
> machine, but I have no idea what it'll do to kswapd cpu
> usage on >1GB machines. I think that the extra freedom in
> allocation will offset the slightly more expensive freeing
> code almost all of the time.

Hi,

This patch seems to help a lot overall in keeping the machine from diving
deep into swap after an average day's work in X (glade, netscape,
mozilla, many rxvts, etc.), but I still seem to see some situations that
seem broken.  Here's an example from when I was diffing pre6-5 against
pre6-6 while listening to an MP3 (shrunk a bit to aovid wrapping):

0 0 0  20224  3136  3312  60392   0   0    16    0  126  1173   2   0  98
0 1 0  20024  2572  3340  60292   0   0   253  254  280  1276   2   2  96
0 1 0  19932  3068  3404  60208   0  44   208   11  303  1423   5   2  93
0 1 0  19768  3020  3384  60340   0  32   424    8  335  1567   2  12  85
0 1 0  19780  2912  3284  60472   0  28   357   11  346  1596   3  11  86
1 1 0  19764  2932  3236  60472   0  32   389    8  357  1614   3  11  85
0 1 0  19644  2780  3252  60620   0   0   296    0  316  1551   3   7  90
1 1 0  19596  2892  3340  60352   0   0   211    0  286  1466   3   5  92
0 1 0  19396  2076  3364  61128   0   0   416    0  392  1712   2   7  91
0 0 0  19044  2956  3412  60096   0   0   304   12  356  1605   2  11  87
1 0 0  18952  2824  3420  60240   0  32   364    8  363  1644   1   6  92
0 0 1  17880  3068  3476  59908   0  52   481   13  398  1730   3   9  88
0 1 0  17760  2904  3556  60012   0  24   400    6  378  1667   1   6  93
1 1 0  17652  2772  3612  60032   0   0   275    0  288  1488   2   2  96
0 1 0  17580  2800  3636  59888   0  32   257    8  275  1468   2   1  96
1 1 0  17384  2568  3692  60072   0   0   568    0  364  1659   4   4  92
0 1 0  17164  2528  3668  60164   0  16   413    4  438  1800   1   3  95
0 2 0  17204  2728  3544  60088   0  40   452   10  434  1788   1   5  94
1 1 0  17236  2932  3588  59752   0  32   253    8  333  1591  12  38  50

It seems a bit odd that it is swapping out here when there is a lot of
cache memory available.

Dual processors at 450 MHz w/128 MB ECC SDRAM and a 7200 RPM WD 27.3 GB
IDE drive.

Simon-

[  Stormix Technologies Inc.  ][  NetNation Communications Inc. ]
[       sim@stormix.com       ][       sim@netnation.com        ]
[ Opinions expressed are not necessarily those of my employers. ]
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

Received: from mail.netwiz.net (Mail.NetWiz.Net [208.136.106.6])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA27929
	for <linux-mm@@kvack.org>; Sat, 23 May 1998 18:58:15 -0400
Received: from dublin.rubylane.com (BayArea56k469.NetWiz.Net [208.164.208.69])
          by mail.netwiz.net (8.8.5/8.8.4) with SMTP
	  id PAA09518 for <linux-mm@@kvack.org>; Sat, 23 May 1998 15:58:04 -0700
Message-Id: <199805232258.PAA09518@mail.netwiz.net>
Date: Sat, 23 May 1998 15:57:59 -0700
From: Jim Wilcoxson <jim@meritnet.com>
Subject: Can someone explain this swap/buffer trace?
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
To: "linux-mm@@kvack.org" <linux-mm@>kvack.org
List-ID: <linux-mm.kvack.org>

Hello, I'm trying to get familiar with the Linux buffer/swap algorithms.

Anybody know good sources of notes/documentation?

I have a 128M machine, 2.0.34pre16 with 5-6 processes running besides system stuff.  I did "dd if=/dev/hdb1 of=/dev/null" to cause some I/O.  Here is the vmstat trace:

[root@london /proc]# vmstat 5 
 procs                  memory    swap        io    system         cpu
 r b w  swpd  free  buff cache  si  so   bi   bo   in   cs  us  sy  id
 0 0 0     0 18484 54212 30384   0   0    0    4  120   35  23   1  76
 1 0 0     0 18484 54212 30392   0   0    0    8  116   29  12   1  87
 0 0 0     0 18480 54212 30384   0   0    0    6  115   25  14   1  86
 1 0 0    80  2252 68584 30396   3  16 5772    5 1562 2909  35  33  32
 2 0 0   168  2248 68656 30412   2  19 7119   11 1894 3573  22  40  38
 1 0 0   280  2252 68752 30416   1  26 7047   20 1879 3539  16  42  42
 1 0 0   344  2252 68840 30372   0  13 8154    5 2153 4093   9  44  47
 1 0 0   504  2232 68948 30432   0  32 4647   12 1284 2340  51  25  24
 2 0 0   568  2236 69016 30432   0  16 7560   14 2001 3794  16  43  40
 2 0 0   744  2248 69160 30428   0  32 7072   14 1888 3550  23  39  37
 1 0 0   756  2252 69220 30380   0   2 6652    3 1776 3341  31  34  34
 1 0 0   772  2236 69348 30300   2   6 7591   12 2006 3790  11  44  45
 1 0 0   884  2236 69444 30288   0  22 7034    8 1874 3533  18  41  41
 2 0 0  1028  2252 69560 30300   0  29 7154   63 1909 3589  19  41  40
 2 0 0  1124  2248 69640 30300   0  19 7215   11 1918 3622  19  39  41
 3 0 0  1236  2240 69752 30296   0  22 7188    8 1911 3609  21  40  39
 1 0 0  1348  2236 69832 30308   0  22 6634   10 1774 3332  23  38  39
 1 0 0  1412  2252 69892 30308   0  13 7173    8 1905 3600  18  43  39
 2 0 0  1572  2248 70012 30328   0  32 7094   12 1892 3566  25  35  40
 1 0 0  1604  2236 70044 30328   0   6 7652    5 2022 3834  16  47  37
 1 0 0  1748  2236 70172 30324   0  29 6692   12 1794 3363  21  38  41
 1 0 0  1828  2236 70228 30348   0  16 5949    6 1602 2991  34  35  31
 2 0 0  1924  2252 70312 30352   0  19 7211    9 1918 3621  14  42  44
 2 0 0  1988  2216 70388 30356   0  13 7376   12 1957 3703  14  41  44
 1 0 0  2080  2236 70460 30332   2  19 6191    8 1666 3114  30  37  33
 1 0 0  2144  2252 70516 30332   0  13 7323    6 1942 3672  19  42  39
 2 0 0  2240  2244 70600 30340   0  19 6624   12 1771 3327  19  38  43
 1 0 0  2416  2236 70720 30352   0  35 7167   11 1910 3601  18  45  37


After I killed the dd, this happened:

[root@london /proc]# vmstat 5
 procs                  memory    swap        io    system         cpu
 r b w  swpd  free  buff cache  si  so   bi   bo   in   cs  us  sy  id
 1 2 0  2592  2164 75204 25404   0   2 1368   28  457  706  21  10  70
 0 0 0  2580  2144 75204 25124   2   0    7   10  121   42  23   1  77
 3 0 0  2580  1928 75204 24972   0   0    8   13  125   38  13   3  84
 2 0 0  2580  1120 75204 25300   0   0   91    3  156  107  48  33  19
 1 0 0  2604  1132 74460 26524   0   5 1198   16  148   56  48  45   6
 1 0 0  2604  1136 68336 33188   0   0  302 2542  177  132  11  40  49
 0 0 0  2604 19768 63284 20768   0   0   10    6  123   38  13  21  66
 0 0 0  2604 19680 63348 20788   0   0    0   16  123   29  12   1  87
 0 0 0  2604 19672 63348 20788   0   0    0    7  111   17  13   1  86
 0 0 0  2600 19704 63348 20760   1   0    0   29  115   23  10   1  89
 1 0 0  2596 19616 63412 20788   1   0    2    5  114   22  15   1  84
 0 1 0  2588 19584 63412 20808   2   0    1  890  142   79  27   2  72


[root@london /proc/sys/vm]# cat freepages
280     420     560

According to the Documentation/memory-tuning file, these settings are:
  min_free_pages = 280 (1120K)
  free_pages_low = 420 (1680K)
  free_pages_high = 560 (2240K)
so I understand why free didn't go below 1120.  What triggered marking 18500K free in the middle though, and what is the glob of disk I/O around that?

The other thing I'm not sure about is why swap kept increasing.  It seems like after agressive buffer algorithm had paged out programs and data, then the active stuff was paged back in because the processes were still running, the amount of swap should not continue to increase.  Actually, since "si" remained fairly low during the test, it indicates that someone (kswapd?) did a good job of picking pages to throw out.  So I don't see why swap increases.  The processes I'm running are not increasing their memory usage this fast.

Dirty buffers are never written to swap are they?

Lost in the buffer cache...

Jim

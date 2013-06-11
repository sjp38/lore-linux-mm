Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 285A86B0033
	for <linux-mm@kvack.org>; Tue, 11 Jun 2013 10:34:39 -0400 (EDT)
From: Martin Steigerwald <ms@teamix.de>
Subject: Slow swap-in with SSD
Date: Tue, 11 Jun 2013 16:34:36 +0200
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Message-Id: <201306111634.36327.ms@teamix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi!

Using Linux 3.10-rc5 on an ThinkPad T520 with Intel Sandybridge i5-2620M,
8 GiB RAM and Intel SSD 320. Currently I have Zcache enabled to test the
effects of it but I observed similar figures on kernels without Zcache.

If I let the kernel swap out for example with

stress -m 1 --vm-keep --vm-bytes 5G

or so, then swapping out is pretty fast, I have seen values around
100-200 MiB/s

But on issuing a swapoff command to swap stuff in again, the swap in is
abysmally slow, just a few MiB/s (see below).

I wonder why is that so? The SSD is basically idling around on swap-in.


merkaba:~> stress -m 1 --vm-keep --vm-bytes 5G
stress: info: [10998] dispatching hogs: 0 cpu, 0 io, 1 vm, 0 hdd
^C

merkaba:~> swapon -s
Filename                                Type            Size    Used    Priority
/dev/mapper/merkaba-swap                partition       12582908        2168872 -1

merkaba:~> free -m
             total       used       free     shared    buffers     cached
Mem:          7767       2342       5425          0          0        305
-/+ buffers/cache:       2036       5730
Swap:        12287       2182      10105



merkaba:~> vmstat 1
procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
 1  0 2234528 5554868     40 313056    5   14   532    53  225  309  6  2 91  0
 0  0 2234508 5554736     40 313168   60    0    60     0  573  926  0  1 99  0
 0  0 2234508 5554736     40 313168    0    0     0     0  708 1317  1  1 98  0
 0  0 2234492 5554612     40 313168   52    0    52     0  530  946  0  1 99  0
 1  0 2193204 5524412    372 340940 1908    0  2476     0 3857 6961  1 22 75  2
 1  0 2190412 5522924    372 341044    0    0     0     0 2334 4606  0 26 74  0
 1  0 2187116 5521188    372 341044    0    0     0     0 2212 4625  0 26 74  0
 1  0 2182972 5517964    372 341072 1852    0  1852     0 3635 6901  0 25 73  2
 1  0 2178332 5515112    372 341076  196    0   196     0 2460 4997  1 26 73  1
 2  0 2172832 5511980    372 341076  104    0   104     0 2275 4742  0 26 74  0
 1  0 2165116 5508136    372 341076   12    0    12     0 2320 4741  0 26 74  0
 1  0 2154596 5501936    372 341080   92    0    92     0 2263 4768  0 26 74  0
 1  0 2144784 5494620    372 341108 3048    0  3048     0 4491 8359  1 24 73  3
 1  0 2135528 5486748    372 341092 5376    0  5376     0 5969 10706  1 23 72  4
 1  0 2131528 5481984    372 341268 2160    0  4776     0 3841 7337  1 24 72  3
 1  3 2128708 5478008    372 341544 3324    0  3648     0 3844 7318  0 24 72  4
 2  0 2126884 5463440    372 353084 2956    0 95900     0 9990 19942  1 27 51 21
 1  0 2124888 5461332    372 353084 1592    0  1592     0 3453 6590  0 25 73  2
 2  1 2118644 5439740    372 360832 6364    0 86884     4 10292 20131  1 29 42 27
 1  0 2113572 5415604    372 370908 4812    0 33340     0 9810 18000  5 33 52 10
 1  0 2111736 5413872    372 370684 1596    0  1684     0 3475 6487  1 25 73  2
 1  0 2109836 5411888    372 370728 1912    0  1912     0 3571 6776  0 25 73  2
 1  0 2107804 5410028    372 370740 1360    0  1360     0 3162 6164  0 25 73  2
 1  0 2106104 5407996    372 370740 1820    0  1820     0 3355 6493  0 25 73  2
 1  0 2103756 5406136    372 370776  976    0   976     0 3057 5974  1 26 71  1
 1  0 2101548 5403160    372 370776 2356    0  2356     0 3588 6939  1 26 71  2
 1  0 2099000 5400804    372 370776 1948    0  1948     0 3666 6884  1 25 72  3
 2  0 2096784 5398820    372 370776 1944    0  1944     0 3881 7383  1 27 70  2
 1  0 2094976 5397208    372 370776 1584    0  1584     0 3541 6564  1 25 73  2
 1  0 2092924 5394976    372 370776 1752    0  1752     0 3513 6649  0 24 73  2
 1  0 2089460 5391752    372 370776 1072    0  1072     0 3051 5932  1 25 73  2
 1  0 2084456 5389116    372 370776  496    0   496     0 2694 5272  0 26 74  1
 1  1 2081160 5386256    372 370804 2116    0  2116   696 4039 7462  1 25 73  2
 3  0 2077804 5383156    372 370816 3004    0  3004     0 4394 8157  1 24 73  3
 1  0 2075284 5380800    372 370816 1856    0  1856     0 3570 6831  1 25 73  2
 1  0 2073544 5379064    372 370824 1452    0  1452     0 3246 6270  0 25 73  2


According to atop the SSD is about 5-15% busy.


Swapoff is quite CPU busy:

  PID   TID  RUID      EUID       THR SYSCPU  USRCPU   VGROW   RGROW  RDDSK   WRDSK  ST  EXC S  CPUNR   CPU  CMD        1/7
11006     -  root      root         1  7.54s   0.00s      0K      0K 30100K      0K  --    - R      0   76%  swapoff

  PID   TID  RUID      EUID       THR SYSCPU  USRCPU   VGROW   RGROW  RDDSK   WRDSK  ST  EXC S  CPUNR   CPU  CMD        1/8
11006     -  root      root         1  9.65s   0.00s      0K      0K  7148K      0K  --    - R      3   97%  swapoff

  PID   TID  RUID      EUID       THR SYSCPU  USRCPU   VGROW   RGROW  RDDSK   WRDSK  ST  EXC S  CPUNR   CPU  CMD        1/6
11006     -  root      root         1  9.60s   0.00s      0K      0K  8752K      0K  --    - R      3   96%  swapoff


Anyway idea?


I can try this without Zcache as well. But I am pretty sure it was slow
as well. But I had ZCACHE compiled in, as far as I guess from hints on
the web, I bet its basically a no-op unless enabled with "zcache" kernel
commandline parameter.

Thanks,
-- 
Martin Steigerwald - teamix GmbH - http://www.teamix.de
gpg: 19E3 8D42 896F D004 08AC A0CA 1E10 C593 0399 AE90

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

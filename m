From: Bongani Hlope <bhlope@mweb.co.za>
Subject: Re: updatedb
Date: Thu, 26 Jul 2007 08:39:51 +0200
References: <367a23780707250830i20a04a60n690e8da5630d39a9@mail.gmail.com> <a491f91d0707251015x75404d9fld7b3382f69112028@mail.gmail.com> <46A81C39.4050009@gmail.com>
In-Reply-To: <46A81C39.4050009@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200707260839.51407.bhlope@mweb.co.za>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rene Herman <rene.herman@gmail.com>
Cc: Robert Deaton <false.hopes@gmail.com>, linux-kernel@vger.kernel.org, ck list <ck@vds.kolivas.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thursday 26 July 2007 05:59:53 Rene Herman wrote:
>
> Problem spot no. 1.
>
> RAM intensive? If I run updatedb here, it never grows itself beyond 2M.
> Yes, two. I'm certainly willing to accept that me and my systems are
> possibly not the reference but assuming I'm _very_ special hasn't done much
> for me either in the past.
>
> The thing updatedb does do, or at least has the potential to do, is fill
> memory with cached inodes/dentries but Linux does not swap to make room for
> caches. So why will updatedb "often cause things to be swapped out"?
>
> [ snip ]
>
> > Swap prefetch, on the other hand, would have kicked in shortly after
> > updatedb finished, leaving the applications in swap for a speedy
> > recovery when the person comes back to their computer.
>
> Problem spot no. 2.
>
> If updatedb filled all of RAM with inodes/dentries, that RAM is now used
> (ie, not free) and swap-prefetch wouldn't have anywhere to prefetch into so
> would _not_ have kicked in.
>
> So what's happening? If you sit down with a copy op "top" in one terminal
> and updatedb in another, what does it show?
>
> Rene.

Just tested that, there's a steady increase in the useage of buff

<start updatedb>
procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
 2  1      0 1279412 201160 234720    0    0   193    29  558  657  5  1 89  5
 0  1      0 1276624 203436 234872    0    0  2276     0 1638 2456  4  2 48 48
 1  1      0 1273372 206292 235012    0    0  2852     0 1773 2755  3  3 48 46
 2  1      0 1270128 208376 235360    0    0  2084     0 1545 2168  5  2 47 46

8<

 0  1      0 1228004 237288 237836    0    0  2192     0 1669 2941  6  3 47 44
 1  1      0 1223424 239228 238020    0    0  1932   272 1580 2881  9  4 44 44
 1  1      0 1219692 241600 238208    0    0  2372     0 1719 2881 10  4 45 43
 0  1      0 1217296 243372 238312    0    0  1772     0 1526 2320  4  2 49 46

8<

 0  1      0 1166852 277912 240840    0    0  2244     0 1699 3037  7  2 48 43
 0  1      0 1164016 279528 241016    0    0  1608   824 1512 2364  7  2 47 44
 1  1      0 1161256 281860 241264    0    0  2332     0 1709 2769  7  2 49 43
 1  1      0 1155632 284792 241452    0    0  2932     0 1835 3084  8  4 46 42

8< 

 0  1      0 1104568 324788 243616    0    0  3500     4 1879 3054  5  4 46 46
 1  1      0 1099596 328524 243768    0    0  3736     0 1990 3257  7  4 48 43
 1  1      0 1093976 332516 244060    0    0  3984   572 2013 3348  6  3 48 43
 0  1      0 1090320 335396 244340    0    0  2880     0 1760 2925  5  3 47 46

8<

 1  1      0 1025212 384380 248224    0    0  2940     0 1763 2864  6  3 46 46
 0  1      0 1022196 386444 248328    0    0  2064     8 1527 2543  5  2 45 47
 0  1      0 1018620 389476 248404    0    0  3032     0 1798 2988  6  3 47 45
 0  1      0 1014800 392364 248552    0    0  2888     0 1738 2821  5  2 48 45

8<

 0  1      0 425200 839828 273392    0    0  1744     0 1441 2248  9  2 44 46
 0  1      0 423360 841220 273544    0    0  1384   368 1374 2144  3  1 48 48
 0  1      0 421288 842868 273576    0    0  1648     0 1400 2141  4  2 46 48
 0  1      0 418252 845172 273676    0    0  2300     0 1570 2492  3  1 49 48
 0  0      0 417300 846100 273776    0    0   928     0 1232 1837  3  2 72 24 

<updatedb finished>

 0  0      0 416724 846100 273776    0    0     0     0 1025 1579  5  1 94  0
 0  0      0 417012 846100 273776    0    0     0     0 1002 1474  3  1 97  0
 1  0      0 417220 846100 273776    0    0     0     0 1026 1414  2  0 98  0

So 32 percent of free memory went to the buffers.

5 minutes later it's still not freed

procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
 2  0      0 409500 846652 277320    0    0   286    31  585  766  6  1 83 10
 1  0      0 409328 846652 277320    0    0     0     0 1003 1442  3  1 97  0

/proc/slabinfo
ext3_inode_cache  176198 176200    816    5    1 : tunables   54   27    8 : 
slabdata  35240  35240      0
dentry            233054 233054    208   19    1 : tunables  120   60    8 : 
slabdata  12266  12266      0
buffer_head       228303 228327    104   37    1 : tunables  120   60    8 : 
slabdata   6171   6171      0

run OpenOffice

procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
 1  0      0 403664 847056 277460    0    0   235    26  577  766  6  1 85  8
 0  0      0 403656 847056 277460    0    0     0     0 1003 1385  5  0 96  0
 0  0      0 403888 847056 277460    0    0     0     0 1237 1968  3  1 96  0

8<

<starts openoffice>
 0  0      0 400708 847088 277620    0    0     0     0 1058 1259  4  0 95  0
 0  0      0 400584 847088 277620    0    0     0     0 1246 1647  7  1 93  0
 1  1      0 389796 847164 284100    0    0  6528   116 1215 2663 10  4 71 14

8<

 0  0      0 307000 847464 361384    0    0     0     0 1031 1398  5  1 95  0
 0  0      0 307000 847464 361384    0    0     0     0 1003 1369  3  1 95  0
 0  0      0 307124 847464 361384    0    0     0     0 1025 1535  4  1 95  0

8<

 1  1      0 301920 847516 363176    0    0  1780   132 1092 1705 11  2 77 10
 1  1      0 289296 847588 367620    0    0  4608   152 1221 2280 31  4 48 18
 1  0      0 285672 847612 369572    0    0  1936     0 1061 3545 14  3 72 10
<open office loaded>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

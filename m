Message-ID: <46814829.8090808@redhat.com>
Date: Tue, 26 Jun 2007 13:08:57 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 01 of 16] remove nr_scan_inactive/active
References: <8e38f7656968417dfee0.1181332979@v2.random> <466C36AE.3000101@redhat.com> <20070610181700.GC7443@v2.random>
In-Reply-To: <20070610181700.GC7443@v2.random>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:

> If all tasks spend 10 minutes in shrink_active_list before the first
> call to shrink_inactive_list that could mean you hit the race that I'm
> just trying to fix with this very patch. 

I got around to testing it now.  I am using AIM7 since it is
a very anonymous memory heavy workload.

Unfortunately your patch does not fix the problem, but behaves
as I had feared :(

Both the normal kernel and your kernel fall over once memory
pressure gets big enough, but they explode differently and
at different points.

I am running the test on a quad core x86-64 system with 2GB
memory.  I am "zooming in" on the 4000 user range, because
that is where they start to diverge.  I am running aim7 to
cross-over, which is the point at which fewer than 1 jobs/min/user
are being completed.

First vanilla 2.6.22-rc5-git8:

Num     Parent   Child   Child  Jobs per   Jobs/min/  Std_dev  Std_dev  JTI
Forked  Time     SysTime UTime   Minute     Child      Time     Percent
4000    119.97   432.86  47.17   204051.01  51.01      11.52    9.99 
  90
4100    141.59   517.31  48.92   177215.91  43.22      6.67     4.84 
  95
4200    154.95   569.16  50.51   165885.77  39.50      5.07     3.35 
  96
4300    166.24   613.40  51.58   158301.25  36.81      10.59    6.51 
  93
4400    170.40   628.63  52.72   158028.17  35.92      5.46     3.27 
  96
4500    188.88   701.84  54.06   145806.86  32.40      6.13     3.31 
  96
4600    200.37   745.73  55.55   140500.07  30.54      4.98     2.54 
  97
4700    219.25   819.80  57.01   131192.70  27.91      5.38     2.51 
  97
4800    219.70   820.36  58.22   133709.60  27.86      5.40     2.52 
  97
4900    232.45   870.08  59.56   129008.39  26.33      4.65     2.02 
  97
5105    1704.46  5406.56 64.03   18329.91   3.59       264.38   18.85 
  81
Crossover achieved
Max Jobs per Minute 204051.01


Now 2.6.22-rc5-git8 with your patches 01/16 and 15/16:
Num     Parent   Child   Child  Jobs per   Jobs/min/  Std_dev  Std_dev  JTI
Forked  Time     SysTime UTime   Minute     Child      Time     Percent
4000    141.51   518.37  47.46   172991.31  43.25      5.20     3.75 
  96
4100    147.07   539.16  48.91   170612.63  41.61      5.11     3.58 
  96
4200    155.43   571.36  50.18   165373.48  39.37      5.42     3.58 
  96
4300    1317.89  4558.95 52.53   19968.28   4.64       219.76   18.42 
  81
Crossover achieved
Max Jobs per Minute 172991.31

One thing I noticed is that with the vanilla kernel, the lower
numbers of users allowed the system to still run fine, while
with your patches the system seemed to get stuck at ~90% system
time pretty quickly...

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 23EEE6B0002
	for <linux-mm@kvack.org>; Mon, 15 Apr 2013 14:15:19 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <1365163198-29726-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1365163198-29726-1-git-send-email-kirill.shutemov@linux.intel.com>
Subject: [RESEND] IOZone with transparent huge page cache
Content-Transfer-Encoding: 7bit
Message-Id: <20130415181718.4A1A1E0085@blue.fi.intel.com>
Date: Mon, 15 Apr 2013 21:17:18 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

[ resend with fixed mail headers, sorry ]

> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> 
> Here's third RFC. Thanks everybody for feedback.
> 
> The patchset is pretty big already and I want to stop generate new
> features to keep it reviewable. Next I'll concentrate on benchmarking and
> tuning.

Okay, here's first test results for the patchset (I did few minor fixes).

I run iozone using mmap files (-B) with different number of threads.
The test machine is 4s Westmere - 4x10 cores + HT.

** Initial writers **
threads:	        1        2        4        8       16       32       64      128      256
baseline:	  1103360   912585   500065   260503   128918    62039    34799    18718     9376
patched:	  2127476  2155029  2345079  1942158  1127109   571899   127090    52939    25950
speed-up(times):     1.93     2.36     4.69     7.46     8.74     9.22     3.65     2.83     2.77

** Rewriters **
threads:	        1        2        4        8       16       32       64      128      256
baseline:	  1391599  1167340  1040505   484431   225883   108426    53239    28133    15007
patched:	  2284535  1943774  2245681  1288542   438100   308559   115641    64990    30638
speed-up(times):     1.64     1.67     2.16     2.66     1.94     2.85     2.17     2.31     2.04

** Readers **
threads:	        1        2        4        8       16       32       64      128      256
baseline:	  1344180  1339641  1094513   604079   273020   129403    76666    41785    20111
patched:	  1790010  1807535  2039022  1884901  1470841   874517   429414   207033    99853
speed-up(times):     1.33     1.35     1.86     3.12     5.39     6.76     5.60     4.95     4.97

** Re-readers **
threads:	        1        2        4        8       16       32       64      128      256
baseline:	  1402398  1239448  1105293   653823   273997   130629    75943    40588    20456
patched:	  1928768  2076134  1791750  1907793  1494477   876014   432898   207279   102002
speed-up(times):     1.38     1.68     1.62     2.92     5.45     6.71     5.70     5.11     4.99

** Reverse readers **
threads:	        1        2        4        8       16       32       64      128      256
baseline:	  1545930  1443504  1175183   604320   277178   128694    76734    40956    20345
patched:	  1907933  1827041  1919202  1734568  1497661   862046   429960   208326    93213
speed-up(times):     1.23     1.27     1.63     2.87     5.40     6.70     5.60     5.09     4.58

** Random_readers **
threads:	        1        2        4        8       16       32       64      128      256
baseline:	  1069364   968029   887646   570211   257909   124713    74354    40663    20213
patched:	  1881762  2144045  1989631  2057963  1560892   867901   424109   205934    98021
speed-up(times):     1.76     2.21     2.24     3.61     6.05     6.96     5.70     5.06     4.85

** Random_writers **
threads:	        1        2        4        8       16       32       64      128      256
baseline:	  1236302  1033694   882697   475439   231973   113590    65675    35458    17890
patched:	  2778110  2484373  2454243  1329193   706394   353300   173871    86194    42815
speed-up(times):     2.25     2.40     2.78     2.80     3.05     3.11     2.65     2.43     2.39

Minimal speed up is in 1-thread reverse readers - 23%.
Maximal is 9.2 times in 32-thread initial writers. It's probably due
batched radix tree insert - we insert 512 pages a time. It reduces
mapping->tree_lock contention.

I wounder why rewriters are slower then initial writers. Readers also
slower then initial writers for low number of threads. It requires further
investigation.

In overall looks pretty impressive to me. :)

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

From: Nikita Danilov <Nikita@Namesys.COM>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16444.54077.645263.274441@laputa.namesys.com>
Date: Wed, 25 Feb 2004 19:54:21 +0300
Subject: Re: qsbench -m 350 numbers
In-Reply-To: <20040225021113.4171c6ab.akpm@osdl.org>
References: <20040225021113.4171c6ab.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <piggin@cyberone.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton writes:
 > This is a single-threaded workload.  We've been beating 2.4 on this since
 > forever.
 > 
 > time ./qsbench -m 350, 256MB, SMP:
 > 
 > 2.4.25					2:02.66 2:05.92 1:39.27
 > 
 > blk_congestion_wait-return-remaining	1:56.61 1:55.23 1:52.92
 > kswapd-throttling-fixes			2:06.49 2:05.53 2:06.18 2:06.52
 > vm-dont-rotate-active-list		2:05.73 2:08.44 2:08.86
 > vm-lru-info				2:07.00 2:07.17 2:08.65
 > vm-shrink-zone				2:02.60 2:00.91 2:02.34
 > vm-tune-throttle			2:05.88 1:58.20 1:58.02
 > shrink_slab-for-all-zones		2:00.67 2:02.30 1:58.36
 > zone-balancing-fix			2:06.54 2:08.29 2:07.17
 > zone-balancing-batching			2:36.25 2:38.86 2:43.28
 > 

I repeated qsbench test with patches from

ftp://ftp.namesys.com/pub/misc-patches/unsupported/extra/2004.02.25-2.6.3

They are mainly supposed to improve file system behavior, so this is to
check they don't hurt anonymous memory (much).

$ export TIMEFORMAT="%3R %3S %3U"
$ for i in $(seq 1 7) ;do time ./qsbench -m 350 -s 12345678 ;done

results for each patch (applied sequentially) are followed by two lines:
average of times and standard deviation ((DX)^2 = E(X^2) - (EX)^2):

          no-patches
109.839 3.001 24.494
111.130 3.070 24.257
109.804 2.871 24.053
109.334 3.015 24.104
112.372 3.009 24.098
109.226 3.135 23.822
109.675 2.996 24.014

110.197 3.014 24.120
  1.143 0.080  0.210

          skip-writepage 
111.444 2.978 24.016
107.087 2.829 23.980
109.878 2.824 24.000
108.302 2.759 24.107
108.967 2.838 23.962
109.467 2.978 23.855
109.485 3.056 23.859

109.233 2.895 23.968
  1.352 0.109  0.089

          dont-rotate-active-list 
107.124 2.959 24.309
109.589 2.872 24.045
108.346 2.977 23.965
108.313 2.965 24.087
110.276 3.020 23.816
107.223 2.979 24.098
110.580 3.007 24.063

108.779 2.968 24.055
  1.397 0.048  0.149

          trasnfer-dirty-on-refill
109.596 2.938 24.106
108.247 2.990 23.859
112.299 2.961 23.933
108.815 2.859 24.069
111.317 3.007 24.151
109.998 3.007 23.986
109.863 2.869 23.970

110.019 2.947 24.011
  1.395 0.062  0.103

          dont-unmap-on-pageout
113.099 2.870 24.224
114.249 2.856 24.101
112.065 2.721 23.919
113.318 2.891 24.209
115.456 2.943 24.152
112.370 2.923 24.087
113.593 2.857 23.983

113.450 2.866 24.096
  1.148 0.072  0.113

          async-writepage
110.078 2.983 24.410
112.285 3.045 23.959
111.987 2.922 23.990
114.183 3.043 24.018
114.291 3.003 24.102
113.335 2.954 24.245
115.764 2.958 24.967

113.132 2.987 24.242
  1.861 0.046  0.358

          set_page_dirty-lru
114.762 3.033 24.237
112.963 2.876 24.314
112.688 2.912 24.093
114.412 2.909 24.029
113.605 2.980 24.218
112.116 2.953 24.092
115.262 2.904 24.762

113.687 2.938 24.249
  1.166 0.054  0.247


Nikita.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

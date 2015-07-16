Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f182.google.com (mail-qk0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id 4C2902802DE
	for <linux-mm@kvack.org>; Thu, 16 Jul 2015 05:58:04 -0400 (EDT)
Received: by qkbp125 with SMTP id p125so46514379qkb.2
        for <linux-mm@kvack.org>; Thu, 16 Jul 2015 02:58:04 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j12si539485qkh.49.2015.07.16.02.58.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jul 2015 02:58:03 -0700 (PDT)
Date: Thu, 16 Jul 2015 11:57:56 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 3/3] slub: build detached freelist with look-ahead
Message-ID: <20150716115756.311496af@redhat.com>
In-Reply-To: <20150715160212.17525.88123.stgit@devil>
References: <20150715155934.17525.2835.stgit@devil>
	<20150715160212.17525.88123.stgit@devil>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Alexander Duyck <alexander.duyck@gmail.com>, Hannes Frederic Sowa <hannes@stressinduktion.org>, brouer@redhat.com


On Wed, 15 Jul 2015 18:02:39 +0200 Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> Results:
[...]
> bulk- Fallback                  - Bulk API
>   1 -  64 cycles(tsc) 16.144 ns - 47 cycles(tsc) 11.931 - improved 26.6%
>   2 -  57 cycles(tsc) 14.397 ns - 29 cycles(tsc)  7.368 - improved 49.1%
>   3 -  55 cycles(tsc) 13.797 ns - 24 cycles(tsc)  6.003 - improved 56.4%
>   4 -  53 cycles(tsc) 13.500 ns - 22 cycles(tsc)  5.543 - improved 58.5%
>   8 -  52 cycles(tsc) 13.008 ns - 20 cycles(tsc)  5.047 - improved 61.5%
>  16 -  51 cycles(tsc) 12.763 ns - 20 cycles(tsc)  5.015 - improved 60.8%
>  30 -  50 cycles(tsc) 12.743 ns - 20 cycles(tsc)  5.062 - improved 60.0%
>  32 -  51 cycles(tsc) 12.908 ns - 20 cycles(tsc)  5.089 - improved 60.8%
>  34 -  87 cycles(tsc) 21.936 ns - 28 cycles(tsc)  7.006 - improved 67.8%
>  48 -  79 cycles(tsc) 19.840 ns - 31 cycles(tsc)  7.755 - improved 60.8%
>  64 -  86 cycles(tsc) 21.669 ns - 68 cycles(tsc) 17.203 - improved 20.9%
> 128 - 101 cycles(tsc) 25.340 ns - 72 cycles(tsc) 18.195 - improved 28.7%
> 158 - 112 cycles(tsc) 28.152 ns - 73 cycles(tsc) 18.372 - improved 34.8%
> 250 - 110 cycles(tsc) 27.727 ns - 73 cycles(tsc) 18.430 - improved 33.6%


Something interesting happens, when I'm tuning the SLAB/slub cache...

I was thinking what happens if I "give" the slub more per CPU partial
pages.  In my benchmark 250 is my "max" bulk working set.

Tuning SLAB/slub for 256 bytes object size, by tuning SLUB saying each
CPU partial should be allowed to contain 256 objects (cpu_partial).

 sudo sh -c 'echo 256 > /sys/kernel/slab/:t-0000256/cpu_partial'

And adjusting 'min_partial' affects __slab_free() by avoiding removing
partial if node->nr_partial >= s->min_partial.  Thus, in our test
min_partial=9 result in keeping 9 pages 32 * 9 = 288 objects in the

 sudo sh -c 'echo 9   > /sys/kernel/slab/:t-0000256/min_partial'
 sudo grep -H . /sys/kernel/slab/:t-0000256/*

First notice the normal fastpath is: 47 cycles(tsc) 11.894 ns

Patch03-TUNED-run01:
bulk-  Fallback                 - Bulk-API
  1 -  63 cycles(tsc) 15.866 ns - 46 cycles(tsc) 11.653 ns - improved 27.0%
  2 -  56 cycles(tsc) 14.137 ns - 28 cycles(tsc)  7.106 ns - improved 50.0%
  3 -  54 cycles(tsc) 13.623 ns - 23 cycles(tsc)  5.845 ns - improved 57.4%
  4 -  53 cycles(tsc) 13.345 ns - 21 cycles(tsc)  5.316 ns - improved 60.4%
  8 -  51 cycles(tsc) 12.960 ns - 20 cycles(tsc)  5.187 ns - improved 60.8%
 16 -  50 cycles(tsc) 12.743 ns - 20 cycles(tsc)  5.091 ns - improved 60.0%
 30 -  80 cycles(tsc) 20.153 ns - 28 cycles(tsc)  7.054 ns - improved 65.0%
 32 -  82 cycles(tsc) 20.621 ns - 33 cycles(tsc)  8.392 ns - improved 59.8%
 34 -  80 cycles(tsc) 20.125 ns - 32 cycles(tsc)  8.046 ns - improved 60.0%
 48 -  91 cycles(tsc) 22.887 ns - 30 cycles(tsc)  7.655 ns - improved 67.0%
 64 -  85 cycles(tsc) 21.362 ns - 36 cycles(tsc)  9.141 ns - improved 57.6%
128 - 101 cycles(tsc) 25.481 ns - 33 cycles(tsc)  8.286 ns - improved 67.3%
158 - 103 cycles(tsc) 25.909 ns - 36 cycles(tsc)  9.179 ns - improved 65.0%
250 - 105 cycles(tsc) 26.481 ns - 39 cycles(tsc)  9.994 ns - improved 62.9%

Notice how ALL of the bulk sizes now are faster than the 47 cycles of
the normal slub fastpath.  This is amazing!

A little strangely, the tuning didn't seem to help the fallback version.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer



On Wed, 15 Jul 2015 18:02:39 +0200 Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> Results:
> 
> bulk size:16, average: +2.01 cycles
>  Prev: between 19-52 (average: 22.65 stddev:+/-6.9)
>  This: between 19-67 (average: 24.67 stddev:+/-9.9)

bulk16:  19-39(average: 21.68+/-4.5) cycles(tsc)
 
> bulk size:48, average: +1.54 cycles
>  Prev: between 23-45 (average: 27.88 stddev:+/-4)
>  This: between 24-41 (average: 29.42 stddev:+/-3.7)

bulk48:  25-38(average: 28.4+/-2.3) cycles(tsc)
 
> bulk size:144, average: +1.73 cycles
>  Prev: between 44-76 (average: 60.31 stddev:+/-7.7)
>  This: between 49-80 (average: 62.04 stddev:+/-7.3)

bulk144: 31-45(average: 34.54+/-3.4) cycles(tsc)

> bulk size:512, average: +8.94 cycles
>  Prev: between 50-68 (average: 60.11 stddev: +/-4.3)
>  This: between 56-80 (average: 69.05 stddev: +/-5.2)

bulk512: 38-68(average: 44.48+/-7.1) cycles(tsc)
(quite good given working set tuned for is 256)

> bulk size:2048, average: +26.81 cycles
>  Prev: between 61-73 (average: 68.10 stddev:+/-2.9)
>  This: between 90-104(average: 94.91 stddev:+/-2.1)

bulk2048: 80-87(average: 83.19+/-1.1)
 
> [1] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/mm/slab_bulk_test02.c
> [2] https://github.com/rustyrussell/stats

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

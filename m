Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 579E39003C7
	for <linux-mm@kvack.org>; Sun, 19 Jul 2015 22:50:04 -0400 (EDT)
Received: by pabkd10 with SMTP id kd10so22320439pab.2
        for <linux-mm@kvack.org>; Sun, 19 Jul 2015 19:50:04 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id c12si32371091pdm.42.2015.07.19.19.50.02
        for <linux-mm@kvack.org>;
        Sun, 19 Jul 2015 19:50:03 -0700 (PDT)
Date: Mon, 20 Jul 2015 11:54:15 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 3/3] slub: build detached freelist with look-ahead
Message-ID: <20150720025415.GA21760@js1304-P5Q-DELUXE>
References: <20150715155934.17525.2835.stgit@devil>
 <20150715160212.17525.88123.stgit@devil>
 <20150716115756.311496af@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150716115756.311496af@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Duyck <alexander.duyck@gmail.com>, Hannes Frederic Sowa <hannes@stressinduktion.org>

On Thu, Jul 16, 2015 at 11:57:56AM +0200, Jesper Dangaard Brouer wrote:
> 
> On Wed, 15 Jul 2015 18:02:39 +0200 Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> 
> > Results:
> [...]
> > bulk- Fallback                  - Bulk API
> >   1 -  64 cycles(tsc) 16.144 ns - 47 cycles(tsc) 11.931 - improved 26.6%
> >   2 -  57 cycles(tsc) 14.397 ns - 29 cycles(tsc)  7.368 - improved 49.1%
> >   3 -  55 cycles(tsc) 13.797 ns - 24 cycles(tsc)  6.003 - improved 56.4%
> >   4 -  53 cycles(tsc) 13.500 ns - 22 cycles(tsc)  5.543 - improved 58.5%
> >   8 -  52 cycles(tsc) 13.008 ns - 20 cycles(tsc)  5.047 - improved 61.5%
> >  16 -  51 cycles(tsc) 12.763 ns - 20 cycles(tsc)  5.015 - improved 60.8%
> >  30 -  50 cycles(tsc) 12.743 ns - 20 cycles(tsc)  5.062 - improved 60.0%
> >  32 -  51 cycles(tsc) 12.908 ns - 20 cycles(tsc)  5.089 - improved 60.8%
> >  34 -  87 cycles(tsc) 21.936 ns - 28 cycles(tsc)  7.006 - improved 67.8%
> >  48 -  79 cycles(tsc) 19.840 ns - 31 cycles(tsc)  7.755 - improved 60.8%
> >  64 -  86 cycles(tsc) 21.669 ns - 68 cycles(tsc) 17.203 - improved 20.9%
> > 128 - 101 cycles(tsc) 25.340 ns - 72 cycles(tsc) 18.195 - improved 28.7%
> > 158 - 112 cycles(tsc) 28.152 ns - 73 cycles(tsc) 18.372 - improved 34.8%
> > 250 - 110 cycles(tsc) 27.727 ns - 73 cycles(tsc) 18.430 - improved 33.6%
> 
> 
> Something interesting happens, when I'm tuning the SLAB/slub cache...
> 
> I was thinking what happens if I "give" the slub more per CPU partial
> pages.  In my benchmark 250 is my "max" bulk working set.
> 
> Tuning SLAB/slub for 256 bytes object size, by tuning SLUB saying each
> CPU partial should be allowed to contain 256 objects (cpu_partial).
> 
>  sudo sh -c 'echo 256 > /sys/kernel/slab/:t-0000256/cpu_partial'
> 
> And adjusting 'min_partial' affects __slab_free() by avoiding removing
> partial if node->nr_partial >= s->min_partial.  Thus, in our test
> min_partial=9 result in keeping 9 pages 32 * 9 = 288 objects in the
> 
>  sudo sh -c 'echo 9   > /sys/kernel/slab/:t-0000256/min_partial'
>  sudo grep -H . /sys/kernel/slab/:t-0000256/*
> 
> First notice the normal fastpath is: 47 cycles(tsc) 11.894 ns
> 
> Patch03-TUNED-run01:
> bulk-  Fallback                 - Bulk-API
>   1 -  63 cycles(tsc) 15.866 ns - 46 cycles(tsc) 11.653 ns - improved 27.0%
>   2 -  56 cycles(tsc) 14.137 ns - 28 cycles(tsc)  7.106 ns - improved 50.0%
>   3 -  54 cycles(tsc) 13.623 ns - 23 cycles(tsc)  5.845 ns - improved 57.4%
>   4 -  53 cycles(tsc) 13.345 ns - 21 cycles(tsc)  5.316 ns - improved 60.4%
>   8 -  51 cycles(tsc) 12.960 ns - 20 cycles(tsc)  5.187 ns - improved 60.8%
>  16 -  50 cycles(tsc) 12.743 ns - 20 cycles(tsc)  5.091 ns - improved 60.0%
>  30 -  80 cycles(tsc) 20.153 ns - 28 cycles(tsc)  7.054 ns - improved 65.0%
>  32 -  82 cycles(tsc) 20.621 ns - 33 cycles(tsc)  8.392 ns - improved 59.8%
>  34 -  80 cycles(tsc) 20.125 ns - 32 cycles(tsc)  8.046 ns - improved 60.0%
>  48 -  91 cycles(tsc) 22.887 ns - 30 cycles(tsc)  7.655 ns - improved 67.0%
>  64 -  85 cycles(tsc) 21.362 ns - 36 cycles(tsc)  9.141 ns - improved 57.6%
> 128 - 101 cycles(tsc) 25.481 ns - 33 cycles(tsc)  8.286 ns - improved 67.3%
> 158 - 103 cycles(tsc) 25.909 ns - 36 cycles(tsc)  9.179 ns - improved 65.0%
> 250 - 105 cycles(tsc) 26.481 ns - 39 cycles(tsc)  9.994 ns - improved 62.9%
> 
> Notice how ALL of the bulk sizes now are faster than the 47 cycles of
> the normal slub fastpath.  This is amazing!
> 
> A little strangely, the tuning didn't seem to help the fallback version.

Hello,

Looks very nice.

I have some questions about your benchmark and result.

1. Does the slab is merged?
- Your above result shows that fallback bulk for 30, 32 takes longer
  than fallback bulk for 16. This is strange result because fallback
  bulk allocation/free for 16, 30, 32 should happens only on cpu cache.
  If the slab is merged, you should turn off merging to get precise
  result.

2. Could you show result with only tuning min_partial?
- I guess that much improvement for Bulk-API comes from disappearing
  slab page allocation/free cost rather than tuning cpu_partial.

3. For more precise test setup, how about setting cpu affinity?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

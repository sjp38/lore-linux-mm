Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id B88136B0264
	for <linux-mm@kvack.org>; Mon, 20 Jul 2015 17:28:26 -0400 (EDT)
Received: by qgii95 with SMTP id i95so48071175qgi.2
        for <linux-mm@kvack.org>; Mon, 20 Jul 2015 14:28:26 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b102si25819158qga.35.2015.07.20.14.28.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Jul 2015 14:28:25 -0700 (PDT)
Date: Mon, 20 Jul 2015 23:28:17 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 3/3] slub: build detached freelist with look-ahead
Message-ID: <20150720232817.05f08663@redhat.com>
In-Reply-To: <20150720025415.GA21760@js1304-P5Q-DELUXE>
References: <20150715155934.17525.2835.stgit@devil>
	<20150715160212.17525.88123.stgit@devil>
	<20150716115756.311496af@redhat.com>
	<20150720025415.GA21760@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Duyck <alexander.duyck@gmail.com>, Hannes Frederic Sowa <hannes@stressinduktion.org>, brouer@redhat.com

On Mon, 20 Jul 2015 11:54:15 +0900
Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:

> On Thu, Jul 16, 2015 at 11:57:56AM +0200, Jesper Dangaard Brouer wrote:
> > 
> > On Wed, 15 Jul 2015 18:02:39 +0200 Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> > 
> > > Results:
> > [...]
> > > bulk- Fallback                  - Bulk API
> > >   1 -  64 cycles(tsc) 16.144 ns - 47 cycles(tsc) 11.931 - improved 26.6%
> > >   2 -  57 cycles(tsc) 14.397 ns - 29 cycles(tsc)  7.368 - improved 49.1%
> > >   3 -  55 cycles(tsc) 13.797 ns - 24 cycles(tsc)  6.003 - improved 56.4%
> > >   4 -  53 cycles(tsc) 13.500 ns - 22 cycles(tsc)  5.543 - improved 58.5%
> > >   8 -  52 cycles(tsc) 13.008 ns - 20 cycles(tsc)  5.047 - improved 61.5%
> > >  16 -  51 cycles(tsc) 12.763 ns - 20 cycles(tsc)  5.015 - improved 60.8%
> > >  30 -  50 cycles(tsc) 12.743 ns - 20 cycles(tsc)  5.062 - improved 60.0%
> > >  32 -  51 cycles(tsc) 12.908 ns - 20 cycles(tsc)  5.089 - improved 60.8%
> > >  34 -  87 cycles(tsc) 21.936 ns - 28 cycles(tsc)  7.006 - improved 67.8%
> > >  48 -  79 cycles(tsc) 19.840 ns - 31 cycles(tsc)  7.755 - improved 60.8%
> > >  64 -  86 cycles(tsc) 21.669 ns - 68 cycles(tsc) 17.203 - improved 20.9%
> > > 128 - 101 cycles(tsc) 25.340 ns - 72 cycles(tsc) 18.195 - improved 28.7%
> > > 158 - 112 cycles(tsc) 28.152 ns - 73 cycles(tsc) 18.372 - improved 34.8%
> > > 250 - 110 cycles(tsc) 27.727 ns - 73 cycles(tsc) 18.430 - improved 33.6%
> > 
> > 
> > Something interesting happens, when I'm tuning the SLAB/slub cache...
> > 
> > I was thinking what happens if I "give" the slub more per CPU partial
> > pages.  In my benchmark 250 is my "max" bulk working set.
> > 
> > Tuning SLAB/slub for 256 bytes object size, by tuning SLUB saying each
> > CPU partial should be allowed to contain 256 objects (cpu_partial).
> > 
> >  sudo sh -c 'echo 256 > /sys/kernel/slab/:t-0000256/cpu_partial'
> > 
> > And adjusting 'min_partial' affects __slab_free() by avoiding removing
> > partial if node->nr_partial >= s->min_partial.  Thus, in our test
> > min_partial=9 result in keeping 9 pages 32 * 9 = 288 objects in the
> > 
> >  sudo sh -c 'echo 9   > /sys/kernel/slab/:t-0000256/min_partial'
> >  sudo grep -H . /sys/kernel/slab/:t-0000256/*
> > 
> > First notice the normal fastpath is: 47 cycles(tsc) 11.894 ns
> > 
> > Patch03-TUNED-run01:
> > bulk-  Fallback                 - Bulk-API
> >   1 -  63 cycles(tsc) 15.866 ns - 46 cycles(tsc) 11.653 ns - improved 27.0%
> >   2 -  56 cycles(tsc) 14.137 ns - 28 cycles(tsc)  7.106 ns - improved 50.0%
> >   3 -  54 cycles(tsc) 13.623 ns - 23 cycles(tsc)  5.845 ns - improved 57.4%
> >   4 -  53 cycles(tsc) 13.345 ns - 21 cycles(tsc)  5.316 ns - improved 60.4%
> >   8 -  51 cycles(tsc) 12.960 ns - 20 cycles(tsc)  5.187 ns - improved 60.8%
> >  16 -  50 cycles(tsc) 12.743 ns - 20 cycles(tsc)  5.091 ns - improved 60.0%
> >  30 -  80 cycles(tsc) 20.153 ns - 28 cycles(tsc)  7.054 ns - improved 65.0%
> >  32 -  82 cycles(tsc) 20.621 ns - 33 cycles(tsc)  8.392 ns - improved 59.8%
> >  34 -  80 cycles(tsc) 20.125 ns - 32 cycles(tsc)  8.046 ns - improved 60.0%
> >  48 -  91 cycles(tsc) 22.887 ns - 30 cycles(tsc)  7.655 ns - improved 67.0%
> >  64 -  85 cycles(tsc) 21.362 ns - 36 cycles(tsc)  9.141 ns - improved 57.6%
> > 128 - 101 cycles(tsc) 25.481 ns - 33 cycles(tsc)  8.286 ns - improved 67.3%
> > 158 - 103 cycles(tsc) 25.909 ns - 36 cycles(tsc)  9.179 ns - improved 65.0%
> > 250 - 105 cycles(tsc) 26.481 ns - 39 cycles(tsc)  9.994 ns - improved 62.9%
> > 
> > Notice how ALL of the bulk sizes now are faster than the 47 cycles of
> > the normal slub fastpath.  This is amazing!
> > 
> > A little strangely, the tuning didn't seem to help the fallback version.
> 
> Hello,
> 
> Looks very nice.

Thanks :-)

> I have some questions about your benchmark and result.
> 
> 1. Does the slab is merged?
> - Your above result shows that fallback bulk for 30, 32 takes longer
>   than fallback bulk for 16. This is strange result because fallback
>   bulk allocation/free for 16, 30, 32 should happens only on cpu cache.

I guess it depends on how "used/full" the page is... some other
subsystem can hold on to objects...

>   If the slab is merged, you should turn off merging to get precise
>   result.

Yes, I think it is merged... how do I turn off merging?

Before adjusting/tuning the SLAB.

$ sudo grep -H . /sys/kernel/slab/:t-0000256/{cpu_partial,min_partial,order,objs_per_slab}
/sys/kernel/slab/:t-0000256/cpu_partial:13
/sys/kernel/slab/:t-0000256/min_partial:5
/sys/kernel/slab/:t-0000256/order:1
/sys/kernel/slab/:t-0000256/objs_per_slab:32

Run01: non-tuned
1 - 64 cycles(tsc) 16.092 ns -  47 cycles(tsc) 11.886 ns
2 - 57 cycles(tsc) 14.258 ns -  28 cycles(tsc) 7.226 ns
3 - 54 cycles(tsc) 13.626 ns -  23 cycles(tsc) 5.822 ns
4 - 53 cycles(tsc) 13.328 ns -  20 cycles(tsc) 5.185 ns
8 - 93 cycles(tsc) 23.301 ns -  49 cycles(tsc) 12.406 ns
16 - 83 cycles(tsc) 20.902 ns -  37 cycles(tsc) 9.418 ns
30 - 77 cycles(tsc) 19.400 ns -  30 cycles(tsc) 7.748 ns
32 - 79 cycles(tsc) 19.938 ns -  30 cycles(tsc) 7.751 ns
34 - 80 cycles(tsc) 20.215 ns -  35 cycles(tsc) 8.907 ns
48 - 85 cycles(tsc) 21.391 ns -  24 cycles(tsc) 6.219 ns
64 - 93 cycles(tsc) 23.272 ns -  67 cycles(tsc) 16.874 ns
128 - 101 cycles(tsc) 25.407 ns -  72 cycles(tsc) 18.097 ns
158 - 105 cycles(tsc) 26.319 ns -  72 cycles(tsc) 18.164 ns
250 - 107 cycles(tsc) 26.783 ns -  72 cycles(tsc) 18.246 ns

Run02: non-tuned
1 - 63 cycles(tsc) 15.864 ns -  46 cycles(tsc) 11.672 ns
2 - 56 cycles(tsc) 14.153 ns -  28 cycles(tsc) 7.119 ns
3 - 54 cycles(tsc) 13.681 ns -  23 cycles(tsc) 5.846 ns
4 - 53 cycles(tsc) 13.354 ns -  20 cycles(tsc) 5.141 ns
8 - 51 cycles(tsc) 12.970 ns -  19 cycles(tsc) 4.954 ns
16 - 51 cycles(tsc) 12.763 ns -  20 cycles(tsc) 5.003 ns
30 - 51 cycles(tsc) 12.760 ns -  20 cycles(tsc) 5.065 ns
32 - 80 cycles(tsc) 20.045 ns -  37 cycles(tsc) 9.311 ns
34 - 73 cycles(tsc) 18.454 ns -  27 cycles(tsc) 6.773 ns
48 - 82 cycles(tsc) 20.544 ns -  35 cycles(tsc) 8.973 ns
64 - 87 cycles(tsc) 21.809 ns -  60 cycles(tsc) 15.167 ns
128 - 103 cycles(tsc) 25.772 ns -  63 cycles(tsc) 15.874 ns
158 - 104 cycles(tsc) 26.215 ns -  61 cycles(tsc) 15.433 ns
250 - 107 cycles(tsc) 26.926 ns -  60 cycles(tsc) 15.058 ns

Notice the variation is fairly high between runs... :-(

> 3. For more precise test setup, how about setting cpu affinity?

Sure, starting to use test cmd:
 sudo taskset -c 1 modprobe slab_bulk_test01 && rmmod slab_bulk_test01 && sudo dmesg

Code:
 https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/mm/slab_bulk_test01.c

For these runs I've also disabled HT (Hyper Threading) in the BIOS, as
this tuned out to be a big disturbance for my network testing use-case.
(ps. I've hacked together a use-case in ixgbe/skbuff.c, but only TX complete
bulk-free which shows improvement of 3ns and 16ns with this slab
tuning, once I also implement alloc-bulk I should get a better boost).


> 2. Could you show result with only tuning min_partial?
> - I guess that much improvement for Bulk-API comes from disappearing
>   slab page allocation/free cost rather than tuning cpu_partial.

Sure, there are some more runs:

  sudo sh -c 'echo 9   > /sys/kernel/slab/:t-0000256/min_partial'

Run03: tuned min_partial=9
1 - 63 cycles(tsc) 15.910 ns -  46 cycles(tsc) 11.720 ns
2 - 57 cycles(tsc) 14.318 ns -  29 cycles(tsc) 7.266 ns
3 - 55 cycles(tsc) 13.762 ns -  23 cycles(tsc) 5.937 ns
4 - 53 cycles(tsc) 13.459 ns -  20 cycles(tsc) 5.211 ns
8 - 51 cycles(tsc) 13.001 ns -  19 cycles(tsc) 4.821 ns
16 - 51 cycles(tsc) 12.772 ns -  20 cycles(tsc) 5.016 ns
30 - 84 cycles(tsc) 21.135 ns -  28 cycles(tsc) 7.047 ns
32 - 83 cycles(tsc) 20.887 ns -  28 cycles(tsc) 7.133 ns
34 - 81 cycles(tsc) 20.454 ns -  28 cycles(tsc) 7.024 ns
48 - 86 cycles(tsc) 21.662 ns -  32 cycles(tsc) 8.121 ns
64 - 92 cycles(tsc) 23.027 ns -  52 cycles(tsc) 13.033 ns
128 - 97 cycles(tsc) 24.270 ns -  51 cycles(tsc) 12.865 ns
158 - 105 cycles(tsc) 26.290 ns -  53 cycles(tsc) 13.435 ns
250 - 106 cycles(tsc) 26.545 ns -  54 cycles(tsc) 13.607 ns

Run04: tuned min_partial=9
1 - 64 cycles(tsc) 16.123 ns -  47 cycles(tsc) 11.906 ns
2 - 57 cycles(tsc) 14.267 ns -  28 cycles(tsc) 7.235 ns
3 - 54 cycles(tsc) 13.691 ns -  23 cycles(tsc) 5.916 ns
4 - 53 cycles(tsc) 13.470 ns -  21 cycles(tsc) 5.278 ns
8 - 51 cycles(tsc) 12.991 ns -  19 cycles(tsc) 4.815 ns
16 - 50 cycles(tsc) 12.651 ns -  19 cycles(tsc) 4.840 ns
30 - 81 cycles(tsc) 20.282 ns -  35 cycles(tsc) 8.835 ns
32 - 77 cycles(tsc) 19.327 ns -  29 cycles(tsc) 7.403 ns
34 - 77 cycles(tsc) 19.438 ns -  31 cycles(tsc) 7.879 ns
48 - 85 cycles(tsc) 21.367 ns -  34 cycles(tsc) 8.563 ns
64 - 87 cycles(tsc) 21.830 ns -  55 cycles(tsc) 13.820 ns
128 - 109 cycles(tsc) 27.445 ns -  56 cycles(tsc) 14.152 ns
158 - 102 cycles(tsc) 25.576 ns -  60 cycles(tsc) 15.120 ns
250 - 108 cycles(tsc) 27.069 ns -  58 cycles(tsc) 14.534 ns

Looking at Run04 the win was not so big...

Also adjust cpu_partial:
 sudo sh -c 'echo 256 > /sys/kernel/slab/:t-0000256/cpu_partial'

$ sudo grep -H . /sys/kernel/slab/:t-0000256/{cpu_partial,min_partial,order,objs_per_slab}
/sys/kernel/slab/:t-0000256/cpu_partial:256
/sys/kernel/slab/:t-0000256/min_partial:9
/sys/kernel/slab/:t-0000256/order:1
/sys/kernel/slab/:t-0000256/objs_per_slab:32

Run05: also tuned cpu_partial=256
1 - 63 cycles(tsc) 15.867 ns -  46 cycles(tsc) 11.656 ns
2 - 56 cycles(tsc) 14.229 ns -  28 cycles(tsc) 7.131 ns
3 - 54 cycles(tsc) 13.587 ns -  23 cycles(tsc) 5.760 ns
4 - 53 cycles(tsc) 13.287 ns -  20 cycles(tsc) 5.081 ns
8 - 51 cycles(tsc) 12.935 ns -  19 cycles(tsc) 4.953 ns
16 - 50 cycles(tsc) 12.707 ns -  20 cycles(tsc) 5.074 ns
30 - 79 cycles(tsc) 19.927 ns -  28 cycles(tsc) 7.057 ns
32 - 79 cycles(tsc) 19.977 ns -  31 cycles(tsc) 7.762 ns
34 - 79 cycles(tsc) 19.800 ns -  33 cycles(tsc) 8.392 ns
48 - 93 cycles(tsc) 23.316 ns -  35 cycles(tsc) 8.777 ns
64 - 92 cycles(tsc) 23.144 ns -  33 cycles(tsc) 8.449 ns
128 - 97 cycles(tsc) 24.268 ns -  35 cycles(tsc) 8.943 ns
158 - 106 cycles(tsc) 26.606 ns -  40 cycles(tsc) 10.067 ns
250 - 109 cycles(tsc) 27.385 ns -  51 cycles(tsc) 12.957 ns

Run06: also tuned cpu_partial=256
1 - 63 cycles(tsc) 15.952 ns -  46 cycles(tsc) 11.710 ns
2 - 57 cycles(tsc) 14.309 ns -  29 cycles(tsc) 7.261 ns
3 - 54 cycles(tsc) 13.703 ns -  23 cycles(tsc) 5.858 ns
4 - 53 cycles(tsc) 13.394 ns -  20 cycles(tsc) 5.161 ns
8 - 52 cycles(tsc) 13.013 ns -  19 cycles(tsc) 4.809 ns
16 - 94 cycles(tsc) 23.734 ns -  49 cycles(tsc) 12.376 ns
30 - 88 cycles(tsc) 22.221 ns -  35 cycles(tsc) 8.933 ns
32 - 101 cycles(tsc) 25.319 ns -  41 cycles(tsc) 10.437 ns
34 - 98 cycles(tsc) 24.711 ns -  41 cycles(tsc) 10.485 ns
48 - 96 cycles(tsc) 24.119 ns -  41 cycles(tsc) 10.479 ns
64 - 100 cycles(tsc) 25.223 ns -  39 cycles(tsc) 9.766 ns
128 - 100 cycles(tsc) 25.078 ns -  34 cycles(tsc) 8.602 ns
158 - 102 cycles(tsc) 25.673 ns -  38 cycles(tsc) 9.645 ns
250 - 110 cycles(tsc) 27.560 ns -  40 cycles(tsc) 10.046 ns

(p.s. I'm currently on vacation for 3 weeks...)
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

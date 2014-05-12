Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f48.google.com (mail-yh0-f48.google.com [209.85.213.48])
	by kanga.kvack.org (Postfix) with ESMTP id C8B326B0037
	for <linux-mm@kvack.org>; Mon, 12 May 2014 10:49:24 -0400 (EDT)
Received: by mail-yh0-f48.google.com with SMTP id a41so4126253yho.35
        for <linux-mm@kvack.org>; Mon, 12 May 2014 07:49:24 -0700 (PDT)
Received: from g5t1625.atlanta.hp.com (g5t1625.atlanta.hp.com. [15.192.137.8])
        by mx.google.com with ESMTPS id c27si4966796yhe.6.2014.05.12.07.49.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 12 May 2014 07:49:24 -0700 (PDT)
Message-ID: <1399906158.2648.6.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH] zram: remove global tb_lock by using lock-free CAS
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Mon, 12 May 2014 07:49:18 -0700
In-Reply-To: <20140512051505.GB32617@bbox>
References: <20140505152014.GA8551@cerebellum.variantweb.net>
	 <1399312844.2570.28.camel@buesod1.americas.hpqcorp.net>
	 <20140505134615.04cb627bb2784cabcb844655@linux-foundation.org>
	 <1399328550.2646.5.camel@buesod1.americas.hpqcorp.net>
	 <000001cf69c9$5776f330$0664d990$%yang@samsung.com>
	 <20140507085743.GA31680@bbox>
	 <CAL1ERfOXNrfKqMVs-Yz8yJjKKU3L5fjUEOb0Aeyqc37py-BWEg@mail.gmail.com>
	 <CAAmzW4Pn2VUEnQ8FyOaBffqfUiHt6ocLEEvyaJrSKmTjaNp_wQ@mail.gmail.com>
	 <20140508062418.GF5282@bbox>
	 <000001cf6c16$afe73800$0fb5a800$%yang@samsung.com>
	 <20140512051505.GB32617@bbox>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Weijie Yang <weijie.yang@samsung.com>, 'Joonsoo Kim' <js1304@gmail.com>, 'Weijie Yang' <weijie.yang.kh@gmail.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Seth Jennings' <sjennings@variantweb.net>, 'Nitin Gupta' <ngupta@vflare.org>, 'Sergey Senozhatsky' <sergey.senozhatsky@gmail.com>, 'Bob Liu' <bob.liu@oracle.com>, 'Dan Streetman' <ddstreet@ieee.org>, 'Heesub Shin' <heesub.shin@samsung.com>, 'linux-kernel' <linux-kernel@vger.kernel.org>, 'Linux-MM' <linux-mm@kvack.org>

On Mon, 2014-05-12 at 14:15 +0900, Minchan Kim wrote:
> On Sat, May 10, 2014 at 02:10:08PM +0800, Weijie Yang wrote:
> > On Thu, May 8, 2014 at 2:24 PM, Minchan Kim <minchan@kernel.org> wrote:
> > > On Wed, May 07, 2014 at 11:52:59PM +0900, Joonsoo Kim wrote:
> > >> >> Most popular use of zram is the in-memory swap for small embedded system
> > >> >> so I don't want to increase memory footprint without good reason although
> > >> >> it makes synthetic benchmark. Alhought it's 1M for 1G, it isn't small if we
> > >> >> consider compression ratio and real free memory after boot
> > >>
> > >> We can use bit spin lock and this would not increase memory footprint for 32 bit
> > >> platform.
> > >
> > > Sounds like a idea.
> > > Weijie, Do you mind testing with bit spin lock?
> > 
> > Yes, I re-test them.
> > This time, I test each case 10 times, and take the average(KS/s).
> > (the test machine and method are same like previous mail's)
> > 
> > Iozone test result:
> > 
> >       Test       BASE     CAS   spinlock   rwlock  bit_spinlock
> > --------------------------------------------------------------
> >  Initial write  1381094   1425435   1422860   1423075   1421521
> >        Rewrite  1529479   1641199   1668762   1672855   1654910
> >           Read  8468009  11324979  11305569  11117273  10997202
> >        Re-read  8467476  11260914  11248059  11145336  10906486
> >   Reverse Read  6821393   8106334   8282174   8279195   8109186
> >    Stride read  7191093   8994306   9153982   8961224   9004434
> >    Random read  7156353   8957932   9167098   8980465   8940476
> > Mixed workload  4172747   5680814   5927825   5489578   5972253
> >   Random write  1483044   1605588   1594329   1600453   1596010
> >         Pwrite  1276644   1303108   1311612   1314228   1300960
> >          Pread  4324337   4632869   4618386   4457870   4500166
> > 
> > Fio test result:
> > 
> >     Test     base     CAS    spinlock    rwlock  bit_spinlock
> > -------------------------------------------------------------
> > seq-write   933789   999357   1003298    995961   1001958
> >  seq-read  5634130  6577930   6380861   6243912   6230006
> >    seq-rw  1405687  1638117   1640256   1633903   1634459
> >   rand-rw  1386119  1614664   1617211   1609267   1612471
> > 
> > 
> > The base is v3.15.0-rc3, the others are per-meta entry lock.
> > Every optimization method shows higher performance than the base, however,
> > it is hard to say which method is the most appropriate.
> 
> It's not too big between CAS and bit_spinlock so I prefer general method.

Well, I imagine that's because the test system is small enough that the
lock is not stressed enough. Bit spinlocks are considerably slower than
other types. I'm not sure if we really care for the case of zram, but in
general I really dislike this lock. It suffers from just about
everything our regular spinlocks try to optimize, specially unfairness
in who gets the lock when contended (ticketing).

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

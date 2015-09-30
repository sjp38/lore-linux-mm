Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 2AAAE6B0038
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 03:50:07 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so33441683pac.2
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 00:50:06 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id yb7si43775151pbc.53.2015.09.30.00.50.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Sep 2015 00:50:05 -0700 (PDT)
Received: by pacfv12 with SMTP id fv12so33440624pac.2
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 00:50:05 -0700 (PDT)
Date: Wed, 30 Sep 2015 16:52:03 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 0/3] allow zram to use zbud as underlying allocator
Message-ID: <20150930075203.GC12727@bbox>
References: <20150914154901.92c5b7b24e15f04d8204de18@gmail.com>
 <20150915061349.GA16485@bbox>
 <CAMJBoFM_bMvQthAJPK+w4uQznqp7eFLdk=c7ZtT-R1aoF-1SeA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMJBoFM_bMvQthAJPK+w4uQznqp7eFLdk=c7ZtT-R1aoF-1SeA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dan Streetman <ddstreet@ieee.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, =?utf-8?B?6rmA7KSA7IiY?= <iamjoonsoo.kim@lge.com>, Gioh Kim <gioh.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>

Hello Vitaly,

First of all, Thanks for the detail report. I will add comments below.

On Fri, Sep 25, 2015 at 11:54:57AM +0200, Vitaly Wool wrote:
> Hello Minchan,
> 
> the main use case where I see unacceptably long stalls in UI with
> zsmalloc is switching between users in Android.

What is main factor of the workload when user switching happens?
I guess lots of fork and read inode/dentry? so high-order allcation by them?

> There is a way to automate user creation and switching between them so
> the test I run both to get vmstat statistics and to profile stalls is
> to create a user, switch to it and switch back. Each test cycle does
> that 10 times, and all the results presented below are averages for 20
> runs.

Could you share your script?
I will ask our production team to reproduce it.

> 
> Kernel configurations used for testing:
> 
> (1): vanilla
> (2): (1) plus "make SLUB atomic" patch [1]

Does it mean "mm/slub: don't wait for high-order page allocation"?

> (3): (1) with zbud instead of zsmalloc
> (4): (2) with compaction defer logic mostly disabled

How does it disable compaction defer logic?
It would be helpful if you show the code.
Strictly speaking, I want to see your mm/compaction.c

The reason I am asking that you said you saw improvement
if you apply below.

        https://lkml.org/lkml/2015/9/9/313.

In compaction pov, without it, compaction does nothing because
zone_watermark_ok can return true(ie, false-positive) by CMA so
VM relies on reclaiming LRU pages to make high-order free pages
rather than compaction. In such case, you could lose lots of
page caches which I guess it's culprit of slowness you are seeing.

NOTE: Mel is trying to remove watermark check logic for high-order
allocation recently so it would be helpful for your workload.
http://lwn.net/Articles/657967/

> 
> > KSM? Is there any reason you mentioned *KSM* in this context?
> > IOW, if you don't use KSM, you couldn't see a problem?
> 
> If I don't use KSM, latenices get smaller in both cases. Worst case
> wise, zbud still gives more deterministic behavior.

I think KSM consumes rmap meta per page via SLAB request so SLAB
will ask high-order alloc for that. I guess that's one of reason
you saw smaller latency if you disabled KSM.

> 
> >> I ran into several occasions when moving pages from compressed swap back
> >> into the "normal" part of RAM caused significant latencies in system operation.
> >
> > What kernel version did you use? Did you enable CMA? ION?
> > What was major factor for the latencies?
> 
> CMA and ION are both enabled. The working kernel is 3.18 based with
> most of the mm/ stuff backported from 4.2.

3.18 is really old so I guess you did backport a lot of MM patches
from 4.2. Especially, there are lots of enhancement on compaction side
since then so it would be very helpful to say what patches you have
backported about compaction/CMA and zsmalloc/zram.

> The major factors for the latencies was a) fragmentation and b)
> compaction deferral. See also below.
> 
> > Decompress? zsmalloc-compaction overhead? rmap overheads?
> > compaction overheads?
> > There are several potential culprits.
> > It would be very helpful if you provide some numbers(perf will help you).
> 
> The UI is blocked after user switching for, average:
> (1) 1.84 seconds
> (2) 0.89 seconds
> (3) 1.32 seconds
> (4) 0.87 seconds

First of all, above data doesn't reveal how many time system spend in
somewhere. For it, perf record will be your friend.
If you use perf on ARM, please keep it in mind that ARM perf doesn't
support NMI so if your routine disable IRQ, sampling point isn't
correct you so you should take care of it.

I guess most of time will be spent in idle to wait I/O complete
because I am seeing this problem caused by page cache thrasing.

Anyway, could you test below two cases more?

1. vanilla + slub fallback + zbud + compaction defer disabling?
2. vanilla + zbud + compaction defer disabling?

I'd like to know how only compaction defer disabling patch affects
your workload without SLUB fallback patch.

> 
> The UI us blocked after user switching for, worst-case:
> (1) 2.91
> (2) 1.12
> (3) 1.79
> (4) 1.34

As worst-case, 4 is slower than 2 so ignoring compaction defering
unconditionally wouldn't be not option.

> 
> Selected vmstat results, average:
> I. allocstall
> (1) 7814
> (2) 4615
> (3) 2004
> (4) 2611
> 

vanilla + zbud is best for allocstall POV but it was not best
for avg and worst-case so it is not a major factor of your slowness.


> II. compact_stall
> (1) 1869

876 / 1869 * 100 = 46%

> (2) 1135

535 / 1135 * 100 = 47%

> (3) 727

419 / 727 * 100 = 57%

> (4) 638

638 / 443 * 100 = 144%

It seems each of data is selected from various experiement so
4 is higher 100% so even though the data is not consistent,
I guess 4 is much better than others.

>From of it, I guess compaction defer logic has a problem and
it made your problem as I said. There are a few of known problems
in compaction.

Joonsoo and Vlastimil have tried to fix it for a long time so
I hope they could solve it in this chance.

> 
> III. compact_fail
> (1) 914
> (2) 520
> (3) 230
> (4) 218
> 
> IV. compact_success
> (1) 876
> (2) 535
> (3) 419
> (4) 443
> 
> More data available on request.

1. Could you show how many of pages zbud/zsmalloc have been used for your
test and /proc/swaps as well as vmstat?

You could get it by pool_total_size on zswap and mem_used_total on zram.

2. Could you show /proc/vmstat raw data at before and after?

So, we could see more values like pgmajfault, nr_inactive, nr_file and
so on.

3. Perf record will prove where your system spent a lot of time.

> 
> >> By using zbud I lose in compression ratio but gain in determinism,
> >> lower latencies and lower fragmentation, so in the coming patches
> >> I tried to generalize what I've done to enable zbud for zram so far.
> >
> > Before that, I'd like to know what is root cause.
> > From my side, I had an similar experience.
> > At that time, problem was that *compaction* which triggered to reclaim
> > lots of page cache pages. The reason compaction triggered a lot was
> > fragmentation caused by zsmalloc, GPU and high-order allocation
> > request by SLUB and somethings(ex, ION, fork).
> >
> > Recently, Joonsoo fixed SLUB side.
> > http://marc.info/?l=linux-kernel&m=143891343223853&w=2
> 
> Yes, it makes things better, see above. However, worst case is still
> looking not so nice.

Your data says only SLUB fallback is best for worst-case. No?

> 
> > And we added zram-auto-compaction recently so zram try to compact
> > objects to reduce memory usage. It might be helpful for fragment
> > problem as side effect but please keep it mind that it would be opposite.
> > Currently, zram-auto-compaction is not aware of virtual memory compaction
> > so as worst case, zsmalloc can spread out pinned object into movable
> > pageblocks via zsmalloc-compaction.
> > Gioh and I try to solve the issue with below patches but is pending now
> > by other urgent works.
> > https://lwn.net/Articles/650917/
> > https://lkml.org/lkml/2015/8/10/90
> >
> > In summary, we need to clarify what's the root cause before diving into
> > code and hiding it.
> 
> I'm not "hiding" anything. This statement is utterly bogus.

Above I said, we found there are many problem between CMA, compaction
and zram a few month ago and we have approached to solve it generally.

        https://lwn.net/Articles/635446/

In this context, your approach is totally *hiding*.
Again saying, let's investigate fundamental problems.

> 
> Summarizing my test results, I would like to stress that:
> * zbud gives better worst-times

It would be different for workload. If you lose page cache by lack of
free memory due to bad compress ratio by zbud, it will bite you
after a while.

> * the system's behavior with zbud is way more stable and predictable

I agree zbud is more predictable. I said that's why zbud/zswap was born
although there are zram in the kenrel.
please read this.

        https://lwn.net/Articles/549740/

Although I will do best effort for zram/zsmalloc to make deterministic
without losing compress ratio, it couldn't do as well as zbud.

> * zsmalloc-based zram operation depends very much on kernel memory
> management subsystem changes

I couldn't agree this claim. What logic in kernel MM system makes you
think so?

> * zsmalloc operates significantly worse with compaction deferral logic
> introduced after ca. 3.18

I already explained how we can approach external fragmentation problems
you mentioned with generic ways and my concerns for supporing zbud.

Please explain what you are seeing problems in my suggestion technically.

> 
> As a bottom line, zsmalloc operation is substantially more fragile and
> far less predictable than zbud's. If that is not a good reason to _at
> least_ have *an option* to use zram with the latter, then I don't know
> what is.

Please have a look.

There are lots of known problems in CMA, compacation and zsmalloc
and several developers have solved it. Although it's not perfect now,
I think we are approaching right ways.

But you are now insisting "let's just use zbud into zram" with just
having compaction stat of vmstat without detailed analysis.
(I never think just throwing result is technical discussion. I really
want to know what makes such result with data).

> 
> ~vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

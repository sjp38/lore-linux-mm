Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 1D6FC6B0253
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 05:54:59 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so14609114wic.1
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 02:54:58 -0700 (PDT)
Received: from mail-wi0-x236.google.com (mail-wi0-x236.google.com. [2a00:1450:400c:c05::236])
        by mx.google.com with ESMTPS id fu4si3568309wib.16.2015.09.25.02.54.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Sep 2015 02:54:57 -0700 (PDT)
Received: by wicgb1 with SMTP id gb1so13030735wic.1
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 02:54:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150915061349.GA16485@bbox>
References: <20150914154901.92c5b7b24e15f04d8204de18@gmail.com>
	<20150915061349.GA16485@bbox>
Date: Fri, 25 Sep 2015 11:54:57 +0200
Message-ID: <CAMJBoFM_bMvQthAJPK+w4uQznqp7eFLdk=c7ZtT-R1aoF-1SeA@mail.gmail.com>
Subject: Re: [PATCH 0/3] allow zram to use zbud as underlying allocator
From: Vitaly Wool <vitalywool@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dan Streetman <ddstreet@ieee.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, =?UTF-8?B?6rmA7KSA7IiY?= <iamjoonsoo.kim@lge.com>, Gioh Kim <gioh.kim@lge.com>

Hello Minchan,

the main use case where I see unacceptably long stalls in UI with
zsmalloc is switching between users in Android.
There is a way to automate user creation and switching between them so
the test I run both to get vmstat statistics and to profile stalls is
to create a user, switch to it and switch back. Each test cycle does
that 10 times, and all the results presented below are averages for 20
runs.

Kernel configurations used for testing:

(1): vanilla
(2): (1) plus "make SLUB atomic" patch [1]
(3): (1) with zbud instead of zsmalloc
(4): (2) with compaction defer logic mostly disabled

> KSM? Is there any reason you mentioned *KSM* in this context?
> IOW, if you don't use KSM, you couldn't see a problem?

If I don't use KSM, latenices get smaller in both cases. Worst case
wise, zbud still gives more deterministic behavior.

>> I ran into several occasions when moving pages from compressed swap back
>> into the "normal" part of RAM caused significant latencies in system operation.
>
> What kernel version did you use? Did you enable CMA? ION?
> What was major factor for the latencies?

CMA and ION are both enabled. The working kernel is 3.18 based with
most of the mm/ stuff backported from 4.2.
The major factors for the latencies was a) fragmentation and b)
compaction deferral. See also below.

> Decompress? zsmalloc-compaction overhead? rmap overheads?
> compaction overheads?
> There are several potential culprits.
> It would be very helpful if you provide some numbers(perf will help you).

The UI is blocked after user switching for, average:
(1) 1.84 seconds
(2) 0.89 seconds
(3) 1.32 seconds
(4) 0.87 seconds

The UI us blocked after user switching for, worst-case:
(1) 2.91
(2) 1.12
(3) 1.79
(4) 1.34

Selected vmstat results, average:
I. allocstall
(1) 7814
(2) 4615
(3) 2004
(4) 2611

II. compact_stall
(1) 1869
(2) 1135
(3) 727
(4) 638

III. compact_fail
(1) 914
(2) 520
(3) 230
(4) 218

IV. compact_success
(1) 876
(2) 535
(3) 419
(4) 443

More data available on request.

>> By using zbud I lose in compression ratio but gain in determinism,
>> lower latencies and lower fragmentation, so in the coming patches
>> I tried to generalize what I've done to enable zbud for zram so far.
>
> Before that, I'd like to know what is root cause.
> From my side, I had an similar experience.
> At that time, problem was that *compaction* which triggered to reclaim
> lots of page cache pages. The reason compaction triggered a lot was
> fragmentation caused by zsmalloc, GPU and high-order allocation
> request by SLUB and somethings(ex, ION, fork).
>
> Recently, Joonsoo fixed SLUB side.
> http://marc.info/?l=linux-kernel&m=143891343223853&w=2

Yes, it makes things better, see above. However, worst case is still
looking not so nice.

> And we added zram-auto-compaction recently so zram try to compact
> objects to reduce memory usage. It might be helpful for fragment
> problem as side effect but please keep it mind that it would be opposite.
> Currently, zram-auto-compaction is not aware of virtual memory compaction
> so as worst case, zsmalloc can spread out pinned object into movable
> pageblocks via zsmalloc-compaction.
> Gioh and I try to solve the issue with below patches but is pending now
> by other urgent works.
> https://lwn.net/Articles/650917/
> https://lkml.org/lkml/2015/8/10/90
>
> In summary, we need to clarify what's the root cause before diving into
> code and hiding it.

I'm not "hiding" anything. This statement is utterly bogus.

Summarizing my test results, I would like to stress that:
* zbud gives better worst-times
* the system's behavior with zbud is way more stable and predictable
* zsmalloc-based zram operation depends very much on kernel memory
management subsystem changes
* zsmalloc operates significantly worse with compaction deferral logic
introduced after ca. 3.18

As a bottom line, zsmalloc operation is substantially more fragile and
far less predictable than zbud's. If that is not a good reason to _at
least_ have *an option* to use zram with the latter, then I don't know
what is.

~vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

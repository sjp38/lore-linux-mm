Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 112A56B0003
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 03:21:45 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id 31-v6so6678518edr.19
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 00:21:45 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d21-v6si481701ejy.0.2018.10.12.00.21.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Oct 2018 00:21:43 -0700 (PDT)
Subject: Re: [PATCH 0/2] mm/swap: Add locking for pagevec
References: <20180914145924.22055-1-bigeasy@linutronix.de>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <02dd6505-2ee5-c1c1-2603-b759bc90d479@suse.cz>
Date: Fri, 12 Oct 2018 09:21:41 +0200
MIME-Version: 1.0
In-Reply-To: <20180914145924.22055-1-bigeasy@linutronix.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>, linux-mm@kvack.org
Cc: tglx@linutronix.de, frederic@kernel.org, Mel Gorman <mgorman@techsingularity.net>

On 9/14/18 4:59 PM, Sebastian Andrzej Siewior wrote:
> The swap code synchronizes its access to the (four) pagevec struct
> (which is allocated per-CPU) by disabling preemption. This works and the
> one struct needs to be accessed from interrupt context is protected by
> disabling interrupts. This was manually audited and there is no lockdep
> coverage for this.
> There is one case where the per-CPU of a remote CPU needs to be accessed
> and this is solved by started a worker on the remote CPU and waiting for
> it to finish.
> 
> I measured the invocation of lru_add_drain_all(), ensured that it would
> invoke the drain function but the drain function would not do anything
> except the locking (preempt / interrupts on/off) of the individual
> pagevec. On a Xeon E5-2650 (2 Socket, 8 cores dual threaded, 32 CPUs in
> total) I tried to drain CPU4 and measured how long it took in
> microseconds:
>                t-771   [001] ....   183.165619: lru_add_drain_all_test: took 92
>                t-771   [001] ....   183.165710: lru_add_drain_all_test: took 87
>                t-771   [001] ....   183.165781: lru_add_drain_all_test: took 68
>                t-771   [001] ....   183.165826: lru_add_drain_all_test: took 43
>                t-771   [001] ....   183.165837: lru_add_drain_all_test: took 9
>                t-771   [001] ....   183.165847: lru_add_drain_all_test: took 9
>                t-771   [001] ....   183.165858: lru_add_drain_all_test: took 9
>                t-771   [001] ....   183.165868: lru_add_drain_all_test: took 9
>                t-771   [001] ....   183.165878: lru_add_drain_all_test: took 9
>                t-771   [001] ....   183.165889: lru_add_drain_all_test: took 9
> 
> This is mostly the wake up from idle that takes long and once the CPU is
> busy and cache hot it goes down to 9us. If all CPUs are busy in user land then 
>                t-1484  [001] .... 40864.452481: lru_add_drain_all_test: took 12
>                t-1484  [001] .... 40864.452492: lru_add_drain_all_test: took 8
>                t-1484  [001] .... 40864.452500: lru_add_drain_all_test: took 7
>                t-1484  [001] .... 40864.452508: lru_add_drain_all_test: took 7
>                t-1484  [001] .... 40864.452516: lru_add_drain_all_test: took 7
>                t-1484  [001] .... 40864.452524: lru_add_drain_all_test: took 7
>                t-1484  [001] .... 40864.452532: lru_add_drain_all_test: took 7
>                t-1484  [001] .... 40864.452540: lru_add_drain_all_test: took 7
>                t-1484  [001] .... 40864.452547: lru_add_drain_all_test: took 7
>                t-1484  [001] .... 40864.452555: lru_add_drain_all_test: took 7
> 
> it goes to 7us once the cache is hot.
> Invoking the same test on every CPU it gets to:
>                t-768   [000] ....    61.508781: lru_add_drain_all_test: took 133
>                t-768   [000] ....    61.508892: lru_add_drain_all_test: took 105
>                t-768   [000] ....    61.509004: lru_add_drain_all_test: took 108
>                t-768   [000] ....    61.509112: lru_add_drain_all_test: took 104
>                t-768   [000] ....    61.509220: lru_add_drain_all_test: took 104
>                t-768   [000] ....    61.509333: lru_add_drain_all_test: took 109
>                t-768   [000] ....    61.509414: lru_add_drain_all_test: took 78
>                t-768   [000] ....    61.509493: lru_add_drain_all_test: took 76
>                t-768   [000] ....    61.509558: lru_add_drain_all_test: took 63
>                t-768   [000] ....    61.509623: lru_add_drain_all_test: took 62
> 
> on an idle machine and once the CPUs are busy:
>                t-849   [020] ....   379.429727: lru_add_drain_all_test: took 57
>                t-849   [020] ....   379.429777: lru_add_drain_all_test: took 47
>                t-849   [020] ....   379.429823: lru_add_drain_all_test: took 45
>                t-849   [020] ....   379.429870: lru_add_drain_all_test: took 45
>                t-849   [020] ....   379.429916: lru_add_drain_all_test: took 45
>                t-849   [020] ....   379.429962: lru_add_drain_all_test: took 45
>                t-849   [020] ....   379.430009: lru_add_drain_all_test: took 45
>                t-849   [020] ....   379.430055: lru_add_drain_all_test: took 45
>                t-849   [020] ....   379.430101: lru_add_drain_all_test: took 45
>                t-849   [020] ....   379.430147: lru_add_drain_all_test: took 45
> 
> so we get down to 45us.
> 
> If the preemption based locking gets replaced with a PER-CPU spin_lock()
> then it gain a locking scope on the operation. The spin_lock() should not
> bring much overhead because it is not contended. However, having the
> lock there does not only add lockdep coverage it also allows to access
> the data from a remote CPU. So the work can be done on the CPU that
> asked for it and there is no need to wake a CPU from idle (or user land).
> 
> With this series applied, the test again:
> Idle box, all CPUs:
>                t-861   [000] ....   861.051780: lru_add_drain_all_test: took 16
>                t-861   [000] ....   861.051789: lru_add_drain_all_test: took 7
>                t-861   [000] ....   861.051797: lru_add_drain_all_test: took 7
>                t-861   [000] ....   861.051805: lru_add_drain_all_test: took 7
>                t-861   [000] ....   861.051813: lru_add_drain_all_test: took 7
>                t-861   [000] ....   861.051821: lru_add_drain_all_test: took 7
>                t-861   [000] ....   861.051829: lru_add_drain_all_test: took 7
>                t-861   [000] ....   861.051837: lru_add_drain_all_test: took 7
>                t-861   [000] ....   861.051844: lru_add_drain_all_test: took 7
>                t-861   [000] ....   861.051852: lru_add_drain_all_test: took 7
> 
> which is almost the same compared with "busy, one CPU". Invoking the
> test only for a single remote CPU: 
>                t-863   [020] ....   906.579885: lru_add_drain_all_test: took 0
>                t-863   [020] ....   906.579887: lru_add_drain_all_test: took 0
>                t-863   [020] ....   906.579889: lru_add_drain_all_test: took 0
>                t-863   [020] ....   906.579889: lru_add_drain_all_test: took 0
>                t-863   [020] ....   906.579890: lru_add_drain_all_test: took 0
>                t-863   [020] ....   906.579891: lru_add_drain_all_test: took 0
>                t-863   [020] ....   906.579892: lru_add_drain_all_test: took 0
>                t-863   [020] ....   906.579892: lru_add_drain_all_test: took 0
>                t-863   [020] ....   906.579893: lru_add_drain_all_test: took 0
>                t-863   [020] ....   906.579894: lru_add_drain_all_test: took 0
> 
> and it is less than a microsecond.

+CC Mel.

Hi,

I think this evaluation is missing the other side of the story, and
that's the cost of using a spinlock (even uncontended) instead of
disabling preemption. The expectation for LRU pagevec is that the local
operations will be much more common than draining of other CPU's, so
it's optimized for the former.

I guess the LKP report for patch 1/2 already hints at some regression,
if it can be trusted. I don't know the details but AFAIU shows that fio
completed 2.4% less operations so it shouldn't be an improvement as you
thought.

Vlastimil

> Sebastian
> 

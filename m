Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6B5A78E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 10:59:32 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id s205-v6so126213wmf.7
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 07:59:32 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id z65-v6si1816164wme.78.2018.09.14.07.59.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 14 Sep 2018 07:59:30 -0700 (PDT)
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 0/2] mm/swap: Add locking for pagevec
Date: Fri, 14 Sep 2018 16:59:22 +0200
Message-Id: <20180914145924.22055-1-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: tglx@linutronix.de, Vlastimil Babka <vbabka@suse.cz>, frederic@kernel.org

The swap code synchronizes its access to the (four) pagevec struct
(which is allocated per-CPU) by disabling preemption. This works and the
one struct needs to be accessed from interrupt context is protected by
disabling interrupts. This was manually audited and there is no lockdep
coverage for this.
There is one case where the per-CPU of a remote CPU needs to be accessed
and this is solved by started a worker on the remote CPU and waiting for
it to finish.

I measured the invocation of lru_add_drain_all(), ensured that it would
invoke the drain function but the drain function would not do anything
except the locking (preempt / interrupts on/off) of the individual
pagevec. On a Xeon E5-2650 (2 Socket, 8 cores dual threaded, 32 CPUs in
total) I tried to drain CPU4 and measured how long it took in
microseconds:
               t-771   [001] ....   183.165619: lru_add_drain_all_test: took 92
               t-771   [001] ....   183.165710: lru_add_drain_all_test: took 87
               t-771   [001] ....   183.165781: lru_add_drain_all_test: took 68
               t-771   [001] ....   183.165826: lru_add_drain_all_test: took 43
               t-771   [001] ....   183.165837: lru_add_drain_all_test: took 9
               t-771   [001] ....   183.165847: lru_add_drain_all_test: took 9
               t-771   [001] ....   183.165858: lru_add_drain_all_test: took 9
               t-771   [001] ....   183.165868: lru_add_drain_all_test: took 9
               t-771   [001] ....   183.165878: lru_add_drain_all_test: took 9
               t-771   [001] ....   183.165889: lru_add_drain_all_test: took 9

This is mostly the wake up from idle that takes long and once the CPU is
busy and cache hot it goes down to 9us. If all CPUs are busy in user land then 
               t-1484  [001] .... 40864.452481: lru_add_drain_all_test: took 12
               t-1484  [001] .... 40864.452492: lru_add_drain_all_test: took 8
               t-1484  [001] .... 40864.452500: lru_add_drain_all_test: took 7
               t-1484  [001] .... 40864.452508: lru_add_drain_all_test: took 7
               t-1484  [001] .... 40864.452516: lru_add_drain_all_test: took 7
               t-1484  [001] .... 40864.452524: lru_add_drain_all_test: took 7
               t-1484  [001] .... 40864.452532: lru_add_drain_all_test: took 7
               t-1484  [001] .... 40864.452540: lru_add_drain_all_test: took 7
               t-1484  [001] .... 40864.452547: lru_add_drain_all_test: took 7
               t-1484  [001] .... 40864.452555: lru_add_drain_all_test: took 7

it goes to 7us once the cache is hot.
Invoking the same test on every CPU it gets to:
               t-768   [000] ....    61.508781: lru_add_drain_all_test: took 133
               t-768   [000] ....    61.508892: lru_add_drain_all_test: took 105
               t-768   [000] ....    61.509004: lru_add_drain_all_test: took 108
               t-768   [000] ....    61.509112: lru_add_drain_all_test: took 104
               t-768   [000] ....    61.509220: lru_add_drain_all_test: took 104
               t-768   [000] ....    61.509333: lru_add_drain_all_test: took 109
               t-768   [000] ....    61.509414: lru_add_drain_all_test: took 78
               t-768   [000] ....    61.509493: lru_add_drain_all_test: took 76
               t-768   [000] ....    61.509558: lru_add_drain_all_test: took 63
               t-768   [000] ....    61.509623: lru_add_drain_all_test: took 62

on an idle machine and once the CPUs are busy:
               t-849   [020] ....   379.429727: lru_add_drain_all_test: took 57
               t-849   [020] ....   379.429777: lru_add_drain_all_test: took 47
               t-849   [020] ....   379.429823: lru_add_drain_all_test: took 45
               t-849   [020] ....   379.429870: lru_add_drain_all_test: took 45
               t-849   [020] ....   379.429916: lru_add_drain_all_test: took 45
               t-849   [020] ....   379.429962: lru_add_drain_all_test: took 45
               t-849   [020] ....   379.430009: lru_add_drain_all_test: took 45
               t-849   [020] ....   379.430055: lru_add_drain_all_test: took 45
               t-849   [020] ....   379.430101: lru_add_drain_all_test: took 45
               t-849   [020] ....   379.430147: lru_add_drain_all_test: took 45

so we get down to 45us.

If the preemption based locking gets replaced with a PER-CPU spin_lock()
then it gain a locking scope on the operation. The spin_lock() should not
bring much overhead because it is not contended. However, having the
lock there does not only add lockdep coverage it also allows to access
the data from a remote CPU. So the work can be done on the CPU that
asked for it and there is no need to wake a CPU from idle (or user land).

With this series applied, the test again:
Idle box, all CPUs:
               t-861   [000] ....   861.051780: lru_add_drain_all_test: took 16
               t-861   [000] ....   861.051789: lru_add_drain_all_test: took 7
               t-861   [000] ....   861.051797: lru_add_drain_all_test: took 7
               t-861   [000] ....   861.051805: lru_add_drain_all_test: took 7
               t-861   [000] ....   861.051813: lru_add_drain_all_test: took 7
               t-861   [000] ....   861.051821: lru_add_drain_all_test: took 7
               t-861   [000] ....   861.051829: lru_add_drain_all_test: took 7
               t-861   [000] ....   861.051837: lru_add_drain_all_test: took 7
               t-861   [000] ....   861.051844: lru_add_drain_all_test: took 7
               t-861   [000] ....   861.051852: lru_add_drain_all_test: took 7

which is almost the same compared with "busy, one CPU". Invoking the
test only for a single remote CPU: 
               t-863   [020] ....   906.579885: lru_add_drain_all_test: took 0
               t-863   [020] ....   906.579887: lru_add_drain_all_test: took 0
               t-863   [020] ....   906.579889: lru_add_drain_all_test: took 0
               t-863   [020] ....   906.579889: lru_add_drain_all_test: took 0
               t-863   [020] ....   906.579890: lru_add_drain_all_test: took 0
               t-863   [020] ....   906.579891: lru_add_drain_all_test: took 0
               t-863   [020] ....   906.579892: lru_add_drain_all_test: took 0
               t-863   [020] ....   906.579892: lru_add_drain_all_test: took 0
               t-863   [020] ....   906.579893: lru_add_drain_all_test: took 0
               t-863   [020] ....   906.579894: lru_add_drain_all_test: took 0

and it is less than a microsecond.

Sebastian

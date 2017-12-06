Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 700896B0307
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 20:27:34 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id v25so1739072pfg.14
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 17:27:34 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id f8si953725pgc.12.2017.12.05.17.27.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 17:27:32 -0800 (PST)
From: Dave Hansen <dave.hansen@intel.com>
Subject: x86 TLB flushing: INVPCID vs. deferred CR3 write
Message-ID: <3062e486-3539-8a1f-5724-16199420be71@intel.com>
Date: Tue, 5 Dec 2017 17:27:31 -0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: the arch/x86 maintainers <x86@kernel.org>
Cc: Andy Lutomirski <luto@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "Kleen, Andi" <andi.kleen@intel.com>, "Chen, Tim C" <tim.c.chen@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>

tl;dr: Kernels with pagetable isolation using INVPCID compile kernels
0.58% faster than using the deferred CR3 write.  This tends to say that
we should leave things as-is and keep using INVPCID, but it's far from
definitive.

If folks have better ideas for a test methodology, or specific workloads
or hardware where you want to see this tested, please speak up.

Details below.

---

With page table isolation on systems with INVPCID (Haswell and newer),
we have a choice on how to flush the TLB for the user address space.  We
can either use INVPCID when running in the kernel to flush individual
pages out of the user address space, or we can just flush the entire TLB
when we reload the page table pointer (CR3) at the kernel->user switch
(initiated by invalidate_user_asid()).

It's currently implemented with INVPCID, mostly because that was the
easiest code that I could drop in to place without adding any
infrastructure.  It was not a data-driven choice.  Now that things have
settled down, it's time to collect some data.  I rigged up a patch to
help me time the TLB flush instruction cost with tracepoints and turn
INVLPG on/off at runtime:

	https://www.sr71.net/~dave/invpcid-on-off.patch

Why does this matter?  We are effectively balancing the incremental
TLB-flush-time cost of ~350 cycles per-page with the potential
tens-of-thousands of cycles which it costs to *fully* reload the TLB.  I
say "potential" because the CPU is *really* good at hiding TLB fill
latencies.  There may be thousands of cycles where the page walker is
trying to fill entries, but that does not mean that the CPU is stalled
waiting for those fills.

The system here is a 4-core (no hyperthreading) Skylake desktop system.
The workload is a make -j8 kernel compile.  HT will probably only serve
to further mask the TLB fill latencies, so it's a blessing that it is
absent here.

Using INVPCID compiles a kernel in 875.36s, while using the deferred
flush is 880.45s.  That's 0.58% worse when we use CR3.  While it is
small, it is consistent across runs.  It's also a workload that, on this
system, is plowing through hundreds of millions of L1 TLB misses a
second, so presumably we *do* pay a cost for the full flush.

A few things of note:

* INVPCID is around 1.75x the cost of doing an INVLPG alone (INVLPG is
  ~200 cycles and INVLPG+INVPCID is ~550).  This roughly correlates with
  how these show up in profiles as well.
* invalidate_user_asid() roughly doubles the number of
  "dtlb_load_misses.walk_completed" events vs INVLPG.  But, it makes
  those misses consume 60% more hardware page walker cycles per miss.
  In other words, the CR3-based flushing causes more TLB misses, but
  they are _relatively_ cheap misses.

The raw data are below.


-------------------------------------------------------------------------

I roughly tried to repeat the methodology from:

> https://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git/commit/?h=WIP.x86/kpti&id=a5102476a24b

The systems are different, though, so don't look too much the old
results versus these.

> echo y > /sys/kernel/debug/x86/use_invpcid_flush_one 
> 
>      1:  91.70%  93.49% avg cycles:  1094 cycles/page: 1094 samples: 1238264
>      2:   1.29%  94.78% avg cycles:  1503 cycles/page:  751 samples: 17451
>      3:   0.29%  95.07% avg cycles:  2016 cycles/page:  672 samples: 3926
>      4:   1.35%  96.42% avg cycles:  2719 cycles/page:  679 samples: 18200
>      5:   0.01%  96.43% avg cycles:  3875 cycles/page:  775 samples: 159
>      9:   0.02%  96.45% avg cycles:  6329 cycles/page:  703 samples: 272
>     20:   0.01%  96.46% avg cycles: 11654 cycles/page:  582 samples: 73
>     22:   0.06%  96.52% avg cycles: 12630 cycles/page:  574 samples: 824
>     25:   0.05%  96.57% avg cycles: 13952 cycles/page:  558 samples: 676
>     26:   0.06%  96.63% avg cycles: 14492 cycles/page:  557 samples: 807
>     27:   0.81%  97.45% avg cycles: 15043 cycles/page:  557 samples: 10977
>     32:   0.01%  97.46% avg cycles: 18568 cycles/page:  580 samples: 107
>     33:   0.08%  97.53% avg cycles: 18481 cycles/page:  560 samples: 1022
>     35:   0.01%  97.55% avg cycles: 20303 cycles/page:  580 samples: 175
>     36:   0.00%  97.56% avg cycles: 20106 cycles/page:  558 samples: 67
>     37:   0.00%  97.56% avg cycles: 20630 cycles/page:  557 samples: 62
>     39:   0.00%  97.57% avg cycles: 21639 cycles/page:  554 samples: 58
>     40:   0.00%  97.57% avg cycles: 22340 cycles/page:  558 samples: 51
>     51:   0.01%  97.59% avg cycles: 28134 cycles/page:  551 samples: 71
>     55:   0.00%  97.59% avg cycles: 30257 cycles/page:  550 samples: 64
>     60:   0.01%  97.61% avg cycles: 32909 cycles/page:  548 samples: 101
>     64:   0.02%  97.63% avg cycles: 35670 cycles/page:  557 samples: 264
>     65:   0.03%  97.66% avg cycles: 35676 cycles/page:  548 samples: 395
>    129:   2.31%  99.98% avg cycles: 70550 cycles/page:  546 samples: 31205
>    133:   0.01%  99.99% avg cycles: 73157 cycles/page:  550 samples: 129

Not using INVPCID:

> echo n > /sys/kernel/debug/x86/use_invpcid_flush_one 
> 
>      1:  91.32%  93.25% avg cycles:   692 cycles/page:  692 samples: 1622083
>      2:   1.50%  94.75% avg cycles:   883 cycles/page:  441 samples: 26638
>      3:   0.27%  95.02% avg cycles:  1146 cycles/page:  382 samples: 4860
>      4:   1.61%  96.63% avg cycles:  1276 cycles/page:  319 samples: 28557
>      5:   0.00%  96.63% avg cycles:  2177 cycles/page:  435 samples: 68
>      7:   0.01%  96.64% avg cycles:  1888 cycles/page:  269 samples: 105
>      9:   0.02%  96.66% avg cycles:  3061 cycles/page:  340 samples: 308
>     14:   0.00%  96.66% avg cycles:  3294 cycles/page:  235 samples: 56
>     20:   0.09%  96.76% avg cycles:  4327 cycles/page:  216 samples: 1614
>     22:   0.07%  96.83% avg cycles:  4955 cycles/page:  225 samples: 1259
>     25:   0.06%  96.88% avg cycles:  5321 cycles/page:  212 samples: 1004
>     26:   0.06%  96.95% avg cycles:  5521 cycles/page:  212 samples: 1129
>     27:   0.92%  97.86% avg cycles:  5622 cycles/page:  208 samples: 16284
>     32:   0.01%  97.88% avg cycles:  7315 cycles/page:  228 samples: 111
>     33:   0.07%  97.94% avg cycles:  7069 cycles/page:  214 samples: 1217
>     35:   0.00%  97.95% avg cycles:  7923 cycles/page:  226 samples: 79
>     36:   0.00%  97.96% avg cycles:  7533 cycles/page:  209 samples: 88
>     37:   0.01%  97.96% avg cycles:  7707 cycles/page:  208 samples: 94
>     39:   0.00%  97.97% avg cycles:  8233 cycles/page:  211 samples: 78
>     40:   0.00%  97.97% avg cycles:  8547 cycles/page:  213 samples: 56
>     60:   0.01%  98.00% avg cycles: 12084 cycles/page:  201 samples: 120
>     64:   0.02%  98.02% avg cycles: 13092 cycles/page:  204 samples: 385
>     65:   0.03%  98.05% avg cycles: 13050 cycles/page:  200 samples: 525
>    129:   1.93%  99.99% avg cycles: 25663 cycles/page:  198 samples: 34209

These are timed kernel compiles.  First column is the value of
/sys/kernel/debug/x86/use_invpcid_flush_one.  The rest is just the
output of /usr/bin/time squashed onto one line.

> n 879.25 77.50 4:15.52 374%CPU (0avgtext+0avgdata 798736maxresident)k 0inputs+4452416outputs (1major+58366597minor)pagefaults 0swaps
> n 879.79 77.59 4:15.25 375%CPU (0avgtext+0avgdata 799840maxresident)k 0inputs+4452416outputs (1major+58381178minor)pagefaults 0swaps
> n 879.94 77.11 4:15.50 374%CPU (0avgtext+0avgdata 798604maxresident)k 0inputs+4452416outputs (1major+58370506minor)pagefaults 0swaps
> n 880.05 76.71 4:15.70 374%CPU (0avgtext+0avgdata 800664maxresident)k 0inputs+4452416outputs (1major+58373637minor)pagefaults 0swaps
> n 880.52 76.40 4:15.22 374%CPU (0avgtext+0avgdata 800408maxresident)k 0inputs+4452416outputs (1major+58382223minor)pagefaults 0swaps
> n 880.53 76.65 4:15.61 374%CPU (0avgtext+0avgdata 800580maxresident)k 0inputs+4452416outputs (1major+58378837minor)pagefaults 0swaps
> n 880.57 76.66 4:15.74 374%CPU (0avgtext+0avgdata 798960maxresident)k 0inputs+4452416outputs (1major+58377678minor)pagefaults 0swaps
> n 880.73 76.40 4:15.34 374%CPU (0avgtext+0avgdata 798716maxresident)k 0inputs+4452416outputs (1major+58367535minor)pagefaults 0swaps
> n 880.74 76.56 4:15.78 374%CPU (0avgtext+0avgdata 798808maxresident)k 0inputs+4452416outputs (1major+58382090minor)pagefaults 0swaps
> n 880.88 76.27 4:15.38 374%CPU (0avgtext+0avgdata 798896maxresident)k 0inputs+4452416outputs (1major+58381214minor)pagefaults 0swaps
> n 880.89 75.77 4:15.42 374%CPU (0avgtext+0avgdata 800036maxresident)k 0inputs+4452416outputs (1major+58378255minor)pagefaults 0swaps
> n 881.36 75.59 4:15.50 374%CPU (0avgtext+0avgdata 800516maxresident)k 0inputs+4452416outputs (1major+58357696minor)pagefaults 0swaps

> y 874.62 77.98 4:14.47 374%CPU (0avgtext+0avgdata 799620maxresident)k 0inputs+4452416outputs (1major+58400992minor)pagefaults 0swaps
> y 874.95 77.34 4:14.54 374%CPU (0avgtext+0avgdata 799524maxresident)k 0inputs+4452416outputs (1major+58371458minor)pagefaults 0swaps
> y 875.07 77.22 4:14.43 374%CPU (0avgtext+0avgdata 799996maxresident)k 0inputs+4452416outputs (1major+58369501minor)pagefaults 0swaps
> y 875.13 77.86 4:14.71 374%CPU (0avgtext+0avgdata 799880maxresident)k 0inputs+4452416outputs (1major+58383810minor)pagefaults 0swaps
> y 875.16 77.44 4:14.32 374%CPU (0avgtext+0avgdata 798704maxresident)k 0inputs+4452416outputs (1major+58393760minor)pagefaults 0swaps
> y 875.41 77.12 4:14.32 374%CPU (0avgtext+0avgdata 798628maxresident)k 0inputs+4452416outputs (1major+58370756minor)pagefaults 0swaps
> y 875.48 76.98 4:14.43 374%CPU (0avgtext+0avgdata 800140maxresident)k 0inputs+4452416outputs (1major+58381980minor)pagefaults 0swaps
> y 875.51 77.03 4:14.30 374%CPU (0avgtext+0avgdata 799720maxresident)k 0inputs+4452416outputs (1major+58379019minor)pagefaults 0swaps
> y 875.67 77.01 4:14.79 373%CPU (0avgtext+0avgdata 798508maxresident)k 0inputs+4452416outputs (1major+58377725minor)pagefaults 0swaps
> y 875.71 77.15 4:14.15 374%CPU (0avgtext+0avgdata 798728maxresident)k 0inputs+4452416outputs (1major+58395120minor)pagefaults 0swaps
> y 875.72 77.10 4:14.59 374%CPU (0avgtext+0avgdata 800744maxresident)k 0inputs+4452416outputs (1major+58377726minor)pagefaults 0swaps
> y 875.73 76.69 4:13.98 374%CPU (0avgtext+0avgdata 800120maxresident)k 0inputs+4452416outputs (1major+58383577minor)pagefaults 0swaps

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

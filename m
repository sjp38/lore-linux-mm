Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id ED7936B0038
	for <linux-mm@kvack.org>; Fri, 14 Apr 2017 06:10:36 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id k13so34344565ywk.2
        for <linux-mm@kvack.org>; Fri, 14 Apr 2017 03:10:36 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k81si482856ybc.25.2017.04.14.03.10.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Apr 2017 03:10:35 -0700 (PDT)
Date: Fri, 14 Apr 2017 12:10:27 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH] mm, page_alloc: re-enable softirq use of per-cpu page
 allocator
Message-ID: <20170414121027.079e5a4c@redhat.com>
In-Reply-To: <20170410142616.6d37a11904dd153298cf7f3b@linux-foundation.org>
References: <20170410150821.vcjlz7ntabtfsumm@techsingularity.net>
	<20170410142616.6d37a11904dd153298cf7f3b@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, willy@infradead.org, peterz@infradead.org, pagupta@redhat.com, ttoukan.linux@gmail.com, tariqt@mellanox.com, netdev@vger.kernel.org, saeedm@mellanox.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, brouer@redhat.com

On Mon, 10 Apr 2017 14:26:16 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Mon, 10 Apr 2017 16:08:21 +0100 Mel Gorman <mgorman@techsingularity.net> wrote:
> 
> > IRQ context were excluded from using the Per-Cpu-Pages (PCP) lists caching
> > of order-0 pages in commit 374ad05ab64d ("mm, page_alloc: only use per-cpu
> > allocator for irq-safe requests").
> > 
> > This unfortunately also included excluded SoftIRQ.  This hurt the performance
> > for the use-case of refilling DMA RX rings in softirq context.  
> 
> Out of curiosity: by how much did it "hurt"?
>
> <ruffles through the archives>
> 
> Tariq found:
> 
> : I disabled the page-cache (recycle) mechanism to stress the page
> : allocator, and see a drastic degradation in BW, from 47.5 G in v4.10 to
> : 31.4 G in v4.11-rc1 (34% drop).

I've tried to reproduce this in my home testlab, using ConnectX-4 dual
100Gbit/s. Hardware limits cause that I cannot reach 100Gbit/s, once a
memory copy is performed.  (Word of warning: you need PCIe Gen3 width
16 (which I do have) to handle 100Gbit/s, and the memory bandwidth of
the system also need something like 2x 12500MBytes/s (which is where my
system failed)).

The mlx5 driver have a driver local page recycler, which I can see fail
between 29%-38% of the time, with 8 parallel netperf TCP_STREAMs.  I
speculate adding more streams will make in fail more.  To factor out
the driver recycler, I simply disable it (like I believe Tariq also did).

With disabled-mlx5-recycler, 8 parallel netperf TCP_STREAMs:

Baseline v4.10.0  : 60316 Mbit/s
Current 4.11.0-rc6: 47491 Mbit/s
This patch        : 60662 Mbit/s

While this patch does "fix" the performance regression, it does not
bring any noticeable improvement (as my micro-bench also indicated),
thus I feel our previous optimization is almost nullified. (p.s. It
does feel wrong to argue against my own patch ;-)).

The reason for the current 4.11.0-rc6 regression is lock congestion on
the (per NUMA) page allocator lock, perf report show we spend 34.92% in
queued_spin_lock_slowpath (compared to top#2 copy cost of 13.81% in
copy_user_enhanced_fast_string).


> then with this patch he found
> 
> : It looks very good!  I get line-rate (94Gbits/sec) with 8 streams, in
> : comparison to less than 55Gbits/sec before.
> 
> Can I take this to mean that the page allocator's per-cpu-pages feature
> ended up doubling the performance of this driver?  Better than the
> driver's private page recycling?  I'd like to believe that, but am
> having trouble doing so ;)

I would not conclude that. I'm also very suspicious about such big
performance "jumps".  Tariq should also benchmark with v4.10 and a
disabled mlx5-recycler, as I believe the results should be the same as
after this patch.

That said, it is possible to see a regression this large, when all the
CPUs are congesting on the page allocator lock. AFAIK Tariq also
mentioned seeing 60% spend on the lock, which would confirm this theory.

 
> > This patch re-allow softirq context, which should be safe by disabling
> > BH/softirq, while accessing the list.  PCP-lists access from both hard-IRQ
> > and NMI context must not be allowed.  Peter Zijlstra says in_nmi() code
> > never access the page allocator, thus it should be sufficient to only test
> > for !in_irq().
> > 
> > One concern with this change is adding a BH (enable) scheduling point at
> > both PCP alloc and free. If further concerns are highlighted by this patch,
> > the result wiill be to revert 374ad05ab64d and try again at a later date
> > to offset the irq enable/disable overhead.  

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

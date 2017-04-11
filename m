Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id C70816B0390
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 04:23:41 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id v52so11384679wrb.14
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 01:23:41 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id u10si1991018wma.76.2017.04.11.01.23.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Apr 2017 01:23:40 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id EA542990AC
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 08:23:39 +0000 (UTC)
Date: Tue, 11 Apr 2017 09:23:35 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm, page_alloc: re-enable softirq use of per-cpu page
 allocator
Message-ID: <20170411082335.i3t4fysi2rw5iydd@techsingularity.net>
References: <20170410150821.vcjlz7ntabtfsumm@techsingularity.net>
 <20170410225302.2ec8cf56@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170410225302.2ec8cf56@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: akpm@linux-foundation.org, willy@infradead.org, peterz@infradead.org, pagupta@redhat.com, ttoukan.linux@gmail.com, tariqt@mellanox.com, netdev@vger.kernel.org, saeedm@mellanox.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Apr 10, 2017 at 10:53:02PM +0200, Jesper Dangaard Brouer wrote:
> 
> I will appreciate review of this patch.

I had reviewed it but didn't have much to say other than the in_interrupt()
is inconvenient rather than wrong.

> My micro-benchmarking show we
> basically return to same page alloc+free cost as before 374ad05ab64d
> ("mm, page_alloc: only use per-cpu allocator for irq-safe requests").
> Which sort of invalidates this attempt of optimizing the page allocator.
> But Mel's micro-benchmarks still show an improvement.
> 

Which could be down to differences in CPUs.

> Notice the slowdown comes from me checking irqs_disabled() ... if
> someone can spot a way to get rid of that this, then this patch will be
> a win.
> 

I didn't spot an easy way of doing it. One approach which would be lighter,
if somewhat surprising, is to put a lock into the per-cpu structures that
is *not* IRQ-safe and trylock it for the per-cpu allocator. If it's !irq
allocation, it'll be uncontended. If it's an irq-allocation and contended,
it means that CPU has re-entered the allocator and must use the irq-safe
buddy lists. That would mean that for the uncontended case, both irq-safe
and irq-unsafe allocations could use the list and in the contended case, irq
allocations will still succeed. However, it would need careful development,
testing and review and not appropriate to wedge in as a fix late in the
rc cycle.

> I'm traveling out of Montreal today, and will rerun my benchmarks when
> I get home.  Tariq will also do some more testing with 100G NIC (he
> also participated in the Montreal conf, so he is likely in transit too).
> 

Rerun them please. If there is a problem or any doubt then I'll post the
revert and try this again outside of an rc cycle. That would be preferable
to releasing 4.11 with a known regression.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

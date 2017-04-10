Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id F40936B0390
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 17:26:19 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id k3so36503695pfg.19
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 14:26:19 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q12si1529524plk.306.2017.04.10.14.26.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Apr 2017 14:26:19 -0700 (PDT)
Date: Mon, 10 Apr 2017 14:26:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm, page_alloc: re-enable softirq use of per-cpu page
 allocator
Message-Id: <20170410142616.6d37a11904dd153298cf7f3b@linux-foundation.org>
In-Reply-To: <20170410150821.vcjlz7ntabtfsumm@techsingularity.net>
References: <20170410150821.vcjlz7ntabtfsumm@techsingularity.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: brouer@redhat.com, willy@infradead.org, peterz@infradead.org, pagupta@redhat.com, ttoukan.linux@gmail.com, tariqt@mellanox.com, netdev@vger.kernel.org, saeedm@mellanox.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 10 Apr 2017 16:08:21 +0100 Mel Gorman <mgorman@techsingularity.net> wrote:

> IRQ context were excluded from using the Per-Cpu-Pages (PCP) lists caching
> of order-0 pages in commit 374ad05ab64d ("mm, page_alloc: only use per-cpu
> allocator for irq-safe requests").
> 
> This unfortunately also included excluded SoftIRQ.  This hurt the performance
> for the use-case of refilling DMA RX rings in softirq context.

Out of curiosity: by how much did it "hurt"?

<ruffles through the archives>

Tariq found:

: I disabled the page-cache (recycle) mechanism to stress the page
: allocator, and see a drastic degradation in BW, from 47.5 G in v4.10 to
: 31.4 G in v4.11-rc1 (34% drop).

then with this patch he found

: It looks very good!  I get line-rate (94Gbits/sec) with 8 streams, in
: comparison to less than 55Gbits/sec before.

Can I take this to mean that the page allocator's per-cpu-pages feature
ended up doubling the performance of this driver?  Better than the
driver's private page recycling?  I'd like to believe that, but am
having trouble doing so ;)

> This patch re-allow softirq context, which should be safe by disabling
> BH/softirq, while accessing the list.  PCP-lists access from both hard-IRQ
> and NMI context must not be allowed.  Peter Zijlstra says in_nmi() code
> never access the page allocator, thus it should be sufficient to only test
> for !in_irq().
> 
> One concern with this change is adding a BH (enable) scheduling point at
> both PCP alloc and free. If further concerns are highlighted by this patch,
> the result wiill be to revert 374ad05ab64d and try again at a later date
> to offset the irq enable/disable overhead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 230D26B0343
	for <linux-mm@kvack.org>; Thu, 23 Mar 2017 09:43:55 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id v127so193558644qkb.5
        for <linux-mm@kvack.org>; Thu, 23 Mar 2017 06:43:55 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p5si3721158qkb.70.2017.03.23.06.43.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Mar 2017 06:43:54 -0700 (PDT)
Date: Thu, 23 Mar 2017 14:43:47 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Page allocator order-0 optimizations merged
Message-ID: <20170323144347.1e6f29de@redhat.com>
In-Reply-To: <20170322234004.kffsce4owewgpqnm@techsingularity.net>
References: <58b48b1f.F/jo2/WiSxvvGm/z%akpm@linux-foundation.org>
	<20170301144845.783f8cad@redhat.com>
	<d4c1625e-cacf-52a9-bfcb-b32a185a2008@mellanox.com>
	<83a0e3ef-acfa-a2af-2770-b9a92bda41bb@mellanox.com>
	<20170322234004.kffsce4owewgpqnm@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Tariq Toukan <tariqt@mellanox.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, akpm@linux-foundation.org, linux-mm <linux-mm@kvack.org>, Saeed Mahameed <saeedm@mellanox.com>, brouer@redhat.com

On Wed, 22 Mar 2017 23:40:04 +0000
Mel Gorman <mgorman@techsingularity.net> wrote:

> On Wed, Mar 22, 2017 at 07:39:17PM +0200, Tariq Toukan wrote:
> > > > > This modification may slow allocations from IRQ context slightly
> > > > > but the
> > > > > main gain from the per-cpu allocator is that it scales better for
> > > > > allocations from multiple contexts.  There is an implicit
> > > > > assumption that
> > > > > intensive allocations from IRQ contexts on multiple CPUs from a single
> > > > > NUMA node are rare  
> > Hi Mel, Jesper, and all.
> > 
> > This assumption contradicts regular multi-stream traffic that is naturally
> > handled
> > over close numa cores.  I compared iperf TCP multistream (8 streams)
> > over CX4 (mlx5 driver) with kernels v4.10 (before this series) vs
> > kernel v4.11-rc1 (with this series).
> > I disabled the page-cache (recycle) mechanism to stress the page allocator,
> > and see a drastic degradation in BW, from 47.5 G in v4.10 to 31.4 G in
> > v4.11-rc1 (34% drop).
> > I noticed queued_spin_lock_slowpath occupies 62.87% of CPU time.  
> 
> Can you get the stack trace for the spin lock slowpath to confirm it's
> from IRQ context?

AFAIK allocations happen in softirq.  Argh and during review I missed
that in_interrupt() also covers softirq.  To Mel, can we use a in_irq()
check instead?

(p.s. just landed and got home)
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

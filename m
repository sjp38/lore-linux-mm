Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 061C56B0343
	for <linux-mm@kvack.org>; Wed, 22 Mar 2017 19:40:07 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id c5so15363974wmi.0
        for <linux-mm@kvack.org>; Wed, 22 Mar 2017 16:40:06 -0700 (PDT)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id i140si4848702wmd.64.2017.03.22.16.40.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 22 Mar 2017 16:40:05 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id 279CD993E5
	for <linux-mm@kvack.org>; Wed, 22 Mar 2017 23:40:05 +0000 (UTC)
Date: Wed, 22 Mar 2017 23:40:04 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: Page allocator order-0 optimizations merged
Message-ID: <20170322234004.kffsce4owewgpqnm@techsingularity.net>
References: <58b48b1f.F/jo2/WiSxvvGm/z%akpm@linux-foundation.org>
 <20170301144845.783f8cad@redhat.com>
 <d4c1625e-cacf-52a9-bfcb-b32a185a2008@mellanox.com>
 <83a0e3ef-acfa-a2af-2770-b9a92bda41bb@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <83a0e3ef-acfa-a2af-2770-b9a92bda41bb@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tariq Toukan <tariqt@mellanox.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, akpm@linux-foundation.org, linux-mm <linux-mm@kvack.org>, Saeed Mahameed <saeedm@mellanox.com>

On Wed, Mar 22, 2017 at 07:39:17PM +0200, Tariq Toukan wrote:
> > > > This modification may slow allocations from IRQ context slightly
> > > > but the
> > > > main gain from the per-cpu allocator is that it scales better for
> > > > allocations from multiple contexts.  There is an implicit
> > > > assumption that
> > > > intensive allocations from IRQ contexts on multiple CPUs from a single
> > > > NUMA node are rare
> Hi Mel, Jesper, and all.
> 
> This assumption contradicts regular multi-stream traffic that is naturally
> handled
> over close numa cores.  I compared iperf TCP multistream (8 streams)
> over CX4 (mlx5 driver) with kernels v4.10 (before this series) vs
> kernel v4.11-rc1 (with this series).
> I disabled the page-cache (recycle) mechanism to stress the page allocator,
> and see a drastic degradation in BW, from 47.5 G in v4.10 to 31.4 G in
> v4.11-rc1 (34% drop).
> I noticed queued_spin_lock_slowpath occupies 62.87% of CPU time.

Can you get the stack trace for the spin lock slowpath to confirm it's
from IRQ context?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

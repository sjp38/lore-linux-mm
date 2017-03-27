Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 600286B0333
	for <linux-mm@kvack.org>; Mon, 27 Mar 2017 08:28:19 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id l95so39260369wrc.12
        for <linux-mm@kvack.org>; Mon, 27 Mar 2017 05:28:19 -0700 (PDT)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id c14si590284wrb.192.2017.03.27.05.28.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 27 Mar 2017 05:28:17 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 0401399242
	for <linux-mm@kvack.org>; Mon, 27 Mar 2017 12:28:17 +0000 (UTC)
Date: Mon, 27 Mar 2017 13:28:16 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: Page allocator order-0 optimizations merged
Message-ID: <20170327122816.dvnfxkyqxasfiknj@techsingularity.net>
References: <58b48b1f.F/jo2/WiSxvvGm/z%akpm@linux-foundation.org>
 <d4c1625e-cacf-52a9-bfcb-b32a185a2008@mellanox.com>
 <83a0e3ef-acfa-a2af-2770-b9a92bda41bb@mellanox.com>
 <20170322234004.kffsce4owewgpqnm@techsingularity.net>
 <20170323144347.1e6f29de@redhat.com>
 <20170323145133.twzt4f5ci26vdyut@techsingularity.net>
 <779ab72d-94b9-1a28-c192-377e91383b4e@gmail.com>
 <1fc7338f-2b36-75f7-8a7e-8321f062207b@gmail.com>
 <2123321554.7161128.1490599967015.JavaMail.zimbra@redhat.com>
 <20170327105514.1ed5b1ba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170327105514.1ed5b1ba@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Pankaj Gupta <pagupta@redhat.com>, Tariq Toukan <ttoukan.linux@gmail.com>, Tariq Toukan <tariqt@mellanox.com>, netdev@vger.kernel.org, akpm@linux-foundation.org, linux-mm <linux-mm@kvack.org>, Saeed Mahameed <saeedm@mellanox.com>

On Mon, Mar 27, 2017 at 10:55:14AM +0200, Jesper Dangaard Brouer wrote:
> On Mon, 27 Mar 2017 03:32:47 -0400 (EDT)
> Pankaj Gupta <pagupta@redhat.com> wrote:
> 
> > Hello,
> > 
> > It looks like a race with softirq and normal process context.
> > 
> > Just thinking if we really want allocations from 'softirqs' to be
> > done using per cpu list? 
> 
> Yes, softirq need fast page allocs. The softirq use-case is refilling
> the DMA RX rings, which is time critical, especially for NIC drivers.
> For this reason most drivers implement different page recycling tricks.
> 
> > Or we can have some check in  'free_hot_cold_page' for softirqs 
> > to check if we are on a path of returning from hard interrupt don't
> > allocate from per cpu list.
> 
> A possible solution, would be use the local_bh_{disable,enable} instead
> of the {preempt_disable,enable} calls.  But it is slower, using numbers
> from [1] (19 vs 11 cycles), thus the expected cycles saving is 38-19=19.
> 
> The problematic part of using local_bh_enable is that this adds a
> softirq/bottom-halves rescheduling point (as it checks for pending
> BHs).  Thus, this might affects real workloads.
> 
> 
> I'm unsure what the best option is.  I'm leaning towards partly
> reverting[1] and go back to doing the slower local_irq_save +
> local_irq_restore as before.
> 
> Afterwards we can add a bulk page alloc+free call, that can amortize
> this 38 cycles cost (of local_irq_{save,restore}).  Or add a function
> call that MUST only be called from contexts with IRQs enabled, which
> allow using the unconditionally local_irq_{disable,enable} as it only
> costs 7 cycles.
> 

It's possible to have a separate list for hard/soft IRQ that are protected
although great care is needed to drain properly. I have a partial prototype
lying around marked as "interesting if we ever need it" but it needs more
work. It's sufficiently complex that I couldn't rush it as a fix with the
time I currently have available. For 4.11, it's safer to revert and try
again later bearing in mind that softirqs are in the critical allocation
path for some drivers.

I'll prepare a patch.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

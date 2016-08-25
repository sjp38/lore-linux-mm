Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 547E983090
	for <linux-mm@kvack.org>; Thu, 25 Aug 2016 18:34:57 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id le9so99584146pab.0
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 15:34:57 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id o10si17604146paw.74.2016.08.25.15.34.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Aug 2016 15:34:56 -0700 (PDT)
Received: by mail-pa0-x22b.google.com with SMTP id hb8so20715213pac.2
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 15:34:56 -0700 (PDT)
Date: Thu, 25 Aug 2016 15:34:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: clarify COMPACTION Kconfig text
In-Reply-To: <20160825065424.GA4230@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1608251524140.48031@chino.kir.corp.google.com>
References: <1471939757-29789-1-git-send-email-mhocko@kernel.org> <alpine.DEB.2.10.1608241750220.98155@chino.kir.corp.google.com> <20160825065424.GA4230@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <js1304@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Markus Trippelsdorf <markus@trippelsdorf.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu, 25 Aug 2016, Michal Hocko wrote:

> > I don't believe it has been an issue in the past for any archs that
> > don't use thp.
> 
> Well, fragmentation is a real problem and order-0 reclaim will be never
> anywhere close to reliably provide higher order pages. Well, reclaiming
> a lot of memory can increase the probability of a success but that
> can quite often lead to over reclaim and long stalls. There are other
> sources of high order requests than THP so this is not about THP at all
> IMHO.
> 

Would it be possible to list the high-order allocations you are concerned 
about other than thp that doesn't have fallback behavior like skbuff and 
slub allocations?  struct task_struct is an order-1 allocation and there 
may be order-1 slab bucket usage, but what is higher order or requires 
aggressive compaction to allocate?  Surely you're not suggesting that 
order-0 reclaim cannot form order-1 memory.  I am concerned about kernels 
that require a small memory footprint and cannot enable all of 
CONFIG_COMPACTION and CONFIG_MIGRATION.  Embedded devices are not a 
negligible minority of kernels.

> > , CONFIG_MIGRATION.  Migration has a 
> > dependency of NUMA or memory hot-remove (not all popular).  Compaction can 
> > defragment memory within single zone without reliance on NUMA.
> 
> I am not sure I am following you here.
> MIGRATION depends on (NUMA || ARCH_ENABLE_MEMORY_HOTREMOVE || COMPACTION || CMA) && MMU
>  

Embedded device may be UMA and not care for memory hotplug or failure 
handling and rely solely on order-0 and order-1 memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 97C6A830BA
	for <linux-mm@kvack.org>; Fri, 26 Aug 2016 02:44:16 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l4so48619065wml.0
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 23:44:16 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id n128si18024707wma.39.2016.08.25.23.44.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Aug 2016 23:44:15 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id q128so10111357wma.1
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 23:44:15 -0700 (PDT)
Date: Fri, 26 Aug 2016 08:44:13 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: clarify COMPACTION Kconfig text
Message-ID: <20160826064406.GB16195@dhcp22.suse.cz>
References: <1471939757-29789-1-git-send-email-mhocko@kernel.org>
 <alpine.DEB.2.10.1608241750220.98155@chino.kir.corp.google.com>
 <20160825065424.GA4230@dhcp22.suse.cz>
 <alpine.DEB.2.10.1608251524140.48031@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1608251524140.48031@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <js1304@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Markus Trippelsdorf <markus@trippelsdorf.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 25-08-16 15:34:54, David Rientjes wrote:
> On Thu, 25 Aug 2016, Michal Hocko wrote:
> 
> > > I don't believe it has been an issue in the past for any archs that
> > > don't use thp.
> > 
> > Well, fragmentation is a real problem and order-0 reclaim will be never
> > anywhere close to reliably provide higher order pages. Well, reclaiming
> > a lot of memory can increase the probability of a success but that
> > can quite often lead to over reclaim and long stalls. There are other
> > sources of high order requests than THP so this is not about THP at all
> > IMHO.
> > 
> 
> Would it be possible to list the high-order allocations you are concerned 
> about other than thp that doesn't have fallback behavior like skbuff and 
> slub allocations?  struct task_struct is an order-1 allocation and there 
> may be order-1 slab bucket usage, but what is higher order or requires 
> aggressive compaction to allocate?

kernel stacks (order-2 on many arches), some arches need higher order
pages for page table allocations (at least the upper level AFAIR).

> Surely you're not suggesting that order-0 reclaim cannot form order-1
> memory.

I haven't seen fragmentation that bad that order-1 would be completely
depleted so I wouldn't be all that worried about this. But order-2 can
get depleted as our last oom reports show.

> I am concerned about kernels that require a small memory footprint and
> cannot enable all of CONFIG_COMPACTION and CONFIG_MIGRATION.  Embedded
> devices are not a negligible minority of kernels.

Fair enough. And nobody discourages them from disabling the
compaction. I would expect that kernels for those machines are
configured by people who know what they are doing. They have to be
careful about disabling many other things already and carefully weight
the missing functionality vs. code size savings. I also expect that
workloads on those machines are also careful to not require large
physically contiguous memory blocks very much. Otherwise they would have
problems described by the help text.

So I am not really sure what you are objecting to. I am not making
COMPACTION on unconditionally. I just want to make sure that regular
users do not think this is just a THP thing which is not true since the
lumpy reclaim is gone. On my laptop I have more than 40 slab caches
which have pagesperslab > 2.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

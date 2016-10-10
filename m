Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id A3CB56B0253
	for <linux-mm@kvack.org>; Mon, 10 Oct 2016 03:47:34 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id i187so33116489lfe.4
        for <linux-mm@kvack.org>; Mon, 10 Oct 2016 00:47:34 -0700 (PDT)
Received: from mail-lf0-f67.google.com (mail-lf0-f67.google.com. [209.85.215.67])
        by mx.google.com with ESMTPS id 79si16385428lfr.225.2016.10.10.00.47.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Oct 2016 00:47:33 -0700 (PDT)
Received: by mail-lf0-f67.google.com with SMTP id x79so5116454lff.2
        for <linux-mm@kvack.org>; Mon, 10 Oct 2016 00:47:33 -0700 (PDT)
Date: Mon, 10 Oct 2016 09:47:31 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/4] use up highorder free pages before OOM
Message-ID: <20161010074724.GC20420@dhcp22.suse.cz>
References: <1475819136-24358-1-git-send-email-minchan@kernel.org>
 <20161007091625.GB18447@dhcp22.suse.cz>
 <20161007150425.GD3060@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161007150425.GD3060@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sangseok Lee <sangseok.lee@lge.com>

On Sat 08-10-16 00:04:25, Minchan Kim wrote:
[...]
> I can show other log which reserve greater than 1%. See the DMA32 zone
> free pages. It was GFP_ATOMIC allocation so it's different with I posted
> but important thing is VM can reserve memory greater than 1% by the race
> which was really what we want.
> 
> in:imklog: page allocation failure: order:0, mode:0x2280020(GFP_ATOMIC|__GFP_NOTRACK)
[...]
> DMA: 7*4kB (UE) 3*8kB (UH) 1*16kB (M) 0*32kB 2*64kB (U) 1*128kB (M) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (U) 1*4096kB (H) = 7748kB
> DMA32: 10*4kB (H) 3*8kB (H) 47*16kB (H) 38*32kB (H) 5*64kB (H) 1*128kB (H) 2*256kB (H) 3*512kB (H) 3*1024kB (H) 3*2048kB (H) 4*4096kB (H) = 30128kB

Yes, this sounds like a bug. Please add this information to the patch
which aims to fix the misaccounting.

> > So while I do agree that potential issues - misaccounting and others you
> > are addressing in the follow up patch - are good to fix but I believe that
> > draining last 19M is not something that would reliably get you over the
> > edge. Your workload (93% of memory sitting on anon LRU with swap full)
> > simply doesn't fit into the amount of memory you have available.
> 
> What happens if the workload fit into additional 19M memory?
> I admit my testing aimed for proving the problem but with this patchset,
> there is no OOM killing with many free pages and the number of OOM was
> reduced highly. It is definitely better than old.
> 
> Please don't ignore 1% memory in embedded system. 20M memory in 2G system,
> If we can use those for zram, it is 60~80M memory via compression.
> You should know how many engineers try to reduce 1M of their driver to
> cost down of the product, seriously.

I am definitely not ignoring neither embedded systems nor 1% of the
memory that might really matter. I just wanted to point out that being
that close to OOM usually blows up later or starts trashing very soon.
It is true that a particular workload might benefit from ever last
allocatable page in the system but it would be better to mention all
that in the changelog.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

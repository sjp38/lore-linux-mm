Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 72EF06B0069
	for <linux-mm@kvack.org>; Tue, 11 Oct 2016 01:06:46 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id 4so16274519itv.4
        for <linux-mm@kvack.org>; Mon, 10 Oct 2016 22:06:46 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id e185si1068190iof.101.2016.10.10.22.06.44
        for <linux-mm@kvack.org>;
        Mon, 10 Oct 2016 22:06:45 -0700 (PDT)
Date: Tue, 11 Oct 2016 14:06:43 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 0/4] use up highorder free pages before OOM
Message-ID: <20161011050643.GC30973@bbox>
References: <1475819136-24358-1-git-send-email-minchan@kernel.org>
 <20161007091625.GB18447@dhcp22.suse.cz>
 <20161007150425.GD3060@bbox>
 <20161010074724.GC20420@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161010074724.GC20420@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sangseok Lee <sangseok.lee@lge.com>

On Mon, Oct 10, 2016 at 09:47:31AM +0200, Michal Hocko wrote:
> On Sat 08-10-16 00:04:25, Minchan Kim wrote:
> [...]
> > I can show other log which reserve greater than 1%. See the DMA32 zone
> > free pages. It was GFP_ATOMIC allocation so it's different with I posted
> > but important thing is VM can reserve memory greater than 1% by the race
> > which was really what we want.
> > 
> > in:imklog: page allocation failure: order:0, mode:0x2280020(GFP_ATOMIC|__GFP_NOTRACK)
> [...]
> > DMA: 7*4kB (UE) 3*8kB (UH) 1*16kB (M) 0*32kB 2*64kB (U) 1*128kB (M) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (U) 1*4096kB (H) = 7748kB
> > DMA32: 10*4kB (H) 3*8kB (H) 47*16kB (H) 38*32kB (H) 5*64kB (H) 1*128kB (H) 2*256kB (H) 3*512kB (H) 3*1024kB (H) 3*2048kB (H) 4*4096kB (H) = 30128kB
> 
> Yes, this sounds like a bug. Please add this information to the patch
> which aims to fix the misaccounting.

No problem.

> 
> > > So while I do agree that potential issues - misaccounting and others you
> > > are addressing in the follow up patch - are good to fix but I believe that
> > > draining last 19M is not something that would reliably get you over the
> > > edge. Your workload (93% of memory sitting on anon LRU with swap full)
> > > simply doesn't fit into the amount of memory you have available.
> > 
> > What happens if the workload fit into additional 19M memory?
> > I admit my testing aimed for proving the problem but with this patchset,
> > there is no OOM killing with many free pages and the number of OOM was
> > reduced highly. It is definitely better than old.
> > 
> > Please don't ignore 1% memory in embedded system. 20M memory in 2G system,
> > If we can use those for zram, it is 60~80M memory via compression.
> > You should know how many engineers try to reduce 1M of their driver to
> > cost down of the product, seriously.
> 
> I am definitely not ignoring neither embedded systems nor 1% of the
> memory that might really matter. I just wanted to point out that being

Whew and I thought you were serious.

> that close to OOM usually blows up later or starts trashing very soon.
> It is true that a particular workload might benefit from ever last
> allocatable page in the system but it would be better to mention all
> that in the changelog.

I don't unerstand what phrase you really want to include the changelog.
I will add the information which isolate 30M free pages before 4K page
allocation failure in next version. If you want something to add,
please say again.

Thanks for the review, Michal.

> -- 
> Michal Hocko
> SUSE Labs
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 68FF66B02B4
	for <linux-mm@kvack.org>; Wed, 19 Jul 2017 17:47:11 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z36so2350482wrb.13
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 14:47:11 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j19si591482wmi.144.2017.07.19.14.47.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 19 Jul 2017 14:47:10 -0700 (PDT)
Date: Wed, 19 Jul 2017 22:47:08 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Potential race in TLB flush batching?
Message-ID: <20170719214708.wuzq3di6rt43txtn@suse.de>
References: <20170712082733.ouf7yx2bnvwwcfms@suse.de>
 <591A2865-13B8-4B3A-B094-8B83A7F9814B@gmail.com>
 <20170713060706.o2cuko5y6irxwnww@suse.de>
 <A9CB595E-7C6D-438F-9835-A9EB8DA90892@gmail.com>
 <20170715155518.ok2q62efc2vurqk5@suse.de>
 <F7E154AB-5C1D-477F-A6BF-EFCAE5381B2D@gmail.com>
 <20170719074131.75wexoal3fiyoxw5@suse.de>
 <E9EE838F-F1E3-43A8-BB87-8B5B8388FF61@gmail.com>
 <20170719195820.drtfmweuhdc4eca6@suse.de>
 <4BD983A1-724B-4FD7-B502-55351717BC5F@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4BD983A1-724B-4FD7-B502-55351717BC5F@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Andy Lutomirski <luto@kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Wed, Jul 19, 2017 at 01:20:01PM -0700, Nadav Amit wrote:
> > From a PTE you cannot know the state of mmap_sem because you can rmap
> > back to multiple mm's for shared mappings. It's also fairly heavy handed.
> > Technically, you could lock on the basis of the VMA but that has other
> > consequences for scalability. The staleness is also a factor because
> > it's a case of "does the staleness matter". Sometimes it does, sometimes
> > it doesn't.  mmap_sem even if it could be used does not always tell us
> > the right information either because it can matter whether we are racing
> > against a userspace reference or a kernel operation.
> > 
> > It's possible your idea could be made work, but right now I'm not seeing a
> > solution that handles every corner case. I asked to hear what your ideas
> > were because anything I thought of that could batch TLB flushing in the
> > general case had flaws that did not improve over what is already there.
> 
> I don???t disagree with what you say - perhaps my scheme is too simplistic.
> But the bottom line, if you cannot form simple rules for when TLB needs to
> be flushed, what are the chances others would get it right?
> 

Broad rule is "flush before the page is freed/reallocated for clean pages
or any IO is initiated for dirty pages" with a lot of details that are not
documented. Often it's the PTL and flush with it held that protects the
majority of cases but it's not universal as the page lock and mmap_sem
play important rules depending ont the context and AFAIK, that's also
not documented.

> > shrink_page_list is the caller of try_to_unmap in reclaim context. It
> > has this check
> > 
> >                if (!trylock_page(page))
> >                        goto keep;
> > 
> > For pages it cannot lock, they get put back on the LRU and recycled instead
> > of reclaimed. Hence, if KSM or anything else holds the page lock, reclaim
> > can't unmap it.
> 
> Yes, of course, since KSM does not batch TLB flushes. I regarded the other
> direction - first try_to_unmap() removes the PTE (but still does not flush),
> unlocks the page, and then KSM acquires the page lock and calls
> write_protect_page(). It finds out the PTE is not present and does not flush
> the TLB.
> 

When KSM acquires the page lock, it then acquires the PTL where the
cleared PTE is observed directly and skipped.

> > There is no question that the area is complicated.
> 
> My comment was actually an unfunny joke... Never mind.
> 
> Thanks,
> Nadav
> 
> p.s.: Thanks for your patience.
> 

No need for thanks. As you pointed out yourself, you have been
identifying races.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id AE9CA6B067F
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 04:56:35 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z48so1121630wrc.4
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 01:56:35 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r127si971239wmr.109.2017.08.03.01.56.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Aug 2017 01:56:34 -0700 (PDT)
Date: Thu, 3 Aug 2017 09:56:32 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: suspicious __GFP_NOMEMALLOC in selinux
Message-ID: <20170803085547.hqpiy7qbyas7nbvy@suse.de>
References: <20170802105018.GA2529@dhcp22.suse.cz>
 <CAGH-Kgt_9So8bDe=yDF3yLZHDfDgeXsnBEu_X6uE_nQnoi=5Vg@mail.gmail.com>
 <20170803081152.GC12521@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170803081152.GC12521@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Paul Moore <pmoore@redhat.com>, Jeff Vander Stoep <jeffv@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, selinux@tycho.nsa.gov

On Thu, Aug 03, 2017 at 10:11:52AM +0200, Michal Hocko wrote:
> > The GFP_ATOMIC|__GFP_NOMEMALLOC use in SELinux appears to be limited
> > to security/selinux/avc.c, and digging a bit, I'm guessing commit
> > fa1aa143ac4a copied the combination from 6290c2c43973 ("selinux: tag
> > avc cache alloc as non-critical") and the avc_alloc_node() function.
> 
> Thanks for the pointer. That makes much more sense now. Back in 2012 we
> really didn't have a good way to distinguish non sleeping and atomic
> with reserves allocations.
>  

Yes, and GFP_NOWAIT is the right way to express that now. It'll still
wake kswapd but it won't stall on direct reclaim and won't dip into
reserves.

Thanks Michal.

> ---
> From 6d506a75da83c0724ed399966971711f37d67411 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Thu, 3 Aug 2017 10:04:20 +0200
> Subject: [PATCH] selinux: replace GFP_ATOMIC | __GFP_NOMEMALLOC with
>  GFP_NOWAIT
> 
> selinux avc code uses a weird combination of gfp flags. It asks for
> GFP_ATOMIC which allows access to memory reserves while it requests
> to not consume memory reserves by __GFP_NOMEMALLOC. This seems to be
> copying the pattern from 6290c2c43973 ("selinux: tag avc cache alloc as
> non-critical").
> 
> Back then (before d0164adc89f6 ("mm, page_alloc: distinguish between
> being unable to sleep, unwilling to sleep and avoiding waking kswapd"))
> we didn't have a good way to distinguish nowait and atomic allocations
> so the construct made some sense. Now we do not have to play tricks
> though and GFP_NOWAIT will provide the required semantic (aka do not
> sleep and do not consume any memory reserves).
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Looks right to me

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

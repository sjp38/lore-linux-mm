Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 04B466B0279
	for <linux-mm@kvack.org>; Fri,  2 Jun 2017 10:43:57 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id d127so17232483wmf.15
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 07:43:56 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g30si19396646ede.335.2017.06.02.07.43.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 02 Jun 2017 07:43:55 -0700 (PDT)
Date: Fri, 2 Jun 2017 16:43:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: strange PAGE_ALLOC_COSTLY_ORDER usage in xgbe_map_rx_buffer
Message-ID: <20170602144352.GI29840@dhcp22.suse.cz>
References: <20170531160422.GW27783@dhcp22.suse.cz>
 <4b894f15-6876-8598-def5-8113df836750@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4b894f15-6876-8598-def5-8113df836750@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri 02-06-17 09:20:54, Tom Lendacky wrote:
> On 5/31/2017 11:04 AM, Michal Hocko wrote:
> >Hi Tom,
> 
> Hi Michal,
> 
> >I have stumbled over the following construct in xgbe_map_rx_buffer
> >	order = max_t(int, PAGE_ALLOC_COSTLY_ORDER - 1, 0);
> >which looks quite suspicious. Why does it PAGE_ALLOC_COSTLY_ORDER - 1?
> >And why do you depend on PAGE_ALLOC_COSTLY_ORDER at all?
> >
> 
> The driver tries to allocate a number of pages to be used as receive
> buffers.  Based on what I could find in documentation, the value of
> PAGE_ALLOC_COSTLY_ORDER is the point at which order allocations
> (could) get expensive.  So I decrease by one the order requested. The
> max_t test is just to insure that in case PAGE_ALLOC_COSTLY_ORDER ever
> gets defined as 0, 0 would be used.

So you have fallen into a carefully prepared trap ;). The thing is that
orders _larger_ than PAGE_ALLOC_COSTLY_ORDER are costly actually. I can
completely see how this can be confusing.

Moreover xgbe_map_rx_buffer does an atomic allocation which doesn't do
any direct reclaim/compaction attempts so the costly vs. non-costly
doesn't apply here at all.

I would be much happier if no code outside of mm used
PAGE_ALLOC_COSTLY_ORDER directly but that requires a deeper
consideration. E.g. what would be the largest size that would be
useful for this path? xgbe_alloc_pages does the order fallback so
PAGE_ALLOC_COSTLY_ORDER sounds like an artificial limit to me.
I guess we can at least simplify the xgbe right away though.
---

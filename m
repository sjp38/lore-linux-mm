Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id DAD46800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 11:43:46 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id 31so2767561wri.9
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 08:43:46 -0800 (PST)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id i20si400407ede.65.2018.01.24.08.43.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jan 2018 08:43:45 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id 7FD091C37EC
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 16:43:45 +0000 (GMT)
Date: Wed, 24 Jan 2018 16:43:45 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 2/2] free_pcppages_bulk: prefetch buddy while not holding
 lock
Message-ID: <20180124164344.lca63gjn7mefuiac@techsingularity.net>
References: <20180124023050.20097-1-aaron.lu@intel.com>
 <20180124023050.20097-2-aaron.lu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20180124023050.20097-2-aaron.lu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>

On Wed, Jan 24, 2018 at 10:30:50AM +0800, Aaron Lu wrote:
> When a page is freed back to the global pool, its buddy will be checked
> to see if it's possible to do a merge. This requires accessing buddy's
> page structure and that access could take a long time if it's cache cold.
> 
> This patch adds a prefetch to the to-be-freed page's buddy outside of
> zone->lock in hope of accessing buddy's page structure later under
> zone->lock will be faster.
> 
> Test with will-it-scale/page_fault1 full load:
> 
> kernel      Broadwell(2S)  Skylake(2S)   Broadwell(4S)  Skylake(4S)
> v4.15-rc4   9037332        8000124       13642741       15728686
> patch1/2    9608786 +6.3%  8368915 +4.6% 14042169 +2.9% 17433559 +10.8%
> this patch 10462292 +8.9%  8602889 +2.8% 14802073 +5.4% 17624575 +1.1%
> 
> Note: this patch's performance improvement percent is against patch1/2.
> 

I'm less convinced by this for a microbenchmark. Prefetch has not been a
universal win in the past and we cannot be sure that it's a good idea on
all architectures or doesn't have other side-effects such as consuming
memory bandwidth for data we don't need or evicting cache hot data for
buddy information that is not used. Furthermore, we end up doing some
calculations twice without any guarantee that the prefetch can offset
the cost.

It's not strong enough of an opinion to outright NAK it but I'm not
ACKing it either.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 39C45800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 11:57:50 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id o128so3461582pfg.6
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 08:57:50 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id g5-v6si447664plp.615.2018.01.24.08.57.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jan 2018 08:57:48 -0800 (PST)
Subject: Re: [PATCH 2/2] free_pcppages_bulk: prefetch buddy while not holding
 lock
References: <20180124023050.20097-1-aaron.lu@intel.com>
 <20180124023050.20097-2-aaron.lu@intel.com>
 <20180124164344.lca63gjn7mefuiac@techsingularity.net>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <148a42d8-8306-2f2f-7f7c-86bc118f8ccd@intel.com>
Date: Wed, 24 Jan 2018 08:57:43 -0800
MIME-Version: 1.0
In-Reply-To: <20180124164344.lca63gjn7mefuiac@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Aaron Lu <aaron.lu@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>

On 01/24/2018 08:43 AM, Mel Gorman wrote:
> I'm less convinced by this for a microbenchmark. Prefetch has not been a
> universal win in the past and we cannot be sure that it's a good idea on
> all architectures or doesn't have other side-effects such as consuming
> memory bandwidth for data we don't need or evicting cache hot data for
> buddy information that is not used.

I had the same reaction.

But, I think this case is special.  We *always* do buddy merging (well,
before the next patch in the series is applied) and check an order-0
page's buddy to try to merge it when it goes into the main allocator.
So, the cacheline will always come in.

IOW, I don't think this has the same downsides normally associated with
prefetch() since the data is always used.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

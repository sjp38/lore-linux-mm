Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 761356B0007
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 10:34:04 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id g66so5450759pfj.11
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 07:34:04 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id a88si5132882pfk.40.2018.03.02.07.34.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Mar 2018 07:34:03 -0800 (PST)
Subject: Re: [PATCH v4 2/3] mm/free_pcppages_bulk: do not hold lock when
 picking pages to free
References: <20180301062845.26038-1-aaron.lu@intel.com>
 <20180301062845.26038-3-aaron.lu@intel.com>
 <20180301135518.GJ15057@dhcp22.suse.cz> <20180302071533.GA6356@intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <aa14d724-525c-7532-2e8e-6c4c6094e03f@intel.com>
Date: Fri, 2 Mar 2018 07:34:01 -0800
MIME-Version: 1.0
In-Reply-To: <20180302071533.GA6356@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>, Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, David Rientjes <rientjes@google.com>

On 03/01/2018 11:15 PM, Aaron Lu wrote:
> 
>> I am still quite surprised that this would have such a large impact.
> Most likely due to the cachelines for these page structures are warmed
> up outside of zone->lock.

The workload here is a pretty tight microbenchmark and single biggest
bottleneck is cache misses on 'struct page'.  It's not memory bandwidth
bound.  So, anything you can give the CPU keep it fed and not waiting on
cache misses will be a win.

There's never going to be a real-world workload that sees this kind of
increase, but the change in the micro isn't super-surprising because it
so directly targets the bottleneck.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

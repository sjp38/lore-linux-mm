Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7213D6B0009
	for <linux-mm@kvack.org>; Thu, 29 Mar 2018 21:41:25 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id s6so3683419pgq.23
        for <linux-mm@kvack.org>; Thu, 29 Mar 2018 18:41:25 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id o18si5436155pfa.346.2018.03.29.18.41.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Mar 2018 18:41:23 -0700 (PDT)
Date: Fri, 30 Mar 2018 09:42:17 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [RFC PATCH v2 0/4] Eliminate zone->lock contention for
 will-it-scale/page_fault1 and parallel free
Message-ID: <20180330014217.GA28440@intel.com>
References: <20180320085452.24641-1-aaron.lu@intel.com>
 <2606b76f-be64-4cef-b1f7-055732d09251@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2606b76f-be64-4cef-b1f7-055732d09251@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>

On Thu, Mar 29, 2018 at 03:19:46PM -0400, Daniel Jordan wrote:
> On 03/20/2018 04:54 AM, Aaron Lu wrote:
> > This series is meant to improve zone->lock scalability for order 0 pages.
> > With will-it-scale/page_fault1 workload, on a 2 sockets Intel Skylake
> > server with 112 CPUs, CPU spend 80% of its time spinning on zone->lock.
> > Perf profile shows the most time consuming part under zone->lock is the
> > cache miss on "struct page", so here I'm trying to avoid those cache
> > misses.
> 
> I ran page_fault1 comparing 4.16-rc5 to your recent work, these four patches
> plus the three others from your github branch zone_lock_rfc_v2. Out of
> curiosity I also threw in another 4.16-rc5 with the pcp batch size adjusted
> so high (10922 pages) that we always stay in the pcp lists and out of buddy
> completely.  I used your patch[*] in this last kernel.
> 
> This was on a 2-socket, 20-core broadwell server.
> 
> There were some small regressions a bit outside the noise at low process
> counts (2-5) but I'm not sure they're repeatable.  Anyway, it does improve
> the microbenchmark across the board.

Thanks for the result.

The limited improvement is expected since lock contention only shifts,
not entirely gone. So what is interesting to see is how it performs with
v4.16-rc5 + my_zone_lock_patchset + your_lru_lock_patchset

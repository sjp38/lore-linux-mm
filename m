Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id F290B6B0028
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 13:45:06 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id y196so2438945ywg.19
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 10:45:06 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id r131-v6si931409ybr.3.2018.03.21.10.45.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 10:45:05 -0700 (PDT)
Subject: Re: [RFC PATCH v2 0/4] Eliminate zone->lock contention for
 will-it-scale/page_fault1 and parallel free
References: <20180320085452.24641-1-aaron.lu@intel.com>
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Message-ID: <1dfd4b33-6eff-160e-52fd-994d9bcbffed@oracle.com>
Date: Wed, 21 Mar 2018 13:44:25 -0400
MIME-Version: 1.0
In-Reply-To: <20180320085452.24641-1-aaron.lu@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>

On 03/20/2018 04:54 AM, Aaron Lu wrote:
...snip...
> reduced zone->lock contention on free path from 35% to 1.1%. Also, it
> shows good result on parallel free(*) workload by reducing zone->lock
> contention from 90% to almost zero(lru lock increased from almost 0 to
> 90% though).

Hi Aaron, I'm looking through your series now.  Just wanted to mention that I'm seeing the same interaction between zone->lock and lru_lock in my own testing.  IOW, it's not enough to fix just one or the other: both need attention to get good performance on a big system, at least in this microbenchmark we've both been using.

There's anti-scaling at high core counts where overall system page faults per second actually decrease with more CPUs added to the test.  This happens when either zone->lock or lru_lock contention are completely removed, but the anti-scaling goes away when both locks are fixed.

Anyway, I'll post some actual data on this stuff soon.

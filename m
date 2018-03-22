Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2FAD76B0023
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 21:29:46 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id 1-v6so4203238plv.6
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 18:29:46 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id x61-v6si2681086plb.213.2018.03.21.18.29.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 18:29:44 -0700 (PDT)
Date: Thu, 22 Mar 2018 09:30:49 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [RFC PATCH v2 0/4] Eliminate zone->lock contention for
 will-it-scale/page_fault1 and parallel free
Message-ID: <20180322013049.GA4056@intel.com>
References: <20180320085452.24641-1-aaron.lu@intel.com>
 <1dfd4b33-6eff-160e-52fd-994d9bcbffed@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1dfd4b33-6eff-160e-52fd-994d9bcbffed@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>

On Wed, Mar 21, 2018 at 01:44:25PM -0400, Daniel Jordan wrote:
> On 03/20/2018 04:54 AM, Aaron Lu wrote:
> ...snip...
> > reduced zone->lock contention on free path from 35% to 1.1%. Also, it
> > shows good result on parallel free(*) workload by reducing zone->lock
> > contention from 90% to almost zero(lru lock increased from almost 0 to
> > 90% though).
> 
> Hi Aaron, I'm looking through your series now.  Just wanted to mention that I'm seeing the same interaction between zone->lock and lru_lock in my own testing.  IOW, it's not enough to fix just one or the other: both need attention to get good performance on a big system, at least in this microbenchmark we've both been using.

Agree.

> 
> There's anti-scaling at high core counts where overall system page faults per second actually decrease with more CPUs added to the test.  This happens when either zone->lock or lru_lock contention are completely removed, but the anti-scaling goes away when both locks are fixed.
> 
> Anyway, I'll post some actual data on this stuff soon.

Looking forward to that, thanks.

In the meantime, I'll also try your lru_lock optimization work on top of
this patchset to see if the lock contention shifts back to zone->lock.

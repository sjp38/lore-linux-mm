Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 245126B0069
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 04:34:30 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id r126so35367227wmr.2
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 01:34:30 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c6si26156016wrd.136.2017.01.25.01.34.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Jan 2017 01:34:28 -0800 (PST)
Date: Wed, 25 Jan 2017 10:34:23 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RFC 2/3] mm, vmscan: limit kswapd loop if no progress is
 made
Message-ID: <20170125093423.GD32377@dhcp22.suse.cz>
References: <1485244144-13487-1-git-send-email-hejianet@gmail.com>
 <1485244144-13487-3-git-send-email-hejianet@gmail.com>
 <20170124165412.GC30832@dhcp22.suse.cz>
 <503b0425-ac4b-9320-c282-41160ebe60c6@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <503b0425-ac4b-9320-c282-41160ebe60c6@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hejianet <hejianet@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, zhong jiang <zhongjiang@huawei.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vaishali Thakkar <vaishali.thakkar@oracle.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

On Wed 25-01-17 11:03:53, hejianet wrote:
> 
> 
> On 25/01/2017 12:54 AM, Michal Hocko wrote:
> > On Tue 24-01-17 15:49:03, Jia He wrote:
> > > Currently there is no hard limitation for kswapd retry times if no progress
> > > is made.
> > 
> > Yes, because the main objective of the kswapd is to balance all memory
> > zones. So having a hard limit on retries doesn't make any sense.
> > 
> But do you think even when there is no any process, kswapd still need
> to run and take the cpu usage uselessly?

The question is whether we can get into such a state during reasonable
workloads. So far you haven't explained what you are seeing and on which
kernel version.
 
> > > Then kswapd will take 100% for a long time.
> > 
> > Where it is spending time?
> I've watched kswapd takes 100% cpu for a whole night.

I assume it didn't get to sleep because your request has consumed enough
memory for hugetlb pages to get below watermarks which would keep kswapd
active. Is that correct?

> > > In my test, I tried to allocate 4000 hugepages by:
> > > echo 4000 > /proc/sys/vm/nr_hugepages
> > > 
> > > Then,kswapd will take 100% cpu for a long time.
> > > 
> > > The numa layout is:
> > > available: 7 nodes (0-6)
> > > node 0 cpus: 0 1 2 3 4 5 6 7
> > > node 0 size: 6611 MB
> > > node 0 free: 1103 MB
> > > node 1 cpus:
> > > node 1 size: 12527 MB
> > > node 1 free: 8477 MB
> > > node 2 cpus:
> > > node 2 size: 15087 MB
> > > node 2 free: 11037 MB
> > > node 3 cpus:
> > > node 3 size: 16111 MB
> > > node 3 free: 12060 MB
> > > node 4 cpus: 8 9 10 11 12 13 14 15
> > > node 4 size: 24815 MB
> > > node 4 free: 20704 MB
> > > node 5 cpus:
> > > node 5 size: 4095 MB
> > > node 5 free: 61 MB
> > > node 6 cpus:
> > > node 6 size: 22750 MB
> > > node 6 free: 18716 MB
> > > 
> > > The cause is kswapd will loop for long time even if there is no progress in
> > > balance_pgdat.
> > 
> > How does this solve anything? If the kswapd just backs off then the more
> > work has to be done in the direct reclaim context.
> What if there is still no progress in direct context?

Then we trigger the OOM killer when applicable.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

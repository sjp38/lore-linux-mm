Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 31B198E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 16:23:38 -0500 (EST)
Received: by mail-yb1-f200.google.com with SMTP id v10so4373174ybq.15
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 13:23:38 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m3sor7334540ybk.122.2019.01.09.13.23.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 09 Jan 2019 13:23:36 -0800 (PST)
Date: Wed, 9 Jan 2019 16:23:34 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC v3 PATCH 0/5] mm: memcontrol: do memory reclaim when
 offlining
Message-ID: <20190109212334.GA18978@cmpxchg.org>
References: <1547061285-100329-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190109193247.GA16319@cmpxchg.org>
 <d92912c7-511e-2ab5-39a6-38af3209fcaf@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d92912c7-511e-2ab5-39a6-38af3209fcaf@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: mhocko@suse.com, shakeelb@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jan 09, 2019 at 12:36:11PM -0800, Yang Shi wrote:
> As I mentioned above, if we know some page caches from some memcgs
> are referenced one-off and unlikely shared, why just keep them
> around to increase memory pressure?

It's just not clear to me that your scenarios are generic enough to
justify adding two interfaces that we have to maintain forever, and
that they couldn't be solved with existing mechanisms.

Please explain:

- Unmapped clean page cache isn't expensive to reclaim, certainly
  cheaper than the IO involved in new application startup. How could
  recycling clean cache be a prohibitive part of workload warmup?

- Why you cannot temporarily raise the kswapd watermarks right before
  an important application starts up (your answer was sorta handwavy)

- Why you cannot use madvise/fadvise when an application whose cache
  you won't reuse exits

- Why you couldn't set memory.high or memory.max to 0 after the
  application quits and before you call rmdir on the cgroup

Adding a permanent kernel interface is a serious measure. I think you
need to make a much better case for it, discuss why other options are
not practical, and show that this will be a generally useful thing for
cgroup users and not just a niche fix for very specific situations.

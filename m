Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id F03496B0069
	for <linux-mm@kvack.org>; Mon, 19 Sep 2016 11:35:52 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l138so10010729wmg.3
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 08:35:52 -0700 (PDT)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id 135si6166120ljj.2.2016.09.19.08.35.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Sep 2016 08:35:51 -0700 (PDT)
Received: by mail-lf0-x244.google.com with SMTP id s64so8624100lfs.2
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 08:35:51 -0700 (PDT)
Date: Mon, 19 Sep 2016 18:35:45 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH 1/3] mm: memcontrol: make per-cpu charge cache IRQ-safe
 for socket accounting
Message-ID: <20160919153545.GF1989@esperanza>
References: <20160914194846.11153-1-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160914194846.11153-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, "David S. Miller" <davem@davemloft.net>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Wed, Sep 14, 2016 at 03:48:44PM -0400, Johannes Weiner wrote:
> From: Johannes Weiner <jweiner@fb.com>
> 
> During cgroup2 rollout into production, we started encountering css
> refcount underflows and css access crashes in the memory controller.
> Splitting the heavily shared css reference counter into logical users
> narrowed the imbalance down to the cgroup2 socket memory accounting.
> 
> The problem turns out to be the per-cpu charge cache. Cgroup1 had a
> separate socket counter, but the new cgroup2 socket accounting goes
> through the common charge path that uses a shared per-cpu cache for
> all memory that is being tracked. Those caches are safe against
> scheduling preemption, but not against interrupts - such as the newly
> added packet receive path. When cache draining is interrupted by
> network RX taking pages out of the cache, the resuming drain operation
> will put references of in-use pages, thus causing the imbalance.
> 
> Disable IRQs during all per-cpu charge cache operations.
> 
> Fixes: f7e1cb6ec51b ("mm: memcontrol: account socket memory in unified hierarchy memory controller")
> Cc: <stable@vger.kernel.org> # 4.5+
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

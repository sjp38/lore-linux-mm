Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 020B5828E1
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 11:48:40 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id nq2so17940992lbc.3
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 08:48:39 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id op3si14789403wjc.83.2016.06.21.08.48.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jun 2016 08:48:38 -0700 (PDT)
Date: Tue, 21 Jun 2016 11:46:01 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/3] mm: memcontrol: fix cgroup creation failure after
 many small jobs
Message-ID: <20160621154601.GA22431@cmpxchg.org>
References: <20160616034244.14839-1-hannes@cmpxchg.org>
 <20160616200617.GD3262@mtj.duckdns.org>
 <20160617162310.GA19084@cmpxchg.org>
 <20160617162516.GD19084@cmpxchg.org>
 <20160621101650.GD15970@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160621101650.GD15970@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Li Zefan <lizefan@huawei.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, Jun 21, 2016 at 01:16:51PM +0300, Vladimir Davydov wrote:
> On Fri, Jun 17, 2016 at 12:25:16PM -0400, Johannes Weiner wrote:
> > After this patch, the IDs get released upon cgroup destruction and the
> > cache and css objects get released once memory reclaim kicks in.
> 
> With 65K cgroups it will take the reclaimer a substantial amount of time
> to iterate over all of them, which might result in latency spikes.
> Probably, to avoid that, we could move pages from a dead cgroup's lru to
> its parent's one on offline while still leaving dead cgroups pinned,
> like we do in case of list_lru entries.

Yep, that is true. list_lru is a bit easier because the walker stays
in the context of the original LRU list, whereas the cache/anon LRUs
are not. We'd have to have mem_cgroup_page_lruvec() etc. do a parent
walk to find the closest live ancestor. Maybe you have a better idea?

But it's definitely worth considering. I'll think more about it.

> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Thanks!

> > +static struct idr mem_cgroup_idr;
> 
> static DEFINE_IDR(mem_cgroup_idr);

Oops, good catch. Andrew, could you kindly fold this?

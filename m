Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9AD816B0253
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 03:35:07 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id y42so12174699wrd.23
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 00:35:07 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o25si5305874edf.508.2017.11.15.00.35.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 15 Nov 2017 00:35:06 -0800 (PST)
Date: Wed, 15 Nov 2017 09:35:04 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memcg: hugetlbfs basic usage accounting
Message-ID: <20171115083504.nwczf5xq6posy3bw@dhcp22.suse.cz>
References: <20171114172429.8916-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171114172429.8916-1-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, Dave Hansen <dave.hansen@intel.com>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 14-11-17 17:24:29, Roman Gushchin wrote:
> This patch implements basic accounting of memory consumption
> by hugetlbfs pages for cgroup v2 memory controller.
> 
> Cgroup v2 memory controller lacks any visibility into the
> hugetlbfs memory consumption. Cgroup v1 implemented a separate
> hugetlbfs controller, which provided such stats, and also
> provided some control abilities. Although porting of the
> hugetlbfs controller to cgroup v2 is arguable a good idea and
> is outside of scope of this patch, it's very useful to have
> basic stats provided by memory.stat.

Separate hugetlb cgroup controller was really a deliberate decision.
We didn't want to mix hugetlb with the reclaimable memory. There is no
reasonable way to enforce memcg limits if hugetlb pages are involved.

AFAICS your patch shouldn't break the hugetlb controller because that
one (ab)uses page[2].private to store the hstate for the accounting.
You also do not really charge those hugetlb pages so the memcg
accounting will work unchaged.

So my primary question is, why don't you simply allow hugetlb controller
rather than tweak stats for memcg? Is there any fundamental reason why
hugetlb controller is not v2 compatible?

It feels really strange to keeps stats of something the controller
doesn't really control. I can imagine confused users claiming that
numbers just do not add up...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id 3137C6B0036
	for <linux-mm@kvack.org>; Fri,  4 Jul 2014 08:16:23 -0400 (EDT)
Received: by mail-we0-f174.google.com with SMTP id u57so1598847wes.19
        for <linux-mm@kvack.org>; Fri, 04 Jul 2014 05:16:22 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e17si16610896wjx.19.2014.07.04.05.16.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 04 Jul 2014 05:16:22 -0700 (PDT)
Date: Fri, 4 Jul 2014 14:16:21 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH RFC 0/5] Virtual Memory Resource Controller for cgroups
Message-ID: <20140704121621.GE12466@dhcp22.suse.cz>
References: <cover.1404383187.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1404383187.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Balbir Singh <bsingharora@gmail.com>

On Thu 03-07-14 16:48:16, Vladimir Davydov wrote:
> Hi,
> 
> Typically, when a process calls mmap, it isn't given all the memory pages it
> requested immediately. Instead, only its address space is grown, while the
> memory pages will be actually allocated on the first use. If the system fails
> to allocate a page, it will have no choice except invoking the OOM killer,
> which may kill this or any other process. Obviously, it isn't the best way of
> telling the user that the system is unable to handle his request. It would be
> much better to fail mmap with ENOMEM instead.
> 
> That's why Linux has the memory overcommit control feature, which accounts and
> limits VM size that may contribute to mem+swap, i.e. private writable mappings
> and shared memory areas. However, currently it's only available system-wide,
> and there's no way of avoiding OOM in cgroups.
>
> This patch set is an attempt to fill the gap. It implements the resource
> controller for cgroups that accounts and limits address space allocations that
> may contribute to mem+swap.

Well, I am not really sure how helpful is this. Could you be more
specific about real use cases? If the only problem is that memcg OOM can
trigger to easily then I do not think this is the right approach to
handle it. Strict no-overcommit is basically unusable for many
workloads. Especially those which try to do their own memory usage
optimization in a much larger address space.

Once I get from internal things (which will happen soon hopefully) I
will post a series with a new sets of memcg limits. One of them is
high_limit which can be used as a trigger for memcg reclaim. Unlike
hard_limit there won't be any OOM if the reclaim fails at this stage. So
if the high_limit is configured properly the admin will have enough time
to make additional steps before OOM happens.
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

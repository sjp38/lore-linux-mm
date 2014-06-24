Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id BA77D6B003B
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 03:37:03 -0400 (EDT)
Received: by mail-wg0-f48.google.com with SMTP id n12so7585962wgh.7
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 00:37:03 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k7si20220982wix.97.2014.06.24.00.37.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 24 Jun 2014 00:37:02 -0700 (PDT)
Date: Tue, 24 Jun 2014 09:36:59 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 0/8] mm: add page cache limit and reclaim feature
Message-ID: <20140624073659.GA15337@dhcp22.suse.cz>
References: <539EB7D6.8070401@huawei.com>
 <20140616111422.GA16915@dhcp22.suse.cz>
 <20140616125040.GA29993@optiplex.redhat.com>
 <539F9B6C.1080802@huawei.com>
 <53A3E948.5020701@huawei.com>
 <20140620153212.GD23115@dhcp22.suse.cz>
 <53A78B7C.1050302@huawei.com>
 <20140623112955.GL9743@dhcp22.suse.cz>
 <53A8E19C.40809@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53A8E19C.40809@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Rafael Aquini <aquini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Li Zefan <lizefan@huawei.com>

On Tue 24-06-14 10:25:32, Xishi Qiu wrote:
> On 2014/6/23 19:29, Michal Hocko wrote:
[...]
> > This doesn't make much sense to me. So you have a problem with latency
> > caused by direct reclaim so you add a new way of direct page cache
> > reclaim.
> > 
> >> A user process produces page cache frequently, so free memory is not
> >> enough after running a long time. Slow path takes much more time because 
> >> direct reclaim. And kswapd will reclaim memory too, but not much. Thus it
> >> always triggers slow path. this will cause performance regression.
> > 
> > If I were you I would focus on why the reclaim doesn't catch up with the
> > page cache users. The mechanism you are proposing in unacceptable.
> 
> Hi Michal,
> 
> Do you mean why the reclaim is slower than page cache increase?
> 
> I think there are two reasons:
> 1. kswapd and direct_reclaim will be triggered only when there is not 
> enough memory(e.g. __alloc_pages_slowpath()). That means it will not 
> reclaim when memory is enough(e.g. get_page_from_freelist()).

Yeah and that is the whole point. If you want to start to reclaim earlier
because you need a bigger pillow for the free memory for sudden memory
pressure then increase min_free_kbytes.

> 2. __alloc_pages_direct_reclaim
> 	try_to_free_pages
> 		nr_to_reclaim = SWAP_CLUSTER_MAX
> And "#define SWAP_CLUSTER_MAX 32UL", that means it expect to reclaim 32
> pages. It is too few, if we alloc 2^10 pages in one time.

Maybe _userspace_ allocates that much of memory but it is not faulted
in/allocated by kernel in one shot. Besides that at the time you enter
direct reclaim kswapd should be reclaiming memory to balance zones.
So reclaiming SWAP_CLUSTER_MAX from the direct reclaim shouldn't
matter that much. If it does then show us some numbers to prove it.
SWAP_CLUSTER_MAX is kind of arbitrary number but I haven't seen any
reclaim regression becuse of this value being too small AFAIR.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

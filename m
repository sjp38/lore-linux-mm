Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B2FB96B0038
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 05:04:47 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id l33so4791898wrl.5
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 02:04:47 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k9si4336574wmi.254.2017.12.15.02.04.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Dec 2017 02:04:46 -0800 (PST)
Date: Fri, 15 Dec 2017 11:04:43 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH -mm -V2] mm, swap: Fix race between swapoff and some swap
 operations
Message-ID: <20171215100443.GX16951@dhcp22.suse.cz>
References: <20171214133832.11266-1-ying.huang@intel.com>
 <20171214151718.GS16951@dhcp22.suse.cz>
 <20171214124246.ceebc9c955bd32601c01a28b@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171214124246.ceebc9c955bd32601c01a28b@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Tim Chen <tim.c.chen@linux.intel.com>, Shaohua Li <shli@fb.com>, Mel Gorman <mgorman@techsingularity.net>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Dave Jiang <dave.jiang@intel.com>, Aaron Lu <aaron.lu@intel.com>

On Thu 14-12-17 12:42:46, Andrew Morton wrote:
> On Thu, 14 Dec 2017 16:17:18 +0100 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > > as fast as possible, SRCU instead of reference count is used to
> > > implement get/put_swap_device().  From get_swap_device() to
> > > put_swap_device(), the reader side of SRCU is locked, so
> > > synchronize_srcu() in swapoff() will wait until put_swap_device() is
> > > called.
> > 
> > It is quite unfortunate to pull SRCU as a dependency to the core kernel.
> > Different attempts to do this have failed in the past. This one is
> > slightly different though because I would suspect that those tiny
> > systems do not configure swap. But who knows, maybe they do.
> > 
> > Anyway, if you are worried about performance then I would expect some
> > numbers to back that worry. So why don't simply start with simpler
> > ref count based and then optimize it later based on some actual numbers.
> > Btw. have you considered pcp refcount framework. I would suspect that
> > this would give you close to SRCU performance.
> 
> <squeaky-wheel>Or use stop_kernel() ;)</squeaky-wheel>

well, stop_kernel is a _huge_ hammer. I think we can do much better
without a large complexity. A simple ref counting (or pcp refcounting if
the former has measurable complexity) should do just fine.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

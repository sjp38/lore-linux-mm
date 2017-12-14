Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id D01AB6B025E
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 15:42:50 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id l33so3847284wrl.5
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 12:42:50 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 32si3929837wrk.548.2017.12.14.12.42.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 12:42:49 -0800 (PST)
Date: Thu, 14 Dec 2017 12:42:46 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm -V2] mm, swap: Fix race between swapoff and some
 swap operations
Message-Id: <20171214124246.ceebc9c955bd32601c01a28b@linux-foundation.org>
In-Reply-To: <20171214151718.GS16951@dhcp22.suse.cz>
References: <20171214133832.11266-1-ying.huang@intel.com>
	<20171214151718.GS16951@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Tim Chen <tim.c.chen@linux.intel.com>, Shaohua Li <shli@fb.com>, Mel Gorman <mgorman@techsingularity.net>, =?ISO-8859-1?Q?J=E9r=F4me?= Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Dave Jiang <dave.jiang@intel.com>, Aaron Lu <aaron.lu@intel.com>

On Thu, 14 Dec 2017 16:17:18 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> > as fast as possible, SRCU instead of reference count is used to
> > implement get/put_swap_device().  From get_swap_device() to
> > put_swap_device(), the reader side of SRCU is locked, so
> > synchronize_srcu() in swapoff() will wait until put_swap_device() is
> > called.
> 
> It is quite unfortunate to pull SRCU as a dependency to the core kernel.
> Different attempts to do this have failed in the past. This one is
> slightly different though because I would suspect that those tiny
> systems do not configure swap. But who knows, maybe they do.
> 
> Anyway, if you are worried about performance then I would expect some
> numbers to back that worry. So why don't simply start with simpler
> ref count based and then optimize it later based on some actual numbers.
> Btw. have you considered pcp refcount framework. I would suspect that
> this would give you close to SRCU performance.

<squeaky-wheel>Or use stop_kernel() ;)</squeaky-wheel>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

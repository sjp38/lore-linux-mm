Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 791E12808B4
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 04:16:31 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id u48so18483909wrc.0
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 01:16:31 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c46si7896231wra.299.2017.03.09.01.16.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Mar 2017 01:16:30 -0800 (PST)
Date: Thu, 9 Mar 2017 10:16:28 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 3/4] xfs: map KM_MAYFAIL to __GFP_RETRY_MAYFAIL
Message-ID: <20170309091628.GD11592@dhcp22.suse.cz>
References: <20170307154843.32516-1-mhocko@kernel.org>
 <20170307154843.32516-4-mhocko@kernel.org>
 <20170308150659.GA24535@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170308150659.GA24535@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "Darrick J. Wong" <darrick.wong@oracle.com>

On Wed 08-03-17 07:06:59, Christoph Hellwig wrote:
> On Tue, Mar 07, 2017 at 04:48:42PM +0100, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > KM_MAYFAIL didn't have any suitable GFP_FOO counterpart until recently
> > so it relied on the default page allocator behavior for the given set
> > of flags. This means that small allocations actually never failed.
> > 
> > Now that we have __GFP_RETRY_MAYFAIL flag which works independently on the
> > allocation request size we can map KM_MAYFAIL to it. The allocator will
> > try as hard as it can to fulfill the request but fails eventually if
> > the progress cannot be made.
> 
> I don't think we really need this - KM_MAYFAIL is basically just
> a flag to not require the retry loop around kmalloc for those places
> in XFS that can deal with allocation failures.  But if the default
> behavior is to not fail we'll happily take that.

Does that mean that you are happy to go OOM and trigger the OOM killer
even when you know that the failure can be handled gracefully?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

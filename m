Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 51A91800D8
	for <linux-mm@kvack.org>; Thu, 25 Jan 2018 05:02:21 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id w102so4173159wrb.21
        for <linux-mm@kvack.org>; Thu, 25 Jan 2018 02:02:21 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e15si3565803wra.96.2018.01.25.02.02.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 25 Jan 2018 02:02:20 -0800 (PST)
Date: Thu, 25 Jan 2018 11:02:19 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] few MM topics
Message-ID: <20180125100219.GO28465@dhcp22.suse.cz>
References: <20180124092649.GC21134@dhcp22.suse.cz>
 <bee1d564-b4b8-ed0c-edfa-f6df6a24fe21@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bee1d564-b4b8-ed0c-edfa-f6df6a24fe21@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-nvme@lists.infradead.org, linux-fsdevel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@surriel.com>

On Wed 24-01-18 10:23:20, Mike Kravetz wrote:
> On 01/24/2018 01:26 AM, Michal Hocko wrote:
[...]
> > - It seems there is some demand for large (> MAX_ORDER) allocations.
> >   We have that alloc_contig_range which was originally used for CMA and
> >   later (ab)used for Giga hugetlb pages. The API is less than optimal
> >   and we should probably think about how to make it more generic.
> 
> This is also of interest to me.  I actually started some efforts in this
> area.  The idea (as you mention above) would be to provide a more usable
> API for allocation of contiguous pages/ranges.  And, gigantic huge pages
> would be the first consumer.
> 
> alloc_contig_range currently has some issues with being used in a 'more
> generic' way.  A comment describing the routine says "it's the caller's
> responsibility to guarantee that we are the only thread that changes
> migrate type of pageblocks the pages fall in.".  This is true, and I think
> it also applies to users of the underlying routines such as
> start_isolate_page_range.  The CMA code has a mechanism that prevents two
> threads from operating on the same range concurrently.  The other users
> (gigantic page allocation and memory offline) happen infrequently enough
> that we are unlikely to have a conflict.  But, opening this up to more
> generic use will require at least a more generic synchronization mechanism.

Yes, that is exactly my concern and the current state of art that has to
change. I am not yet sure how. So any discussion seems interesting.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

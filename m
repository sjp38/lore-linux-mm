Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 13F006B0253
	for <linux-mm@kvack.org>; Fri, 16 Sep 2016 10:07:12 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id fu14so87328844pad.0
        for <linux-mm@kvack.org>; Fri, 16 Sep 2016 07:07:12 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id m66si45316548pfc.281.2016.09.16.07.07.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Sep 2016 07:07:11 -0700 (PDT)
Date: Fri, 16 Sep 2016 16:07:07 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 1/4] mm, vmscan: Batch removal of mappings under a single
 lock during reclaim
Message-ID: <20160916140707.GI5020@twins.programming.kicks-ass.net>
References: <1473415175-20807-1-git-send-email-mgorman@techsingularity.net>
 <1473415175-20807-2-git-send-email-mgorman@techsingularity.net>
 <20160916132506.GB5035@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160916132506.GB5035@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Linus Torvalds <torvalds@linux-foundation.org>, Ying Huang <ying.huang@intel.com>, Michal Hocko <mhocko@kernel.org>

On Fri, Sep 16, 2016 at 03:25:06PM +0200, Peter Zijlstra wrote:
> On Fri, Sep 09, 2016 at 10:59:32AM +0100, Mel Gorman wrote:
> > Pages unmapped during reclaim acquire/release the mapping->tree_lock for
> > every single page. There are two cases when it's likely that pages at the
> > tail of the LRU share the same mapping -- large amounts of IO to/from a
> > single file and swapping. This patch acquires the mapping->tree_lock for
> > multiple page removals.
> 
> So, once upon a time, in a galaxy far away,..  I did a concurrent
> pagecache patch set that replaced the tree_lock with a per page bit-
> spinlock and fine grained locking in the radix tree.
> 
> I know the mm has changed quite a bit since, but would such an approach
> still be feasible?
> 
> I cannot seem to find an online reference to a 'complete' version of
> that patch set, but I did find the OLS paper on it and I did find some
> copies on my local machines.

https://www.kernel.org/doc/ols/2007/ols2007v2-pages-311-318.pdf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

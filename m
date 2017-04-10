Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8C0D16B0397
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 13:20:58 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id z62so4763154wrc.0
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 10:20:58 -0700 (PDT)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id e10si20329284wre.324.2017.04.10.10.20.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Apr 2017 10:20:57 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id E391698E07
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 17:20:56 +0000 (UTC)
Date: Mon, 10 Apr 2017 18:20:56 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm, numa: Fix bad pmd by atomically check for
 pmd_trans_huge when marking page tables prot_numa
Message-ID: <20170410172056.shyx6qzcjglbt5nd@techsingularity.net>
References: <20170410094825.2yfo5zehn7pchg6a@techsingularity.net>
 <84B5E286-4E2A-4DE0-8351-806D2102C399@cs.rutgers.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <84B5E286-4E2A-4DE0-8351-806D2102C399@cs.rutgers.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Apr 10, 2017 at 11:45:08AM -0500, Zi Yan wrote:
> > While this could be fixed with heavy locking, it's only necessary to
> > make a copy of the PMD on the stack during change_pmd_range and avoid
> > races. A new helper is created for this as the check if quite subtle and the
> > existing similar helpful is not suitable. This passed 154 hours of testing
> > (usually triggers between 20 minutes and 24 hours) without detecting bad
> > PMDs or corruption. A basic test of an autonuma-intensive workload showed
> > no significant change in behaviour.
> >
> > Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> > Cc: stable@vger.kernel.org
> 
> Does this patch fix the same problem fixed by Kirill's patch here?
> https://lkml.org/lkml/2017/3/2/347
> 

I don't think so. The race I'm concerned with is due to locks not being
held and is in a different path.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

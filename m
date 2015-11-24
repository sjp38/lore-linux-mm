Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id C19EC6B0255
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 12:02:43 -0500 (EST)
Received: by wmuu63 with SMTP id u63so105292265wmu.0
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 09:02:42 -0800 (PST)
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com. [74.125.82.50])
        by mx.google.com with ESMTPS id hx7si12462263wjb.181.2015.11.24.09.02.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 09:02:41 -0800 (PST)
Received: by wmuu63 with SMTP id u63so105291300wmu.0
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 09:02:41 -0800 (PST)
Date: Tue, 24 Nov 2015 18:02:39 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: Give __GFP_NOFAIL allocations access to memory
 reserves
Message-ID: <20151124170239.GA13492@dhcp22.suse.cz>
References: <1447249697-13380-1-git-send-email-mhocko@kernel.org>
 <5651BB43.8030102@suse.cz>
 <20151123092925.GB21050@dhcp22.suse.cz>
 <5652DFCE.3010201@suse.cz>
 <20151123101345.GF21050@dhcp22.suse.cz>
 <alpine.DEB.2.10.1511231320160.30886@chino.kir.corp.google.com>
 <20151124094708.GA29472@dhcp22.suse.cz>
 <20151124162604.GB9598@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151124162604.GB9598@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 24-11-15 11:26:04, Johannes Weiner wrote:
> On Tue, Nov 24, 2015 at 10:47:09AM +0100, Michal Hocko wrote:
> > Besides that there is no other reliable warning that we are getting
> > _really_ short on memory unlike when the allocation failure is
> > allowed. OOM killer report might be missing because there was no actual
> > killing happening.
> 
> This is why I would like to see that warning generalized, and not just
> for __GFP_NOFAIL. We have allocations other than explicit __GFP_NOFAIL
> that will loop forever in the allocator,

Yes but does it make sense to warn for all of them? Wouldn't it be
sufficient to warn about those which cannot allocate anything even
though they are doing ALLOC_NO_WATERMARKS? We could still hint the
administrator to increase min_free_kbytes for his particular workload.
Such a situation should be really exceptional and warn_once should be
sufficient.

> and when this deadlocks the
> machine all we see is other tasks hanging, but not the culprit. If we
> were to get a backtrace of some task in the allocator that is known to
> hold locks, suddenly all the other hung tasks will make sense, and it
> will clearly distinguish such an allocator deadlock from other issues.

Tetsuo was suggesting a more sophisticated infrastructure for tracking
allocations [1] which take too long without making progress. I haven't
seen his patch because I was too busy with other stuff but maybe this is
what you would like to see?

Anyway I would like to make some progress on this patch. Do you think
that it would be acceptable in the current form without the warning or
you preffer a different way?

[1] http://lkml.kernel.org/r/201510182105.AGA00839.FHVFFStLQOMOOJ%40I-love.SAKURA.ne.jp
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

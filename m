Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id C87CD6B0254
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 11:26:13 -0500 (EST)
Received: by wmvv187 with SMTP id v187so217787521wmv.1
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 08:26:13 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id r7si13388725wmg.47.2015.11.24.08.26.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 08:26:12 -0800 (PST)
Date: Tue, 24 Nov 2015 11:26:04 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm, oom: Give __GFP_NOFAIL allocations access to memory
 reserves
Message-ID: <20151124162604.GB9598@cmpxchg.org>
References: <1447249697-13380-1-git-send-email-mhocko@kernel.org>
 <5651BB43.8030102@suse.cz>
 <20151123092925.GB21050@dhcp22.suse.cz>
 <5652DFCE.3010201@suse.cz>
 <20151123101345.GF21050@dhcp22.suse.cz>
 <alpine.DEB.2.10.1511231320160.30886@chino.kir.corp.google.com>
 <20151124094708.GA29472@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151124094708.GA29472@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, Nov 24, 2015 at 10:47:09AM +0100, Michal Hocko wrote:
> Besides that there is no other reliable warning that we are getting
> _really_ short on memory unlike when the allocation failure is
> allowed. OOM killer report might be missing because there was no actual
> killing happening.

This is why I would like to see that warning generalized, and not just
for __GFP_NOFAIL. We have allocations other than explicit __GFP_NOFAIL
that will loop forever in the allocator, and when this deadlocks the
machine all we see is other tasks hanging, but not the culprit. If we
were to get a backtrace of some task in the allocator that is known to
hold locks, suddenly all the other hung tasks will make sense, and it
will clearly distinguish such an allocator deadlock from other issues.

Do you remember the patch you proposed at LSF about failing requests
after looping a certain (configurable) number of times? Well, instead
of failing them, it would be good to start WARNING after a certain #
of loops when we know we won't quit (implicit or explicit NOFAIL).

[ Kind of like fs/xfs/kmem::kmem_alloc() does, only that that is
  currently dead code due to our looping inside the allocator. ]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

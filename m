Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id D32006B028D
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 03:57:17 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b13-v6so2703190edb.1
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 00:57:17 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t6-v6si12341356eds.246.2018.10.10.00.57.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 00:57:16 -0700 (PDT)
Subject: Re: [PATCH 1/2] mm: thp: relax __GFP_THISNODE for MADV_HUGEPAGE
 mappings
References: <20180925120326.24392-1-mhocko@kernel.org>
 <20180925120326.24392-2-mhocko@kernel.org>
 <alpine.DEB.2.21.1810041302330.16935@chino.kir.corp.google.com>
 <20181005073854.GB6931@suse.de>
 <alpine.DEB.2.21.1810051320270.202739@chino.kir.corp.google.com>
 <20181005232155.GA2298@redhat.com>
 <alpine.DEB.2.21.1810081303060.221006@chino.kir.corp.google.com>
 <20181009094825.GC6931@suse.de>
 <alpine.DEB.2.21.1810091424170.57306@chino.kir.corp.google.com>
 <20181009225147.GD9307@redhat.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <53169158-09b1-e592-def0-de5e4c47ce16@suse.cz>
Date: Wed, 10 Oct 2018 09:54:32 +0200
MIME-Version: 1.0
In-Reply-To: <20181009225147.GD9307@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andrea Argangeli <andrea@kernel.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stable tree <stable@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 10/10/18 12:51 AM, Andrea Arcangeli wrote:
> Yes there's one case where reclaim is "pointless", but it happens once
> and then COMPACT_DEFERRED is returned and __GFP_NORETRY will skip
> reclaim then.
> 
> So you're right when we hit fragmentation there's one and only one
> "pointless" reclaim invocation. And immediately after we also
> exponentially backoff on the compaction invocations with the
> compaction deferred logic.
> 
> We could try optimize away such "pointless" reclaim event for sure,
> but it's probably an optimization that may just get lost in the noise
> and may not be measurable, because it only happens once when the first
> full fragmentation is encountered.

Note there's a small catch in the above. defer_compaction() has always
only been called after a failure on higher priority than
COMPACT_PRIO_ASYNC, where it's assumed that async compaction can
terminate prematurely due to a number of reasons, so it doesn't mean
that the zone itself cannot be compacted.
And, for __GFP_NORETRY, if the initial compaction fails, we keep using
async compaction also for the second, after-reclaim attempt (which would
otherwise use SYNC_LIGHT):

        /*
         * Looks like reclaim/compaction is worth trying, but
         * sync compaction could be very expensive, so keep
         * using async compaction.
         */
        compact_priority = INIT_COMPACT_PRIORITY;

This doesn't affect current madvised THP allocation which doesn't use
__GFP_NORETRY, but could explain why you saw no benefit from changing it
to __GFP_NORETRY.

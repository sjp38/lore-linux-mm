Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 11B168E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 06:28:27 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id e17so1484597edr.7
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 03:28:27 -0800 (PST)
Received: from outbound-smtp13.blacknight.com (outbound-smtp13.blacknight.com. [46.22.139.230])
        by mx.google.com with ESMTPS id l19-v6si4504870ejp.77.2019.01.08.03.28.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 03:28:25 -0800 (PST)
Received: from mail.blacknight.com (unknown [81.17.255.152])
	by outbound-smtp13.blacknight.com (Postfix) with ESMTPS id 545D61C1F16
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 11:28:25 +0000 (GMT)
Date: Tue, 8 Jan 2019 11:28:23 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [RFC 3/3] mm, compaction: introduce deferred async compaction
Message-ID: <20190108112823.GP31517@techsingularity.net>
References: <20181211142941.20500-1-vbabka@suse.cz>
 <20181211142941.20500-4-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20181211142941.20500-4-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Tue, Dec 11, 2018 at 03:29:41PM +0100, Vlastimil Babka wrote:
> Deferring compaction happens when it fails to fulfill the allocation request at
> given order, and then a number of the following direct compaction attempts for
> same or higher orders is skipped; with further failures, the number grows
> exponentially up to 64. This is reset e.g. when compaction succeeds.
> 
> Until now, defering compaction is only performed after a sync compaction fails,
> and then it also blocks async compaction attempts. The rationale is that only a
> failed sync compaction is expected to fully exhaust all compaction potential of
> a zone. However, for THP page faults that use __GFP_NORETRY, this means only
> async compaction is attempted and thus it is never deferred, potentially
> resulting in pointless reclaim/compaction attempts in a badly fragmented node.
> 
> This patch therefore tracks and checks async compaction deferred status in
> addition, and mostly separately from sync compaction. This allows deferring THP
> fault compaction without affecting any sync pageblock-order compaction.
> Deferring for sync compaction however implies deferring for async compaction as
> well. When deferred status is reset, it is reset for both modes.
> 
> The expected outcome is less compaction/reclaim activity for failing THP faults
> likely with some expense on THP fault success rate.
> 

Either pre/post compaction series I think this makes sense although the
details may change slightly. If the caller allows then do async
compaction, sync compaction if that fails and defer if that also fails.
If the caller can only do async compaction then defer upon failure and
keep track of those two callers separetly.

-- 
Mel Gorman
SUSE Labs

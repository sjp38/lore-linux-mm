Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id A3EFC6B007E
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 10:25:22 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id u74so74720981lff.0
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 07:25:22 -0700 (PDT)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id o72si4414944wmg.48.2016.06.14.07.25.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jun 2016 07:25:19 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id B53051C1F3C
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 15:25:18 +0100 (IST)
Date: Tue, 14 Jun 2016 15:25:07 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 01/27] mm, vmstat: Add infrastructure for per-node vmstats
Message-ID: <20160614142506.GA1868@techsingularity.net>
References: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
 <1465495483-11855-2-git-send-email-mgorman@techsingularity.net>
 <alpine.DEB.2.20.1606131208110.25027@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1606131208110.25027@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jun 13, 2016 at 12:26:13PM -0500, Christoph Lameter wrote:
> On Thu, 9 Jun 2016, Mel Gorman wrote:
> 
> > VM statistic counters for reclaim decisions are zone-based. If the kernel
> > is to reclaim on a per-node basis then we need to track per-node statistics
> > but there is no infrastructure for that. The most notable change is that
> 
> There is node_page_state() so the value of any counter per node is already
> available. Note that some of the counters (NUMA_xx) for example do not
> make much sense as per zone counters and are effectively used as per node
> counters.
> 
> So the main effect you are looking for is to have the counters stored in
> the per node structure as opposed to the per zone struct in order to
> avoid the summing?

Yes.

> Doing so duplicates a large amount of code it seems.
> 

Also yes. I considered macro magic to cover it but it turned into a
major mess. They could always be summed so it would be a minor
performance dent and a heavier cache footprint.

> If you do this then also move over certain counters that have more of a
> per node use from per zone to per node. Like the NUMA_xxx counters.
> 

As the NUMA counters are consumed by userspace, I worried that it would
break some tools. If the rest of the series gets solidified then I will
do it as a single patch on top so it can be reverted if necessary
relatively easily.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

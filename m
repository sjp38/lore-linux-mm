Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id CB3996B004A
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 13:16:40 -0400 (EDT)
Message-ID: <4F85BC8E.3020400@redhat.com>
Date: Wed, 11 Apr 2012 13:17:02 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] Removal of lumpy reclaim V2
References: <1334162298-18942-1-git-send-email-mgorman@suse.de>
In-Reply-To: <1334162298-18942-1-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 04/11/2012 12:38 PM, Mel Gorman wrote:

> Success rates are completely hosed for 3.4-rc2 which is almost certainly
> due to [fe2c2a10: vmscan: reclaim at order 0 when compaction is enabled]. I
> expected this would happen for kswapd and impair allocation success rates
> (https://lkml.org/lkml/2012/1/25/166) but I did not anticipate this much
> a difference: 80% less scanning, 37% less reclaim by kswapd

Also, no gratuitous pageouts of anonymous memory.
That was what really made a difference on a somewhat
heavily loaded desktop + kvm workload.

> In comparison, reclaim/compaction is not aggressive and gives up easily
> which is the intended behaviour. hugetlbfs uses __GFP_REPEAT and would be
> much more aggressive about reclaim/compaction than THP allocations are. The
> stress test above is allocating like neither THP or hugetlbfs but is much
> closer to THP.

Next step: get rid of __GFP_NO_KSWAPD for THP, first
in the -mm kernel

> Mainline is now impaired in terms of high order allocation under heavy load
> although I do not know to what degree as I did not test with __GFP_REPEAT.
> Keep this in mind for bugs related to hugepage pool resizing, THP allocation
> and high order atomic allocation failures from network devices.

This might be due to smaller allocations not bumping
the compaction deferring code, when we have deferred
compaction for a higher order allocation.

I wonder if the compaction deferring code is simply
too defer-happy, now that we ignore compaction at
lower orders than where compaction failed?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 134D76B005D
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 07:06:11 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id r15so1704495wrc.11
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 04:06:11 -0800 (PST)
Received: from outbound-smtp20.blacknight.com (outbound-smtp20.blacknight.com. [46.22.139.247])
        by mx.google.com with ESMTPS id e29si555218eda.89.2018.02.15.04.06.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Feb 2018 04:06:09 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp20.blacknight.com (Postfix) with ESMTPS id A6B0F1C5014
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 12:06:08 +0000 (GMT)
Date: Thu, 15 Feb 2018 12:06:08 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH v2 1/2] free_pcppages_bulk: do not hold lock when picking
 pages to free
Message-ID: <20180215120608.g5wj2qb2thkkzu5e@techsingularity.net>
References: <20180124023050.20097-1-aaron.lu@intel.com>
 <20180124163926.c7ptagn655aeiut3@techsingularity.net>
 <20180125072144.GA27678@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20180125072144.GA27678@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>

On Thu, Jan 25, 2018 at 03:21:44PM +0800, Aaron Lu wrote:
> When freeing a batch of pages from Per-CPU-Pages(PCP) back to buddy,
> the zone->lock is held and then pages are chosen from PCP's migratetype
> list. While there is actually no need to do this 'choose part' under
> lock since it's PCP pages, the only CPU that can touch them is us and
> irq is also disabled.
> 
> Moving this part outside could reduce lock held time and improve
> performance. Test with will-it-scale/page_fault1 full load:
> 
> kernel      Broadwell(2S)  Skylake(2S)   Broadwell(4S)  Skylake(4S)
> v4.15-rc4   9037332        8000124       13642741       15728686
> this patch  9608786 +6.3%  8368915 +4.6% 14042169 +2.9% 17433559 +10.8%
> 
> What the test does is: starts $nr_cpu processes and each will repeatedly
> do the following for 5 minutes:
> 1 mmap 128M anonymouse space;
> 2 write access to that space;
> 3 munmap.
> The score is the aggregated iteration.
> 
> https://github.com/antonblanchard/will-it-scale/blob/master/tests/page_fault1.c
> 
> Acked-by: Mel Gorman <mgorman@techsingularity.net>
> Signed-off-by: Aaron Lu <aaron.lu@intel.com>

It looks like this series may have gotten lost because it was embedded
within an existing thread or else it was the proximity to the merge
window. I suggest a rebase, retest and resubmit unless there was some
major objection that I missed. Patch 1 is fine by me at least. I never
explicitly acked patch 2 but I've no major objection to it, just am a tad
uncomfortable with prefetch magic sauce in general.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1763D800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 14:23:53 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id p20so3769746pfh.17
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 11:23:53 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id c41-v6si612717plj.682.2018.01.24.11.23.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jan 2018 11:23:52 -0800 (PST)
Subject: Re: [PATCH 2/2] free_pcppages_bulk: prefetch buddy while not holding
 lock
References: <20180124023050.20097-1-aaron.lu@intel.com>
 <20180124023050.20097-2-aaron.lu@intel.com>
 <20180124164344.lca63gjn7mefuiac@techsingularity.net>
 <148a42d8-8306-2f2f-7f7c-86bc118f8ccd@intel.com>
 <20180124181921.vnivr32q72ey7p5i@techsingularity.net>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <525a20be-dea9-ed54-ca8e-8c4bc5e8a04f@intel.com>
Date: Wed, 24 Jan 2018 11:23:49 -0800
MIME-Version: 1.0
In-Reply-To: <20180124181921.vnivr32q72ey7p5i@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Aaron Lu <aaron.lu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>

On 01/24/2018 10:19 AM, Mel Gorman wrote:
>> IOW, I don't think this has the same downsides normally associated with
>> prefetch() since the data is always used.
> That doesn't side-step the calculations are done twice in the
> free_pcppages_bulk path and there is no guarantee that one prefetch
> in the list of pages being freed will not evict a previous prefetch
> due to collisions.

Fair enough.  The description here could probably use some touchups to
explicitly spell out the downsides.

I do agree with you that there is no guarantee that this will be
resident in the cache before use.  In fact, it might be entertaining to
see if we can show the extra conflicts in the L1 given from this change
given a large enough PCP batch size.

But, this isn't just about the L1.  If the results of the prefetch()
stay in *ANY* cache, then the memory bandwidth impact of this change is
still zero.  You'll have a lot harder time arguing that we're likely to
see L2/L3 evictions in this path for our typical PCP batch sizes.

Do you want to see some analysis for less-frequent PCP frees?  We could
pretty easily instrument the latency doing normal-ish things to see if
we can measure a benefit from this rather than a tight-loop micro.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id E671A6B025F
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 13:51:46 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id y192so27345368pgd.12
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 10:51:46 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id s85si5798763pfa.472.2017.08.15.10.51.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Aug 2017 10:51:45 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm: Update NUMA counter threshold size
References: <1502786736-21585-1-git-send-email-kemi.wang@intel.com>
 <1502786736-21585-3-git-send-email-kemi.wang@intel.com>
 <20170815095819.5kjh4rrhkye3lgf2@techsingularity.net>
 <a258ea24-6830-4907-0165-fec17ccb7f9f@linux.intel.com>
 <20170815173050.xn5ffrsvdj4myoam@techsingularity.net>
From: Tim Chen <tim.c.chen@linux.intel.com>
Message-ID: <6f58040a-d273-cbd3-98ac-679add61c337@linux.intel.com>
Date: Tue, 15 Aug 2017 10:51:21 -0700
MIME-Version: 1.0
In-Reply-To: <20170815173050.xn5ffrsvdj4myoam@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Kemi Wang <kemi.wang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On 08/15/2017 10:30 AM, Mel Gorman wrote:
> On Tue, Aug 15, 2017 at 09:55:39AM -0700, Tim Chen wrote:

>>
>> Doubling the threshold and counter size will help, but not as much
>> as making them above u8 limit as seen in Kemi's data:
>>
>>       125         537         358906028 <==> system by default (base)
>>       256         468         412397590
>>       32765       394(-26.6%) 488932078(+36.2%) <==> with this patchset
>>
>> For small system making them u8 makes sense.  For larger ones the
>> frequent local counter overflow into the global counter still
>> causes a lot of cache bounce.  Kemi can perhaps collect some data
>> to see what is the gain from making the counters u8. 
>>
> 
> The same comments hold. The increase of a cache line is undesirable but
> there are other places where the overall cost can be reduced by special
> casing based on how this counter is used (always incrementing by one).

Can you be more explicit of what optimization you suggest here and changes
to inc/dec_zone_page_state?  Seems to me like we will still overflow
the local counter with the same frequency unless the threshold and
counter size is changed.

Thanks.

Tim

> It would be preferred if those were addressed to see how close that gets
> to the same performance of doubling the necessary storage for a counter.
> doubling the storage 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

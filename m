Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5BD0A28024B
	for <linux-mm@kvack.org>; Sat, 24 Sep 2016 09:18:39 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 21so281525757pfy.3
        for <linux-mm@kvack.org>; Sat, 24 Sep 2016 06:18:39 -0700 (PDT)
Received: from mail-pa0-x243.google.com (mail-pa0-x243.google.com. [2607:f8b0:400e:c03::243])
        by mx.google.com with ESMTPS id p72si13606496pfi.197.2016.09.24.06.18.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 24 Sep 2016 06:18:38 -0700 (PDT)
Received: by mail-pa0-x243.google.com with SMTP id my20so6324268pab.3
        for <linux-mm@kvack.org>; Sat, 24 Sep 2016 06:18:38 -0700 (PDT)
Subject: Re: [PATCH] mm: warn about allocations which stall for too long
References: <20160923081555.14645-1-mhocko@kernel.org>
 <57E56789.1070205@intel.com>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <31729f1f-c0da-29e4-5777-69446daab122@gmail.com>
Date: Sat, 24 Sep 2016 23:19:04 +1000
MIME-Version: 1.0
In-Reply-To: <57E56789.1070205@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>



On 24/09/16 03:34, Dave Hansen wrote:
> On 09/23/2016 01:15 AM, Michal Hocko wrote:
>> +	/* Make sure we know about allocations which stall for too long */
>> +	if (!(gfp_mask & __GFP_NOWARN) && time_after(jiffies, alloc_start + stall_timeout)) {
>> +		pr_warn("%s: page alloction stalls for %ums: order:%u mode:%#x(%pGg)\n",
>> +				current->comm, jiffies_to_msecs(jiffies-alloc_start),
>> +				order, gfp_mask, &gfp_mask);
>> +		stall_timeout += 10 * HZ;
>> +		dump_stack();
>> +	}
> 
> This would make an awesome tracepoint.  There's probably still plenty of
> value to having it in dmesg, but the configurability of tracepoints is
> hard to beat.

An awesome tracepoint and a great place to trigger other tracepoints. With stall timeout
increasing every time, do we only care about the first instance when we exceeded stall_timeout?
Do we debug just that instance?

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

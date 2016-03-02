Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 5F4F36B0261
	for <linux-mm@kvack.org>; Wed,  2 Mar 2016 08:22:37 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id p65so77605876wmp.0
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 05:22:37 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x63si4874074wmb.0.2016.03.02.05.22.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 02 Mar 2016 05:22:36 -0800 (PST)
Subject: Re: [PATCH 0/3] OOM detection rework v4
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <20160203132718.GI6757@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602241832160.15564@eggly.anvils>
 <20160229203502.GW16930@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602292251170.7563@eggly.anvils>
 <20160301133846.GF9461@dhcp22.suse.cz> <56D5DBF0.2020004@suse.cz>
 <20160302122410.GD26686@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56D6E918.5030109@suse.cz>
Date: Wed, 2 Mar 2016 14:22:32 +0100
MIME-Version: 1.0
In-Reply-To: <20160302122410.GD26686@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 03/02/2016 01:24 PM, Michal Hocko wrote:
> On Tue 01-03-16 19:14:08, Vlastimil Babka wrote:
>>
>> I was under impression that similar checks to compaction_suitable() were
>> done also in compact_finished(), to stop compacting if memory got low due to
>> parallel activity. But I guess it was a patch from Joonsoo that didn't get
>> merged.
>>
>> My only other theory so far is that watermark checks fail in
>> __isolate_free_page() when we want to grab page(s) as migration targets.
>
> yes this certainly contributes to the problem and triggered in my case a
> lot:
> $ grep __isolate_free_page trace.log | wc -l
> 181
> $ grep __alloc_pages_direct_compact: trace.log | wc -l
> 7
>
>> I would suggest enabling all compaction tracepoint and the migration
>> tracepoint. Looking at the trace could hopefully help faster than
>> going one trace_printk() per attempt.
>
> OK, here we go with both watermarks checks removed and hopefully all the
> compaction related tracepoints enabled:
> echo 1 > /debug/tracing/events/compaction/enable
> echo 1 > /debug/tracing/events/migrate/mm_migrate_pages/enable

The trace shows only 4 direct compaction attempts with order=2. The rest 
is order=9, i.e. THP, which has little chances of success under such 
pressure, and thus those failures and defers. The few order=2 attempts 
appear all successful (defer_reset is called).

So it seems your system is mostly fine with just reclaim, and there's 
little need for order-2 compaction, and that's also why you can't 
reproduce the OOMs. So I'm afraid we'll learn nothing here, and looks 
like Hugh will have to try those watermark check adjustments/removals 
and/or provide the same kind of trace.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

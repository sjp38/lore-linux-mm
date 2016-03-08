Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 73B386B0253
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 07:29:55 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id n186so129143270wmn.1
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 04:29:55 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bg9si3444783wjb.182.2016.03.08.04.29.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 08 Mar 2016 04:29:54 -0800 (PST)
Subject: Re: [PATCH] mm, oom: protect !costly allocations some more
References: <20160203132718.GI6757@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602241832160.15564@eggly.anvils>
 <20160225092315.GD17573@dhcp22.suse.cz>
 <20160229210213.GX16930@dhcp22.suse.cz>
 <20160307160838.GB5028@dhcp22.suse.cz> <56DE9A68.2010301@suse.cz>
 <20160308094612.GB13542@dhcp22.suse.cz> <56DEA0CF.2070902@suse.cz>
 <20160308101016.GC13542@dhcp22.suse.cz> <56DEB394.40602@suse.cz>
 <20160308122241.GD13542@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56DEC5BE.6040209@suse.cz>
Date: Tue, 8 Mar 2016 13:29:50 +0100
MIME-Version: 1.0
In-Reply-To: <20160308122241.GD13542@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <js1304@gmail.com>

On 03/08/2016 01:22 PM, Michal Hocko wrote:
>> Thanks.
>>
>>> A more important question is whether the criteria I have chosen are
>>> reasonable and reasonably independent on the particular implementation
>>> of the compaction. I still cannot convince myself about the convergence
>>> here. Is it possible that the compaction would keep returning 
>>> compact_result <= COMPACT_CONTINUE while not making any progress at all?
>>
>> Theoretically, if reclaim/compaction suitability decisions and
>> allocation attempts didn't match the watermark checks, including the
>> alloc_flags and classzone_idx parameters. Possible scenarios:
>>
>> - reclaim thinks compaction has enough to proceed, but compaction thinks
>> otherwise and returns COMPACT_SKIPPED
>> - compaction thinks it succeeded and returns COMPACT_PARTIAL, but
>> allocation attempt fails
>> - and perhaps some other combinations
> 
> But that might happen right now as well so it wouldn't be a regression,
> right?

Maybe, somehow, I didn't study closely how the retry decisions work.
Your patch adds another way to retry so it's theoretically more
dangerous. Just hinting at what to possibly check (the watermark checks) :)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

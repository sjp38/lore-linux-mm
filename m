Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 78DD16B0253
	for <linux-mm@kvack.org>; Mon, 16 May 2016 05:28:01 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id m64so96053731lfd.1
        for <linux-mm@kvack.org>; Mon, 16 May 2016 02:28:01 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id wt5si15893761wjb.111.2016.05.16.02.27.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 May 2016 02:27:59 -0700 (PDT)
Subject: Re: [RFC 12/13] mm, compaction: more reliably increase direct
 compaction priority
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
 <1462865763-22084-13-git-send-email-vbabka@suse.cz>
 <20160513141539.GR20141@dhcp22.suse.cz> <57397760.4060407@suse.cz>
 <20160516081439.GD23146@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5739929C.5000500@suse.cz>
Date: Mon, 16 May 2016 11:27:56 +0200
MIME-Version: 1.0
In-Reply-To: <20160516081439.GD23146@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On 05/16/2016 10:14 AM, Michal Hocko wrote:
> On Mon 16-05-16 09:31:44, Vlastimil Babka wrote:
>>
>> Yeah it should work, my only worry was that this may get subtly wrong (as
>> experience shows us) and due to e.g. slightly different watermark checks
>> and/or a corner-case zone such as ZONE_DMA, should_reclaim_retry() would
>> keep returning true, even if reclaim couldn't/wouldn't help anything. Then
>> compaction would be needlessly kept at ineffective priority.
>
> watermark check for ZONE_DMA should always fail because it fails even
> when is completely free to the lowmem reserves. I had a subtle bug in
> the original code to check highzone_idx rather than classzone_idx but
> that should the fix has been posted recently:
> http://lkml.kernel.org/r/1463051677-29418-2-git-send-email-mhocko@kernel.org

Sure, but that just adds to the experience of being subtly wrong in this 
area :) But sure we can leave this part alone until proven wrong, I 
don't insist strongly.

>> Also my understanding of the initial compaction priorities is to lower the
>> latency if fragmentation is just light and there's enough memory. Once we
>> start struggling, I don't see much point in not switching to the full
>> compaction priority quickly.
>
> That is true but why to compact when there are high order pages and they
> are just hidden by the watermark check.

Compaction should skip such zone regardless of priority.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

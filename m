Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 0DD24828F2
	for <linux-mm@kvack.org>; Wed,  2 Mar 2016 09:40:59 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id l68so88616583wml.0
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 06:40:59 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bl6si43328310wjc.222.2016.03.02.06.40.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 02 Mar 2016 06:40:57 -0800 (PST)
Subject: Re: [PATCH v2 4/5] mm, kswapd: replace kswapd compaction with waking
 up kcompactd
References: <1454938691-2197-1-git-send-email-vbabka@suse.cz>
 <1454938691-2197-5-git-send-email-vbabka@suse.cz>
 <20160302063322.GB32695@js1304-P5Q-DELUXE> <56D6BACB.7060005@suse.cz>
 <CAAmzW4PHAsMvifgV2FpS_FYE78_PzDtADvoBY67usc_9-D4Hjg@mail.gmail.com>
 <56D6F41D.9080107@suse.cz>
 <CAAmzW4PGgYkL9xnCXgSQ=8kW0sJkaYyrxenb_XKHcW1wDGMEyw@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56D6FB77.2090801@suse.cz>
Date: Wed, 2 Mar 2016 15:40:55 +0100
MIME-Version: 1.0
In-Reply-To: <CAAmzW4PGgYkL9xnCXgSQ=8kW0sJkaYyrxenb_XKHcW1wDGMEyw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>

On 03/02/2016 03:22 PM, Joonsoo Kim wrote:
> 2016-03-02 23:09 GMT+09:00 Vlastimil Babka <vbabka@suse.cz>:
>> On 03/02/2016 02:57 PM, Joonsoo Kim wrote:
>>>
>>>
>>> Yes, I know.
>>> What I'd like to say here is that you need to care current_is_kswapd() in
>>> this patch. This patch unintentionally change the back ground compaction
>>> thread
>>> behaviour to restart compaction by every 64 trials because calling
>>> curret_is_kswapd()
>>
>>> by kcompactd would return false and is treated as direct reclaim.
>>
>> Oh, you mean this path to reset the skip bits. I see. But if skip bits are
>> already reset by kswapd when waking kcompactd, then effect of another (rare)
>> reset in kcompactd itself will be minimal?
> 
> If you care current_is_kswapd() in this patch properly (properly means change
> like "current_is_kcompactd()), reset in kswapd would not
> happen because, compact_blockskip_flush would not be set by kcompactd.
> 
> In this case, patch 5 would have it's own meaning so cannot be folded.

So I understand that patch 5 would be just about this?

-	if (compaction_restarting(zone, cc->order) && !current_is_kcompactd())
+	if (compaction_restarting(zone, cc->order))
 		__reset_isolation_suitable(zone);

I'm more inclined to fold it in that case. 

> Thanks.
> 
>>> Result of patch 4
>>> and patch 5 would be same.
>>
>>
>> It's certainly possible to fold patch 5 into 4. I posted them separately
>> mainly to make review more feasible. But the differences in results are
>> already quite small.
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

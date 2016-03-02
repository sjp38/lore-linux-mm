Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 61CF1828F2
	for <linux-mm@kvack.org>; Wed,  2 Mar 2016 09:09:37 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id l68so79512224wml.1
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 06:09:37 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j187si5046643wma.69.2016.03.02.06.09.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 02 Mar 2016 06:09:36 -0800 (PST)
Subject: Re: [PATCH v2 4/5] mm, kswapd: replace kswapd compaction with waking
 up kcompactd
References: <1454938691-2197-1-git-send-email-vbabka@suse.cz>
 <1454938691-2197-5-git-send-email-vbabka@suse.cz>
 <20160302063322.GB32695@js1304-P5Q-DELUXE> <56D6BACB.7060005@suse.cz>
 <CAAmzW4PHAsMvifgV2FpS_FYE78_PzDtADvoBY67usc_9-D4Hjg@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56D6F41D.9080107@suse.cz>
Date: Wed, 2 Mar 2016 15:09:33 +0100
MIME-Version: 1.0
In-Reply-To: <CAAmzW4PHAsMvifgV2FpS_FYE78_PzDtADvoBY67usc_9-D4Hjg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>

On 03/02/2016 02:57 PM, Joonsoo Kim wrote:
> 2016-03-02 19:04 GMT+09:00 Vlastimil Babka <vbabka@suse.cz>:
>> On 03/02/2016 07:33 AM, Joonsoo Kim wrote:
>>>
>>>
>>> Why you did the test with THP? THP interferes result of main test so
>>> it would be better not to enable it.
>>
>>
>> Hmm I've always left it enabled. It makes for a more realistic interference
>> and would also show unintended regressions in that closely related area.
>
> But, it makes review hard because complex analysis is needed to
> understand the result.
>
> Following is the example.
>
> "The compaction stalls
> (direct compaction) in the interfering kernel builds (probably THP's) also
> decreased somewhat to kcompactd activity, yet THP alloc successes improved a
> bit."
>
> So, why do we need this comment to understand effect of this patch? If you did
> a test without THP, it would not be necessary.

I see. Next time I'll do a run with THP disabled.

>>> And, this patch increased compaction activity (10 times for migrate
>>> scanned)
>>> may be due to resetting skip block information.
>>
>>
>> Note that kswapd compaction activity was completely non-existent for reasons
>> outlined in the changelog.
>>> Isn't is better to disable it
>>> for this patch to work as similar as possible that kswapd does and
>>> re-enable it
>>> on next patch? If something goes bad, it can simply be reverted.
>>>
>>> Look like it is even not mentioned in the description.
>>
>>
>> Yeah skip block information is discussed in the next patch, which mentions
>> that it's being reset and why. I think it makes more sense, as when kswapd
>
> Yes, I know.
> What I'd like to say here is that you need to care current_is_kswapd() in
> this patch. This patch unintentionally change the back ground compaction thread
> behaviour to restart compaction by every 64 trials because calling
> curret_is_kswapd()
 > by kcompactd would return false and is treated as direct reclaim.

Oh, you mean this path to reset the skip bits. I see. But if skip bits 
are already reset by kswapd when waking kcompactd, then effect of 
another (rare) reset in kcompactd itself will be minimal?

> Result of patch 4
> and patch 5 would be same.

It's certainly possible to fold patch 5 into 4. I posted them separately 
mainly to make review more feasible. But the differences in results are 
already quite small.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

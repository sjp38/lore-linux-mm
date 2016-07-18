Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id E84C26B0253
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 07:34:32 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id f126so56028166wma.3
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 04:34:32 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j17si14300702wmd.23.2016.07.18.04.34.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 18 Jul 2016 04:34:31 -0700 (PDT)
Subject: Re: [PATCH 3/8] mm, page_alloc: don't retry initial attempt in
 slowpath
References: <20160718112302.27381-1-vbabka@suse.cz>
 <20160718112302.27381-4-vbabka@suse.cz>
 <20160718112939.GH22671@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <6a427871-c1fb-77e7-2f45-1c4be436fa23@suse.cz>
Date: Mon, 18 Jul 2016 13:34:29 +0200
MIME-Version: 1.0
In-Reply-To: <20160718112939.GH22671@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>

On 07/18/2016 01:29 PM, Michal Hocko wrote:
> On Mon 18-07-16 13:22:57, Vlastimil Babka wrote:
>> After __alloc_pages_slowpath() sets up new alloc_flags and wakes up kswapd, it
>> first tries get_page_from_freelist() with the new alloc_flags, as it may
>> succeed e.g. due to using min watermark instead of low watermark. It makes
>> sense to to do this attempt before adjusting zonelist based on
>> alloc_flags/gfp_mask, as it's still relatively a fast path if we just wake up
>> kswapd and successfully allocate.
>>
>> This patch therefore moves the initial attempt above the retry label and
>> reorganizes a bit the part below the retry label. We still have to attempt
>> get_page_from_freelist() on each retry, as some allocations cannot do that
>> as part of direct reclaim or compaction, and yet are not allowed to fail
>> (even though they do a WARN_ON_ONCE() and thus should not exist). We can reuse
>> the call meant for ALLOC_NO_WATERMARKS attempt and just set alloc_flags to
>> ALLOC_NO_WATERMARKS if the context allows it. As a side-effect, the attempts
>> from direct reclaim/compaction will also no longer obey watermarks once this
>> is set, but there's little harm in that.
>>
>> Kswapd wakeups are also done on each retry to be safe from potential races
>> resulting in kswapd going to sleep while a process (that may not be able to
>> reclaim by itself) is still looping.
>>
>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
>
> Same here, my ack still holds
> Acked-by: Michal Hocko <mhocko@suse.com>

Sorry, forgot to add them before sending. Thanks for both!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

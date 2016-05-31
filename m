Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id DBE1C6B0253
	for <linux-mm@kvack.org>; Tue, 31 May 2016 03:59:39 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id w16so89925230lfd.0
        for <linux-mm@kvack.org>; Tue, 31 May 2016 00:59:39 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t134si35273561wmd.45.2016.05.31.00.59.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 31 May 2016 00:59:38 -0700 (PDT)
Subject: Re: [RFC 02/13] mm, page_alloc: set alloc_flags only once in slowpath
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
 <1462865763-22084-3-git-send-email-vbabka@suse.cz>
 <201605102028.AAC26596.SMHOQOtLOFFFVJ@I-love.SAKURA.ne.jp>
 <5731D453.8050104@suse.cz> <20160531062057.GA30967@js1304-P5Q-DELUXE>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <354b700b-0dee-32a8-2ee6-17a78ba299b8@suse.cz>
Date: Tue, 31 May 2016 09:59:36 +0200
MIME-Version: 1.0
In-Reply-To: <20160531062057.GA30967@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, riel@redhat.com, rientjes@google.com, mgorman@techsingularity.net, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

On 05/31/2016 08:20 AM, Joonsoo Kim wrote:
>> >From 68f09f1d4381c7451238b4575557580380d8bf30 Mon Sep 17 00:00:00 2001
>> From: Vlastimil Babka <vbabka@suse.cz>
>> Date: Fri, 29 Apr 2016 11:51:17 +0200
>> Subject: [RFC 02/13] mm, page_alloc: set alloc_flags only once in slowpath
>>
>> In __alloc_pages_slowpath(), alloc_flags doesn't change after it's initialized,
>> so move the initialization above the retry: label. Also make the comment above
>> the initialization more descriptive.
>>
>> The only exception in the alloc_flags being constant is ALLOC_NO_WATERMARKS,
>> which may change due to TIF_MEMDIE being set on the allocating thread. We can
>> fix this, and make the code simpler and a bit more effective at the same time,
>> by moving the part that determines ALLOC_NO_WATERMARKS from
>> gfp_to_alloc_flags() to gfp_pfmemalloc_allowed(). This means we don't have to
>> mask out ALLOC_NO_WATERMARKS in several places in __alloc_pages_slowpath()
>> anymore.  The only test for the flag can instead call gfp_pfmemalloc_allowed().
>
> Your patch looks correct to me but it makes me wonder something.
> Why do we need to mask out ALLOC_NO_WATERMARKS in several places? If
> some requestors have ALLOC_NO_WATERMARKS flag, he will
> eventually do ALLOC_NO_WATERMARKS allocation in retry loop. I don't
> understand what's the merit of masking out it.

I can think of a reason. If e.g. reclaim makes free pages above 
watermark in the 4th zone in the zonelist, we would like the subsequent 
get_page_from_freelist() to succeed in that 4th zone. Passing 
ALLOC_NO_WATERMARKS there would likely succeed in the first zone, 
needlessly below the watermark.

But this actually makes no difference, since the ALLOC_NO_WATERMARKS 
attempt precedes reclaim/compaction attempts. It probably shouldn't...

> Thanks.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

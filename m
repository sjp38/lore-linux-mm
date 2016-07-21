Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id A57796B0262
	for <linux-mm@kvack.org>; Thu, 21 Jul 2016 03:00:50 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id x83so6344720wma.2
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 00:00:50 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z6si1128841wmg.146.2016.07.21.00.00.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 21 Jul 2016 00:00:49 -0700 (PDT)
Subject: Re: [PATCH 2/8] mm, page_alloc: set alloc_flags only once in slowpath
References: <20160718112302.27381-1-vbabka@suse.cz>
 <20160718112302.27381-3-vbabka@suse.cz>
 <alpine.DEB.2.10.1607191527400.19940@chino.kir.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <49843a12-3b00-06f5-8645-098e875ec075@suse.cz>
Date: Thu, 21 Jul 2016 09:00:46 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1607191527400.19940@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>

On 07/20/2016 12:28 AM, David Rientjes wrote:
> On Mon, 18 Jul 2016, Vlastimil Babka wrote:
>
>> In __alloc_pages_slowpath(), alloc_flags doesn't change after it's initialized,
>> so move the initialization above the retry: label. Also make the comment above
>> the initialization more descriptive.
>>
>> The only exception in the alloc_flags being constant is ALLOC_NO_WATERMARKS,
>> which may change due to TIF_MEMDIE being set on the allocating thread. We can
>> fix this, and make the code simpler and a bit more effective at the same time,
>> by moving the part that determines ALLOC_NO_WATERMARKS from
>> gfp_to_alloc_flags() to gfp_pfmemalloc_allowed(). This means we don't have to
>> mask out ALLOC_NO_WATERMARKS in numerous places in __alloc_pages_slowpath()
>> anymore. The only two tests for the flag can instead call
>> gfp_pfmemalloc_allowed().
>>
>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
>
> Acked-by: David Rientjes <rientjes@google.com>
>
> Looks good, although maybe a new name for gfp_pfmemalloc_allowed() would
> be in order.

I don't disagree... any good suggestions? :)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

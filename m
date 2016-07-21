Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id EC940828E1
	for <linux-mm@kvack.org>; Thu, 21 Jul 2016 03:13:42 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id 33so46075241lfw.1
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 00:13:42 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id yq2si4462155wjb.244.2016.07.21.00.13.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 21 Jul 2016 00:13:41 -0700 (PDT)
Subject: Re: [PATCH 5/8] mm, page_alloc: make THP-specific decisions more
 generic
References: <20160718112302.27381-1-vbabka@suse.cz>
 <20160718112302.27381-6-vbabka@suse.cz>
 <alpine.DEB.2.10.1607191608550.19940@chino.kir.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <59bfd68b-2333-d762-6bc1-5f156e83c3d3@suse.cz>
Date: Thu, 21 Jul 2016 09:13:39 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1607191608550.19940@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>

On 07/20/2016 01:10 AM, David Rientjes wrote:
> On Mon, 18 Jul 2016, Vlastimil Babka wrote:
>
>> This means we can further distinguish allocations that are costly order *and*
>> additionally include the __GFP_NORETRY flag. As it happens, GFP_TRANSHUGE
>> allocations do already fall into this category. This will also allow other
>> costly allocations with similar high-order benefit vs latency considerations to
>> use this semantic. Furthermore, we can distinguish THP allocations that should
>> try a bit harder (such as from khugepageed) by removing __GFP_NORETRY, as will
>> be done in the next patch.
>>
>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
>> Acked-by: Michal Hocko <mhocko@suse.com>
>
> I think this is fine, but I would hope that we could check
> gfp_pfmemalloc_allowed() before compacting and failing even for costly
> orders when otherwise the first get_page_from_freelist() in the slowpath
> may have succeeded due to watermarks.

Hm ok, I will add it for the sake of avoiding goto nopage where 
previously it would have tried alloc without watermarks, as that would 
be unintended side-effect of the series... although I have some doubts 
about sanity of such scenarios (wants a costly order, can 
reclaim/compact but only with __GFP_NORETRY, yet is allowed to avoid 
watermarks?). Do you know about examples of such callers and think they 
do the right thing?

Thanks,
Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

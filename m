Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 98CA36B0253
	for <linux-mm@kvack.org>; Fri, 20 May 2016 09:57:12 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id k186so2054985lfe.3
        for <linux-mm@kvack.org>; Fri, 20 May 2016 06:57:12 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q9si25844129wjo.133.2016.05.20.06.57.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 20 May 2016 06:57:10 -0700 (PDT)
Subject: Re: [RFC 06/13] mm, thp: remove __GFP_NORETRY from khugepaged and
 madvised allocations
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
 <1462865763-22084-7-git-send-email-vbabka@suse.cz>
 <20160512162043.GA4261@dhcp22.suse.cz> <57358F03.5080707@suse.cz>
 <20160513120558.GL20141@dhcp22.suse.cz> <573C5939.1080909@suse.cz>
 <20160518152423.GK21654@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <573F17B4.70701@suse.cz>
Date: Fri, 20 May 2016 15:57:08 +0200
MIME-Version: 1.0
In-Reply-To: <20160518152423.GK21654@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On 05/18/2016 05:24 PM, Michal Hocko wrote:
>>   
>> So the following patch attempts what you suggest, if I understand you
>> correctly. GFP_TRANSHUGE includes all possible flag, and then they are
>> removed as needed. I don't really think it helps code readability
>> though.
> 
> yeah it is ugly has _hell_. I do not think this deserves too much time
> to discuss as the flag is mostly internal but one last proposal would be
> to define different THP allocations context explicitly. Some callers
> would still need some additional meddling but maybe it would be slightly
> better to read. Dunno. Anyway if you think this is not really an
> improvement then I won't insist on any change to your original patch.
> ---
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 570383a41853..e7926b466107 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -255,9 +255,14 @@ struct vm_area_struct;
>   #define GFP_DMA32	__GFP_DMA32
>   #define GFP_HIGHUSER	(GFP_USER | __GFP_HIGHMEM)
>   #define GFP_HIGHUSER_MOVABLE	(GFP_HIGHUSER | __GFP_MOVABLE)
> -#define GFP_TRANSHUGE	((GFP_HIGHUSER_MOVABLE | __GFP_COMP | \
> +
> +/* Optimistic or latency sensitive THP allocation - page fault path */
> +#define GFP_TRANSHUGE_LIGHT	((GFP_HIGHUSER_MOVABLE | __GFP_COMP | \
>   			 __GFP_NOMEMALLOC | __GFP_NORETRY | __GFP_NOWARN) & \
>   			 ~__GFP_RECLAIM)
> +/* More serious THP allocation request - kcompactd */
> +#define GFP_TRANSHUGE (GFP_TRANSHUGE_LIGHT | __GFP_DIRECT_RECLAIM) & \
> +			~__GFP_NORETRY

[...]

OK I took the core idea and arrived at the following. I think it could
work and the amount of further per-site modifications to GFP_TRANSHUGE*
is reduced, but if anyone think it's overkill to have two
GFP_TRANSHUGE*, I will just return to the original patch.

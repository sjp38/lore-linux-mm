Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id B13D96B0033
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 04:19:57 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id jz4so1339192wjb.5
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 01:19:57 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o64si1665309wmi.143.2017.01.18.01.19.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Jan 2017 01:19:56 -0800 (PST)
Date: Wed, 18 Jan 2017 10:19:55 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 0/4] fix premature OOM due to cpuset races
Message-ID: <20170118091955.GG7015@dhcp22.suse.cz>
References: <20170117221610.22505-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170117221610.22505-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@techsingularity.net>, Ganapatrao Kulkarni <gpkulkarni@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 17-01-17 23:16:06, Vlastimil Babka wrote:
> This is my attempt to fix the recent report based on LTP cpuset stress test [1].
> Patches are based on 4.9 as that was the initial reported version, but later
> it was reported that this problem exists since 4.7. We will probably want to
> go to stable with this, as triggering OOMs is not nice. That's why the patches
> try to be not too intrusive.
> 
> Longer-term we might try to think how to fix the cpuset mess in a better and
> less error prone way. I was for example very surprised to learn, that cpuset
> updates change not only task->mems_allowed, but also nodemask of mempolicies.
> Until now I expected the parameter to alloc_pages_nodemask() to be stable.
> I wonder why do we then treat cpusets specially in get_page_from_freelist()
> and distinguish HARDWALL etc, when there's unconditional intersection between
> mempolicy and cpuset. I would expect the nodemask adjustment for saving
> overhead in g_p_f(), but that clearly doesn't happen in the current form.
> So we have both crazy complexity and overhead, AFAICS.

Absolutely agreed! This is a mess which should be fixed and nodemask
should be stable for each allocation attempt. Trying to catch up with
concurrent changes is just insane and makes the code more complicated.

> [1] https://lkml.kernel.org/r/CAFpQJXUq-JuEP=QPidy4p_=FN0rkH5Z-kfB4qBvsf6jMS87Edg@mail.gmail.com
> 
> Vlastimil Babka (4):
>   mm, page_alloc: fix check for NULL preferred_zone
>   mm, page_alloc: fix fast-path race with cpuset update or removal
>   mm, page_alloc: move cpuset seqcount checking to slowpath
>   mm, page_alloc: fix premature OOM when racing with cpuset mems update
> 
>  mm/page_alloc.c | 58 ++++++++++++++++++++++++++++++++++++---------------------
>  1 file changed, 37 insertions(+), 21 deletions(-)
> 
> -- 
> 2.11.0

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

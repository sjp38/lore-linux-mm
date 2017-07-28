Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1C4DE6B0545
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 09:15:07 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id e204so12755012wma.2
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 06:15:07 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o73si13061119wmi.82.2017.07.28.06.15.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 28 Jul 2017 06:15:06 -0700 (PDT)
Subject: Re: [RFC PATCH] treewide: remove GFP_TEMPORARY allocation flag
References: <20170728091904.14627-1-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <7ba2635d-68bd-ee1a-caa2-3ff571c7a3ee@suse.cz>
Date: Fri, 28 Jul 2017 15:15:03 +0200
MIME-Version: 1.0
In-Reply-To: <20170728091904.14627-1-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Mel Gorman <mgorman@suse.de>, Matthew Wilcox <willy@infradead.org>, Neil Brown <neilb@suse.de>, Theodore Ts'o <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 07/28/2017 11:19 AM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> GFP_TEMPORARY has been introduced by e12ba74d8ff3 ("Group short-lived
> and reclaimable kernel allocations") along with __GFP_RECLAIMABLE. It's
> primary motivation was to allow users to tell that an allocation is
> short lived and so the allocator can try to place such allocations close
> together and prevent long term fragmentation. As much as this sounds
> like a reasonable semantic it becomes much less clear when to use the
> highlevel GFP_TEMPORARY allocation flag. How long is temporary? Can
> the context holding that memory sleep? Can it take locks? It seems
> there is no good answer for those questions.
> 
> The current implementation of GFP_TEMPORARY is basically
> GFP_KERNEL | __GFP_RECLAIMABLE which in itself is tricky because
> basically none of the existing caller provide a way to reclaim the
> allocated memory. So this is rather misleading and hard to evaluate for
> any benefits.
> 
> I have checked some random users and none of them has added the flag
> with a specific justification. I suspect most of them just copied from
> other existing users and others just thought it might be a good idea
> to use without any measuring. This suggests that GFP_TEMPORARY just
> motivates for cargo cult usage without any reasoning.
> 
> I believe that our gfp flags are quite complex already and especially
> those with highlevel semantic should be clearly defined to prevent from
> confusion and abuse. Therefore I propose dropping GFP_TEMPORARY and
> replace all existing users to simply use GFP_KERNEL. Please note that
> SLAB users with shrinkers will still get __GFP_RECLAIMABLE heuristic
> and so they will be placed properly for memory fragmentation prevention.
> 
> I can see reasons we might want some gfp flag to reflect shorterm
> allocations but I propose starting from a clear semantic definition and
> only then add users with proper justification.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Yes, it's best we remove it.

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

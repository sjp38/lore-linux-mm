Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 307F46B0038
	for <linux-mm@kvack.org>; Fri,  2 Dec 2016 02:23:28 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id o3so43218920wjo.1
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 23:23:28 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id mn20si4010185wjb.216.2016.12.01.23.23.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Dec 2016 23:23:26 -0800 (PST)
Subject: Re: [PATCH 2/2] mm, oom: do not enfore OOM killer for __GFP_NOFAIL
 automatically
References: <20161201152517.27698-1-mhocko@kernel.org>
 <20161201152517.27698-3-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <f7ac6711-4c9b-5603-7901-ae90a56a0d1a@suse.cz>
Date: Fri, 2 Dec 2016 08:23:24 +0100
MIME-Version: 1.0
In-Reply-To: <20161201152517.27698-3-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 12/01/2016 04:25 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> __alloc_pages_may_oom makes sure to skip the OOM killer depending on
> the allocation request. This includes lowmem requests, costly high
> order requests and others. For a long time __GFP_NOFAIL acted as an
> override for all those rules. This is not documented and it can be quite
> surprising as well. E.g. GFP_NOFS requests are not invoking the OOM
> killer but GFP_NOFS|__GFP_NOFAIL does so if we try to convert some of
> the existing open coded loops around allocator to nofail request (and we
> have done that in the past) then such a change would have a non trivial
> side effect which is not obvious. Note that the primary motivation for
> skipping the OOM killer is to prevent from pre-mature invocation.
>
> The exception has been added by 82553a937f12 ("oom: invoke oom killer
> for __GFP_NOFAIL"). The changelog points out that the oom killer has to
> be invoked otherwise the request would be looping for ever. But this
> argument is rather weak because the OOM killer doesn't really guarantee
> any forward progress for those exceptional cases - e.g. it will hardly
> help to form costly order - I believe we certainly do not want to kill
> all processes and eventually panic the system just because there is a
> nasty driver asking for order-9 page with GFP_NOFAIL not realizing all
> the consequences - it is much better this request would loop for ever
> than the massive system disruption, lowmem is also highly unlikely to be
> freed during OOM killer and GFP_NOFS request could trigger while there
> is still a lot of memory pinned by filesystems.
>
> This patch simply removes the __GFP_NOFAIL special case in order to have
> a more clear semantic without surprising side effects. Instead we do
> allow nofail requests to access memory reserves to move forward in both
> cases when the OOM killer is invoked and when it should be supressed.
> __alloc_pages_nowmark helper has been introduced for that purpose.
>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

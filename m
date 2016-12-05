Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id C6A1F6B0038
	for <linux-mm@kvack.org>; Mon,  5 Dec 2016 08:45:34 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id j198so551951902oih.5
        for <linux-mm@kvack.org>; Mon, 05 Dec 2016 05:45:34 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 5si7008182ota.119.2016.12.05.05.45.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 05 Dec 2016 05:45:33 -0800 (PST)
Subject: Re: [PATCH 2/2] mm, oom: do not enfore OOM killer for __GFP_NOFAIL automatically
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20161201152517.27698-1-mhocko@kernel.org>
	<20161201152517.27698-3-mhocko@kernel.org>
In-Reply-To: <20161201152517.27698-3-mhocko@kernel.org>
Message-Id: <201612052245.HDB21880.OHJMOOQFFSVLtF@I-love.SAKURA.ne.jp>
Date: Mon, 5 Dec 2016 22:45:19 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org
Cc: vbabka@suse.cz, hannes@cmpxchg.org, mgorman@suse.de, rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.com

Michal Hocko wrote:
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

I disagree. I believe that panic caused by OOM killer is much much better
than a locked up system. I hate to add new locations that can lockup inside
page allocator. This is __GFP_NOFAIL and reclaim has failed. Administrator
has to go in front of console and press SysRq-f until locked up situation
gets resolved is silly.

If there is a nasty driver asking for order-9 page with __GFP_NOFAIL, fix
that driver.

> 
> This patch simply removes the __GFP_NOFAIL special case in order to have
> a more clear semantic without surprising side effects. Instead we do
> allow nofail requests to access memory reserves to move forward in both
> cases when the OOM killer is invoked and when it should be supressed.
> __alloc_pages_nowmark helper has been introduced for that purpose.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

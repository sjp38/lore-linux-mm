Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id B27746B0253
	for <linux-mm@kvack.org>; Mon,  5 Dec 2016 09:10:13 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id o3so63970530wjo.1
        for <linux-mm@kvack.org>; Mon, 05 Dec 2016 06:10:13 -0800 (PST)
Received: from mail-wj0-f196.google.com (mail-wj0-f196.google.com. [209.85.210.196])
        by mx.google.com with ESMTPS id c133si241064wme.54.2016.12.05.06.10.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Dec 2016 06:10:12 -0800 (PST)
Received: by mail-wj0-f196.google.com with SMTP id he10so25333483wjc.2
        for <linux-mm@kvack.org>; Mon, 05 Dec 2016 06:10:12 -0800 (PST)
Date: Mon, 5 Dec 2016 15:10:10 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm, oom: do not enfore OOM killer for __GFP_NOFAIL
 automatically
Message-ID: <20161205141009.GJ30758@dhcp22.suse.cz>
References: <20161201152517.27698-1-mhocko@kernel.org>
 <20161201152517.27698-3-mhocko@kernel.org>
 <201612052245.HDB21880.OHJMOOQFFSVLtF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201612052245.HDB21880.OHJMOOQFFSVLtF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, hannes@cmpxchg.org, mgorman@suse.de, rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 05-12-16 22:45:19, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > __alloc_pages_may_oom makes sure to skip the OOM killer depending on
> > the allocation request. This includes lowmem requests, costly high
> > order requests and others. For a long time __GFP_NOFAIL acted as an
> > override for all those rules. This is not documented and it can be quite
> > surprising as well. E.g. GFP_NOFS requests are not invoking the OOM
> > killer but GFP_NOFS|__GFP_NOFAIL does so if we try to convert some of
> > the existing open coded loops around allocator to nofail request (and we
> > have done that in the past) then such a change would have a non trivial
> > side effect which is not obvious. Note that the primary motivation for
> > skipping the OOM killer is to prevent from pre-mature invocation.
> > 
> > The exception has been added by 82553a937f12 ("oom: invoke oom killer
> > for __GFP_NOFAIL"). The changelog points out that the oom killer has to
> > be invoked otherwise the request would be looping for ever. But this
> > argument is rather weak because the OOM killer doesn't really guarantee
> > any forward progress for those exceptional cases - e.g. it will hardly
> > help to form costly order - I believe we certainly do not want to kill
> > all processes and eventually panic the system just because there is a
> > nasty driver asking for order-9 page with GFP_NOFAIL not realizing all
> > the consequences - it is much better this request would loop for ever
> > than the massive system disruption, lowmem is also highly unlikely to be
> > freed during OOM killer and GFP_NOFS request could trigger while there
> > is still a lot of memory pinned by filesystems.
> 
> I disagree. I believe that panic caused by OOM killer is much much better
> than a locked up system. I hate to add new locations that can lockup inside
> page allocator. This is __GFP_NOFAIL and reclaim has failed.

As a matter of fact any __GFP_NOFAIL can lockup inside the allocator.
Full stop. There is no guaranteed way to make a forward progress with
the current page allocator implementation.

So we are somewhere in the middle between pre-mature and pointless
system disruption (GFP_NOFS with a lots of metadata or lowmem request)
where the OOM killer even might not help and potential lockup which is
inevitable with the current design. Dunno about you but I would rather
go with the first option. To be honest I really fail to understand your
line of argumentation. We have this
	do {
		cond_resched();
	} (page = alloc_page(GFP_NOFS));
vs.
	page = alloc_page(GFP_NOFS | __GFP_NOFAIL);

the first one doesn't invoke OOM killer while the later does. This
discrepancy just cannot make any sense... The same is true for

	alloc_page(GFP_DMA) vs alloc_page(GFP_DMA|__GFP_NOFAIL)

Now we can discuss whether it is a _good_ idea to not invoke OOM killer
for those exceptions but whatever we do __GFP_NOFAIL is not a way to
give such a subtle side effect. Or do you disagree even with that?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

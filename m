Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 244176B0038
	for <linux-mm@kvack.org>; Tue,  6 Dec 2016 14:25:48 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id w13so28862888wmw.0
        for <linux-mm@kvack.org>; Tue, 06 Dec 2016 11:25:48 -0800 (PST)
Received: from mail-wj0-f194.google.com (mail-wj0-f194.google.com. [209.85.210.194])
        by mx.google.com with ESMTPS id sj4si21016157wjb.0.2016.12.06.11.25.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Dec 2016 11:25:47 -0800 (PST)
Received: by mail-wj0-f194.google.com with SMTP id j10so18344194wjb.3
        for <linux-mm@kvack.org>; Tue, 06 Dec 2016 11:25:46 -0800 (PST)
Date: Tue, 6 Dec 2016 20:25:45 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm, oom: do not enfore OOM killer for __GFP_NOFAIL
 automatically
Message-ID: <20161206192544.GB10273@dhcp22.suse.cz>
References: <20161201152517.27698-1-mhocko@kernel.org>
 <20161201152517.27698-3-mhocko@kernel.org>
 <201612052245.HDB21880.OHJMOOQFFSVLtF@I-love.SAKURA.ne.jp>
 <20161205141009.GJ30758@dhcp22.suse.cz>
 <201612061938.DDD73970.QFHOFJStFOLVOM@I-love.SAKURA.ne.jp>
 <01a495b8-36f6-28f5-5a55-089f4860747d@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <01a495b8-36f6-28f5-5a55-089f4860747d@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 06-12-16 12:03:02, Vlastimil Babka wrote:
> On 12/06/2016 11:38 AM, Tetsuo Handa wrote:
> >>
> >> So we are somewhere in the middle between pre-mature and pointless
> >> system disruption (GFP_NOFS with a lots of metadata or lowmem request)
> >> where the OOM killer even might not help and potential lockup which is
> >> inevitable with the current design. Dunno about you but I would rather
> >> go with the first option. To be honest I really fail to understand your
> >> line of argumentation. We have this
> >> 	do {
> >> 		cond_resched();
> >> 	} while (!(page = alloc_page(GFP_NOFS)));
> >> vs.
> >> 	page = alloc_page(GFP_NOFS | __GFP_NOFAIL);
> >>
> >> the first one doesn't invoke OOM killer while the later does. This
> >> discrepancy just cannot make any sense... The same is true for
> >>
> >> 	alloc_page(GFP_DMA) vs alloc_page(GFP_DMA|__GFP_NOFAIL)
> >>
> >> Now we can discuss whether it is a _good_ idea to not invoke OOM killer
> >> for those exceptions but whatever we do __GFP_NOFAIL is not a way to
> >> give such a subtle side effect. Or do you disagree even with that?
> > 
> > "[PATCH 1/2] mm: consolidate GFP_NOFAIL checks in the allocator slowpath"
> > silently changes __GFP_NOFAIL vs. __GFP_NORETRY priority.
> 
> I guess that wasn't intended?

I even didn't think about that possibility because it just doesn't make
any sense.

> > Currently, __GFP_NORETRY is stronger than __GFP_NOFAIL; __GFP_NOFAIL
> > allocation requests fail without invoking the OOM killer when both
> > __GFP_NORETRY and __GFP_NOFAIL are given.
> > 
> > With [PATCH 1/2], __GFP_NOFAIL becomes stronger than __GFP_NORETRY;
> > __GFP_NOFAIL allocation requests will loop forever without invoking
> > the OOM killer when both __GFP_NORETRY and __GFP_NOFAIL are given.
> 
> Does such combination of flag make sense? Should we warn about it, or
> even silently remove __GFP_NORETRY in such case?

No this combination doesn't make any sense. I seriously doubt we should
even care about it and simply following the stronger requirement makes
more sense from a semantic point of view.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

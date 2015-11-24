Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id ED0F06B0038
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 05:03:09 -0500 (EST)
Received: by wmuu63 with SMTP id u63so88891266wmu.0
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 02:03:09 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v79si25571940wmv.95.2015.11.24.02.03.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 24 Nov 2015 02:03:08 -0800 (PST)
Date: Tue, 24 Nov 2015 11:03:05 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 1/3] mm, oom: refactor oom detection
Message-ID: <20151124100305.GB29472@dhcp22.suse.cz>
References: <1447851840-15640-1-git-send-email-mhocko@kernel.org>
 <1447851840-15640-2-git-send-email-mhocko@kernel.org>
 <alpine.DEB.2.10.1511191455310.17510@chino.kir.corp.google.com>
 <20151120090626.GB16698@dhcp22.suse.cz>
 <alpine.DEB.2.10.1511201523520.10092@chino.kir.corp.google.com>
 <20151123094106.GD21050@dhcp22.suse.cz>
 <20151123182447.GF13000@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151123182447.GF13000@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Mon 23-11-15 13:24:47, Johannes Weiner wrote:
> On Mon, Nov 23, 2015 at 10:41:06AM +0100, Michal Hocko wrote:
> > @@ -3197,8 +3197,10 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >  		unsigned long target;
> >  
> >  		reclaimable = zone_reclaimable_pages(zone) +
> > -			      zone_page_state(zone, NR_ISOLATED_FILE) +
> > -			      zone_page_state(zone, NR_ISOLATED_ANON);
> > +			      zone_page_state(zone, NR_ISOLATED_FILE);
> > +		if (get_nr_swap_pages() > 0)
> > +			reclaimable += zone_page_state(zone, NR_ISOLATED_ANON);
> 
> Can you include the isolated counts in zone_reclaimable_pages()?

OK, this makes sense. NR_ISOLATED_* should be a temporary condition
after which pages either get back to the LRU or they get migrated to a
different location thus freed.

I will spin this intot a separate patch.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

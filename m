Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 049B782F64
	for <linux-mm@kvack.org>; Fri, 30 Oct 2015 04:36:29 -0400 (EDT)
Received: by wmec75 with SMTP id c75so6237449wme.1
        for <linux-mm@kvack.org>; Fri, 30 Oct 2015 01:36:28 -0700 (PDT)
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com. [74.125.82.49])
        by mx.google.com with ESMTPS id mc1si7541262wjb.112.2015.10.30.01.36.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Oct 2015 01:36:28 -0700 (PDT)
Received: by wmll128 with SMTP id l128so6272484wml.0
        for <linux-mm@kvack.org>; Fri, 30 Oct 2015 01:36:27 -0700 (PDT)
Date: Fri, 30 Oct 2015 09:36:26 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 1/3] mm, oom: refactor oom detection
Message-ID: <20151030083626.GC18429@dhcp22.suse.cz>
References: <1446131835-3263-1-git-send-email-mhocko@kernel.org>
 <1446131835-3263-2-git-send-email-mhocko@kernel.org>
 <00f201d112c8$e2377720$a6a66560$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <00f201d112c8$e2377720$a6a66560$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: linux-mm@kvack.org, 'Andrew Morton' <akpm@linux-foundation.org>, 'Linus Torvalds' <torvalds@linux-foundation.org>, 'Mel Gorman' <mgorman@suse.de>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Rik van Riel' <riel@redhat.com>, 'David Rientjes' <rientjes@google.com>, 'Tetsuo Handa' <penguin-kernel@I-love.SAKURA.ne.jp>, 'LKML' <linux-kernel@vger.kernel.org>

On Fri 30-10-15 12:10:15, Hillf Danton wrote:
[...]
> > +	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist, ac->high_zoneidx, ac->nodemask) {
> > +		unsigned long free = zone_page_state(zone, NR_FREE_PAGES);
> > +		unsigned long reclaimable;
> > +		unsigned long target;
> > +
> > +		reclaimable = zone_reclaimable_pages(zone) +
> > +			      zone_page_state(zone, NR_ISOLATED_FILE) +
> > +			      zone_page_state(zone, NR_ISOLATED_ANON);
> > +		target = reclaimable;
> > +		target -= stall_backoff * (1 + target/MAX_STALL_BACKOFF);
> 
> 		target = reclaimable - stall_backoff * (1 + target/MAX_STALL_BACKOFF);
> 		             = reclaimable - stall_backoff - stall_backoff  * (target/MAX_STALL_BACKOFF);
> 
> then the first stall_backoff looks unreasonable.

First stall_backoff is off by 1 but that shouldn't make any difference.

> I guess you mean
> 		target	= reclaimable - target * (stall_backoff/MAX_STALL_BACKOFF);
> 			= reclaimable - stall_back * (target/MAX_STALL_BACKOFF);

No the reason I used the bias is to converge for MAX_STALL_BACKOFF. If
you have target which is not divisible by MAX_STALL_BACKOFF then the
rounding would get target > 0 and so we wouldn't converge. With the +1
you underflow which is MAX_STALL_BACKOFF in maximum which should be
fixed up by the free memory. Maybe a check for free < MAX_STALL_BACKOFF
would be good but I didn't get that far with this.

[...]

> /*
> > @@ -2734,10 +2730,6 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
> >  		goto retry;
> >  	}
> > 
> > -	/* Any of the zones still reclaimable?  Don't OOM. */
> > -	if (zones_reclaimable)
> > -		return 1;
> > -
> 
> Looks cleanup of zones_reclaimable left.

Removed. Thanks!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 98B086B0005
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 04:31:10 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id fl4so8900876pad.0
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 01:31:10 -0800 (PST)
Received: from mail-pf0-x22d.google.com (mail-pf0-x22d.google.com. [2607:f8b0:400e:c00::22d])
        by mx.google.com with ESMTPS id bw10si3531776pac.157.2016.03.08.01.31.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Mar 2016 01:31:09 -0800 (PST)
Received: by mail-pf0-x22d.google.com with SMTP id x188so9017311pfb.2
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 01:31:09 -0800 (PST)
Date: Tue, 8 Mar 2016 18:32:30 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm, oom: protect !costly allocations some more
Message-ID: <20160308093230.GB3860@swordfish>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <20160203132718.GI6757@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602241832160.15564@eggly.anvils>
 <20160225092315.GD17573@dhcp22.suse.cz>
 <20160229210213.GX16930@dhcp22.suse.cz>
 <20160307160838.GB5028@dhcp22.suse.cz>
 <56DE9A68.2010301@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56DE9A68.2010301@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <js1304@gmail.com>

On (03/08/16 10:24), Vlastimil Babka wrote:
[..]
> > @@ -3294,6 +3289,18 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >  				 did_some_progress > 0, no_progress_loops))
> >  		goto retry;
> >  
> > +	/*
> > +	 * !costly allocations are really important and we have to make sure
> > +	 * the compaction wasn't deferred or didn't bail out early due to locks
> > +	 * contention before we go OOM.
> > +	 */
> > +	if (order && order <= PAGE_ALLOC_COSTLY_ORDER) {
> > +		if (compact_result <= COMPACT_CONTINUE)
> 
> Same here.
> I was going to say that this didn't have effect on Sergey's test, but
> turns out it did :)

I'm sorry, my test is not correct. I have disabled compaction last weeked on
purpose - to provoke more OOM-kills and OOM conditions for reworked printk()
patch set testing (http://marc.info/?l=linux-kernel&m=145734549308803); and I
forgot to re-enable it.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

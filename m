Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9BB9B6B0038
	for <linux-mm@kvack.org>; Thu, 15 Dec 2016 05:28:42 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id q10so96476344pgq.7
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 02:28:42 -0800 (PST)
Received: from mail-pg0-f66.google.com (mail-pg0-f66.google.com. [74.125.83.66])
        by mx.google.com with ESMTPS id r14si1816436pfb.184.2016.12.15.02.28.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Dec 2016 02:28:41 -0800 (PST)
Received: by mail-pg0-f66.google.com with SMTP id e9so5804435pgc.1
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 02:28:41 -0800 (PST)
Date: Thu, 15 Dec 2016 11:28:38 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH v2] mm: consolidate GFP_NOFAIL checks in the allocator
 slowpath
Message-ID: <20161215102838.GA8602@dhcp22.suse.cz>
References: <20161214150706.27412-1-mhocko@kernel.org>
 <04b001d256a8$7bc813d0$73583b70$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <04b001d256a8$7bc813d0$73583b70$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Vlastimil Babka' <vbabka@suse.cz>, 'Tetsuo Handa' <penguin-kernel@I-love.SAKURA.ne.jp>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Mel Gorman' <mgorman@suse.de>, 'David Rientjes' <rientjes@google.com>, linux-mm@kvack.org, 'LKML' <linux-kernel@vger.kernel.org>

On Thu 15-12-16 15:54:37, Hillf Danton wrote:
> On Wednesday, December 14, 2016 11:07 PM Michal Hocko wrote: 
[...]
> >  	/* Avoid allocations with no watermarks from looping endlessly */
> > -	if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
> > +	if (test_thread_flag(TIF_MEMDIE))
> >  		goto nopage;
> > 
> Nit: currently we allow TIF_MEMDIE & __GFP_NOFAIL request to
> try direct reclaim. Are you intentionally reclaiming that chance?

That is definitely not a nit! Thanks for catching that. We definitely
shouldn't bypass the direct reclaim because that would mean we rely on
somebody else makes progress for us.

Updated patch below:
--- 

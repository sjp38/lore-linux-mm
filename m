Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 717016B0005
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 08:23:23 -0400 (EDT)
Received: by mail-wm0-f49.google.com with SMTP id a140so51438601wma.0
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 05:23:23 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id e14si34063513wjz.208.2016.04.12.05.23.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Apr 2016 05:23:22 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id y144so4881704wmd.0
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 05:23:22 -0700 (PDT)
Date: Tue, 12 Apr 2016 14:23:20 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 09/11] mm, compaction: Abstract compaction feedback to
 helpers
Message-ID: <20160412122320.GD10771@dhcp22.suse.cz>
References: <1459855533-4600-1-git-send-email-mhocko@kernel.org>
 <1459855533-4600-10-git-send-email-mhocko@kernel.org>
 <570BB719.2030007@suse.cz>
 <20160411151410.GL23157@dhcp22.suse.cz>
 <570CE1CB.7070106@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <570CE1CB.7070106@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Joonsoo Kim <js1304@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 12-04-16 13:53:47, Vlastimil Babka wrote:
> On 04/11/2016 05:14 PM, Michal Hocko wrote:
> >On Mon 11-04-16 16:39:21, Vlastimil Babka wrote:
> >>On 04/05/2016 01:25 PM, Michal Hocko wrote:
> >[...]
> >>>+/* Compaction has failed and it doesn't make much sense to keep retrying. */
> >>>+static inline bool compaction_failed(enum compact_result result)
> >>>+{
> >>>+	/* All zones where scanned completely and still not result. */
> >>
> >>Hmm given that try_to_compact_pages() uses a max() on results, then in fact
> >>it takes only one zone to get this. Others could have been also SKIPPED or
> >>DEFERRED. Is that what you want?
> >
> >In short I didn't find any better way and still guarantee a some
> >guarantee of convergence. COMPACT_COMPLETE means that at least one zone
> >was completely scanned and led to no result. That zone would be
> >compact_suitable by definition. If I made DEFERRED or SKIPPED more
> >priorite (aka higher in the enum) then I could easily end up in a state
> >where all zones would return COMPACT_COMPLETE and few remaining would
> >just alternate returning their DEFFERED resp. SKIPPED. So while this
> >might sound like giving up too early I couldn't come up with anything
> >more specific that would lead to reliable results.
> >
> >I am open to any suggestions of course.
> 
> I guess you would have to track each zone separately and make sure you've
> seen COMPACT_COMPLETE in all of them, although not necessary during the same
> zonelist attempt. But then do the same for reclaim, as you would also have
> to match COMPAT_SKIPPED and inability of reclaim... and that gets uglier and
> uglier, and also against the move to node-based reclaim...

I think we want to get rid some of these states long term. Or at least
do not defer or skip for small orders that really matter and are nofail
in fact. But I cannot tell I would understand the defer logic enought to
do it right now.

> So there's a danger that you'll see COMPACT_COMPLETE on a small ZONE_DMA
> early on, before the larger zones even stop being deferred, but I don't see
> an easy solution.

ZONE_DMA should back off most of the time due to watermark checks. But
it is true that we might a small zone which is not protected by lowmem
reserves.

I certainly see a lot of room for improving the compaction and this
rework looks like a good motivation.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 975386B0278
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 04:26:30 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id l138so9887372wmg.3
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 01:26:30 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id e5si2162603wmd.141.2016.09.23.01.26.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Sep 2016 01:26:29 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id w84so1526266wmg.0
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 01:26:29 -0700 (PDT)
Date: Fri, 23 Sep 2016 10:26:28 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/4] reintroduce compaction feedback for OOM decisions
Message-ID: <20160923082627.GE4478@dhcp22.suse.cz>
References: <20160906135258.18335-1-vbabka@suse.cz>
 <20160921171830.GH24210@dhcp22.suse.cz>
 <56f2c2ed-8a58-cf9c-dd00-c0d0e274607a@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56f2c2ed-8a58-cf9c-dd00-c0d0e274607a@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Olaf Hering <olaf@aepfle.de>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Rik van Riel <riel@redhat.com>

On Thu 22-09-16 17:18:48, Vlastimil Babka wrote:
> On 09/21/2016 07:18 PM, Michal Hocko wrote:
> > On Tue 06-09-16 15:52:54, Vlastimil Babka wrote:
> > 
> > We still do not ignore fragindex in the full priority. This part has
> > always been quite unclear to me so I cannot really tell whether that
> > makes any difference or not but just to be on the safe side I would
> > preffer to have _all_ the shortcuts out of the way in the highest
> > priority. It is true that this will cause COMPACT_NOT_SUITABLE_ZONE
> > so keep retrying but still a complication to understand the workflow.
> > 
> > What do you think?
>  
> I was thinking that this shouldn't be a problem on non-costly orders and default
> extfrag_threshold. But better be safe. Moreover I think the issue is much more
> dangerous for compact_zonelist_suitable() as explained below.
> 
> ----8<----
> >From 0e6cb251aa6e3b1be7deff315c0238c4d478f22e Mon Sep 17 00:00:00 2001
> From: Vlastimil Babka <vbabka@suse.cz>
> Date: Thu, 22 Sep 2016 15:33:57 +0200
> Subject: [PATCH] mm, compaction: ignore fragindex on highest direct compaction
>  priority
> 
> Fragmentation index check in compaction_suitable() should be the last heuristic
> that we allow on the highest compaction priority. Since that's a potential
> premature OOM, disable it too. Even more problematic is its usage from
> compaction_zonelist_suitable() -> __compaction_suitable() where we check the
> order-0 watermark against free plus available-for-reclaim pages, but the
> fragindex considers only truly free pages. Thus we can get a result close to 0
> indicating failure do to lack of memory, and wrongly decide that compaction
> won't be suitable even after reclaim. The solution is to skip the fragindex
> check also in this context, regardless of priority.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> ---
>  include/linux/compaction.h |  5 +++--
>  mm/compaction.c            | 44 +++++++++++++++++++++++---------------------
>  mm/internal.h              |  1 +
>  mm/vmscan.c                |  6 ++++--
>  4 files changed, 31 insertions(+), 25 deletions(-)

This is much more code churn than I expected. I was thiking about it
some more and I am really wondering whether it actually make any sense
to check the fragidx for !costly orders. Wouldn't it be much simpler to
just put it out of the way for those regardless of the compaction
priority. In other words does this check makes any measurable difference
for !costly orders?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

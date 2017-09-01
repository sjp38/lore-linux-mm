Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id BB3986B025F
	for <linux-mm@kvack.org>; Fri,  1 Sep 2017 11:17:11 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id u206so884216oif.5
        for <linux-mm@kvack.org>; Fri, 01 Sep 2017 08:17:11 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id w9si280456oib.470.2017.09.01.08.17.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Sep 2017 08:17:10 -0700 (PDT)
Subject: Re: [PATCH] mm,page_alloc: apply gfp_allowed_mask before the first allocation attempt.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1504275091-4427-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20170901142845.nqcn2na4vy6giyhm@dhcp22.suse.cz>
In-Reply-To: <20170901142845.nqcn2na4vy6giyhm@dhcp22.suse.cz>
Message-Id: <201709020016.ADJ21342.OFLJHOOSMFVtFQ@I-love.SAKURA.ne.jp>
Date: Sat, 2 Sep 2017 00:16:58 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, vbabka@suse.cz, brouer@redhat.com, mgorman@techsingularity.net

Michal Hocko wrote:
> On Fri 01-09-17 23:11:31, Tetsuo Handa wrote:
> > We are by error initializing alloc_flags before gfp_allowed_mask is
> > applied. Apply gfp_allowed_mask before initializing alloc_flags so that
> > the first allocation attempt uses correct flags.
> 
> It would be worth noting that this will not matter in most cases,
> actually when only the node reclaim is enabled we can misbehave because
> NOFS request for PM paths would be ignored.
> 
> > Fixes: 9cd7555875bb09da ("mm, page_alloc: split alloc_pages_nodemask()")
> 
> AFAICS this patch hasn't changed the logic and it was broken since
> 83d4ca8148fd ("mm, page_alloc: move __GFP_HARDWALL modifications out of
> the fastpath")

Indeed. Updated patch follows.

> 
> > Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > Cc: Mel Gorman <mgorman@techsingularity.net>
> > Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
> > Cc: Vlastimil Babka <vbabka@suse.cz>
> > Cc: Jesper Dangaard Brouer <brouer@redhat.com>
> 
> Other than that this looks correct to me. 
> Acked-by: Michal Hocko <mhocko@suse.com>
> 
> I wish we can finally get rid of gfp_allowed_mask. I have it on my todo
> list but never got to it.
> 
> Thanks!
> 
----------
>From b454863bea884158a25460aa29a26c5feb16fe94 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Fri, 1 Sep 2017 23:11:31 +0900
Subject: [PATCH v2] mm,page_alloc: apply gfp_allowed_mask before the first
 allocation attempt.

We are by error initializing alloc_flags before gfp_allowed_mask is
applied. This could cause problems after pm_restrict_gfp_mask() is
called during suspend operation. Apply gfp_allowed_mask before
initializing alloc_flags so that the first allocation attempt uses
correct flags.

Fixes: 83d4ca8148fd9092 ("mm, page_alloc: move __GFP_HARDWALL modifications out of the fastpath")
Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Acked-by: Michal Hocko <mhocko@suse.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
---
 mm/page_alloc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6dbc49e..a123dee 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4179,10 +4179,11 @@ struct page *
 {
 	struct page *page;
 	unsigned int alloc_flags = ALLOC_WMARK_LOW;
-	gfp_t alloc_mask = gfp_mask; /* The gfp_t that was actually used for allocation */
+	gfp_t alloc_mask; /* The gfp_t that was actually used for allocation */
 	struct alloc_context ac = { };
 
 	gfp_mask &= gfp_allowed_mask;
+	alloc_mask = gfp_mask;
 	if (!prepare_alloc_pages(gfp_mask, order, preferred_nid, nodemask, &ac, &alloc_mask, &alloc_flags))
 		return NULL;
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

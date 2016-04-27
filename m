Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f197.google.com (mail-ob0-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id E05D06B0253
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 20:59:30 -0400 (EDT)
Received: by mail-ob0-f197.google.com with SMTP id u2so56737044obx.0
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 17:59:30 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id g139si6239827iog.99.2016.04.26.17.59.29
        for <linux-mm@kvack.org>;
        Tue, 26 Apr 2016 17:59:30 -0700 (PDT)
Date: Wed, 27 Apr 2016 09:59:28 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH mmotm 3/3] mm, compaction: prevent nr_isolated_* from
 going negative
Message-ID: <20160427005927.GC6336@js1304-P5Q-DELUXE>
References: <1461591269-28615-1-git-send-email-vbabka@suse.cz>
 <1461591350-28700-1-git-send-email-vbabka@suse.cz>
 <1461591350-28700-4-git-send-email-vbabka@suse.cz>
 <20160426005503.GC2707@js1304-P5Q-DELUXE>
 <571FC43D.6010102@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <571FC43D.6010102@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>

On Tue, Apr 26, 2016 at 09:40:45PM +0200, Vlastimil Babka wrote:
> On 04/26/2016 02:55 AM, Joonsoo Kim wrote:
> >On Mon, Apr 25, 2016 at 03:35:50PM +0200, Vlastimil Babka wrote:
> >>@@ -846,9 +845,11 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
> >> 				spin_unlock_irqrestore(&zone->lru_lock,	flags);
> >> 				locked = false;
> >> 			}
> >>-			putback_movable_pages(migratelist);
> >>-			nr_isolated = 0;
> >>+			acct_isolated(zone, cc);
> >>+			putback_movable_pages(&cc->migratepages);
> >>+			cc->nr_migratepages = 0;
> >> 			cc->last_migrated_pfn = 0;
> >>+			nr_isolated = 0;
> >
> >Is it better to use separate list and merge it cc->migratepages when
> >finishing instead of using cc->migratepages directly? If
> >isolate_migratepages() try to isolate more than one page block and keep
> >isolated page on previous pageblock, this putback all will invalidate
> >all the previous work. It would be beyond of the scope of this
> >function. Now, isolate_migratepages() try to isolate the page in one
> >pageblock so this code is safe. But, I think that removing such
> >dependency will be helpful in the future. I'm not strongly insisting it
> >so if you think it's not useful thing, please ignore this comment.
> 
> migratelist was merely a reference to cc->migratepages, so it
> wouldn't prevent the situation you are suggesting. A truly separate
> list would need to be appended to cc->migratepages when leaving
> isolate_migratepages_block() and there's no need to do that right
> now.

What I suggest is using truly separate list by defining LIST_HEAD(xxx)
on top of the function. But, I'm okay you think that there's no need
to do it right now.

> 
> BTW, can you check patch 1/3? Thanks!

Done.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 47C26280250
	for <linux-mm@kvack.org>; Fri,  7 Oct 2016 02:50:24 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id u84so18659407pfj.1
        for <linux-mm@kvack.org>; Thu, 06 Oct 2016 23:50:24 -0700 (PDT)
Received: from mail-pf0-f194.google.com (mail-pf0-f194.google.com. [209.85.192.194])
        by mx.google.com with ESMTPS id f2si7215403pfb.292.2016.10.06.23.50.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Oct 2016 23:50:23 -0700 (PDT)
Received: by mail-pf0-f194.google.com with SMTP id i85so2369443pfa.0
        for <linux-mm@kvack.org>; Thu, 06 Oct 2016 23:50:23 -0700 (PDT)
Date: Fri, 7 Oct 2016 08:50:19 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, compaction: allow compaction for GFP_NOFS
 requests
Message-ID: <20161007065019.GA18439@dhcp22.suse.cz>
References: <20161004081215.5563-1-mhocko@kernel.org>
 <e7dc1e23-10fe-99de-e9c8-581857e3ab9d@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e7dc1e23-10fe-99de-e9c8-581857e3ab9d@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>, Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri 07-10-16 07:27:37, Vlastimil Babka wrote:
[...]
> > diff --git a/mm/compaction.c b/mm/compaction.c
> > index badb92bf14b4..07254a73ee32 100644
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -834,6 +834,13 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
> >  		    page_count(page) > page_mapcount(page))
> >  			goto isolate_fail;
> > 
> > +		/*
> > +		 * Only allow to migrate anonymous pages in GFP_NOFS context
> > +		 * because those do not depend on fs locks.
> > +		 */
> > +		if (!(cc->gfp_mask & __GFP_FS) && page_mapping(page))
> > +			goto isolate_fail;
> 
> Unless page can acquire a page_mapping between this check and migration, I
> don't see a problem with allowing this.

It can be become swapcache but I guess this should be OK. We do not
allow to get here with GFP_NOIO and migrating swapcache pages in NOFS
mode should be OK AFAICS.

> But make sure you don't break kcompactd and manual compaction from /proc, as
> they don't currently set cc->gfp_mask. Looks like until now it was only used
> to determine direct compactor's migratetype which is irrelevant in those
> contexts.

OK, I see. This is really subtle. One way to go would be to provide a
fake gfp_mask for them. How does the following look to you?
---
diff --git a/mm/compaction.c b/mm/compaction.c
index 557c165b63ad..d1d90e96ef4b 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1779,6 +1779,7 @@ static void compact_node(int nid)
 		.mode = MIGRATE_SYNC,
 		.ignore_skip_hint = true,
 		.whole_zone = true,
+		.gfp_mask = GFP_KERNEL,
 	};
 
 
@@ -1904,6 +1905,7 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 		.classzone_idx = pgdat->kcompactd_classzone_idx,
 		.mode = MIGRATE_SYNC_LIGHT,
 		.ignore_skip_hint = true,
+		.gfp_mask = GFP_KERNEL,
 
 	};
 	trace_mm_compaction_kcompactd_wake(pgdat->node_id, cc.order,
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

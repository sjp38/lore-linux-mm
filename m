Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 630B06B0175
	for <linux-mm@kvack.org>; Wed, 11 Jun 2014 20:25:01 -0400 (EDT)
Received: by mail-ig0-f169.google.com with SMTP id a13so6929535igq.2
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 17:25:01 -0700 (PDT)
Received: from mail-ie0-x230.google.com (mail-ie0-x230.google.com [2607:f8b0:4001:c03::230])
        by mx.google.com with ESMTPS id je3si17796768igb.22.2014.06.11.17.25.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 11 Jun 2014 17:25:00 -0700 (PDT)
Received: by mail-ie0-f176.google.com with SMTP id rd18so497289iec.35
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 17:25:00 -0700 (PDT)
Date: Wed, 11 Jun 2014 17:24:58 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 08/10] mm, compaction: pass gfp mask to compact_control
In-Reply-To: <539841A7.3040202@suse.cz>
Message-ID: <alpine.DEB.2.02.1406111724140.11536@chino.kir.corp.google.com>
References: <1402305982-6928-1-git-send-email-vbabka@suse.cz> <1402305982-6928-8-git-send-email-vbabka@suse.cz> <20140611024855.GH15630@bbox> <539841A7.3040202@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On Wed, 11 Jun 2014, Vlastimil Babka wrote:

> > > diff --git a/mm/compaction.c b/mm/compaction.c
> > > index c339ccd..d1e30ba 100644
> > > --- a/mm/compaction.c
> > > +++ b/mm/compaction.c
> > > @@ -965,8 +965,8 @@ static isolate_migrate_t isolate_migratepages(struct
> > > zone *zone,
> > >   	return ISOLATE_SUCCESS;
> > >   }
> > > 
> > > -static int compact_finished(struct zone *zone,
> > > -			    struct compact_control *cc)
> > > +static int compact_finished(struct zone *zone, struct compact_control
> > > *cc,
> > > +			    const int migratetype)
> > 
> > If we has gfp_mask, we could use gfpflags_to_migratetype from cc->gfp_mask.
> > What's is your intention?
> 
> Can't speak for David but I left it this way as it means
> gfpflags_to_migratetype is only called once per compact_zone. Now I realize my
> patch 10/10 repeats the call in isolate_migratepages_range so I'll probably
> update that as well.
> 

Yes, that was definitely the intention: call it once in compact_zone() and 
store it as const and then avoid calling it every time for 
compact_finished().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

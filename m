Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 145136B00C6
	for <linux-mm@kvack.org>; Mon,  9 Jun 2014 19:41:40 -0400 (EDT)
Received: by mail-ig0-f174.google.com with SMTP id h3so4480634igd.1
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 16:41:39 -0700 (PDT)
Received: from mail-ie0-x234.google.com (mail-ie0-x234.google.com [2607:f8b0:4001:c03::234])
        by mx.google.com with ESMTPS id dq1si9688519icb.23.2014.06.09.16.41.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 09 Jun 2014 16:41:39 -0700 (PDT)
Received: by mail-ie0-f180.google.com with SMTP id at20so6275653iec.39
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 16:41:39 -0700 (PDT)
Date: Mon, 9 Jun 2014 16:41:36 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 01/10] mm, compaction: do not recheck suitable_migration_target
 under lock
In-Reply-To: <1402305982-6928-1-git-send-email-vbabka@suse.cz>
Message-ID: <alpine.DEB.2.02.1406091636190.17705@chino.kir.corp.google.com>
References: <1402305982-6928-1-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On Mon, 9 Jun 2014, Vlastimil Babka wrote:

> isolate_freepages_block() rechecks if the pageblock is suitable to be a target
> for migration after it has taken the zone->lock. However, the check has been
> optimized to occur only once per pageblock, and compact_checklock_irqsave()
> might be dropping and reacquiring lock, which means somebody else might have
> changed the pageblock's migratetype meanwhile.
> 
> Furthermore, nothing prevents the migratetype to change right after
> isolate_freepages_block() has finished isolating. Given how imperfect this is,
> it's simpler to just rely on the check done in isolate_freepages() without
> lock, and not pretend that the recheck under lock guarantees anything. It is
> just a heuristic after all.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: David Rientjes <rientjes@google.com>

Acked-by: David Rientjes <rientjes@google.com>

We already do a preliminary check for suitable_migration_target() in 
isolate_freepages() in a racy way to avoid unnecessary work (and 
page_order() there is unprotected, I think you already mentioned this) so 
this seems fine to abandon.

> ---
> I suggest folding mm-compactionc-isolate_freepages_block-small-tuneup.patch into this
> 

Hmm, Andrew was just moving some code around in that patch, I'm not sure 
that it makes sense to couple these two together and your patch here is 
addressing an optimization rather than a cleanup (and you've documented it 
well, no need to obscure it with unrelated changes).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

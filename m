Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f173.google.com (mail-qc0-f173.google.com [209.85.216.173])
	by kanga.kvack.org (Postfix) with ESMTP id 226C76B007B
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 13:34:24 -0400 (EDT)
Received: by mail-qc0-f173.google.com with SMTP id l6so600764qcy.18
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 10:34:23 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k6si1266440qct.2.2014.06.24.10.34.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jun 2014 10:34:23 -0700 (PDT)
Date: Tue, 24 Jun 2014 12:58:21 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v3 04/13] mm, compaction: move pageblock checks up from
 isolate_migratepages_range()
Message-ID: <20140624165821.GC18289@nhori.bos.redhat.com>
References: <1403279383-5862-1-git-send-email-vbabka@suse.cz>
 <1403279383-5862-5-git-send-email-vbabka@suse.cz>
 <20140624045252.GA18289@nhori.bos.redhat.com>
 <53A99A88.1040500@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53A99A88.1040500@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, linux-kernel@vger.kernel.org

On Tue, Jun 24, 2014 at 05:34:32PM +0200, Vlastimil Babka wrote:
> On 06/24/2014 06:52 AM, Naoya Horiguchi wrote:
> >>-	low_pfn = isolate_migratepages_range(zone, cc, low_pfn, end_pfn, false);
> >>-	if (!low_pfn || cc->contended)
> >>-		return ISOLATE_ABORT;
> >>+		/* Do not scan within a memory hole */
> >>+		if (!pfn_valid(low_pfn))
> >>+			continue;
> >>+
> >>+		page = pfn_to_page(low_pfn);
> >
> >Can we move (page_zone != zone) check here as isolate_freepages() does?
> 
> Duplicate perhaps, not sure about move.

Sorry for my unclearness.
I meant that we had better do this check in per-pageblock loop (as the free
scanner does) instead of in per-pfn loop (as we do now.)

> Does CMA make sure that all pages
> are in the same zone?

It seems not, CMA just specifies start pfn and end pfn, so it can cover
multiple zones.
And we also have a case of node overlapping as commented in commit dc9086004
"mm: compaction: check for overlapping nodes during isolation for migration".
So we need this check in compaction side.

Thanks,
Naoya Horiguchi

> Common sense tells me it would be useless otherwise,
> but I haven't checked if we can rely on it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

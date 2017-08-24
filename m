Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 515CD44088B
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 19:59:05 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id q68so3443566pgq.11
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 16:59:05 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id s13si3971487plj.176.2017.08.24.16.59.03
        for <linux-mm@kvack.org>;
        Thu, 24 Aug 2017 16:59:04 -0700 (PDT)
Date: Fri, 25 Aug 2017 08:59:30 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] mm/mlock: use page_zone() instead of page_zone_id()
Message-ID: <20170824235930.GB29701@js1304-P5Q-DELUXE>
References: <1503559211-10259-1-git-send-email-iamjoonsoo.kim@lge.com>
 <a8cca363-544d-1b7e-0e93-d7df5c5b6f20@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a8cca363-544d-1b7e-0e93-d7df5c5b6f20@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>

On Thu, Aug 24, 2017 at 01:05:15PM +0200, Vlastimil Babka wrote:
> +CC Mel
> 
> On 08/24/2017 09:20 AM, js1304@gmail.com wrote:
> > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > 
> > page_zone_id() is a specialized function to compare the zone for the pages
> > that are within the section range. If the section of the pages are
> > different, page_zone_id() can be different even if their zone is the same.
> > This wrong usage doesn't cause any actual problem since
> > __munlock_pagevec_fill() would be called again with failed index. However,
> > it's better to use more appropriate function here.
> 
> Hmm using zone id was part of the series making munlock faster. Too bad
> it's doing the wrong thing on some memory models. Looks like it wasn't
> evaluated in isolation, but only as part of the pagevec usage (commit
> 7a8010cd36273) but most likely it wasn't contributing too much to the
> 14% speedup.

I roughly checked that patch and it seems that performance improvement
of that commit isn't related to page_zone_id() usage. With
page_zone(), we would have more chance that do a job as a batch.

> 
> > This patch is also preparation for futher change about page_zone_id().
> 
> Out of curiosity, what kind of change?
>

I prepared one more patch that prevent another user of page_zone_id()
since it is too tricky. However, I don't submit it. That description
should be removed. :/

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

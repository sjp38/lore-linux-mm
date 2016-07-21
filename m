Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 31D936B0276
	for <linux-mm@kvack.org>; Thu, 21 Jul 2016 04:15:10 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id r97so47025948lfi.2
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 01:15:10 -0700 (PDT)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.16])
        by mx.google.com with ESMTPS id ha4si4664862wjc.183.2016.07.21.01.15.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jul 2016 01:15:08 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id 641111C1DC7
	for <linux-mm@kvack.org>; Thu, 21 Jul 2016 09:15:08 +0100 (IST)
Date: Thu, 21 Jul 2016 09:15:06 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 1/5] mm, vmscan: Do not account skipped pages as scanned
Message-ID: <20160721081506.GF10438@techsingularity.net>
References: <1469028111-1622-1-git-send-email-mgorman@techsingularity.net>
 <1469028111-1622-2-git-send-email-mgorman@techsingularity.net>
 <20160721051648.GA31865@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160721051648.GA31865@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 21, 2016 at 02:16:48PM +0900, Minchan Kim wrote:
> On Wed, Jul 20, 2016 at 04:21:47PM +0100, Mel Gorman wrote:
> > Page reclaim determines whether a pgdat is unreclaimable by examining how
> > many pages have been scanned since a page was freed and comparing that
> > to the LRU sizes. Skipped pages are not considered reclaim candidates but
> > contribute to scanned. This can prematurely mark a pgdat as unreclaimable
> > and trigger an OOM kill.
> > 
> > While this does not fix an OOM kill message reported by Joonsoo Kim,
> > it did stop pgdat being marked unreclaimable.
> > 
> > Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> > ---
> >  mm/vmscan.c | 5 ++++-
> >  1 file changed, 4 insertions(+), 1 deletion(-)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 22aec2bcfeec..b16d578ce556 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -1415,7 +1415,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
> >  	LIST_HEAD(pages_skipped);
> >  
> >  	for (scan = 0; scan < nr_to_scan && nr_taken < nr_to_scan &&
> > -					!list_empty(src); scan++) {
> > +					!list_empty(src);) {
> >  		struct page *page;
> >  
> >  		page = lru_to_page(src);
> > @@ -1429,6 +1429,9 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
> >  			continue;
> >  		}
> >  
> > +		/* Pages skipped do not contribute to scan */
> 
> The comment should explain why.
> 
> /* Pages skipped do not contribute to scan to prevent premature OOM */
> 

Specifically, it's to prevent pgdat being considered unreclaimable
prematurely. I'll update the comment.

> 
> > +		scan++;
> > +
> 
> 
> The one of my concern about node-lru is to add more lru lock contetion
> in multiple zone system so such unbounded skip scanning under the lock
> should have a limit to prevent latency spike and serialization of
> current reclaim work.
> 

The LRU lock already was quite a large lock, particularly on NUMA systems,
with contention raising the more direct reclaimers that are active. It's
worth remembering that the series also shows much lower system CPU time
in some tests. This is the current CPU usage breakdown for a parallel dd test

           4.7.0-rc4   4.7.0-rc7   4.7.0-rc7
        mmotm-20160623mm1-followup-v3r1mm1-oomfix-v4r2
User         1548.01      927.23      777.74
System       8609.71     5540.02     4445.56
Elapsed      3587.10     3598.00     3498.54

The LRU lock is held during skips but it's also doing no real work.

> Another concern is big mismatch between the number of pages from list and
> LRU stat count because lruvec_lru_size call sites don't take the stat
> under the lock while isolate_lru_pages moves many pages from lru list
> to temporal skipped list.
> 

It's already known that the reading of the LRU size can mismatch the
actual size. It's why inactive_list_is_low() in the last patch has
checks like

inactive -= min(inactive, inactive_zone);

It's watching for underflows

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

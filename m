Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id C797D6B0302
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 08:10:42 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id g23so24930361wme.4
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 05:10:42 -0800 (PST)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id v4si22567335wjk.289.2016.12.20.05.10.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 05:10:41 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id 601B71C22F5
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 13:10:41 +0000 (GMT)
Date: Tue, 20 Dec 2016 13:10:40 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH RFC 1/1] mm, page_alloc: fix incorrect zone_statistics
 data
Message-ID: <20161220131040.f5ga5426dduh3mhu@techsingularity.net>
References: <1481522347-20393-1-git-send-email-hejianet@gmail.com>
 <1481522347-20393-2-git-send-email-hejianet@gmail.com>
 <20161220091814.GC3769@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20161220091814.GC3769@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Jia He <hejianet@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>

On Tue, Dec 20, 2016 at 10:18:14AM +0100, Michal Hocko wrote:
> On Mon 12-12-16 13:59:07, Jia He wrote:
> > In commit b9f00e147f27 ("mm, page_alloc: reduce branches in
> > zone_statistics"), it reconstructed codes to reduce the branch miss rate.
> > Compared with the original logic, it assumed if !(flag & __GFP_OTHER_NODE)
> >  z->node would not be equal to preferred_zone->node. That seems to be
> > incorrect.
> 
> I am sorry but I have hard time following the changelog. It is clear
> that you are trying to fix a missed NUMA_{HIT,OTHER} accounting
> but it is not really clear when such thing happens. You are adding
> preferred_zone->node check. preferred_zone is the first zone in the
> requested zonelist. So for the most allocations it is a node from the
> local node. But if something request an explicit numa node (without
> __GFP_OTHER_NODE which would be the majority I suspect) then we could
> indeed end up accounting that as a NUMA_MISS, NUMA_FOREIGN so the
> referenced patch indeed caused an unintended change of accounting AFAIU.
> 

This is a similar concern to what I had. If the preferred zone, which is
the first valid usable zone, is not a "hit" for the statistics then I
don't know what "hit" is meant to mean.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

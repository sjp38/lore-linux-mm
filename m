Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id DCED76B007E
	for <linux-mm@kvack.org>; Fri, 13 May 2016 04:31:14 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id 68so35047442lfq.2
        for <linux-mm@kvack.org>; Fri, 13 May 2016 01:31:14 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id a8si21045108wjv.84.2016.05.13.01.31.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 May 2016 01:31:13 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id r12so2213166wme.0
        for <linux-mm@kvack.org>; Fri, 13 May 2016 01:31:13 -0700 (PDT)
Date: Fri, 13 May 2016 10:31:11 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 04/13] mm, page_alloc: restructure direct compaction
 handling in slowpath
Message-ID: <20160513083110.GG20141@dhcp22.suse.cz>
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
 <1462865763-22084-5-git-send-email-vbabka@suse.cz>
 <20160512132918.GJ4200@dhcp22.suse.cz>
 <57358C0A.4020002@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57358C0A.4020002@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>

On Fri 13-05-16 10:10:50, Vlastimil Babka wrote:
> On 05/12/2016 03:29 PM, Michal Hocko wrote:
> > On Tue 10-05-16 09:35:54, Vlastimil Babka wrote:
> > > This patch attempts to restructure the code with only minimal functional
> > > changes. The call to the first compaction and THP-specific checks are now
> > > placed above the retry loop, and the "noretry" direct compaction is removed.
> > > 
> > > The initial compaction is additionally restricted only to costly orders, as we
> > > can expect smaller orders to be held back by watermarks, and only larger orders
> > > to suffer primarily from fragmentation. This better matches the checks in
> > > reclaim's shrink_zones().
> > > 
> > > There are two other smaller functional changes. One is that the upgrade from
> > > async migration to light sync migration will always occur after the initial
> > > compaction.
> > 
> > I do not think this belongs to the patch. There are two reasons. First
> > we do not need to do potentially more expensive sync mode when async is
> > able to make some progress and the second
> 
> My concern was that __GFP_NORETRY non-costly allocations wouldn't otherwise
> get a MIGRATE_SYNC_LIGHT pass at all. Previously they would get it in the
> noretry: label.

OK, I haven't considered this. So scratch this then.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id B6FDB829B4
	for <linux-mm@kvack.org>; Tue,  6 May 2014 11:55:05 -0400 (EDT)
Received: by mail-ee0-f47.google.com with SMTP id c13so864996eek.20
        for <linux-mm@kvack.org>; Tue, 06 May 2014 08:55:04 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u9si1018536eel.239.2014.05.06.08.55.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 May 2014 08:55:04 -0700 (PDT)
Date: Tue, 6 May 2014 16:55:00 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 15/17] mm: Do not use unnecessary atomic operations when
 adding pages to the LRU
Message-ID: <20140506155500.GA23991@suse.de>
References: <1398933888-4940-1-git-send-email-mgorman@suse.de>
 <1398933888-4940-16-git-send-email-mgorman@suse.de>
 <5369002D.7030600@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <5369002D.7030600@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Linux Kernel <linux-kernel@vger.kernel.org>

On Tue, May 06, 2014 at 05:30:53PM +0200, Vlastimil Babka wrote:
> On 05/01/2014 10:44 AM, Mel Gorman wrote:
> >When adding pages to the LRU we clear the active bit unconditionally. As the
> >page could be reachable from other paths we cannot use unlocked operations
> >without risk of corruption such as a parallel mark_page_accessed. This
> >patch test if is necessary to clear the atomic flag before using an atomic
> 
>                                           active
> 

Thanks. Clearly I had atomic on the brain.

> >operation. In the unlikely even this races with mark_page_accesssed the
> >consequences are simply that the page may be promoted to the active list
> >that might have been left on the inactive list before the patch. This is
> >a marginal consequence.
> 
> Well if this is racy, then even before the patch, mark_page_accessed
> might have come right after ClearPageActive(page) anyway?
> Or is the
> changelog saying that this change only extended the race window that
> already existed? If yes it could be more explicit, as now it might
> sound as if the race was introduced.
> 

When adding pages to the LRU we clear the active bit unconditionally. As the
page could be reachable from other paths we cannot use unlocked operations
without risk of corruption such as a parallel mark_page_accessed. This
patch tests if is necessary to clear the active flag before using an atomic
operation. This potentially opens a tiny race when PageActive is checked
as mark_page_accessed could be called after PageActive was checked. The
race already exists but this patch changes it slightly. The consequence
is that that the page may be promoted to the active list that might have
been left on the inactive list before the patch. It's too tiny a race and
too marginal a consequence to always use atomic operations for.

?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id D86B76B006E
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 16:53:22 -0500 (EST)
Received: by pabrd3 with SMTP id rd3so39169203pab.4
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 13:53:22 -0800 (PST)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id b4si2340663pdb.10.2015.02.24.13.53.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Feb 2015 13:53:22 -0800 (PST)
Received: by paceu11 with SMTP id eu11so39122771pac.10
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 13:53:21 -0800 (PST)
Date: Tue, 24 Feb 2015 14:54:01 -0800
From: Shaohua Li <shli@kernel.org>
Subject: Re: [PATCH RFC 1/4] mm: throttle MADV_FREE
Message-ID: <20150224225401.GA2506@kernel.org>
References: <1424765897-27377-1-git-send-email-minchan@kernel.org>
 <20150224154318.GA14939@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150224154318.GA14939@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Yalin.Wang@sonymobile.com

On Tue, Feb 24, 2015 at 04:43:18PM +0100, Michal Hocko wrote:
> On Tue 24-02-15 17:18:14, Minchan Kim wrote:
> > Recently, Shaohua reported that MADV_FREE is much slower than
> > MADV_DONTNEED in his MADV_FREE bomb test. The reason is many of
> > applications went to stall with direct reclaim since kswapd's
> > reclaim speed isn't fast than applications's allocation speed
> > so that it causes lots of stall and lock contention.
> 
> I am not sure I understand this correctly. So the issue is that there is
> huge number of MADV_FREE on the LRU and they are not close to the tail
> of the list so the reclaim has to do a lot of work before it starts
> dropping them?

I thought the main reason is current reclaim stragety. Anonymous pages are
considered to be hard to be reclaimed with current policy, VM bias to reclaim
file pages (anon pages are in active list first, referenced pte will reactivate
anon pages and increase rotate count)

> > This patch throttles MADV_FREEing so it works only if there
> > are enough pages in the system which will not trigger backgroud/
> > direct reclaim. Otherwise, MADV_FREE falls back to MADV_DONTNEED
> > because there is no point to delay freeing if we know system
> > is under memory pressure.
> 
> Hmm, this is still conforming to the documentation because the kernel is
> free to free pages at its convenience. I am not sure this is a good
> idea, though. Why some MADV_FREE calls should be treated differently?
> Wouldn't that lead to hard to predict behavior? E.g. LIFO reused blocks
> would work without long stalls most of the time - except when there is a
> memory pressure.
> 
> Comparison to MADV_DONTNEED is not very fair IMHO because the scope of the
> two calls is different.
> 
> > When I test the patch on my 3G machine + 12 CPU + 8G swap,
> > test: 12 processes
> > 
> > loop = 5;
> > mmap(512M);
> 
> Who is eating the rest of the memory?
> 
> > while (loop--) {
> > 	memset(512M);
> > 	madvise(MADV_FREE or MADV_DONTNEED);
> > }
> > 
> > 1) dontneed: 6.78user 234.09system 0:48.89elapsed
> > 2) madvfree: 6.03user 401.17system 1:30.67elapsed
> > 3) madvfree + this ptach: 5.68user 113.42system 0:36.52elapsed
> > 
> > It's clearly win.
> > 
> > Reported-by: Shaohua Li <shli@kernel.org>
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> 
> I don't know. This looks like a hack with hard to predict consequences
> which might trigger pathological corner cases.

This has big improvement in practise, but as Michael said, this will introduce
unpredictable behavior. madvfree pages before memory pressure will be free
later. Plus, this doesn't change the situation madvfree pages are hard to be
free (even with the 3rd patch). Of course it's not introduced by the the
madfree patch, VM bias free file pages.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

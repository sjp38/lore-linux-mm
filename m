Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 5C3DD6B006E
	for <linux-mm@kvack.org>; Wed, 25 Feb 2015 09:13:40 -0500 (EST)
Received: by wggx12 with SMTP id x12so3895391wgg.6
        for <linux-mm@kvack.org>; Wed, 25 Feb 2015 06:13:39 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t12si29240553wib.91.2015.02.25.06.13.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 25 Feb 2015 06:13:38 -0800 (PST)
Date: Wed, 25 Feb 2015 15:13:37 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH RFC 1/4] mm: throttle MADV_FREE
Message-ID: <20150225141337.GE26680@dhcp22.suse.cz>
References: <1424765897-27377-1-git-send-email-minchan@kernel.org>
 <20150224154318.GA14939@dhcp22.suse.cz>
 <20150224225401.GA2506@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150224225401.GA2506@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Yalin.Wang@sonymobile.com

On Tue 24-02-15 14:54:01, Shaohua Li wrote:
> On Tue, Feb 24, 2015 at 04:43:18PM +0100, Michal Hocko wrote:
> > On Tue 24-02-15 17:18:14, Minchan Kim wrote:
> > > Recently, Shaohua reported that MADV_FREE is much slower than
> > > MADV_DONTNEED in his MADV_FREE bomb test. The reason is many of
> > > applications went to stall with direct reclaim since kswapd's
> > > reclaim speed isn't fast than applications's allocation speed
> > > so that it causes lots of stall and lock contention.
> > 
> > I am not sure I understand this correctly. So the issue is that there is
> > huge number of MADV_FREE on the LRU and they are not close to the tail
> > of the list so the reclaim has to do a lot of work before it starts
> > dropping them?
> 
> I thought the main reason is current reclaim stragety. Anonymous pages are
> considered to be hard to be reclaimed with current policy, VM bias to reclaim
> file pages (anon pages are in active list first, referenced pte will reactivate
> anon pages and increase rotate count)

Makes sense. We are really biasing to page cache reclaim most of the
time.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
